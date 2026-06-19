import 'dart:async';

import 'package:flutter/widgets.dart';
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
    this.reconnectAttempt = 0,
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
  /// رقم محاولة إعادة الاتصال الحالية — 0 يعني متصل عادي.
  /// الـ banner يستخدمه ليطبع "محاولة #N".
  final int reconnectAttempt;

  CarromMatchSnapshot copyWith({
    CarromState? state,
    bool? pendingShot,
    IncomingChat? lastIncomingChat,
    DateTime? opponentReconnectDeadline,
    CarromOutcome? outcome,
    bool? connectionUp,
    String? lastError,
    int? reconnectAttempt,
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
        reconnectAttempt: reconnectAttempt ?? this.reconnectAttempt,
      );
}

/// يدير WS lifecycle + state لمباراة محددة.
///
/// مرتبط بـ family عبر roomId — كل غرفة = controller مستقل.
///
/// يطبّق `WidgetsBindingObserver` ليتعامل مع تعليق التطبيق (backgrounded)
/// — عند الـ resume يطلب snapshot جديد، ويتحقق إذا فاتنا أي game_over
/// أثناء الـ pause.
class CarromMatchController extends StateNotifier<CarromMatchSnapshot>
    with WidgetsBindingObserver {
  CarromMatchController({
    required this.ref,
    required this.roomId,
  }) : super(CarromMatchSnapshot()) {
    WidgetsBinding.instance.addObserver(this);
    _connect();
  }

  final Ref ref;
  final String roomId;
  CarromWsClient? _ws;
  StreamSubscription<CarromEvent>? _sub;
  StreamSubscription<int>? _retrySub;

  /// آخر مرة استلمنا فيها state event من السيرفر — مرجع لقرار الـ resume.
  DateTime? _lastStateAt;
  /// متى صار آخر paused — لتقدير المدة في الخلفية.
  DateTime? _pausedAt;
  /// آخر matchId معروف (من state أو game_over) — للـ REST fallback.
  int? _lastKnownMatchId;
  /// Timer للـ stale-state check بعد الـ resume.
  Timer? _resumeCheckTimer;
  /// نمنع double-fallback لو SDK خلّى hello يفشل مراراً.
  bool _restFallbackInFlight = false;

  Future<void> _connect() async {
    final repo = ref.read(carromRepositoryProvider);
    final ws = repo.openRoom(roomId);
    _ws = ws;
    _sub = ws.events.listen(_onEvent);
    _retrySub = ws.reconnectAttempts.listen((n) {
      if (!mounted) return;
      state = state.copyWith(reconnectAttempt: n);
    });
    await ws.connect();
  }

  void _onEvent(CarromEvent e) {
    if (!mounted) return;
    if (e is CarromStateEvent) {
      // إذا الـ state seq أقل أو يساوي ما عندنا → ignore (out of order)
      final cur = state.state;
      if (cur != null && e.state.seq < cur.seq) return;
      _lastStateAt = DateTime.now();
      state = state.copyWith(state: e.state, pendingShot: false);
      // إذا الـ snapshot الجديد فيه status=finished لكن ما عندنا outcome،
      // معناه فاتنا game_over أثناء التعليق → نركّب outcome من الـ state.
      _maybeSynthesizeGameOverFromState();
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
      if (e.matchId > 0) _lastKnownMatchId = e.matchId;
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
      // لو نعرف الـ matchId والـ WS فشل يـ-hello — جرّب REST fallback
      // لاستكشاف game_over ضائع. خاصة بعد عودة الـ app من السواد
      // والـ retry الأول كان فاشل (room may already be settled & GC'd).
      if (state.outcome == null && _lastKnownMatchId != null) {
        _maybeFetchMatchStatusFallback();
      }
    } else if (e is CarromConnectionUp) {
      state = state.copyWith(
        connectionUp: true,
        clearReconnect: true,
        reconnectAttempt: 0,
      );
    } else if (e is CarromResyncRequested) {
      // إشارة بس — الـ WS طلب resync. لا نفعل شيء هنا حالياً، لكن
      // لو السيرفر ما رد بـ state خلال 4s، نسقط على REST.
      Timer(const Duration(seconds: 4), () {
        if (!mounted) return;
        final got = _lastStateAt;
        if (got == null || DateTime.now().difference(got) > const Duration(seconds: 4)) {
          _maybeFetchMatchStatusFallback();
        }
      });
    } else if (e is CarromErrorEvent) {
      state = state.copyWith(lastError: e.code, pendingShot: false);
    }
  }

  /// لو وصلنا state.status == finished ولا يوجد outcome → نولّد outcome
  /// محلياً (winner = صاحب الـ higher score) حتى لا تعلق الشاشة.
  void _maybeSynthesizeGameOverFromState() {
    final s = state.state;
    if (s == null) return;
    if (s.status != CarromStatus.finished) return;
    if (state.outcome != null) return;
    final winnerId = s.aScore >= s.bScore ? s.playerAId : s.playerBId;
    state = state.copyWith(
      outcome: CarromOutcome(
        winnerId: winnerId,
        pot: s.pot,
        byConcede: false,
        revealOffer: true,
        // مفقود من snapshot — نخبئ 0 ونعتمد على REST لاحقاً.
        matchId: _lastKnownMatchId ?? 0,
      ),
    );
  }

  /// عند الـ resume أو فشل WS لمباراة منتهية — نسأل REST عن الـ match.
  /// إذا كانت `finished/abandoned` نولّد CarromOutcome.
  ///
  /// NOTE: backend `/api/v1/carrom/match/{match_id}` يحتاج DB match_id
  /// (int)، وهو متوفر فقط بعد ما يصل state أو game_over أول مرة.
  /// لا يوجد endpoint بـ room_id حالياً → TODO: backend gap.
  Future<void> _maybeFetchMatchStatusFallback() async {
    if (_restFallbackInFlight) return;
    final mid = _lastKnownMatchId;
    if (mid == null || mid <= 0) {
      // TODO(backend): لا يوجد `GET /api/v1/carrom/state/{room_id}`
      // وما نقدر نسأل عن المباراة قبل ما نعرف الـ DB match_id.
      // لو السيرفر أضاف endpoint لاحقاً — نستدعيه هنا.
      return;
    }
    _restFallbackInFlight = true;
    try {
      final api = ref.read(carromApiProvider);
      final ms = await api.matchStatus(mid);
      if (!mounted) return;
      if (ms.status == 'finished' || ms.status == 'abandoned') {
        if (state.outcome == null) {
          state = state.copyWith(
            outcome: CarromOutcome(
              winnerId: ms.winnerId ?? 0,
              pot: ms.pot,
              // ما عندنا تأكيد إن كان concede من REST — افتراضي false.
              byConcede: false,
              // reveal_offer نخليه true (الـ UI يفلتر حسب توفر الـ feature).
              revealOffer: true,
              matchId: ms.matchId,
            ),
          );
        }
      }
    } catch (_) {
      // تجاهل — الـ UI يبقى كما هو وننتظر الـ WS reconnect.
    } finally {
      _restFallbackInFlight = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      _onResume();
    }
  }

  void _onResume() {
    if (!mounted) return;
    // لو الـ pause كان قصير جداً (< 1s، مثل scrim/keyboard) — تجاهل.
    final pausedAt = _pausedAt;
    _pausedAt = null;
    if (pausedAt != null &&
        DateTime.now().difference(pausedAt) < const Duration(seconds: 1)) {
      return;
    }
    // اطلب resync فوراً — الـ WS يتعامل مع الإرسال الآمن لو غير متصل.
    _ws?.requestResync();
    // افحص بعد 5s — لو لسه ما عندنا state، فورس reconnect+resync.
    _resumeCheckTimer?.cancel();
    _resumeCheckTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      final lastIn = _ws?.lastInboundAt;
      final stale = lastIn == null ||
          DateTime.now().difference(lastIn) > const Duration(seconds: 8);
      if (state.state == null || stale) {
        // طلب resync تاني — إذا الـ socket مقطوع، watchdog/onDone بالفعل
        // جدول reconnect. هنا نضمن إن لما يرجع — يطلب snapshot.
        _ws?.requestResync();
      }
      // كذلك — لو الـ snapshot المعروف فيه finished status من قبل ما
      // ندخل الخلفية، نركّب outcome.
      _maybeSynthesizeGameOverFromState();
      // وفي حال لسه ما عندنا outcome ونعرف matchId — جرّب REST.
      if (state.outcome == null && _lastKnownMatchId != null) {
        _maybeFetchMatchStatusFallback();
      }
    });
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

  /// Force a fresh state pull. صالحة للاستخدام من الـ UI (مثلاً زر "أعد الاتصال").
  void requestResync() {
    _ws?.requestResync();
  }

  void clearError() {
    if (state.lastError != null) state = state.copyWith(clearError: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resumeCheckTimer?.cancel();
    _resumeCheckTimer = null;
    _retrySub?.cancel();
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
