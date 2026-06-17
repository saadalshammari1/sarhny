import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/api_providers.dart';
import '../../../../core/providers/storage_providers.dart';
import '../data/admob_service.dart';
import '../data/carrom_api.dart';
import '../data/carrom_repository.dart';
import '../domain/chat_preset.dart';
import '../domain/cosmetics.dart';

/// REST API instance — singleton مرتبط بـ DioClient.
final carromApiProvider = Provider<CarromApi>((ref) {
  return CarromApi(ref.watch(dioClientProvider));
});

/// Repo يجمع REST + WS factory.
final carromRepositoryProvider = Provider<CarromRepository>((ref) {
  return CarromRepository(
    api: ref.watch(carromApiProvider),
    dioClient: ref.watch(dioClientProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

/// رصيد اللاعب — يُعاد تحميله بعد كل مباراة.
final carromWalletProvider = FutureProvider<CarromWallet>((ref) async {
  return ref.watch(carromApiProvider).wallet();
});

/// AdMob rewarded-ad service — single instance per session so the
/// preloaded ad is reused across screens.
final admobRewardServiceProvider = Provider<AdMobRewardService>((ref) {
  final svc = AdMobRewardService(ref.watch(carromApiProvider));
  ref.onDispose(svc.dispose);
  return svc;
});

/// chat presets — caching على مستوى الـ session (12 ساعة).
/// السيرفر نادراً ما يغير القائمة، فلا نريد طلب جديد مع كل dialog.
final carromChatPresetsProvider = FutureProvider<({
  List<CarromChatPreset> presets,
  int cooldownSeconds,
})>((ref) async {
  return ref.watch(carromApiProvider).chatPresets();
});

// ── Cosmetics ─────────────────────────────────────────────────────────

/// الـ catalogue + الاختيار الحالي. نُعيد التحميل عند فتح صفحة الـ
/// picker (invalidate يدوي بعد update) — السيرفر هو المرجع.
final cosmeticsResponseProvider =
    FutureProvider<CosmeticsResponse>((ref) async {
  return ref.watch(carromApiProvider).getCosmetics();
});

/// لاختيارات المستخدم محلياً. تُهيّأ من الـ FutureProvider أعلاه عبر
/// `selectionController.hydrate(...)` ثم تتحكم بها صفحة الـ picker
/// بصورة optimistic — كل update يُرسل للسيرفر، والـ catch يرجع الـ
/// state للقيمة السابقة لو الـ API رفض الاختيار.
class CosmeticsSelectionController extends StateNotifier<UserCosmetics> {
  CosmeticsSelectionController(this._api) : super(UserCosmetics.defaults);

  final CarromApi _api;

  void hydrate(UserCosmetics initial) {
    state = initial;
  }

  Future<void> setBoard(String key) async {
    final prev = state;
    state = state.copyWith(boardSkin: key);
    try {
      final updated = await _api.updateCosmetics(boardSkin: key);
      state = updated;
    } catch (e) {
      state = prev;
      rethrow;
    }
  }

  Future<void> setPiece(String key) async {
    final prev = state;
    state = state.copyWith(pieceSkin: key);
    try {
      final updated = await _api.updateCosmetics(pieceSkin: key);
      state = updated;
    } catch (e) {
      state = prev;
      rethrow;
    }
  }

  Future<void> setStriker(String key) async {
    final prev = state;
    state = state.copyWith(strikerSkin: key);
    try {
      final updated = await _api.updateCosmetics(strikerSkin: key);
      state = updated;
    } catch (e) {
      state = prev;
      rethrow;
    }
  }
}

final cosmeticsSelectionProvider =
    StateNotifierProvider<CosmeticsSelectionController, UserCosmetics>((ref) {
  return CosmeticsSelectionController(ref.watch(carromApiProvider));
});
