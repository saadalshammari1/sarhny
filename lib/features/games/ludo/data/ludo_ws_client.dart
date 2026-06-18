import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/storage/secure_storage.dart';
import '../domain/ludo_chat_preset.dart';
import '../domain/ludo_move_result.dart';
import '../domain/ludo_state.dart';

/// Typed event من السيرفر — sealed pattern.
sealed class LudoEvent {
  const LudoEvent();
}

class LudoHelloAck extends LudoEvent {
  const LudoHelloAck();
}

class LudoStateEvent extends LudoEvent {
  const LudoStateEvent(this.state);
  final LudoState state;
}

class LudoDiceRolledEvent extends LudoEvent {
  const LudoDiceRolledEvent(this.dice);
  final LudoDiceRolled dice;
}

class LudoMoveResultEvent extends LudoEvent {
  const LudoMoveResultEvent(this.result);
  final LudoMoveResult result;
}

class LudoNextTurnEvent extends LudoEvent {
  const LudoNextTurnEvent(this.seat);
  final int seat;
}

class LudoChatEvent extends LudoEvent {
  const LudoChatEvent({
    required this.fromUserId,
    required this.presetKey,
    required this.ts,
  });
  final int fromUserId;
  final String presetKey;
  final DateTime ts;
}

class LudoPresenceEvent extends LudoEvent {
  const LudoPresenceEvent({required this.userId, required this.online});
  final int userId;
  final bool online;
}

class LudoOpponentDisconnect extends LudoEvent {
  const LudoOpponentDisconnect(this.reconnectDeadline);
  final DateTime reconnectDeadline;
}

class LudoMatchFoundEvent extends LudoEvent {
  const LudoMatchFoundEvent(this.roomId);
  final String roomId;
}

class LudoGameOverEvent extends LudoEvent {
  const LudoGameOverEvent({
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

  /// DB id — للـ /match/{id}/reveal و /match/{id}/send-sarhny (optional).
  final int matchId;
}

class LudoErrorEvent extends LudoEvent {
  const LudoErrorEvent(this.code);
  final String code;
}

class LudoConnectionDown extends LudoEvent {
  const LudoConnectionDown();
}

class LudoConnectionUp extends LudoEvent {
  const LudoConnectionUp();
}

/// WebSocket client مع auto-reconnect + heartbeat.
///
/// - يفتح الاتصال بـ `wss://<host>/api/v1/ludo/ws/{room_id}`.
/// - أول رسالة: `{type: hello, token: <jwt>}`.
/// - ping كل 20 ثانية.
/// - Exponential backoff: 1, 2, 4, 8, 16, 30s (cap).
class LudoWsClient {
  LudoWsClient({
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

  final _controller = StreamController<LudoEvent>.broadcast();
  Stream<LudoEvent> get events => _controller.stream;

  bool get isConnected => _channel != null;

  Future<void> connect() async {
    if (_disposed || _connecting) return;
    _connecting = true;
    try {
      final token = await secureStorage.readAccessToken();
      final uri = Uri.parse('$_wsBaseUrl/api/v1/ludo/ws/$roomId');
      final ch = WebSocketChannel.connect(uri);
      _channel = ch;
      _sub = ch.stream.listen(
        _onRaw,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: true,
      );
      ch.sink.add(jsonEncode({'type': 'hello', 'token': token ?? ''}));
      _startHeartbeat();
      _retry = 0;
      if (!_controller.isClosed) {
        _controller.add(const LudoConnectionUp());
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Ludo WS connect failed: $e');
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
      } catch (_) {
        // onDone سيتولّى reconnect
      }
    });
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _cleanup();
    if (!_controller.isClosed) {
      _controller.add(const LudoConnectionDown());
    }
    final delaySec = [1, 2, 4, 8, 16, 30][_retry.clamp(0, 5)];
    _retry++;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delaySec), connect);
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
          _emit(LudoStateEvent(LudoState.fromJson(payload)));
          break;
        case 'dice_rolled':
          // السيرفر قد يبعث الـ data flat أو داخل payload — ندعم الاثنين.
          final src = payload.isNotEmpty ? payload : msg;
          _emit(LudoDiceRolledEvent(LudoDiceRolled.fromJson(src)));
          break;
        case 'move_result':
          _emit(LudoMoveResultEvent(LudoMoveResult.fromJson(payload)));
          break;
        case 'next_turn':
          _emit(LudoNextTurnEvent((msg['seat'] as num?)?.toInt() ?? 0));
          break;
        case 'chat':
          _emit(LudoChatEvent(
            fromUserId: (msg['from'] as num?)?.toInt() ?? 0,
            presetKey: msg['preset_key']?.toString() ?? '',
            ts: DateTime.fromMillisecondsSinceEpoch(
              ((msg['ts'] as num?)?.toInt() ?? 0) * 1000,
            ),
          ));
          break;
        case 'presence':
          _emit(LudoPresenceEvent(
            userId: (msg['user_id'] as num?)?.toInt() ?? 0,
            online: msg['online'] == true,
          ));
          break;
        case 'opponent_disconnect':
          final secs = (msg['reconnect_deadline'] as num?)?.toInt() ?? 30;
          _emit(LudoOpponentDisconnect(
            DateTime.now().add(Duration(seconds: secs)),
          ));
          break;
        case 'match_found':
          _emit(LudoMatchFoundEvent(msg['room_id']?.toString() ?? ''));
          break;
        case 'game_over':
          final rawRanks = (msg['ranks'] as List?) ?? const [];
          _emit(LudoGameOverEvent(
            winnerId: (msg['winner_id'] as num?)?.toInt() ?? 0,
            pot: (msg['pot'] as num?)?.toInt() ?? 0,
            ranks: rawRanks
                .whereType<Map>()
                .map((m) =>
                    LudoRankEntry.fromJson(m.cast<String, dynamic>()))
                .toList(growable: false),
            revealOffer: msg['reveal_offer'] == true,
            matchId: (msg['match_id'] as num?)?.toInt() ?? 0,
          ));
          break;
        case 'error':
          _emit(LudoErrorEvent(msg['code']?.toString() ?? 'unknown'));
          break;
        case 'pong':
        case 'hello_ack':
          break;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Ludo WS parse error: $e');
    }
  }

  void _emit(LudoEvent ev) {
    if (!_controller.isClosed) _controller.add(ev);
  }

  void _onError(Object err, StackTrace st) {
    if (kDebugMode) debugPrint('Ludo WS error: $err');
    _scheduleReconnect();
  }

  void _onDone() {
    _scheduleReconnect();
  }

  /// رمي الزهر — only your turn.
  void sendRoll() {
    final ch = _channel;
    if (ch == null) return;
    try {
      ch.sink.add(jsonEncode({'type': 'roll'}));
    } catch (_) {}
  }

  /// تحريك token [0..3].
  void sendMove(int tokenIndex) {
    final ch = _channel;
    if (ch == null) return;
    try {
      ch.sink.add(jsonEncode({'type': 'move', 'token_index': tokenIndex}));
    } catch (_) {}
  }

  void sendChat(String presetKey) {
    final ch = _channel;
    if (ch == null) return;
    try {
      ch.sink.add(jsonEncode({'type': 'chat', 'preset_key': presetKey}));
    } catch (_) {}
  }

  void sendConcede() {
    final ch = _channel;
    if (ch == null) return;
    try {
      ch.sink.add(jsonEncode({'type': 'concede'}));
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
