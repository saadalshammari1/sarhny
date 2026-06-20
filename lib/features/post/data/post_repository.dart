import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/dto.dart';
import 'comment_dto.dart';

class PostRepository {
  PostRepository(this._client);
  final DioClient _client;

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

  Future<CommentsPageDto> listComments(int id, {int? cursor, int limit = 10}) {
    return _client.request<CommentsPageDto>(
      () => _client.raw.get(
        ApiEndpoints.postComments(id),
        queryParameters: {
          'limit': limit,
          if (cursor != null) 'cursor_id': cursor,
        },
      ),
      parser: (data) =>
          CommentsPageDto.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<AnonRepliesPageDto> listAnonReplies(int id,
      {int? cursor, int limit = 10}) {
    return _client.request<AnonRepliesPageDto>(
      () => _client.raw.get(
        ApiEndpoints.postReplies(id),
        queryParameters: {
          'limit': limit,
          if (cursor != null) 'cursor_id': cursor,
        },
      ),
      parser: (data) =>
          AnonRepliesPageDto.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<AnonReplyDto> createAnonReply(
    int postId, {
    required String message,
    required bool senderHidden,
    String mediaType = 'text',
    String? mediaRef,
  }) {
    return _client.request<AnonReplyDto>(
      () => _client.raw.post(
        ApiEndpoints.postReplies(postId),
        data: {
          'message': message,
          'is_sender_hidden': senderHidden,
          'media_type': mediaType,
          if (mediaRef != null) 'media_ref': mediaRef,
        },
      ),
      parser: (data) {
        final map = (data as Map);
        final reply = (map['reply'] is Map ? map['reply'] : map) as Map;
        return AnonReplyDto.fromJson(reply.cast<String, dynamic>());
      },
    );
  }

  Future<CommentDto> createComment(int postId, String body,
      {bool isAnonymous = false}) {
    return _client.request<CommentDto>(
      () => _client.raw.post(
        ApiEndpoints.comment,
        data: {
          'post_id': postId,
          'body': body,
          'is_anonymous': isAnonymous,
        },
      ),
      parser: (data) {
        final map = (data as Map);
        final c = (map['comment'] is Map ? map['comment'] : map) as Map;
        return CommentDto.fromJson(c.cast<String, dynamic>());
      },
    );
  }

  Future<void> deleteComment(int commentId) {
    return _client.request<void>(
      () => _client.raw.delete(ApiEndpoints.deleteComment(commentId)),
      parser: (_) {},
    );
  }

  /// Permanently delete a post the caller owns. Backend enforces
  /// ownership; non-owners get 403.
  Future<void> deletePost(int postId) {
    return _client.request<void>(
      () => _client.raw.delete(ApiEndpoints.postById(postId)),
      parser: (_) {},
    );
  }

  /// Soft-hide a reply. Backend allows BOTH the reply author and the
  /// post owner to call this — the client must check `reply.canDelete`
  /// before showing the trigger.
  Future<void> hideReply(int postId, int replyId) {
    return _client.request<void>(
      () => _client.raw.delete(ApiEndpoints.hideReply(postId, replyId)),
      parser: (_) {},
    );
  }

  Future<void> like(int postId) {
    return _client.request<void>(
      () =>
          _client.raw.post(ApiEndpoints.like, data: {'post_id': postId}),
      parser: (_) {},
    );
  }

  Future<void> unlike(int postId) {
    return _client.request<void>(
      () => _client.raw.delete(ApiEndpoints.unlike(postId)),
      parser: (_) {},
    );
  }

  Future<void> save(int postId) {
    return _client.request<void>(
      () =>
          _client.raw.post(ApiEndpoints.save, data: {'post_id': postId}),
      parser: (_) {},
    );
  }

  Future<SavedPostsPage> listSavedPosts({int? cursor, int limit = 10}) {
    return _client.request<SavedPostsPage>(
      () => _client.raw.get(
        ApiEndpoints.savedPosts,
        queryParameters: {
          'limit': limit,
          if (cursor != null) 'cursor_id': cursor,
        },
      ),
      parser: (data) {
        final map = (data as Map).cast<String, dynamic>();
        return SavedPostsPage(
          posts: (map['posts'] as List? ?? const [])
              .whereType<Map>()
              .map((e) => PostDto.fromJson(e.cast<String, dynamic>()))
              .toList(),
          nextCursor: (map['next_cursor'] as num?)?.toInt(),
        );
      },
    );
  }

  Future<void> unsave(int postId) {
    return _client.request<void>(
      () => _client.raw.delete(ApiEndpoints.unsave(postId)),
      parser: (_) {},
    );
  }
}

class SavedPostsPage {
  const SavedPostsPage({required this.posts, this.nextCursor});
  final List<PostDto> posts;
  final int? nextCursor;
}
