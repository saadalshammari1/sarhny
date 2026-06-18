import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ludo_ws_client.dart';
import '../domain/ludo_chat_preset.dart';
import '../domain/ludo_move_result.dart';
import '../domain/ludo_state.dart';
import 'ludo_controllers.dart';

/// رسالة chat واردة — نخزن آخر واحدة لإظهارها كـ bubble.
class LudoIncomingChat {
  LudoIncomingChat({
    required this.fromUserId,
    required this.presetKey,
    required this.ts,
  });
  final int fromUserId;
  final String presetKey;
  final DateTime ts;
}

/// نتيجة نهائية للمباراة — تُعطى لـ game-over page.
class LudoOutcome {
  LudoOutcome({
    required this.winnerId,
    required this.pot,
    required this.ranks,
    required this.revealOffer,
    required this.matchId,
  });
  final int winnerId;
  final int pot;
  final List<LudoRankEntry> ranks;
  final bool revealOffer;
  final int matchId;
}

/// State متكامل لشاشة المباراة.
class LudoMatchSnapshot {
  LudoMatchSnapshot({
    this.state,
    this.lastDiceRoll,
    this.pendingRoll = false,
    this.pendingMove = false,
    this.lastIncomingChat,
    this.opponentReconnectDeadline,
    this.outcome,
    this.connectionUp = true,
    this.lastError,
  });

  /// آخر state الحقيقي من السيرفر.
  final LudoState? state;

  /// آخر dice rolled event (للـ animation).
  final LudoDiceRolled? lastDiceRoll;

  /// true: ضغطنا roll وننتظر الردّ.
  final bool pendingRoll;

  /// true: اخترنا token وننتظر الـ move_result.
  final bool pendingMove;

  /// آخر chat للخصم (للـ bubble).
  final LudoIncomingChat? lastIncomingChat;

  /// لو الخصم انقطع، deadline لإعادة الاتصال.
  final DateTime? opponentReconnectDeadline;

  /// نتيجة المباراة لو انتهت.
  final LudoOutcome? outcome;

  /// حالة الـ WS — false → نعرض banner "إعادة اتصال".
  final bool connectionUp;

  /// آخر خطأ من السيرفر (للـ toast).
  final String? lastError;

  LudoMatchSnapshot copyWith({
    LudoState? state,
    LudoDiceRolled? lastDiceRoll,
    bool? pendingRoll,
    bool? pendingMove,
    LudoIncomingChat? lastIncomingChat,
    DateTime? opponentReconnectDeadline,
    LudoOutcome? outcome,
    bool? connectionUp,
    String? lastError,
    bool clearChat = false,
    bool clearReconnect = false,
    bool clearError = false,
    bool clearDice = false,
  }) =>
      LudoMatchSnapshot(
        state: state ?? this.state,
        lastDiceRoll:
            clearDice ? null : (lastDiceRoll ?? this.lastDiceRoll),
        pendingRoll: pendingRoll ?? this.pendingRoll,
        pendingMove: pendingMove ?? this.pendingMove,
        lastIncomingChat:
            clearChat ? null : (lastIncomingChat ?? this.lastIncomingChat),
        opponentReconnectDeadline: clearReconnect
            ? null
            : (opponentReconnectDeadline ?? this.opponentReconnectDeadline),
        outcome: outcome ?? this.outcome,
        connectionUp: connectionUp ?? this.connectionUp,
        lastError: clearError ? null : (lastError ?? this.lastError),
      );
}

/// يدير WS lifecycle + state لمباراة محددة.
///
/// Family عبر roomId — كل غرفة = controller مستقل.
class LudoMatchController extends StateNotifier<LudoMatchSnapshot> {
  LudoMatchController({
    required this.ref,
    required this.roomId,
  }) : super(LudoMatchSnapshot()) {
    _connect();
  }

  final Ref ref;
  final String roomId;
  LudoWsClient? _ws;
  StreamSubscription<LudoEvent>? _sub;

  /// آخر move للأنيميشن — الـ board يستمع عبر [moveStream].
  final _moveController = StreamController<LudoMoveResult>.broadcast();
  Stream<LudoMoveResult> get moveStream => _moveController.stream;

  /// آخر dice rolled — الـ board يستمع لتشغيل أنيميشن الزهر.
  final _diceController = StreamController<LudoDiceRolled>.broadcast();
  Stream<LudoDiceRolled> get diceStream => _diceController.stream;

  Future<void> _connect() async {
    final repo = ref.read(ludoRepositoryProvider);
    final ws = repo.openRoom(roomId);
    _ws = ws;
    _sub = ws.events.listen(_onEvent);
    await ws.connect();
  }

