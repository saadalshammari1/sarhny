import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/storage/secure_storage.dart';

/// Typed event hierarchy mirroring the server's WS message schema.
sealed class CarromV2WsEvent {
  const CarromV2WsEvent();
}

class CarromV2StateEvent extends CarromV2WsEvent {
  const CarromV2StateEvent({
    required this.aScore,
    required this.bScore,
    required this.turnSeat,
    required this.status,
    required this.winnerSeat,
  });
  final int aScore;
  final int bScore;
  final String turnSeat; // "a" | "b"
  final String status; // "playing" | "finished"
  final String? winnerSeat; // "a" | "b" | null
}

class CarromV2ShotResultEvent extends CarromV2WsEvent {
  const CarromV2ShotResultEvent({
    required this.fromSeat,
    required this.pocketedIds,
    required this.strikerPocketed,
    required this.queenPocketed,
    required this.firstPieceHitId,
    required this.foul,
    required this.foulReason,
    required this.aScoreAfter,
    required this.bScoreAfter,
    required this.turnAfterSeat,
    required this.status,
  });
  final String fromSeat;
  final List<int> pocketedIds;
  final bool strikerPocketed;
  final bool queenPocketed;
  final int firstPieceHitId;
  final bool foul;
  final String? foulReason;
  final int aScoreAfter;
  final int bScoreAfter;
  final String turnAfterSeat;
  final String status;
}

class CarromV2OpponentLeftEvent extends CarromV2WsEvent {
  const CarromV2OpponentLeftEvent();
}

class CarromV2MatchFoundEvent extends CarromV2WsEvent {
  const CarromV2MatchFoundEvent(this.roomId);
  final String roomId;
}

class CarromV2ErrorEvent extends CarromV2WsEvent {
  const CarromV2ErrorEvent(this.code);
  final String code;
}

class CarromV2ConnectionDown extends CarromV2WsEvent {
  const CarromV2ConnectionDown();
}

class CarromV2ConnectionUp extends CarromV2WsEvent {
  const CarromV2ConnectionUp();
}

/// WebSocket client for Carrom v2.
///
/// Protocol:
///   - Client → server: hello (first), ping, shot (with outcome payload)
///   - Server → client: state, shot_result, opponent_left, match_found,
///     error
class CarromV2WsClient {
  CarromV2WsClient({
    required String httpBaseUrl,
    required this.roomId,
    required this.secureStorage,
  }) : _wsBaseUrl = _toWsBase(httpBaseUrl);

  static String _toWsBase(String http) {
    if (http.startsWith('https://')) return 'wss://${http.substring(8)}';
    if (http.startsWith('http://')) return 'ws://${http.substring(7)}';
    return http;
  }

  final String _wsBaseUrl;
  final String roomId;
  final SecureStorage secureStorage;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  Timer? _heartbeat;
  Timer? _reconnectTimer;
  int _retry = 0;
  bool _disposed = false;
  bool _connecting = false;

  final _controller = StreamController<CarromV2WsEvent>.broadcast();
  Stream<CarromV2WsEvent> get events => _controller.stream;
  bool get isConnected => _channel != null;

  Future<void> connect() async {
    if (_disposed || _connecting) return;
    _connecting = true;
    try {
      final token = await secureStorage.readAccessToken();
      final uri = Uri.parse('$_wsBaseUrl/api/v1/carrom-v2/ws/$roomId');
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
      _emit(const CarromV2ConnectionUp());
    } catch (e) {
      if (kDebugMode) debugPrint('CarromV2 WS connect failed: $e');
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
    _emit(const CarromV2ConnectionDown());
    final delay = [1, 2, 4, 8, 16, 30][_retry.clamp(0, 5)];
    _retry += 1;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delay), connect);
  }

  void _onRaw(dynamic raw) {
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
          final scores = (payload['scores'] as Map?)?.cast<String, dynamic>() ??
              const {};
          _emit(CarromV2StateEvent(
            aScore: (scores['a'] as num?)?.toInt() ?? 0,
            bScore: (scores['b'] as num?)?.toInt() ?? 0,
            turnSeat: payload['turn_seat']?.toString() ?? 'a',
            status: payload['status']?.toString() ?? 'playing',
            winnerSeat: payload['winner_seat']?.toString(),
          ));
          break;
        case 'shot_result':
          final outcome =
              (msg['outcome'] as Map?)?.cast<String, dynamic>() ?? const {};
          final scoresAfter =
              (msg['scores_after'] as Map?)?.cast<String, dynamic>() ??
                  const {};
          final pocketed = (outcome['pocketed_piece_ids'] as List?)
                  ?.map((v) => (v as num).toInt())
                  .toList(growable: false) ??
              const <int>[];
          _emit(CarromV2ShotResultEvent(
            fromSeat: msg['from_seat']?.toString() ?? 'a',
            pocketedIds: pocketed,
            strikerPocketed: outcome['striker_pocketed'] == true,
            queenPocketed: outcome['queen_pocketed'] == true,
            firstPieceHitId:
                (outcome['first_piece_hit_id'] as num?)?.toInt() ?? -1,
            foul: outcome['foul'] == true,
            foulReason: outcome['foul_reason']?.toString(),
            aScoreAfter: (scoresAfter['a'] as num?)?.toInt() ?? 0,
            bScoreAfter: (scoresAfter['b'] as num?)?.toInt() ?? 0,
            turnAfterSeat: msg['turn_after_seat']?.toString() ?? 'a',
            status: msg['status']?.toString() ?? 'playing',
          ));
          break;
        case 'opponent_left':
          _emit(const CarromV2OpponentLeftEvent());
          break;
        case 'match_found':
          _emit(CarromV2MatchFoundEvent(msg['room_id']?.toString() ?? ''));
          break;
        case 'error':
          _emit(CarromV2ErrorEvent(msg['code']?.toString() ?? 'unknown'));
          break;
        case 'pong':
        case 'hello_ack':
          break;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('CarromV2 WS parse error: $e');
    }
  }

  void _emit(CarromV2WsEvent ev) {
    if (!_controller.isClosed) _controller.add(ev);
  }

  /// Submit a local shot outcome to the server. Server applies rules,
  /// echoes a `shot_result` event back to both clients.
  void sendShot({
    required List<int> pocketedIds,
    required bool strikerPocketed,
    required bool queenPocketed,
    required int firstPieceHitId,
  }) {
    final ch = _channel;
    if (ch == null) return;
    try {
      ch.sink.add(jsonEncode({
        'type': 'shot',
        'outcome': {
          'pocketed_piece_ids': pocketedIds,
          'striker_pocketed': strikerPocketed,
          'queen_pocketed': queenPocketed,
          'first_piece_hit_id': firstPieceHitId,
        },
      }));
    } catch (_) {}
  }

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
