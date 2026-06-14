import 'package:dio/dio.dart';

import '../../../core/api/dio_client.dart';

typedef Json = Map<String, dynamic>;

/// Mirrors the public_state shape the FastAPI backend returns. Everything
/// the UI needs to render a turn is here — opponent moves are null until
/// both players have locked in (the backend hides them server-side).
class GameSnapshot {
  GameSnapshot({
    required this.gameId,
    required this.role,
    required this.status,
    required this.mood,
    required this.scoreMe,
    required this.scoreOpp,
    required this.winScore,
    required this.roundIndex,
    required this.meLocked,
    required this.oppLocked,
    required this.waitingForOpponent,
    required this.isInvite,
    this.inviteCode,
    this.isWinner,
    this.winnerKnown = false,
    this.finalQuestionText,
    this.finalQuestionDeadline,
    this.finalAnswer,
    this.finalSkipUsed = false,
    this.currentMyChoice,
    this.currentMyGuess,
    this.currentOppChoice,
    this.currentOppGuess,
    this.lastRoundRevealed = false,
    this.lastRoundAPoints = 0,
    this.lastRoundBPoints = 0,
  });

  final String gameId;
  final String role; // 'a' or 'b'
  final String status; // waiting | playing | final | answered | abandoned
  final String mood; // light | bold | funny
  final int scoreMe;
  final int scoreOpp;
  final int winScore;
  final int roundIndex;
  final bool meLocked;
  final bool oppLocked;
  final bool waitingForOpponent;
  final bool isInvite;
  final String? inviteCode;
  final bool? isWinner;
  final bool winnerKnown;
  final String? finalQuestionText;
  final double? finalQuestionDeadline;
  final String? finalAnswer;
  final bool finalSkipUsed;
  final String? currentMyChoice;
  final String? currentMyGuess;
  final String? currentOppChoice;
  final String? currentOppGuess;
  final bool lastRoundRevealed;
  final int lastRoundAPoints;
  final int lastRoundBPoints;

  factory GameSnapshot.fromJson(Json j) {
    final rounds = (j['rounds'] as List?) ?? const [];
    final cur = rounds.isNotEmpty ? rounds.last as Map : const {};
    return GameSnapshot(
      gameId: '${j['game_id'] ?? ''}',
      role: '${j['role'] ?? 'a'}',
      status: '${j['status'] ?? 'waiting'}',
      mood: '${j['mood'] ?? 'light'}',
      scoreMe: (j['score_me'] as num?)?.toInt() ?? 0,
      scoreOpp: (j['score_opp'] as num?)?.toInt() ?? 0,
      winScore: (j['win_score'] as num?)?.toInt() ?? 5,
      roundIndex: (j['round_index'] as num?)?.toInt() ?? 0,
      meLocked: j['me_locked'] == true,
      oppLocked: j['opp_locked'] == true,
      waitingForOpponent: j['waiting_for_opponent'] == true,
      isInvite: j['is_invite'] == true,
      inviteCode: j['invite_code']?.toString(),
      isWinner: j['is_winner'] as bool?,
      winnerKnown: j['winner_known'] == true,
      finalQuestionText: j['final_question_text']?.toString(),
      finalQuestionDeadline: (j['final_question_deadline'] as num?)?.toDouble(),
      finalAnswer: j['final_answer']?.toString(),
      finalSkipUsed: j['final_skip_used'] == true,
      currentMyChoice: cur['my_choice']?.toString(),
      currentMyGuess: cur['my_guess']?.toString(),
      currentOppChoice: cur['opp_choice']?.toString(),
      currentOppGuess: cur['opp_guess']?.toString(),
      lastRoundRevealed: cur['revealed'] == true,
      lastRoundAPoints: (cur['a_points'] as num?)?.toInt() ?? 0,
      lastRoundBPoints: (cur['b_points'] as num?)?.toInt() ?? 0,
    );
  }
}

class GameRepository {
  GameRepository(this._client);
  final DioClient _client;

  Future<({GameSnapshot snapshot, bool waiting})> join({
    required String mood,
    String? inviteCode,
    bool createInvite = false,
  }) async {
    final r = await _client.raw.post<dynamic>(
      '/api/v1/game/join',
      data: {
        'mood': mood,
        if (inviteCode != null) 'invite_code': inviteCode,
        'create_invite': createInvite,
      },
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensureSuccess(r);
    final data = (r.data as Map)['data'] as Map;
    return (
      snapshot: GameSnapshot.fromJson(
        ((data['state'] ?? {}) as Map).cast<String, dynamic>(),
      ),
      waiting: data['waiting'] == true,
    );
  }

  Future<GameSnapshot> state(String gameId) async {
    final r = await _client.raw.get<dynamic>(
      '/api/v1/game/$gameId/state',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensureSuccess(r);
    final state = ((r.data as Map)['data'] as Map)['state'] as Map;
    return GameSnapshot.fromJson(state.cast<String, dynamic>());
  }

  Future<GameSnapshot> move(String gameId, String choice, String guess) async {
    final r = await _client.raw.post<dynamic>(
      '/api/v1/game/$gameId/move',
      data: {'choice': choice, 'guess': guess},
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensureSuccess(r);
    final state = ((r.data as Map)['data'] as Map)['state'] as Map;
    return GameSnapshot.fromJson(state.cast<String, dynamic>());
  }

  Future<GameSnapshot> winnerQuestion(String gameId, String? text) async {
    final r = await _client.raw.post<dynamic>(
      '/api/v1/game/$gameId/winner-question',
      data: {'text': text},
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensureSuccess(r);
    final state = ((r.data as Map)['data'] as Map)['state'] as Map;
    return GameSnapshot.fromJson(state.cast<String, dynamic>());
  }

  Future<GameSnapshot> answer(String gameId, String text) async {
    final r = await _client.raw.post<dynamic>(
      '/api/v1/game/$gameId/answer',
      data: {'text': text},
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensureSuccess(r);
    final state = ((r.data as Map)['data'] as Map)['state'] as Map;
    return GameSnapshot.fromJson(state.cast<String, dynamic>());
  }

  Future<GameSnapshot> skip(String gameId) async {
    final r = await _client.raw.post<dynamic>(
      '/api/v1/game/$gameId/skip',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensureSuccess(r);
    final state = ((r.data as Map)['data'] as Map)['state'] as Map;
    return GameSnapshot.fromJson(state.cast<String, dynamic>());
  }

  Future<void> leave(String gameId) async {
    await _client.raw.post<dynamic>(
      '/api/v1/game/$gameId/leave',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
  }

  void _ensureSuccess(Response<dynamic> r) {
    final body = r.data;
    if (r.statusCode != null && r.statusCode! >= 200 && r.statusCode! < 300) {
      if (body is Map && body['success'] == true) return;
    }
    // Surface backend messages so the UI can show them.
    final err = (body is Map) ? body['error'] : null;
    String msg = 'حدث خطأ غير متوقع';
    bool cancelled = false;
    if (err is String) {
      msg = err;
    } else if (err is Map) {
      final m = err['message'];
      if (m is String) msg = m;
      cancelled = err['cancelled'] == true;
    } else if (err is List && err.isNotEmpty) {
      final first = err.first;
      if (first is Map && first['msg'] != null) msg = '${first['msg']}';
    }
    throw GameApiException(msg, cancelled: cancelled, statusCode: r.statusCode);
  }
}

class GameApiException implements Exception {
  GameApiException(this.message, {this.cancelled = false, this.statusCode});
  final String message;
  final bool cancelled;
  final int? statusCode;
  @override
  String toString() => message;
}
