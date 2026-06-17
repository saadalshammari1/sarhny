import '../../../../core/api/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';
import 'carrom_api.dart';
import 'carrom_ws_client.dart';

/// Facade على REST + WebSocket — يفصل الـ UI عن تفاصيل الـ transport.
class CarromRepository {
  CarromRepository({
    required this.api,
    required this.dioClient,
    required this.secureStorage,
  });

  final CarromApi api;
  final DioClient dioClient;
  final SecureStorage secureStorage;

  /// يفتح WS لغرفة محددة. مسؤول الـ caller أن يستدعي dispose().
  CarromWsClient openRoom(String roomId) {
    return CarromWsClient(
      httpBaseUrl: dioClient.raw.options.baseUrl,
      roomId: roomId,
      secureStorage: secureStorage,
    );
  }
}
