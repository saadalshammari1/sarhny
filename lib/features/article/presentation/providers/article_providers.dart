import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/api_providers.dart';
import '../../data/article_repository.dart';

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return ArticleRepository(ref.watch(dioClientProvider));
});

final questionnaireQuestionsProvider =
    FutureProvider<List<QuestionnaireQuestion>>((ref) async {
  return ref.read(articleRepositoryProvider).listQuestions();
});

final questionnaireProgressProvider =
    FutureProvider<QuestionnaireProgress>((ref) async {
  return ref.read(articleRepositoryProvider).progress();
});

final questionnaireMyAnswersProvider =
    FutureProvider<Map<int, String>>((ref) async {
  final list = await ref.read(articleRepositoryProvider).myAnswers();
  return {for (final a in list) a.questionId: a.text};
});

final myArticleProvider = FutureProvider<UserArticle?>((ref) async {
  return ref.read(articleRepositoryProvider).myArticle();
});
