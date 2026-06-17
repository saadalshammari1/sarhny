import 'package:dio/dio.dart';

import '../../../../core/api/dio_client.dart';
import '../domain/chat_preset.dart';
import '../domain/cosmetics.dart';
import '../domain/match_status.dart';

/// نتيجة الانضمام للطابور — إما matched فوراً أو في الطابور.
class CarromJoinResult {
  const CarromJoinResult({
    required this.matched,
    this.roomId,
    this.queuePosition,
  });
  final bool matched;
  final String? roomId;
  final int? queuePosition;
}

/// نتيجة إنشاء دعوة.
class CarromInviteResult {
  const CarromInviteResult({
    required this.inviteCode,
    required this.roomId,
    required this.expiresInSeconds,
  });
  final String inviteCode;
  final String roomId;
  final int expiresInSeconds;
}

/// Outcome of `/match/{id}/rematch` and `/match/{id}/rematch-status`.
class CarromRematchStatus {
  const CarromRematchStatus({
    required this.status,
    this.roomId,
    this.yourChoice,
    this.opponentChoice,
    this.windowSeconds,
  });

  /// pending | matched | declined | timeout (timeout is client-derived).
  final String status;
  final String? roomId;
  final String? yourChoice;
  final String? opponentChoice;
  final int? windowSeconds;

  factory CarromRematchStatus.fromJson(Map<String, dynamic> j) =>
      CarromRematchStatus(
        status: '${j['status'] ?? 'pending'}',
        roomId: j['room_id']?.toString(),
        yourChoice: j['your_choice']?.toString(),
        opponentChoice: j['opponent_choice']?.toString(),
        windowSeconds: (j['window_seconds'] as num?)?.toInt(),
      );
}

class CarromApiException implements Exception {
  CarromApiException(this.message, {this.code, this.statusCode});
  final String message;
  final String? code;
  final int? statusCode;
  @override
  String toString() => message;
}

/// REST client للـ Carrom — uses the shared DioClient (Bearer + refresh).
class CarromApi {
  CarromApi(this._client);
  final DioClient _client;

  static const _base = '/api/v1/carrom';

