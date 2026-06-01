import 'package:dio/dio.dart';

import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/storage/secure_storage.dart';

/// Result of a register/login attempt.
class AuthResult {
  const AuthResult({
    required this.accessToken,
    required this.accessTtlSeconds,
    required this.userId,
    required this.username,
    this.displayName,
  });

  final String accessToken;
  final int accessTtlSeconds;
  final int userId;
  final String username;
  final String? displayName;
}

class AuthRepository {
  AuthRepository(this._client, this._secure);
  final DioClient _client;
  final SecureStorage _secure;

  /// V2 login (form-encoded). On success: stores access token + user id,
  /// HttpOnly refresh cookie is auto-persisted via PersistCookieJar.
  Future<AuthResult> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    return _client.request<AuthResult>(
      () => _client.raw.post(
        ApiEndpoints.login,
        data: FormData.fromMap({
          'username': usernameOrEmail,
          'password': password,
        }),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      ),
      parser: (data) => _persist(data as Map),
    );
  }

  /// V2 register (form-encoded). Hard age-18 gate enforced by the backend.
  /// After success, we immediately call login() to mint the refresh cookie.
  Future<AuthResult> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String sex, // "male" | "female"
    required bool agreeAge18,
  }) async {
    await _client.request<void>(
      () => _client.raw.post(
        ApiEndpoints.register,
        data: FormData.fromMap({
          'name': name,
          'username': username,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'sex': sex,
          'agree_age_18': agreeAge18 ? 'true' : 'false',
        }),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      ),
      parser: (_) {},
    );
    return login(usernameOrEmail: username, password: password);
  }

  Future<void> logout() async {
    try {
      await _client.raw.post(ApiEndpoints.logout);
    } catch (_) {}
    await _secure.clear();
    await _client.clearCookies();
  }

  AuthResult _persist(Map data) {
    final access = '${data['access_token'] ?? ''}';
    final ttl = (data['access_ttl_seconds'] as num?)?.toInt() ?? 900;
    final user = (data['user'] is Map ? data['user'] as Map : const {});
    final uid = (user['id'] as num?)?.toInt() ?? 0;
    final username = '${user['username'] ?? ''}';
    final displayName = user['name']?.toString() ?? user['display_name']?.toString();
    // Refresh token lives in HttpOnly cookie — we store an empty placeholder
    // so SecureStorage.hasSession() still recognises an authenticated state
    // via the access token alone.
    _secure.writeTokens(
      accessToken: access,
      refreshToken: '',
      userId: uid,
      username: username,
    );
    return AuthResult(
      accessToken: access,
      accessTtlSeconds: ttl,
      userId: uid,
      username: username,
      displayName: displayName,
    );
  }
}
