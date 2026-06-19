import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

import '../../../../core/storage/secure_storage.dart';
import '../domain/carrom_state.dart';
import '../domain/shot_input.dart';
import '../domain/shot_result.dart';

/// Typed event من السيرفر — sealed-like via dart 3 sealed pattern.
sealed class CarromEvent {
  const CarromEvent();
}

class CarromHelloAck extends CarromEvent {
  const CarromHelloAck();
}

class CarromStateEvent extends CarromEvent {
  const CarromStateEvent(this.state);
  final CarromState state;
}

class CarromShotResultEvent extends CarromEvent {
  const CarromShotResultEvent(this.result);
  final CarromShotResult result;
}

class CarromChatEvent extends CarromEvent {
  const CarromChatEvent({
    required this.fromUserId,
    required this.presetKey,
    required this.ts,
  });
  final int fromUserId;
  final String presetKey;
  final DateTime ts;
}

class CarromPresenceEvent extends CarromEvent {
  const CarromPresenceEvent({required this.userId, required this.online});
  final int userId;
  final bool online;
}

class CarromOpponentDisconnect extends CarromEvent {
  const CarromOpponentDisconnect(this.reconnectDeadline);
  final DateTime reconnectDeadline;
}

class CarromMatchFoundEvent extends CarromEvent {
  const CarromMatchFoundEvent(this.roomId);
  final String roomId;
}

