import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/dio_client.dart';
import '../../../core/providers/api_providers.dart';

/// Tiny client for /api/v1/game/random-question — the local vs-AI play
/// page hits this when the AI wins a match so it can "ask" the player
/// a real question pulled from the shared bank. Falls back to a hard-
/// coded local question if the network fails — the play loop never
/// blocks on the network.
class RandomQuestionRepo {
  RandomQuestionRepo(this._client);
  final DioClient _client;

  /// Pull one random active question for [mood]. Returns the question
  /// text, or [fallback] (a localized string supplied by the caller)
  /// when the API is unreachable.
  Future<String> fetch({String mood = 'light', String fallback = ''}) async {
    try {
      final r = await _client.raw.get<dynamic>(
        '/api/v1/game/random-question',
        queryParameters: {'mood': mood},
      );
      final data = (r.data as Map)['data'] as Map;
      final text = data['text']?.toString();
      if (text != null && text.isNotEmpty) return text;
    } catch (_) {/* network/parse failure → fall through */}
    return fallback;
  }
}

final randomQuestionRepoProvider = Provider<RandomQuestionRepo>((ref) {
  return RandomQuestionRepo(ref.read(dioClientProvider));
});
