import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/dto.dart';

class NotificationsPage {
  NotificationsPage({required this.items, this.nextCursor});
  final List<NotificationDto> items;
  final int? nextCursor;
}

class NotificationsRepository {
  NotificationsRepository(this._client);
  final DioClient _client;

  Future<NotificationsPage> list({
    int? cursor,
    int limit = 20,
    bool onlyUnread = false,
  }) {
    return _client.request<NotificationsPage>(
      () => _client.raw.get(
        ApiEndpoints.notifications,
        queryParameters: {
          'limit': limit,
          if (onlyUnread) 'only_unread': true,
          if (cursor != null) 'cursor_id': cursor,
        },
      ),
      parser: (data) {
        final map = (data as Map).cast<String, dynamic>();
        return NotificationsPage(
          items: (map['items'] as List? ?? const [])
              .whereType<Map>()
              .map((e) => NotificationDto.fromJson(e.cast<String, dynamic>()))
              .toList(),
          nextCursor: (map['next_cursor'] as num?)?.toInt(),
        );
      },
    );
  }

  Future<int> markAllRead() {
    return _client.request<int>(
      () => _client.raw.post(ApiEndpoints.notificationsMarkRead),
      parser: (data) => (((data as Map)['marked_read'] ?? 0) as num).toInt(),
    );
  }

  Future<int> unreadCount() {
    return _client.request<int>(
      () => _client.raw.get(ApiEndpoints.notificationsUnreadCount),
      parser: (data) => (((data as Map)['unread'] ?? 0) as num).toInt(),
    );
  }

  Future<void> registerDevice(String fcmToken, {String platform = 'mobile'}) {
    return _client.request<void>(
      () => _client.raw.post(
        ApiEndpoints.devices,
        data: {'fcm_token': fcmToken, 'platform': platform},
      ),
      parser: (_) {},
    );
  }

  /// Fire-and-forget diagnostic ping so the server can see what stage the
  /// FCM flow reached on a release / TestFlight build. Failure is silent.
  Future<void> diagnostic({
    required String phase,
    required String status,
    String detail = '',
  }) async {
    try {
      await _client.raw.post(
        '${ApiEndpoints.devices}/diagnostic',
        data: {'phase': phase, 'status': status, 'detail': detail},
      );
    } catch (_) {/* never throws to caller */}
  }
}
