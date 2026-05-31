import 'dart:io';

import 'package:dio/dio.dart';

import '../api/api_endpoints.dart';
import '../api/dio_client.dart';

/// Shared uploader for inbox/reply media (voice + image). Used by anon replies,
/// inbox composer, etc. Returns the stored path the caller stitches into the
/// message payload as `media_ref`.
class UploadRepository {
  UploadRepository(this._client);
  final DioClient _client;

  Future<String> uploadVoice(File file, {int? durationSeconds}) {
    return _client.request<String>(
      () => _client.raw.post(
        ApiEndpoints.uploadsVoice,
        data: FormData.fromMap({
          'audio': MultipartFile.fromFileSync(
            file.path,
            filename: file.path.split(Platform.pathSeparator).last,
          ),
          if (durationSeconds != null) 'duration_s': durationSeconds,
        }),
      ),
      parser: (data) => '${(data as Map)['path'] ?? ''}',
    );
  }

  Future<String> uploadImage(File file) {
    return _client.request<String>(
      () => _client.raw.post(
        ApiEndpoints.uploadsImage,
        data: FormData.fromMap({
          'image': MultipartFile.fromFileSync(
            file.path,
            filename: file.path.split(Platform.pathSeparator).last,
          ),
        }),
      ),
      parser: (data) => '${(data as Map)['path'] ?? ''}',
    );
  }
}
