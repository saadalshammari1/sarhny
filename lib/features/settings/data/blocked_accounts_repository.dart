import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/dto.dart';

class BlockedAccount {
  const BlockedAccount({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarPath,
    this.verified = false,
    this.blockedAt,
  });

  factory BlockedAccount.fromJson(Map<String, dynamic> json) => BlockedAccount(
        id: asInt(json['id']),
        username: '${json['username'] ?? ''}',
        displayName: '${json['display_name'] ?? json['username'] ?? ''}',
        avatarPath: json['avatar_path']?.toString(),
        verified: json['verified'] == true,
        blockedAt: json['blocked_at']?.toString(),
      );

  final int id;
  final String username;
  final String displayName;
  final String? avatarPath;
  final bool verified;
  final String? blockedAt;
}

class BlockedAccountsRepository {
  BlockedAccountsRepository(this._client);
  final DioClient _client;

  Future<List<BlockedAccount>> list() {
    return _client.request<List<BlockedAccount>>(
      () => _client.raw.get(ApiEndpoints.blocks),
      parser: (data) {
        final map = (data as Map).cast<String, dynamic>();
        final raw = (map['blocks'] as List?) ?? const [];
        return raw
            .whereType<Map>()
            .map((e) => BlockedAccount.fromJson(e.cast<String, dynamic>()))
            .toList();
      },
    );
  }

  Future<void> unblock(int userId) {
    return _client.request<void>(
      () => _client.raw.delete(ApiEndpoints.block(userId)),
      parser: (_) {},
    );
  }
}
