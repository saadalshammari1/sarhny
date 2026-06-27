import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/dio_client.dart';
import '../../../../core/providers/api_providers.dart';

/// REST surface for the Carrom v3 online relay. The WS endpoint is opened
/// separately by [Carrom3WsClient].
class Carrom3Api {
  Carrom3Api(this._dio);
  final DioClient _dio;

  static const String _base = '/api/v1/carrom3';

  /// Join matchmaking. When paired immediately the response carries the room +
  /// opponent; otherwise [roomId] is empty (keep polling until matched).
  Future<Carrom3MatchStart> startMatch() async {
    final r = await _dio.raw.post<dynamic>('$_base/match/start');
    final data = (r.data as Map).cast<String, dynamic>();
    if (data['success'] != true) {
      throw Carrom3ApiException(data['error']?.toString() ?? 'unknown');
    }
    final d = (data['data'] as Map).cast<String, dynamic>();
    return Carrom3MatchStart(
      roomId: d['room_id']?.toString() ?? '',
      mySeat: d['your_seat']?.toString() == 'b' ? 'b' : 'a',
      opponentId: d['opponent_id'] is int ? d['opponent_id'] as int : null,
    );
  }

  /// Leave the queue while still waiting (no room yet).
  Future<void> cancel() async {
    try {
      await _dio.raw.post<dynamic>('$_base/cancel');
    } catch (_) {}
  }

  /// Forfeit the active room. Idempotent server-side.
  Future<void> concede(String roomId) async {
    try {
      await _dio.raw.post<dynamic>('$_base/concede/$roomId');
    } catch (_) {}
  }
}

class Carrom3MatchStart {
  Carrom3MatchStart({
    required this.roomId,
    required this.mySeat,
    required this.opponentId,
  });
  final String roomId;
  final String mySeat; // "a" | "b"
  final int? opponentId;
  bool get isMatched => roomId.isNotEmpty && opponentId != null;
}

class Carrom3ApiException implements Exception {
  Carrom3ApiException(this.code);
  final String code;
  @override
  String toString() => 'Carrom3ApiException($code)';
}

final carrom3ApiProvider = Provider<Carrom3Api>((ref) {
  return Carrom3Api(ref.read(dioClientProvider));
});
