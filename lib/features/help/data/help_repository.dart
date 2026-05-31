import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';

class HelpFeature {
  HelpFeature({required this.key, required this.icon, required this.title, required this.body});
  factory HelpFeature.fromJson(Map<String, dynamic> j) => HelpFeature(
        key: '${j['key'] ?? ''}',
        icon: '${j['icon'] ?? ''}',
        title: '${j['title'] ?? ''}',
        body: '${j['body'] ?? ''}',
      );
  final String key;
  final String icon;
  final String title;
  final String body;
}

class FaqItem {
  FaqItem({required this.q, required this.a});
  factory FaqItem.fromJson(Map<String, dynamic> j) => FaqItem(
        q: '${j['question'] ?? j['q'] ?? ''}',
        a: '${j['answer'] ?? j['a'] ?? ''}',
      );
  final String q;
  final String a;
}

class HelpRepository {
  HelpRepository(this._client);
  final DioClient _client;

  Future<List<HelpFeature>> features() {
    return _client.request<List<HelpFeature>>(
      () => _client.raw.get(ApiEndpoints.helpFeatures),
      parser: (data) => ((data as Map)['features'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => HelpFeature.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }

  Future<List<FaqItem>> faq() {
    return _client.request<List<FaqItem>>(
      () => _client.raw.get(ApiEndpoints.helpFaq),
      parser: (data) => ((data as Map)['faq'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => FaqItem.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }
}
