import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/api_providers.dart';
import '../../data/settings_repository.dart';
import '../../data/subscription_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(dioClientProvider)),
);

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>(
  (ref) => SubscriptionRepository(ref.watch(dioClientProvider)),
);

final settingsStateProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(settingsRepositoryProvider).read();
});

final subscriptionStateProvider =
    FutureProvider<SubscriptionState>((ref) async {
  return ref.watch(subscriptionRepositoryProvider).me();
});

final subscriptionTiersProvider =
    FutureProvider<List<SubscriptionTier>>((ref) async {
  return ref.watch(subscriptionRepositoryProvider).tiers();
});
