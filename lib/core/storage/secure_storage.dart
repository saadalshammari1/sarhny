import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// تخزين آمن للـ JWT access + refresh tokens.
/// يستخدم Keychain على iOS و EncryptedSharedPreferences على Android.
class SecureStorage {
  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  final FlutterSecureStorage _storage;

  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kUserId = 'user_id';
  static const _kUsername = 'username';

  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
    int? userId,
    String? username,
  }) async {
    await _storage.write(key: _kAccessToken, value: accessToken);
    await _storage.write(key: _kRefreshToken, value: refreshToken);
    if (userId != null) {
      await _storage.write(key: _kUserId, value: userId.toString());
    }
    if (username != null) {
      await _storage.write(key: _kUsername, value: username);
    }
  }

  Future<String?> readAccessToken() => _storage.read(key: _kAccessToken);
  Future<String?> readRefreshToken() => _storage.read(key: _kRefreshToken);
  Future<String?> readUsername() => _storage.read(key: _kUsername);

  Future<int?> readUserId() async {
    final raw = await _storage.read(key: _kUserId);
    return raw == null ? null : int.tryParse(raw);
  }

  Future<bool> hasSession() async {
    final token = await readAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
    await _storage.delete(key: _kUserId);
    await _storage.delete(key: _kUsername);
  }
}
