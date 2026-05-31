import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';

class PasswordResetRepository {
  PasswordResetRepository(this._client);
  final DioClient _client;

  Future<void> requestReset(String email) {
    return _client.request<void>(
      () => _client.raw.post(
        ApiEndpoints.passwordReset,
        data: {'email': email},
      ),
      parser: (_) {},
    );
  }

  Future<void> confirmReset({
    required String token,
    required String newPassword,
  }) {
    return _client.request<void>(
      () => _client.raw.post(
        ApiEndpoints.passwordResetConfirm,
        data: {
          'token': token,
          'new_password': newPassword,
        },
      ),
      parser: (_) {},
    );
  }
}
