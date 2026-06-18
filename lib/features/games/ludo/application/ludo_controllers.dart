import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/api_providers.dart';
import '../../../../core/providers/storage_providers.dart';
import '../data/ludo_api.dart';
import '../data/ludo_repository.dart';
import '../domain/ludo_chat_preset.dart';

/// REST API instance — singleton مرتبط بـ DioClient.
final ludoApiProvider = Provider<LudoApi>((ref) {
  return LudoApi(ref.watch(dioClientProvider));
});

/// Repo يجمع REST + WS factory.
final ludoRepositoryProvider = Provider<LudoRepository>((ref) {
  return LudoRepository(
    api: ref.watch(ludoApiProvider),
    dioClient: ref.watch(dioClientProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

/// رصيد اللاعب — يُعاد تحميله بعد كل مباراة.
final ludoWalletProvider = FutureProvider<LudoWallet>((ref) async {
  return ref.watch(ludoApiProvider).wallet();
});

/// chat presets — caching على مستوى الـ session.
/// السيرفر نادراً ما يغيّر القائمة، فنريد تجنّب الطلبات المتكررة.
final ludoChatPresetsProvider = FutureProvider<({
  List<LudoChatPreset> presets,
  int cooldownSeconds,
})>((ref) async {
  return ref.watch(ludoApiProvider).chatPresets();
});
