import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/carrom_ws_client.dart';
import '../domain/carrom_state.dart';
import '../domain/shot_input.dart';
import '../domain/shot_result.dart';
import 'carrom_controllers.dart';

/// رسالة chat واردة — نخزن آخر واحدة لإظهارها كـ bubble.
class IncomingChat {
  IncomingChat({
    required this.fromUserId,
    required this.presetKey,
    required this.ts,
  });
  final int fromUserId;
  final String presetKey;
  final DateTime ts;
}

/// نتيجة نهائية — تظهر للـ game-over page.
class CarromOutcome {
  CarromOutcome({
    required this.winnerId,
    required this.pot,
    required this.byConcede,
    required this.revealOffer,
    required this.matchId,
  });
  final int winnerId;
  final int pot;
  final bool byConcede;
  final bool revealOffer;
  /// DB id — للـ /match/{id}/reveal و /match/{id}/send-sarhny.
  final int matchId;
}

/// State متكامل لشاشة المباراة.
class CarromMatchSnapshot {
  CarromMatchSnapshot({
    this.state,
    this.pendingShot,
    this.lastIncomingChat,
    this.opponentReconnectDeadline,
    this.outcome,
    this.connectionUp = true,
    this.lastError,
  });

  /// آخر state الحقيقي من السيرفر.
  final CarromState? state;
  /// لو ضربنا shot وننتظر الرد — نعطل التحكم.
  final bool? pendingShot;
  /// آخر chat للخصم (للـ bubble).
  final IncomingChat? lastIncomingChat;
  /// لو الخصم انقطع، deadline لإعادة الاتصال.
  final DateTime? opponentReconnectDeadline;
  /// نتيجة المباراة لو انتهت.
  final CarromOutcome? outcome;
  /// حالة الـ WS — false → نعرض banner "إعادة اتصال".
  final bool connectionUp;
  /// آخر خطأ من السيرفر (للـ toast).
  final String? lastError;

  CarromMatchSnapshot copyWith({
    CarromState? state,
    bool? pendingShot,
    IncomingChat? lastIncomingChat,
    DateTime? opponentReconnectDeadline,
    CarromOutcome? outcome,
    bool? connectionUp,
    String? lastError,
    bool clearChat = false,
    bool clearReconnect = false,
    bool clearError = false,
  }) =>
      CarromMatchSnapshot(
        state: state ?? this.state,
        pendingShot: pendingShot ?? this.pendingShot,
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
/// مرتبط بـ family عبر roomId — كل غرفة = controller مستقل.
class CarromMatchController extends StateNotifier<CarromMatchSnapshot> {
  CarromMatchController({
    required this.ref,
    required this.roomId,
  }) : super(CarromMatchSnapshot()) {
    _connect();
  }

  final Ref ref;
  final String roomId;
  CarromWsClient? _ws;
  StreamSubscription<CarromEvent>? _sub;

  Future<void> _connect() async {
    final repo = ref.read(carromRepositoryProvider);
    final ws = repo.openRoom(roomId);
    _ws = ws;
    _sub = ws.events.listen(_onEvent);
    await ws.connect();
  }

  void _onEvent(CarromEvent e) {
    if (!mounted) return;
    if (e is CarromStateEvent) {
      // إذا الـ state seq أقل أو يساوي ما عندنا → ignore (out of order)
      final cur = state.state;
      if (cur != null && e.state.seq < cur.seq) return;
      state = state.copyWith(state: e.state, pendingShot: false);
    } else if (e is CarromShotResultEvent) {
      // نضع الـ pendingShot على false بعد ما يبدأ الـ playback
      // (الـ board widget يلتقط النتيجة عبر provider منفصل)
      _lastShotResult = e.result;
      _shotController.add(e.result);
    } else if (e is CarromChatEvent) {
      state = state.copyWith(
        lastIncomingChat: IncomingChat(
          fromUserId: e.fromUserId,
          presetKey: e.presetKey,
          ts: e.ts,
        ),
      );
      // auto-hide بعد 3 ثوان
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && state.lastIncomingChat?.ts == e.ts) {
          state = state.copyWith(clearChat: true);
        }
      });
    } else if (e is CarromPresenceEvent) {
      // لا داعي لـ rebuild كبير — نتجاهل (state event سيتبعها عادة)
    } else if (e is CarromOpponentDisconnect) {
      state = state.copyWith(opponentReconnectDeadline: e.reconnectDeadline);
    } else if (e is CarromGameOverEvent) {
      state = state.copyWith(
        outcome: CarromOutcome(
          winnerId: e.winnerId,
          pot: e.pot,
          byConcede: e.byConcede,
          revealOffer: e.revealOffer,
          matchId: e.matchId,
        ),
      );
    } else if (e is CarromConnectionDown) {
      state = state.copyWith(connectionUp: false);
    } else if (e is CarromConnectionUp) {
      state = state.copyWith(connectionUp: true, clearReconnect: true);
    } else if (e is CarromErrorEvent) {
      state = state.copyWith(lastError: e.code, pendingShot: false);
    }
  }

  /// آخر shot result مستلم — يستخدمه الـ board widget كـ "command".
  CarromShotResult? _lastShotResult;
  CarromShotResult? get lastShotResult => _lastShotResult;

  /// stream من نتائج shots — للـ board widget.
  final _shotController = StreamController<CarromShotResult>.broadcast();
  Stream<CarromShotResult> get shotStream => _shotController.stream;

  void shoot(CarromShotInput input) {
    if (state.pendingShot == true) return;
    state = state.copyWith(pendingShot: true);
    _ws?.sendShoot(input);
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
    _shotController.close();
    super.dispose();
  }
}

