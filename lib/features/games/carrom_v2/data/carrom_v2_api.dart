import '../../../../core/api/dio_client.dart';

/// REST surface for Carrom v2 — the WS endpoint is opened separately.
class CarromV2Api {
  CarromV2Api(this._dio);
  final DioClient _dio;

  static const String _base = '/api/v1/carrom-v2';

  /// Start matchmaking. Returns the assigned room + seat. If
  /// [opponentId] is null in the response, the player is waiting in
  /// the queue (poll again, or open the WS for the `match_found` push).
  Future<CarromV2MatchStartResponse> startMatch() async {
    final r = await _dio.raw.post<dynamic>('$_base/match/start');
    final data = (r.data as Map).cast<String, dynamic>();
    if (data['success'] != true) {
      throw CarromV2ApiException(data['error']?.toString() ?? 'unknown');
    }
    final d = (data['data'] as Map).cast<String, dynamic>();
    return CarromV2MatchStartResponse(
      roomId: d['room_id']?.toString() ?? '',
      mySeat: d['your_seat']?.toString() == 'b' ? 'b' : 'a',
      opponentId: d['opponent_id'] is int ? d['opponent_id'] as int : null,
    );
  }

  /// Forfeit the active room. Idempotent server-side.
  Future<void> concede(String roomId) async {
    await _dio.raw.post<dynamic>('$_base/concede/$roomId');
  }
}

class CarromV2MatchStartResponse {
  CarromV2MatchStartResponse({
    required this.roomId,
    required this.mySeat,
    required this.opponentId,
  });
  final String roomId;
  final String mySeat; // "a" | "b"
  final int? opponentId;
  bool get isMatched => opponentId != null;
}

class CarromV2ApiException implements Exception {
  CarromV2ApiException(this.code);
  final String code;
  @override
  String toString() => 'CarromV2ApiException($code)';
}
