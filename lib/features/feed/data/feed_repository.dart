import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/dto.dart';

enum FeedScope { global, following }

class FeedRepository {
  FeedRepository(this._client);
  final DioClient _client;

  Future<FeedPageDto> fetch({
    required FeedScope scope,
    required String section,
    FeedCursor? cursor,
    int limit = 10,
  }) {
    final url = scope == FeedScope.global
        ? ApiEndpoints.feedGlobal
        : ApiEndpoints.feedFollowing;
    final query = <String, dynamic>{
      'section': section,
      'limit': limit,
      if (cursor != null) 'cursor_id': cursor.id,
      if (cursor != null && cursor.gravity != null && scope == FeedScope.global)
        'cursor_gravity': cursor.gravity,
    };
    return _client.request<FeedPageDto>(
      () => _client.raw.get(url, queryParameters: query),
      parser: (data) =>
          FeedPageDto.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<PostDto> getPost(int id) {
    return _client.request<PostDto>(
      () => _client.raw.get(ApiEndpoints.postById(id)),
      parser: (data) {
        final map = (data as Map).cast<String, dynamic>();
        final post = (map['post'] is Map ? map['post'] : map) as Map;
        return PostDto.fromJson(post.cast<String, dynamic>());
      },
    );
  }
}
