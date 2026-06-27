import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/storage/secure_storage.dart';

/// Typed events from the carrom3 relay. Game frames carry the sender's seat
/// ('a' | 'b'); the client ignores its own echoes upstream (the server already
/// filters them, this is belt-and-braces).
sealed class C3Event {
  const C3Event();
}

class C3StateEvent extends C3Event {
  const C3StateEvent({required this.status, required this.winnerSeat});
  final String status; // playing | finished
  final String? winnerSeat;
}

/// A relayed shot — replay it through the local engine for a synced board.
class C3ShotEvent extends C3Event {
  const C3ShotEvent({
    required this.fromSeat,
    required this.placeX,
    required this.dirX,
    required this.dirY,
    required this.power,
  });
  final String fromSeat;
  final double placeX;
  final double dirX;
  final double dirY;
  final double power;
}

class C3ChatEvent extends C3Event {
  const C3ChatEvent(this.fromSeat, this.emoji, this.text);
  final String fromSeat;
  final String emoji;
  final String text;
}

class C3QuestionEvent extends C3Event {
  const C3QuestionEvent(this.fromSeat, this.text);
  final String fromSeat;
  final String text;
}

class C3AnswerEvent extends C3Event {
  const C3AnswerEvent(this.fromSeat, this.text);
  final String fromSeat;
  final String text;
}

class C3ConcedeEvent extends C3Event {
  const C3ConcedeEvent(this.fromSeat);
  final String fromSeat;
}

/// The sender's turn timed out — pass the turn (no shot was played).
class C3SkipEvent extends C3Event {
  const C3SkipEvent(this.fromSeat);
  final String fromSeat;
}

class C3OpponentReadyEvent extends C3Event {
  const C3OpponentReadyEvent(this.fromSeat);
  final String fromSeat;
}

class C3OpponentLeftEvent extends C3Event {
  const C3OpponentLeftEvent();
}

class C3ErrorEvent extends C3Event {
  const C3ErrorEvent(this.code);
  final String code;
}

class C3ConnectionUp extends C3Event {
  const C3ConnectionUp();
}

class C3ConnectionDown extends C3Event {
  const C3ConnectionDown();
}

/// WebSocket client for the carrom3 deterministic-lockstep relay.
class Carrom3WsClient {
  Carrom3WsClient({
    required String httpBaseUrl,
    required this.roomId,
    required this.mySeat,
    required this.secureStorage,
  }) : _wsBaseUrl = _toWsBase(httpBaseUrl);

  static String _toWsBase(String http) {
    if (http.startsWith('https://')) return 'wss://${http.substring(8)}';
    if (http.startsWith('http://')) return 'ws://${http.substring(7)}';
    return http;
  }

  final String _wsBaseUrl;
  final String roomId;
  final String mySeat; // 'a' | 'b'
  final SecureStorage secureStorage;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  Timer? _heartbeat;
  Timer? _reconnectTimer;
  int _retry = 0;
  bool _disposed = false;
  bool _connecting = false;

  final _controller = StreamController<C3Event>.broadcast();
  Stream<C3Event> get events => _controller.stream;
  bool get isConnected => _channel != null;

  Future<void> connect() async {
    if (_disposed || _connecting) return;
    _connecting = true;
    try {
      final token = await secureStorage.readAccessToken();
      final uri = Uri.parse('$_wsBaseUrl/api/v1/carrom3/ws/$roomId');
      final ch = WebSocketChannel.connect(uri);
      _channel = ch;
      _sub = ch.stream.listen(
        _onRaw,
        onError: (_, __) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: true,
      );
      ch.sink.add(jsonEncode({'type': 'hello', 'token': token ?? ''}));
      _startHeartbeat();
      _retry = 0;
      _emit(const C3ConnectionUp());
    } catch (e) {
      if (kDebugMode) debugPrint('carrom3 WS connect failed: $e');
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  void _startHeartbeat() {
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(const Duration(seconds: 20), (_) {
      try {
        _channel?.sink.add(jsonEncode({'type': 'ping'}));
      } catch (_) {}
    });
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _cleanup();
    _emit(const C3ConnectionDown());
    final delay = [1, 2, 4, 8, 16, 30][_retry.clamp(0, 5)];
    _retry += 1;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delay), connect);
  }

  void _onRaw(dynamic raw) {
    try {
      final Map<String, dynamic> m;
      if (raw is String) {
        m = (jsonDecode(raw) as Map).cast<String, dynamic>();
      } else if (raw is List<int>) {
        m = (jsonDecode(utf8.decode(raw)) as Map).cast<String, dynamic>();
      } else {
        return;
      }
      final type = m['type']?.toString() ?? '';
      final from = m['from_seat']?.toString() ?? '';
      // Ignore our own relayed frames (defensive — server filters too).
      if (from == mySeat &&
          const {'shot', 'chat', 'question', 'answer', 'skip', 'concede'}
              .contains(type)) {
        return;
      }
      switch (type) {
        case 'state':
          final p = (m['payload'] as Map?)?.cast<String, dynamic>() ?? const {};
          _emit(C3StateEvent(
            status: p['status']?.toString() ?? 'playing',
            winnerSeat: p['winner_seat']?.toString(),
          ));
        case 'shot':
          _emit(C3ShotEvent(
            fromSeat: from,
            placeX: (m['place_x'] as num?)?.toDouble() ?? 0,
            dirX: (m['dir_x'] as num?)?.toDouble() ?? 0,
            dirY: (m['dir_y'] as num?)?.toDouble() ?? -1,
            power: (m['power'] as num?)?.toDouble() ?? 0,
          ));
        case 'chat':
          _emit(C3ChatEvent(from, m['emoji']?.toString() ?? '',
              m['text']?.toString() ?? ''));
        case 'question':
          _emit(C3QuestionEvent(from, m['text']?.toString() ?? ''));
        case 'answer':
          _emit(C3AnswerEvent(from, m['text']?.toString() ?? ''));
        case 'concede':
          _emit(C3ConcedeEvent(from));
        case 'skip':
          _emit(C3SkipEvent(from));
        case 'opponent_ready':
          _emit(C3OpponentReadyEvent(from));
        case 'opponent_left':
          _emit(const C3OpponentLeftEvent());
        case 'error':
          _emit(C3ErrorEvent(m['code']?.toString() ?? 'unknown'));
        case 'pong':
          break;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('carrom3 WS parse error: $e');
    }
  }

  void _emit(C3Event ev) {
    if (!_controller.isClosed) _controller.add(ev);
  }

  void _send(Map<String, dynamic> msg) {
    try {
      _channel?.sink.add(jsonEncode(msg));
    } catch (_) {}
  }

  void sendShot(
      {required double placeX,
      required double dirX,
      required double dirY,
      required double power}) {
    _send({
      'type': 'shot',
      'place_x': placeX,
      'dir_x': dirX,
      'dir_y': dirY,
      'power': power,
    });
  }

  void sendChat(String emoji, String text) =>
      _send({'type': 'chat', 'emoji': emoji, 'text': text});
  void sendQuestion(String text) => _send({'type': 'question', 'text': text});
  void sendAnswer(String text) => _send({'type': 'answer', 'text': text});
  void sendConcede() => _send({'type': 'concede'});
  void sendSkip() => _send({'type': 'skip'});

  void _cleanup() {
    _heartbeat?.cancel();
    _heartbeat = null;
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
    _cleanup();
    await _controller.close();
  }
}
