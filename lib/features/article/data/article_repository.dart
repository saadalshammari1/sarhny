import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';

class QuestionnaireQuestion {
  const QuestionnaireQuestion({required this.id, required this.text});
  final int id;
  final String text;
  factory QuestionnaireQuestion.fromJson(Map<String, dynamic> j) =>
      QuestionnaireQuestion(
        id: (j['id'] as num).toInt(),
        text: j['text']?.toString() ?? '',
      );
}

class QuestionnaireAnswer {
  const QuestionnaireAnswer({required this.questionId, required this.text});
  final int questionId;
  final String text;
  factory QuestionnaireAnswer.fromJson(Map<String, dynamic> j) =>
      QuestionnaireAnswer(
        questionId: (j['question_id'] as num).toInt(),
        text: j['answer_text']?.toString() ?? '',
      );
}

class QuestionnaireProgress {
  const QuestionnaireProgress({
    required this.answered,
    required this.total,
    required this.minRequired,
    required this.canGenerate,
    required this.cooldownDays,
    required this.daysRemaining,
    this.nextAvailableAt,
  });
  final int answered;
  final int total;
  final int minRequired;
  final bool canGenerate;
  final int cooldownDays;
  final int daysRemaining;
  final String? nextAvailableAt;
  factory QuestionnaireProgress.fromJson(Map<String, dynamic> j) =>
      QuestionnaireProgress(
        answered: (j['answered'] as num?)?.toInt() ?? 0,
        total: (j['total'] as num?)?.toInt() ?? 0,
        minRequired: (j['min_required'] as num?)?.toInt() ?? 30,
        canGenerate: j['can_generate'] == true,
        cooldownDays: (j['cooldown_days'] as num?)?.toInt() ?? 30,
        daysRemaining: (j['days_remaining'] as num?)?.toInt() ?? 0,
        nextAvailableAt: j['next_available_at']?.toString(),
      );
}

class UserArticle {
  const UserArticle({
    required this.content,
    required this.status,
    this.generatedAt,
    this.publishedAt,
    this.editedAt,
    this.editCount = 0,
  });
  final String content;
  final String status; // 'private' | 'published' | 'deleted'
  final String? generatedAt;
  final String? publishedAt;
  final String? editedAt;
  final int editCount;
  bool get isPrivate => status == 'private';
  bool get isPublished => status == 'published';
  factory UserArticle.fromJson(Map<String, dynamic> j) => UserArticle(
        content: j['content']?.toString() ?? '',
        status: j['status']?.toString() ?? 'private',
        generatedAt: j['generated_at']?.toString(),
        publishedAt: j['published_at']?.toString(),
        editedAt: j['edited_at']?.toString(),
        editCount: (j['edit_count'] as num?)?.toInt() ?? 0,
      );
}

class ArticleRepository {
  ArticleRepository(this._client);
  final DioClient _client;

  Future<List<QuestionnaireQuestion>> listQuestions() {
    return _client.request<List<QuestionnaireQuestion>>(
      () => _client.raw.get(ApiEndpoints.questionnaire),
      parser: (data) {
        final list = (data as Map?)?['questions'] as List? ?? const [];
        return list
            .whereType<Map>()
            .map((e) => QuestionnaireQuestion.fromJson(e.cast<String, dynamic>()))
            .toList();
      },
    );
  }

  Future<List<QuestionnaireAnswer>> myAnswers() {
    return _client.request<List<QuestionnaireAnswer>>(
      () => _client.raw.get(ApiEndpoints.questionnaireMe),
      parser: (data) {
        final list = (data as Map?)?['answers'] as List? ?? const [];
        return list
            .whereType<Map>()
            .map((e) => QuestionnaireAnswer.fromJson(e.cast<String, dynamic>()))
            .toList();
      },
    );
  }

  Future<QuestionnaireProgress> progress() {
    return _client.request<QuestionnaireProgress>(
      () => _client.raw.get(ApiEndpoints.questionnaireProgress),
      parser: (data) =>
          QuestionnaireProgress.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<void> upsertAnswer(int questionId, String text) {
    return _client.request<void>(
      () => _client.raw.post(
        ApiEndpoints.questionnaireAnswer,
        data: {'question_id': questionId, 'answer_text': text.trim()},
      ),
      parser: (_) {},
    );
  }

  Future<UserArticle> generate() {
    return _client.request<UserArticle>(
      () => _client.raw.post(ApiEndpoints.articleGenerate),
      parser: (data) => UserArticle.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<UserArticle?> myArticle() {
    return _client.request<UserArticle?>(
      () => _client.raw.get(ApiEndpoints.articleMe),
      parser: (data) {
        final a = (data as Map?)?['article'];
        if (a == null) return null;
        return UserArticle.fromJson((a as Map).cast<String, dynamic>());
      },
    );
  }

  Future<void> edit(String content) {
    return _client.request<void>(
      () => _client.raw.patch(
        ApiEndpoints.articleMe,
        data: {'content': content},
      ),
      parser: (_) {},
    );
  }

  Future<void> publish() {
    return _client.request<void>(
      () => _client.raw.post(ApiEndpoints.articlePublish),
      parser: (_) {},
    );
  }

  Future<void> deleteArticle() {
    return _client.request<void>(
      () => _client.raw.delete(ApiEndpoints.articleMe),
      parser: (_) {},
    );
  }
}
