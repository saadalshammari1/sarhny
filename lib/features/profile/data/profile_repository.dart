import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/dto.dart';

class ProfilePostsPage {
  ProfilePostsPage({required this.posts, this.nextCursor});
  final List<PostDto> posts;
  final int? nextCursor;
}

class ProfileRepository {
  ProfileRepository(this._client);
  final DioClient _client;

  Future<PublicProfileDto> get(String username) {
    return _client.request<PublicProfileDto>(
      () => _client.raw.get(ApiEndpoints.publicProfile(username)),
      parser: (data) =>
          PublicProfileDto.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<ProfilePostsPage> listCrystals(String username,
      {int? cursor, int limit = 20}) {
    return _listSection(
      ApiEndpoints.profileCrystals(username),
      cursor: cursor,
      limit: limit,
    );
  }

  Future<ProfilePostsPage> listActive(String username,
      {int? cursor, int limit = 20}) {
    return _listSection(
      ApiEndpoints.profileActive(username),
      cursor: cursor,
      limit: limit,
    );
  }

  Future<ProfilePostsPage> listLikes(String username,
      {int? cursor, int limit = 20}) {
    return _listSection(
      ApiEndpoints.profileLikes(username),
      cursor: cursor,
      limit: limit,
    );
  }

  Future<ProfilePostsPage> _listSection(String url,
      {int? cursor, int limit = 20}) {
    return _client.request<ProfilePostsPage>(
      () => _client.raw.get(
        url,
        queryParameters: {
          'limit': limit,
          if (cursor != null) 'cursor_id': cursor,
        },
      ),
      parser: (data) {
        final map = (data as Map).cast<String, dynamic>();
        final posts = (map['posts'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => PostDto.fromJson(e.cast<String, dynamic>()))
            .toList();
        return ProfilePostsPage(
          posts: posts,
          nextCursor: (map['next_cursor'] as num?)?.toInt(),
        );
      },
    );
  }

  Future<void> follow(int userId) {
    return _client.request<void>(
      () => _client.raw.post(ApiEndpoints.follow(userId)),
      parser: (_) {},
    );
  }

  Future<void> unfollow(int userId) {
    return _client.request<void>(
      () => _client.raw.delete(ApiEndpoints.follow(userId)),
      parser: (_) {},
    );
  }

  Future<void> editProfile({
    String? displayName,
    String? bio,
    String? location,
    String? website,
    String? coverColor,
  }) {
    return _client.request<void>(
      () => _client.raw.put(
        ApiEndpoints.profileEdit,
        data: {
          if (displayName != null) 'display_name': displayName,
          if (bio != null) 'bio': bio,
          if (location != null) 'location': location,
          if (website != null) 'website': website,
          if (coverColor != null) 'cover_color': coverColor,
        },
      ),
      parser: (_) {},
    );
  }

  Future<String> uploadAvatar(File file) {
    return _client.request<String>(
      () => _client.raw.post(
        ApiEndpoints.profileAvatar,
        data: FormData.fromMap({
          'avatar': MultipartFile.fromFileSync(
            file.path,
            filename: file.path.split(Platform.pathSeparator).last,
          ),
        }),
      ),
      parser: (data) => '${(data as Map)['path'] ?? ''}',
    );
  }

  Future<String> uploadCover(File file) {
    return _client.request<String>(
      () => _client.raw.post(
        ApiEndpoints.profileCover,
        data: FormData.fromMap({
          'cover': MultipartFile.fromFileSync(
            file.path,
            filename: file.path.split(Platform.pathSeparator).last,
          ),
        }),
      ),
      parser: (data) => '${(data as Map)['path'] ?? ''}',
    );
  }

  Future<void> changeUsername(String username) {
    return _client.request<void>(
      () => _client.raw.put(
        ApiEndpoints.profileUsername,
        data: {'username': username},
      ),
      parser: (_) {},
    );
  }

  Future<void> sendAnonymous({
    required String recipientUsername,
    required String message,
    String mediaType = 'text',
    String? mediaRef,
  }) {
    return _client.request<void>(
      () => _client.raw.post(
        ApiEndpoints.anonymousSend,
        data: {
          'recipient_username': recipientUsername,
          'message': message,
          'media_type': mediaType,
          if (mediaRef != null) 'media_ref': mediaRef,
        },
      ),
      parser: (_) {},
    );
  }
}
