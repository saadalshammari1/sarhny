import '../../../../core/api/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';
import 'ludo_api.dart';
import 'ludo_ws_client.dart';

/// Facade على REST + WebSocket — يفصل الـ UI عن تفاصيل الـ transport.
class LudoRepository {
  LudoRepository({
    required this.api,
    required this.dioClient,
    required this.secureStorage,
  });

  final LudoApi api;
  final DioClient dioClient;
  final SecureStorage secureStorage;

  /// يفتح WS لغرفة محددة. مسؤول الـ caller أن يستدعي dispose().
  LudoWsClient openRoom(String roomId) {
    return LudoWsClient(
      httpBaseUrl: dioClient.raw.options.baseUrl,
      roomId: roomId,
      secureStorage: secureStorage,
    );
  }
}
