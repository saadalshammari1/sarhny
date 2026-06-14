import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/api_providers.dart';
import '../../data/article_repository.dart';

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return ArticleRepository(ref.watch(dioClientProvider));
});

/// Eligibility = single source of truth for the article landing card.
/// Determines whether to show the "Generate" button, the cooldown
/// countdown, or the "answer more first" empty state.
final articleEligibilityProvider =
    FutureProvider<ArticleEligibility>((ref) async {
  return ref.read(articleRepositoryProvider).eligibility();
});

final myArticleProvider = FutureProvider<UserArticle?>((ref) async {
  return ref.read(articleRepositoryProvider).myArticle();
});

final articleHistoryProvider =
    FutureProvider<List<ArticleHistoryItem>>((ref) async {
  return ref.read(articleRepositoryProvider).history();
});
