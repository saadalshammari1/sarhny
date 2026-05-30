import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';

class SettingsRepository {
  SettingsRepository(this._client);
  final DioClient _client;

  Future<Map<String, dynamic>> read() {
    return _client.request<Map<String, dynamic>>(
      () => _client.raw.get(ApiEndpoints.settings),
      parser: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  Future<void> updateAccount({String? email, String? phone}) {
    return _client.request<void>(
      () => _client.raw.put(
        ApiEndpoints.settingsAccount,
        data: {
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
        },
      ),
      parser: (_) {},
    );
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _client.request<void>(
      () => _client.raw.put(
        ApiEndpoints.settingsPassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      ),
      parser: (_) {},
    );
  }

  Future<void> updatePrivacy(Map<String, dynamic> mutation) {
    return _client.request<void>(
      () => _client.raw.put(ApiEndpoints.settingsPrivacy, data: mutation),
      parser: (_) {},
    );
  }

  Future<void> updateNotifications(Map<String, dynamic> mutation) {
    return _client.request<void>(
      () => _client.raw.put(ApiEndpoints.settingsNotifications, data: mutation),
      parser: (_) {},
    );
  }

  Future<void> updateAnonymousPolicy(String policy) {
    return _client.request<void>(
      () => _client.raw.put(
        ApiEndpoints.settingsAnonymous,
        data: {'policy': policy},
      ),
      parser: (_) {},
    );
  }

  Future<void> updateTheme(String mode) {
    return _client.request<void>(
      () => _client.raw.put(
        ApiEndpoints.settingsTheme,
        data: {'mode': mode},
      ),
      parser: (_) {},
    );
  }

  Future<void> deactivate() {
    return _client.request<void>(
      () => _client.raw.post(
        '/api/v1/settings/deactivate',
        data: {'confirm': true},
      ),
      parser: (_) {},
    );
  }

  Future<void> deleteAccount({required String password}) {
    return _client.request<void>(
      () => _client.raw.delete(
        ApiEndpoints.settingsDeleteAccount,
        data: {'password': password, 'confirm': true},
      ),
      parser: (_) {},
    );
  }
}
