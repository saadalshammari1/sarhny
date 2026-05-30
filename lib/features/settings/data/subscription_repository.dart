import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';

class SubscriptionTier {
  SubscriptionTier({
    required this.key,
    required this.label,
    this.dailyMax,
    this.features = const [],
    this.priceLabel,
  });
  factory SubscriptionTier.fromJson(Map<String, dynamic> json) =>
      SubscriptionTier(
        key: '${json['key'] ?? ''}',
        label: '${json['label'] ?? json['key'] ?? ''}',
        dailyMax: (json['daily_max'] as num?)?.toInt(),
        features: (json['features'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        priceLabel: json['price']?.toString() ?? json['price_label']?.toString(),
      );
  final String key;
  final String label;
  final int? dailyMax;
  final List<String> features;
  final String? priceLabel;
}

class SubscriptionState {
  SubscriptionState({
    required this.tier,
    this.balance,
    this.dailyMax,
    this.features = const [],
  });
  final String tier;
  final int? balance;
  final int? dailyMax;
  final List<String> features;
}

class SubscriptionRepository {
  SubscriptionRepository(this._client);
  final DioClient _client;

  Future<List<SubscriptionTier>> tiers() {
    return _client.request<List<SubscriptionTier>>(
      () => _client.raw.get(ApiEndpoints.subscriptionTiers),
      parser: (data) => ((data as Map)['tiers'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => SubscriptionTier.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }

  Future<SubscriptionState> me() {
    return _client.request<SubscriptionState>(
      () => _client.raw.get(ApiEndpoints.subscriptionMe),
      parser: (data) {
        final map = (data as Map).cast<String, dynamic>();
        final tier = '${map['tier'] ?? 'free'}';
        final attn = (map['attention'] as Map?)?.cast<String, dynamic>();
        final defn = (map['definition'] as Map?)?.cast<String, dynamic>();
        return SubscriptionState(
          tier: tier,
          balance: (attn?['balance'] as num?)?.toInt(),
          dailyMax: (attn?['daily_max'] as num?)?.toInt(),
          features: (defn?['features'] as List? ?? const [])
              .map((e) => e.toString())
              .toList(),
        );
      },
    );
  }

  Future<void> upgrade(String tier) {
    return _client.request<void>(
      () => _client.raw.post(ApiEndpoints.subscriptionUpgrade(tier)),
      parser: (_) {},
    );
  }

  Future<void> cancel() {
    return _client.request<void>(
      () => _client.raw.post(ApiEndpoints.subscriptionCancel),
      parser: (_) {},
    );
  }
}
