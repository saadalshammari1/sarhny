import 'package:dio/dio.dart';

import '../../../../core/api/dio_client.dart';
import '../domain/ludo_chat_preset.dart';
import '../domain/ludo_state.dart';

/// نتيجة الانضمام للطابور — إما matched فوراً أو في الطابور.
class LudoJoinResult {
  const LudoJoinResult({
    required this.matched,
    this.roomId,
    this.queuePosition,
  });
  final bool matched;
  final String? roomId;
  final int? queuePosition;
}

/// نتيجة إنشاء دعوة.
class LudoInviteResult {
  const LudoInviteResult({
    required this.inviteCode,
    required this.roomId,
    required this.expiresInSeconds,
  });
  final String inviteCode;
  final String roomId;
  final int expiresInSeconds;
}

/// نتيجة قبول دعوة.
class LudoInviteRedeem {
  const LudoInviteRedeem({
    required this.matched,
    required this.roomId,
    required this.yourSeat,
  });
  final bool matched;
  final String roomId;
  final int yourSeat;
}

class LudoApiException implements Exception {
  LudoApiException(this.message, {this.code, this.statusCode});
  final String message;
  final String? code;
  final int? statusCode;
  @override
  String toString() => message;
}

/// REST client لـ Ludo — uses the shared DioClient (Bearer + refresh).
class LudoApi {
  LudoApi(this._client);
  final DioClient _client;

  static const _base = '/api/v1/ludo';

  Future<LudoWallet> wallet() async {
    final r = await _client.raw.get<dynamic>(
      '$_base/wallet',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensure(r);
    return LudoWallet.fromJson(_data(r));
  }

  Future<LudoJoinResult> join(LudoMode mode) async {
    final r = await _client.raw.post<dynamic>(
      '$_base/join',
      data: {'mode': mode.wire},
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensure(r);
    final data = _data(r);
    return LudoJoinResult(
      matched: data['matched'] == true,
      roomId: data['room_id']?.toString(),
      queuePosition: (data['queue_position'] as num?)?.toInt(),
    );
  }

  Future<LudoInviteResult> createInvite(LudoMode mode) async {
    final r = await _client.raw.post<dynamic>(
      '$_base/invite',
      data: {'mode': mode.wire},
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensure(r);
    final d = _data(r);
    return LudoInviteResult(
      inviteCode: '${d['invite_code']}',
      roomId: '${d['room_id']}',
      expiresInSeconds: (d['expires_in_seconds'] as num?)?.toInt() ?? 300,
    );
  }

  Future<LudoInviteRedeem> redeemInvite(String code) async {
    final r = await _client.raw.post<dynamic>(
      '$_base/invite/$code',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensure(r);
    final d = _data(r);
    return LudoInviteRedeem(
      matched: d['matched'] == true,
      roomId: '${d['room_id'] ?? ''}',
      yourSeat: (d['your_seat'] as num?)?.toInt() ?? 0,
    );
  }

  Future<void> cancel() async {
    final r = await _client.raw.post<dynamic>(
      '$_base/cancel',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensure(r);
  }

  /// chat-presets — caller should cache the result (it rarely changes).
  Future<({List<LudoChatPreset> presets, int cooldownSeconds})>
      chatPresets() async {
    final r = await _client.raw.get<dynamic>(
      '$_base/chat-presets',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    _ensure(r);
    final d = _data(r);
    final raw = (d['presets'] as Map?)?.cast<String, dynamic>() ?? const {};
    final presets = raw.entries
        .map((e) => LudoChatPreset.fromJson(
              e.key,
              (e.value as Map).cast<String, dynamic>(),
            ))
        .toList(growable: false);
    return (
      presets: presets,
      cooldownSeconds: (d['cooldown_seconds'] as num?)?.toInt() ?? 3,
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
    throw LudoApiException(
      message,
      code: code,
      statusCode: r.statusCode,
    );
  }
}