  void _onEvent(LudoEvent e) {
    if (!mounted) return;
    if (e is LudoStateEvent) {
      final cur = state.state;
      if (cur != null && e.state.seq < cur.seq) return;
      state = state.copyWith(
        state: e.state,
        pendingRoll: false,
        pendingMove: false,
      );
    } else if (e is LudoDiceRolledEvent) {
      state = state.copyWith(
        lastDiceRoll: e.dice,
        pendingRoll: false,
      );
      _diceController.add(e.dice);
    } else if (e is LudoMoveResultEvent) {
      state = state.copyWith(pendingMove: false);
      _moveController.add(e.result);
    } else if (e is LudoNextTurnEvent) {
      // ستأتي state event مرفقة عادة — مجرد نظّف الـ dice
      state = state.copyWith(clearDice: true);
    } else if (e is LudoChatEvent) {
      state = state.copyWith(
        lastIncomingChat: LudoIncomingChat(
          fromUserId: e.fromUserId,
          presetKey: e.presetKey,
          ts: e.ts,
        ),
      );
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && state.lastIncomingChat?.ts == e.ts) {
          state = state.copyWith(clearChat: true);
        }
      });
    } else if (e is LudoOpponentDisconnect) {
      state = state.copyWith(opponentReconnectDeadline: e.reconnectDeadline);
    } else if (e is LudoGameOverEvent) {
      state = state.copyWith(
        outcome: LudoOutcome(
          winnerId: e.winnerId,
          pot: e.pot,
          ranks: e.ranks,
          revealOffer: e.revealOffer,
          matchId: e.matchId,
        ),
      );
    } else if (e is LudoConnectionDown) {
      state = state.copyWith(connectionUp: false);
    } else if (e is LudoConnectionUp) {
      state = state.copyWith(connectionUp: true, clearReconnect: true);
    } else if (e is LudoErrorEvent) {
      state = state.copyWith(
        lastError: e.code,
        pendingRoll: false,
        pendingMove: false,
      );
    }
  }

  void roll() {
    final s = state.state;
    if (s == null || !s.yourTurn) return;
    if (state.pendingRoll || state.pendingMove) return;
    if (s.dice != null) return; // لم نحرّك بعد آخر رمية
    state = state.copyWith(pendingRoll: true);
    _ws?.sendRoll();
  }

  void move(int tokenIndex) {
    final s = state.state;
    if (s == null || !s.yourTurn || s.dice == null) return;
    if (state.pendingMove) return;
    final canMove = state.lastDiceRoll?.canMove ?? const [];
    if (canMove.isNotEmpty && !canMove.contains(tokenIndex)) return;
    state = state.copyWith(pendingMove: true);
    _ws?.sendMove(tokenIndex);
  }

  void sendChat(String presetKey) {
    _ws?.sendChat(presetKey);
  }

  void concede() {
    _ws?.sendConcede();
  }

  void clearError() {
    if (state.lastError != null) state = state.copyWith(clearError: true);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _ws?.dispose();
    _moveController.close();
    _diceController.close();
    super.dispose();
  }
}

/// Family provider — controller لكل room.
final ludoMatchControllerProvider = StateNotifierProvider.autoDispose
    .family<LudoMatchController, LudoMatchSnapshot, String>((ref, roomId) {
  return LudoMatchController(ref: ref, roomId: roomId);
});

/// Matchmaking controller — يدير الـ join + waiter.
class LudoMatchmakingSnapshot {
  LudoMatchmakingSnapshot({
    this.searching = false,
    this.elapsedSeconds = 0,
    this.queuePosition,
    this.roomId,
    this.error,
    this.mode = LudoMode.twoPlayer,
  });
  final bool searching;
  final int elapsedSeconds;
  final int? queuePosition;
  final String? roomId; // غير null = matched
  final String? error;
  final LudoMode mode;

  LudoMatchmakingSnapshot copyWith({
    bool? searching,
    int? elapsedSeconds,
    int? queuePosition,
    String? roomId,
    String? error,
    LudoMode? mode,
    bool clearError = false,
  }) =>
      LudoMatchmakingSnapshot(
        searching: searching ?? this.searching,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        queuePosition: queuePosition ?? this.queuePosition,
        roomId: roomId ?? this.roomId,
        error: clearError ? null : (error ?? this.error),
        mode: mode ?? this.mode,
      );
}

class LudoMatchmakingController
    extends StateNotifier<LudoMatchmakingSnapshot> {
  LudoMatchmakingController(this.ref) : super(LudoMatchmakingSnapshot());

  final Ref ref;
  Timer? _ticker;
  Timer? _poller;

  Future<void> start(LudoMode mode) async {
    state = LudoMatchmakingSnapshot(searching: true, mode: mode);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });

    try {
      final api = ref.read(ludoApiProvider);
      final r = await api.join(mode);
      if (r.matched && r.roomId != null) {
        state = state.copyWith(roomId: r.roomId, searching: false);
        _stopTickers();
        return;
      }
      state = state.copyWith(queuePosition: r.queuePosition);
      _poller = Timer.periodic(const Duration(seconds: 3), (_) async {
        try {
          final r2 = await api.join(mode);
          if (r2.matched && r2.roomId != null) {
            state = state.copyWith(roomId: r2.roomId, searching: false);
            _stopTickers();
          } else {
            state = state.copyWith(queuePosition: r2.queuePosition);
          }
        } catch (_) {
          // تجاهل أخطاء الـ polling المؤقتة
        }
      });
    } catch (e) {
      state = state.copyWith(searching: false, error: e.toString());
      _stopTickers();
    }
  }

  Future<void> cancel() async {
    _stopTickers();
    try {
      await ref.read(ludoApiProvider).cancel();
    } catch (_) {}
    state = LudoMatchmakingSnapshot();
  }

  void _stopTickers() {
    _ticker?.cancel();
    _ticker = null;
    _poller?.cancel();
    _poller = null;
  }

  @override
  void dispose() {
    _stopTickers();
    super.dispose();
  }
}

final ludoMatchmakingControllerProvider = StateNotifierProvider.autoDispose<
    LudoMatchmakingController, LudoMatchmakingSnapshot>((ref) {
  return LudoMatchmakingController(ref);
});
