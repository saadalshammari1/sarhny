import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/dto.dart';

class InboxPageDto {
  InboxPageDto({required this.items, this.nextCursor, this.statusFilter});
  final List<InboxItemDto> items;
  final int? nextCursor;
  final String? statusFilter;
}

class InboxRepository {
  InboxRepository(this._client);
  final DioClient _client;

  Future<InboxPageDto> list({String status = 'all', int? cursor, int limit = 20}) {
    return _client.request<InboxPageDto>(
      () => _client.raw.get(
        ApiEndpoints.inbox,
        queryParameters: {
          'status': status,
          'limit': limit,
          if (cursor != null) 'cursor_id': cursor,
        },
      ),
      parser: (data) {
        final map = (data as Map).cast<String, dynamic>();
        return InboxPageDto(
          items: (map['items'] as List? ?? const [])
              .whereType<Map>()
              .map((e) => InboxItemDto.fromJson(e.cast<String, dynamic>()))
              .toList(),
          nextCursor: (map['next_cursor'] as num?)?.toInt(),
          statusFilter: map['status_filter']?.toString(),
        );
      },
    );
  }

  Future<void> markRead(int id) {
    return _client.request<void>(
      () => _client.raw.post(ApiEndpoints.inboxRead(id)),
      parser: (_) {},
    );
  }

  Future<void> delete(int id) {
    return _client.request<void>(
      () => _client.raw.delete(ApiEndpoints.inboxDelete(id)),
      parser: (_) {},
    );
  }

  Future<void> report(int id) {
    return _client.request<void>(
      () => _client.raw.post(ApiEndpoints.inboxReport(id)),
      parser: (_) {},
    );
  }

  Future<int> answer(int id, {required String body, String? layer3}) {
    return _client.request<int>(
      () => _client.raw.post(
        ApiEndpoints.inboxAnswer(id),
        data: {
          'body': body,
          if (layer3 != null && layer3.isNotEmpty) 'layer3': layer3,
        },
      ),
      parser: (data) =>
          (((data as Map)['v2_post_id'] ?? 0) as num).toInt(),
    );
  }
}