/// Family provider — controller لكل room.
final carromMatchControllerProvider = StateNotifierProvider.autoDispose
    .family<CarromMatchController, CarromMatchSnapshot, String>((ref, roomId) {
  return CarromMatchController(ref: ref, roomId: roomId);
});

/// Matchmaking controller — يدير الـ join + waiter.
class CarromMatchmakingSnapshot {
  CarromMatchmakingSnapshot({
    this.searching = false,
    this.elapsedSeconds = 0,
    this.queuePosition,
    this.roomId,
    this.error,
  });
  final bool searching;
  final int elapsedSeconds;
  final int? queuePosition;
  final String? roomId; // غير null = matched
  final String? error;

  CarromMatchmakingSnapshot copyWith({
    bool? searching,
    int? elapsedSeconds,
    int? queuePosition,
    String? roomId,
    String? error,
    bool clearError = false,
  }) =>
      CarromMatchmakingSnapshot(
        searching: searching ?? this.searching,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        queuePosition: queuePosition ?? this.queuePosition,
        roomId: roomId ?? this.roomId,
        error: clearError ? null : (error ?? this.error),
      );
}

class CarromMatchmakingController
    extends StateNotifier<CarromMatchmakingSnapshot> {
  CarromMatchmakingController(this.ref) : super(CarromMatchmakingSnapshot());

  final Ref ref;
  Timer? _ticker;
  Timer? _poller;

  Future<void> start() async {
    state = CarromMatchmakingSnapshot(searching: true);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });

    try {
      final api = ref.read(carromApiProvider);
      final r = await api.join();
      if (r.matched && r.roomId != null) {
        state = state.copyWith(roomId: r.roomId, searching: false);
        _stopTickers();
        return;
      }
      state = state.copyWith(queuePosition: r.queuePosition);
      // poll كل 3 ثواني عبر إعادة الاستدعاء — في الواقع الـ WS الخاص بـ
      // الـ queue غير مفتوح (نفتح WS للغرفة فقط). هنا نستخدم REST polling
      // كحل احتياطي حتى يفتح السيرفر pubsub-queue endpoint.
      _poller = Timer.periodic(const Duration(seconds: 3), (_) async {
        try {
          final r2 = await api.join();
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
      await ref.read(carromApiProvider).cancel();
    } catch (_) {}
    state = CarromMatchmakingSnapshot();
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

final carromMatchmakingControllerProvider = StateNotifierProvider.autoDispose<
    CarromMatchmakingController, CarromMatchmakingSnapshot>((ref) {
  return CarromMatchmakingController(ref);
});