  Future<CarromWallet> wallet() async {
    final r = await _client.raw.get<dynamic>(
      '$_base/wallet',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensure(r);
    return CarromWallet.fromJson(_data(r));
  }

  Future<CarromJoinResult> join() async {
    final r = await _client.raw.post<dynamic>(
      '$_base/join',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensure(r);
    final data = _data(r);
    return CarromJoinResult(
      matched: data['matched'] == true,
      roomId: data['room_id']?.toString(),
      queuePosition: (data['queue_position'] as num?)?.toInt(),
    );
  }

  Future<CarromInviteResult> createInvite() async {
    final r = await _client.raw.post<dynamic>(
      '$_base/invite',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensure(r);
    final d = _data(r);
    return CarromInviteResult(
      inviteCode: '${d['invite_code']}',
      roomId: '${d['room_id']}',
      expiresInSeconds: (d['expires_in_seconds'] as num?)?.toInt() ?? 300,
    );
  }

  Future<String> redeemInvite(String code) async {
    final r = await _client.raw.post<dynamic>(
      '$_base/invite/$code',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensure(r);
    return '${_data(r)['room_id']}';
  }

  Future<void> cancel() async {
    final r = await _client.raw.post<dynamic>(
      '$_base/cancel',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensure(r);
  }

  /// POST same-opponent rematch intent. `action` is `accept` or `decline`.
  ///
  /// Returns a status object:
  ///   * `pending`  — waiting for the opponent
  ///   * `matched`  — both accepted; `roomId` is the new match
  ///   * `declined` — opponent (or you) declined
  Future<CarromRematchStatus> rematch(int matchId, String action) async {
    final r = await _client.raw.post<dynamic>(
      '$_base/match/$matchId/rematch',
      data: {'action': action},
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensure(r);
    return CarromRematchStatus.fromJson(_data(r));
  }

  /// Poll target for the rematch wait UI.
  Future<CarromRematchStatus> rematchStatus(int matchId) async {
    final r = await _client.raw.get<dynamic>(
      '$_base/match/$matchId/rematch-status',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensure(r);
    return CarromRematchStatus.fromJson(_data(r));
  }

  /// Post-game reveal action.
  ///
  /// [action] is either `"reveal"` (consensual mutual identity exposure) or
  /// `"hide"` (10-point spend to lock the reveal off). Server enforces the
  /// wallet charge and Redis intent storage.
  Future<({String action, int? balance})> revealAction(
    int matchId,
    String action,
  ) async {
    final r = await _client.raw.post<dynamic>(
      '$_base/match/$matchId/reveal',
      data: {'action': action},
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensure(r);
    final d = _data(r);
    return (
      action: '${d['action']}',
      balance: (d['balance'] as num?)?.toInt(),
    );
  }

  /// Fetch match state + opponent identity (only when both opted in).
  Future<CarromMatchStatus> matchStatus(int matchId) async {
    final r = await _client.raw.get<dynamic>(
      '$_base/match/$matchId',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensure(r);
    return CarromMatchStatus.fromJson(_data(r));
  }

  /// Send an anonymous "صراحة" message to the match's opponent.
  ///
  /// Backend re-uses the inbox pipeline + tags it with
  /// `media_meta = {source: "carrom_match", ref_match_id: <id>}`.
  Future<int> sendSarhnyToOpponent(int matchId, String message) async {
    final r = await _client.raw.post<dynamic>(
      '$_base/match/$matchId/send-sarhny',
      data: {'message': message},
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensure(r);
    return (_data(r)['inbox_id'] as num).toInt();
  }

  /// Recent wallet ledger entries (newest first).
  Future<({List<CarromLedgerEntry> entries, int currentBalance})>
      walletHistory({int limit = 20}) async {
    final r = await _client.raw.get<dynamic>(
      '$_base/wallet/history',
      queryParameters: {'limit': limit},
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensure(r);
    final d = _data(r);
    final list = ((d['entries'] as List?) ?? const [])
        .map((e) => CarromLedgerEntry.fromJson((e as Map).cast<String, dynamic>()))
        .toList(growable: false);
    return (
      entries: list,
      currentBalance: (d['current_balance'] as num?)?.toInt() ?? 0,
    );
  }

  /// chat-presets — caller should cache the result (it rarely changes).
  Future<({List<CarromChatPreset> presets, int cooldownSeconds})>
      chatPresets() async {
    final r = await _client.raw.get<dynamic>(
      '$_base/chat-presets',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensure(r);
    final d = _data(r);
    final raw = (d['presets'] as Map?)?.cast<String, dynamic>() ?? const {};
    final presets = raw.entries
        .map((e) => CarromChatPreset.fromJson(
              e.key,
              (e.value as Map).cast<String, dynamic>(),
            ))
        .toList(growable: false);
    return (
      presets: presets,
      cooldownSeconds: (d['cooldown_seconds'] as num?)?.toInt() ?? 3,
    );
  }

  /// Forward an AdMob SSV callback to the backend.
  ///
  /// [ssvQuery] is the full query string from the AdMob SSV callback URL —
  /// everything after the `?`. The backend re-verifies the signature
  /// against Google's published verifier keys before crediting.
  Future<AdGrantResult> grantAdReward(String ssvQuery) async {
    final r = await _client.raw.post<dynamic>(
      '/api/v1/games/ad/grant',
      data: {'ssv_query': ssvQuery},
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensure(r);
    final d = _data(r);
    return AdGrantResult(
      credited: (d['credited'] as num?)?.toInt() ?? 0,
      balance: (d['balance'] as num?)?.toInt() ?? 0,
      remainingToday: (d['remaining_today'] as num?)?.toInt() ?? 0,
    );
  }

  // ── Cosmetics ───────────────────────────────────────────────────────

  /// جلب الكاتالوج الكامل + الاختيار الحالي.
  Future<CosmeticsResponse> getCosmetics() async {
    final r = await _client.raw.get<dynamic>(
      '$_base/cosmetics',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensure(r);
    return CosmeticsResponse.fromJson(_data(r));
  }

  /// تحديث جزئي للاختيار. أي parameter == null = لا تغيير.
  ///
  /// السيرفر يردّ بالـ selection الجديدة فنحدّث الـ state محلياً بدون
  /// GET إضافي.
  Future<UserCosmetics> updateCosmetics({
    String? boardSkin,
    String? pieceSkin,
    String? strikerSkin,
  }) async {
    final body = <String, dynamic>{};
    if (boardSkin != null) body['board_skin'] = boardSkin;
    if (pieceSkin != null) body['piece_skin'] = pieceSkin;
    if (strikerSkin != null) body['striker_skin'] = strikerSkin;
    final r = await _client.raw.put<dynamic>(
      '$_base/cosmetics',
      data: body,
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensure(r);
    return UserCosmetics.fromJson(_data(r));
  }

  /// Daily cap state for the rewarded-ad button.
  Future<AdQuotaInfo> adQuota() async {
    final r = await _client.raw.get<dynamic>(
      '/api/v1/games/ad/quota',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensure(r);
    final d = _data(r);
    return AdQuotaInfo(
      usedToday: (d['used_today'] as num?)?.toInt() ?? 0,
      dailyCap: (d['daily_cap'] as num?)?.toInt() ?? 10,
      remaining: (d['remaining'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> _data(Response<dynamic> r) =>
      ((r.data as Map)['data'] as Map).cast<String, dynamic>();

  void _ensure(Response<dynamic> r) {
    final body = r.data;
    final ok = r.statusCode != null &&
        r.statusCode! >= 200 &&
        r.statusCode! < 300 &&
        body is Map &&
        body['success'] == true;
    if (ok) return;
    final err = (body is Map) ? body['error'] : null;
    String message = 'تعذّر تنفيذ الطلب';
    String? code;
    if (err is String) {
      message = err;
    } else if (err is Map) {
      message = '${err['message'] ?? message}';
      code = err['code']?.toString();
    }
    throw CarromApiException(
      message,
      code: code,
      statusCode: r.statusCode,
    );
  }
}
