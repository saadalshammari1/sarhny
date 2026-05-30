import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/dto.dart';

class ComposeRepository {
  ComposeRepository(this._client);
  final DioClient _client;

  Future<String> uploadImage(File file) {
    return _client.request<String>(
      () => _client.raw.post(
        ApiEndpoints.postsUploadImage,
        data: FormData.fromMap({
          'image': MultipartFile.fromFileSync(
            file.path,
            filename: file.path.split(Platform.pathSeparator).last,
          ),
        }),
      ),
      parser: (data) => '${(data as Map)['path']}',
    );
  }

  Future<PostDto> createPost({
    required String section,
    required String layer1,
    List<String> images = const [],
    String? layer3,
  }) {
    final body = <String, dynamic>{
      'section': section,
      'layer1': layer1,
      if (images.isNotEmpty)
        'layer2': {
          'content_type': 'image',
          'content_body': '',
          'media_refs': images,
        },
      if (layer3 != null && layer3.isNotEmpty)
        'layer3': {'content_type': 'article', 'content_body': layer3},
    };
    return _client.request<PostDto>(
      () => _client.raw.post(ApiEndpoints.posts, data: body),
      parser: (data) {
        final map = (data as Map);
        final post = (map['post'] is Map ? map['post'] : map) as Map;
        return PostDto.fromJson(post.cast<String, dynamic>());
      },
    );
  }
}
