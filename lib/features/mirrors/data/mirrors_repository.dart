import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';
import 'mirror_dto.dart';

class MirrorsRepository {
  MirrorsRepository(this._client);
  final DioClient _client;

  Future<List<MirrorDto>> listMine() {
    return _client.request<List<MirrorDto>>(
      () => _client.raw.get(ApiEndpoints.mirrorsMe),
      parser: (data) => ((data as Map)['mirrors'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => MirrorDto.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }

  Future<PublicMirrorDto> getPublic(String token) {
    return _client.request<PublicMirrorDto>(
      () => _client.raw.get(ApiEndpoints.publicMirror(token)),
      parser: (data) =>
          PublicMirrorDto.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<int> respondAuthed(String token, String responseText) {
    return _client.request<int>(
      () => _client.raw.post(
        ApiEndpoints.mirrorRespondAuthed(token),
        data: {'response_text': responseText},
      ),
      parser: (data) =>
          (((data as Map)['extracted_words'] ?? 0) as num).toInt(),
    );
  }

  Future<MirrorDto> create(String questionText) {
    return _client.request<MirrorDto>(
      () => _client.raw.post(
        ApiEndpoints.mirrors,
        data: {'question_text': questionText},
      ),
      parser: (data) {
        final m = (data as Map)['mirror'] as Map;
        return MirrorDto.fromJson(m.cast<String, dynamic>());
      },
    );
  }
}