class CarromGameOverEvent extends CarromEvent {
  const CarromGameOverEvent({
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
  /// DB numeric match id — used for /match/{id}/* REST endpoints
  /// (separate from the WS-only room_id string).
  final int matchId;
}

class CarromErrorEvent extends CarromEvent {
  const CarromErrorEvent(this.code);
  final String code;
}

class CarromConnectionDown extends CarromEvent {
  const CarromConnectionDown();
}

class CarromConnectionUp extends CarromEvent {
  const CarromConnectionUp();
}

/// Fired whenever the WS asks for a fresh state — controller may use this
/// as a signal to also try a REST fallback if the server doesn't echo a
/// `state` event back within a short window.
class CarromResyncRequested extends CarromEvent {
  const CarromResyncRequested();
}

/// WebSocket client مع auto-reconnect + heartbeat + liveness watchdog.
///
/// - يفتح الاتصال بـ `wss://<host>/api/v1/carrom/ws/{room_id}`.
/// - أول رسالة: `{type: hello, token: <jwt>}`.
/// - ping كل 20 ثانية.
/// - Watchdog كل 10s — لو ما وصلت رسالة من السيرفر خلال 60s نقطع ونعيد.
/// - Exponential backoff: 1, 2, 4, 8, 16, 30s (cap).
class CarromWsClient {
  CarromWsClient({
    required String httpBaseUrl,
    required this.roomId,
    required this.secureStorage,
  }) : _wsBaseUrl = _toWsBase(httpBaseUrl);

  static String _toWsBase(String httpUrl) {
    if (httpUrl.startsWith('https://')) {
      return 'wss://${httpUrl.substring(8)}';
    }
    if (httpUrl.startsWith('http://')) {
      return 'ws://${httpUrl.substring(7)}';
    }
    return httpUrl;
  }

  /// كم ثانية بدون أي رسالة من السيرفر قبل ما نعتبر الاتصال ميت.
  static const Duration livenessTimeout = Duration(seconds: 60);
  static const Duration _livenessTickEvery = Duration(seconds: 10);

  final String _wsBaseUrl;
  final String roomId;
  final SecureStorage secureStorage;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  Timer? _heartbeat;
  Timer? _reconnectTimer;
  Timer? _livenessTimer;
  int _retry = 0;
  bool _disposed = false;
  bool _connecting = false;
  bool _hasConnectedOnce = false;
  DateTime? _lastInboundAt;

  final _controller = StreamController<CarromEvent>.broadcast();
  Stream<CarromEvent> get events => _controller.stream;

  /// Live counter — increments on every scheduled reconnect attempt and
  /// resets to 0 on a successful (connection-up) handshake.
  final _retryController = StreamController<int>.broadcast();

  /// Broadcasts the current retry attempt (1, 2, 3 …) so the UI can show
  /// "محاولة #N" banners.
  Stream<int> get reconnectAttempts => _retryController.stream;

  /// Public getter — useful for the controller's lifecycle decisions.
  int get retryCount => _retry;

  /// آخر وقت وصلت فيه رسالة من السيرفر — exposed للـ controller حتى
  /// يقرر هل يطلب resync بعد ما يرجع الـ app من الخلفية.
  DateTime? get lastInboundAt => _lastInboundAt;

  bool get isConnected => _channel != null;

  Future<void> connect() async {
    if (_disposed || _connecting) return;
    _connecting = true;
    try {
      final token = await secureStorage.readAccessToken();
      final uri = Uri.parse('$_wsBaseUrl/api/v1/carrom/ws/$roomId');
      final ch = WebSocketChannel.connect(uri);
      _channel = ch;
      _sub = ch.stream.listen(
        _onRaw,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: true,
      );
      // hello أولاً — السيرفر يقطع الاتصال لو ما وصلته خلال 5s.
      ch.sink.add(jsonEncode({'type': 'hello', 'token': token ?? ''}));
      // لو كان هذا reconnect (ليست أول مرة) — اطلب فوراً snapshot كامل
      // حتى نلحق أي events ضاعت أثناء الانقطاع (خصوصاً game_over).
      if (_hasConnectedOnce) {
        _sendRawSafe(jsonEncode({'type': 'resync'}));
        if (!_controller.isClosed) {
          _controller.add(const CarromResyncRequested());
        }
      }
      _hasConnectedOnce = true;
      _lastInboundAt = DateTime.now();
      _startHeartbeat();
      _startLivenessWatchdog();
      _retry = 0;
      if (!_controller.isClosed) {
        _controller.add(const CarromConnectionUp());
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Carrom WS connect failed: $e');
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  void _startHeartbeat() {
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(const Duration(seconds: 20), (_) {
      _sendRawSafe(jsonEncode({'type': 'ping'}));
    });
  }

  void _startLivenessWatchdog() {
    _livenessTimer?.cancel();
    _livenessTimer = Timer.periodic(_livenessTickEvery, (_) => _checkLiveness());
  }

  void _checkLiveness() {
    if (_disposed) return;
    final last = _lastInboundAt;
    if (last == null) return;
    if (_channel == null) return; // already disconnected — reconnect path handles it
    final silence = DateTime.now().difference(last);
    if (silence >= livenessTimeout) {
      if (kDebugMode) {
        debugPrint('Carrom WS liveness watchdog — ${silence.inSeconds}s of silence, forcing reconnect');
      }
      // Drop and reschedule. _scheduleReconnect emits ConnectionDown.
      _scheduleReconnect();
    }
  }

  void _sendRawSafe(String payload) {
    final ch = _channel;
    if (ch == null) return;
    try {
      ch.sink.add(payload);
    } catch (_) {
      // sink قد يكون مغلق — onDone سيتولّى reconnect
    }
  }

  /// Public API — اطلب من السيرفر يرسل state snapshot كامل.
  /// آمن لاستدعائه من الـ controller حتى لو ما كان متصل (no-op وقتها،
  /// والـ reconnect-resync path سيتكفّل بالأمر).
  void requestResync() {
    _sendRawSafe(jsonEncode({'type': 'resync'}));
    if (!_controller.isClosed) {
      _controller.add(const CarromResyncRequested());
    }
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _cleanup();
    if (!_controller.isClosed) {
      _controller.add(const CarromConnectionDown());
    }
    final delaySec = [1, 2, 4, 8, 16, 30][_retry.clamp(0, 5)];
    _retry++;
    if (!_retryController.isClosed) {
      _retryController.add(_retry);
    }
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delaySec), connect);
  }

  void _onRaw(dynamic raw) {
    _lastInboundAt = DateTime.now();
    try {
      final Map<String, dynamic> msg;
      if (raw is String) {
        msg = (jsonDecode(raw) as Map).cast<String, dynamic>();
      } else if (raw is List<int>) {
        msg = (jsonDecode(utf8.decode(raw)) as Map).cast<String, dynamic>();
      } else {
        return;
      }
      final type = msg['type']?.toString() ?? '';
      final payload = (msg['payload'] is Map)
          ? (msg['payload'] as Map).cast<String, dynamic>()
          : <String, dynamic>{};
      switch (type) {
        case 'state':
          _emit(CarromStateEvent(CarromState.fromJson(payload)));
          break;
        case 'shot_result':
          _emit(CarromShotResultEvent(CarromShotResult.fromJson(payload)));
          break;
        case 'chat':
          _emit(CarromChatEvent(
            fromUserId: (msg['from'] as num?)?.toInt() ?? 0,
            presetKey: msg['preset_key']?.toString() ?? '',
            ts: DateTime.fromMillisecondsSinceEpoch(
              ((msg['ts'] as num?)?.toInt() ?? 0) * 1000,
            ),
          ));
          break;
        case 'presence':
          _emit(CarromPresenceEvent(
            userId: (msg['user_id'] as num?)?.toInt() ?? 0,
            online: msg['online'] == true,
          ));
          break;
        case 'opponent_disconnect':
          final secs = (msg['reconnect_deadline'] as num?)?.toInt() ?? 30;
          _emit(CarromOpponentDisconnect(
            DateTime.now().add(Duration(seconds: secs)),
          ));
          break;
        case 'match_found':
          _emit(CarromMatchFoundEvent(msg['room_id']?.toString() ?? ''));
          break;
        case 'game_over':
          _emit(CarromGameOverEvent(
            winnerId: (msg['winner_id'] as num?)?.toInt() ?? 0,
            pot: (msg['pot'] as num?)?.toInt() ?? 0,
            byConcede: msg['by_concede'] == true,
            revealOffer: msg['reveal_offer'] == true,
            matchId: (msg['match_id'] as num?)?.toInt() ?? 0,
          ));
          break;
        case 'error':
          _emit(CarromErrorEvent(msg['code']?.toString() ?? 'unknown'));
          break;
        case 'pong':
        case 'hello_ack':
          // benign — `_lastInboundAt` is already refreshed.
          break;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Carrom WS parse error: $e');
    }
  }

  void _emit(CarromEvent ev) {
    if (!_controller.isClosed) _controller.add(ev);
  }

  void _onError(Object err, StackTrace st) {
    if (kDebugMode) debugPrint('Carrom WS error: $err');
    _scheduleReconnect();
  }

  void _onDone() {
    _scheduleReconnect();
  }

  /// إرسال تصويب.
  void sendShoot(CarromShotInput input) {
    _sendRawSafe(jsonEncode(input.toJson()));
  }

  /// إرسال chat preset.
  void sendChat(String presetKey) {
    _sendRawSafe(jsonEncode({'type': 'chat', 'preset_key': presetKey}));
  }

  /// انسحاب من المباراة.
  void sendConcede() {
    _sendRawSafe(jsonEncode({'type': 'concede'}));
  }

  void _cleanup() {
    _heartbeat?.cancel();
    _heartbeat = null;
    _livenessTimer?.cancel();
    _livenessTimer = null;
    _sub?.cancel();
    _sub = null;
    try {
      _channel?.sink.close(ws_status.goingAway);
    } catch (_) {}
    _channel = null;
  }

  Future<void> dispose() async {
    _disposed = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _cleanup();
    await _controller.close();
    await _retryController.close();
  }
}
