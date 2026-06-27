import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/generated/app_localizations.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/providers/api_providers.dart';
import '../domain/xo_state.dart';

/// Internal XO error codes emitted by the controller/repository map to
/// localized text; any other value (e.g. a server-supplied message) is
/// shown verbatim.
String xoErrorMessage(String error, AppLocalizations l) {
  switch (error) {
    case 'xo_state_failed':
    case 'xo_op_failed':
    case 'xo_request_failed':
    case 'xo_bad_response':
      return l.errorUnexpected;
    default:
      return error;
  }
}

class XoApiException implements Exception {
  XoApiException(this.message, {this.status});
  final String message;
  final int? status;
  @override
  String toString() => 'XoApiException($status: $message)';
}

class XoRepository {
  XoRepository(this._client);
  final DioClient _client;

  static const String _base = '/api/v1/xo';

  void _ensureSuccess(Response<dynamic> r) {
    if (r.data is! Map) {
      throw XoApiException('xo_bad_response', status: r.statusCode);
    }
    final map = r.data as Map;
    if (map['success'] != true) {
      final detail = map['error'] ?? map['detail'];
      final msg = detail is Map ? (detail['message'] ?? detail['error']) : detail;
      throw XoApiException(
        msg?.toString() ?? 'xo_request_failed',
        status: r.statusCode,
      );
    }
  }

  XoSnapshot _extract(Response<dynamic> r) {
    _ensureSuccess(r);
    final state = ((r.data as Map)['data'] as Map)['state'] as Map;
    return XoSnapshot.fromJson(state.cast<String, dynamic>());
  }

  Future<({XoSnapshot snapshot, bool waiting})> join({
    required String mood,
    String? inviteCode,
    bool createInvite = false,
  }) async {
    final r = await _client.raw.post<dynamic>(
      '$_base/join',
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
      snapshot:
          XoSnapshot.fromJson(((data['state'] ?? {}) as Map).cast<String, dynamic>()),
      waiting: data['waiting'] == true,
    );
  }

  Future<XoSnapshot> state(String gameId) async {
    final r = await _client.raw.get<dynamic>(
      '$_base/$gameId/state',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    return _extract(r);
  }

  Future<XoSnapshot> move(String gameId, int row, int col) async {
    final r = await _client.raw.post<dynamic>(
      '$_base/$gameId/move',
      data: {'row': row, 'col': col},
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    return _extract(r);
  }

  Future<XoSnapshot> winnerQuestion(String gameId, String? text) async {
    final r = await _client.raw.post<dynamic>(
      '$_base/$gameId/winner-question',
      data: {'text': text},
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    return _extract(r);
  }

  Future<XoSnapshot> answer(String gameId, String text) async {
    final r = await _client.raw.post<dynamic>(
      '$_base/$gameId/answer',
      data: {'text': text},
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    return _extract(r);
  }

  Future<XoSnapshot> skip(String gameId) async {
    final r = await _client.raw.post<dynamic>(
      '$_base/$gameId/skip',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    return _extract(r);
  }

  /// Abstain — call AFTER the AdMob rewarded ad finished AND the
  /// /games/ad/grant flow credited the wallet. Pass the ad's
  /// transaction_id (returned by /grant) as `adToken`.
  Future<XoSnapshot> abstain(String gameId, String adToken) async {
    final r = await _client.raw.post<dynamic>(
      '$_base/$gameId/abstain',
      data: {'ad_token': adToken},
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    return _extract(r);
  }

  Future<void> leave(String gameId) async {
    await _client.raw.post<dynamic>(
      '$_base/$gameId/leave',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
  }

  Future<RematchResult> rematch(String gameId, {required bool accept}) async {
    final r = await _client.raw.post<dynamic>(
      '$_base/$gameId/rematch',
      data: {'accept': accept},
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensureSuccess(r);
    final data = (r.data as Map)['data'] as Map;
    return RematchResult.fromJson(data.cast<String, dynamic>());
  }

  Future<RematchResult> rematchStatus(String gameId) async {
    final r = await _client.raw.get<dynamic>(
      '$_base/$gameId/rematch-status',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensureSuccess(r);
    final data = (r.data as Map)['data'] as Map;
    return RematchResult.fromJson(data.cast<String, dynamic>());
  }

  Future<void> cancelQueue(String mood) async {
    await _client.raw.post<dynamic>(
      '$_base/cancel',
      data: {'mood': mood},
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
  }
}

/// Discriminated result for /rematch + /rematch-status — `phase` is the
/// state machine value; `newGameId` + `state` are populated only when
/// `phase == "ready"`.
class RematchResult {
  RematchResult({required this.phase, this.newGameId, this.snapshot});
  final String phase; // none | waiting | ready | declined | timeout
  final String? newGameId;
  final XoSnapshot? snapshot;

  factory RematchResult.fromJson(Map<String, dynamic> j) {
    XoSnapshot? snap;
    final stateJson = j['state'];
    if (stateJson is Map) {
      snap = XoSnapshot.fromJson(stateJson.cast<String, dynamic>());
    }
    return RematchResult(
      phase: j['phase']?.toString() ?? 'none',
      newGameId: j['new_game_id']?.toString(),
      snapshot: snap,
    );
  }
}

final xoRepositoryProvider = Provider<XoRepository>((ref) {
  return XoRepository(ref.read(dioClientProvider));
});
