import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';

/// Tells the client whether the user qualifies to generate an article
/// + how many real Q&A answers they have + cooldown countdown.
class ArticleEligibility {
  const ArticleEligibility({
    required this.realAnswersCount,
    required this.minRequired,
    required this.cooldownDays,
    required this.daysRemaining,
    required this.canGenerate,
    required this.hasArticle,
    this.nextAvailableAt,
  });
  final int realAnswersCount;
  final int minRequired;
  final int cooldownDays;
  final int daysRemaining;
  final bool canGenerate;
  final bool hasArticle;
  final String? nextAvailableAt;
  factory ArticleEligibility.fromJson(Map<String, dynamic> j) =>
      ArticleEligibility(
        realAnswersCount: (j['real_answers_count'] as num?)?.toInt() ?? 0,
        minRequired: (j['min_required'] as num?)?.toInt() ?? 15,
        cooldownDays: (j['cooldown_days'] as num?)?.toInt() ?? 30,
        daysRemaining: (j['days_remaining'] as num?)?.toInt() ?? 0,
        canGenerate: j['can_generate'] == true,
        hasArticle: j['has_article'] == true,
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

class ArticleHistoryItem {
  const ArticleHistoryItem({
    required this.id,
    required this.content,
    this.generatedAt,
    this.archivedAt,
    this.wasPublished = false,
  });
  final int id;
  final String content;
  final String? generatedAt;
  final String? archivedAt;
  final bool wasPublished;
  factory ArticleHistoryItem.fromJson(Map<String, dynamic> j) =>
      ArticleHistoryItem(
        id: (j['id'] as num).toInt(),
        content: j['content']?.toString() ?? '',
        generatedAt: j['generated_at']?.toString(),
        archivedAt: j['archived_at']?.toString(),
        wasPublished: j['was_published'] == true,
      );
}

class ArticleRepository {
  ArticleRepository(this._client);
  final DioClient _client;

  Future<ArticleEligibility> eligibility() {
    return _client.request<ArticleEligibility>(
      () => _client.raw.get(ApiEndpoints.articleEligibility),
      parser: (data) =>
          ArticleEligibility.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<UserArticle> generate() {
    return _client.request<UserArticle>(
      () => _client.raw.post(ApiEndpoints.articleGenerate),
      parser: (data) =>
          UserArticle.fromJson((data as Map).cast<String, dynamic>()),
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

  Future<List<ArticleHistoryItem>> history() {
    return _client.request<List<ArticleHistoryItem>>(
      () => _client.raw.get(ApiEndpoints.articleHistory),
      parser: (data) {
        final list = (data as Map?)?['history'] as List? ?? const [];
        return list
            .whereType<Map>()
            .map((e) =>
                ArticleHistoryItem.fromJson(e.cast<String, dynamic>()))
            .toList();
      },
    );
  }

  Future<void> deleteHistory(int id) {
    return _client.request<void>(
      () => _client.raw.delete(ApiEndpoints.articleHistoryDelete(id)),
      parser: (_) {},
    );
  }
}
