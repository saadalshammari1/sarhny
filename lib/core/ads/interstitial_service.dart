import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cross-game interstitial ad layer.
///
/// Triggered once every [_kRoundsPerAd] match completions. The counter
/// persists across app restarts so we honor the cadence even if the user
/// closes and reopens the app mid-cycle.
///
/// Same AdMob app the rewarded service uses — interstitials sit on
/// separate ad units. Test mode via `--dart-define=ADMOB_TEST_MODE=1`
/// falls back to Google's official test interstitial IDs which always
/// fill — useful during local QA without burning prod impressions.
class InterstitialAdService {
  InterstitialAdService();

  /// Show an interstitial after every N completed matches (across games).
  static const int _kRoundsPerAd = 3;

  /// Shared storage key for the persistent counter.
  static const String _kCounterKey = 'interstitial_round_counter';

  InterstitialAd? _ad;
  bool _isLoading = false;

  // Production interstitial units. The owner must create these in AdMob
  // and supply them via --dart-define for prod (until then, test IDs
  // ship in test mode and prod falls back to test if env vars empty).
  static const String _testIosInterstitial =
      'ca-app-pub-3940256099942544/4411468910';
  static const String _testAndroidInterstitial =
      'ca-app-pub-3940256099942544/1033173712';

  String get _adUnitId {
    const testMode = String.fromEnvironment('ADMOB_TEST_MODE');
    if (testMode == '1') {
      return Platform.isIOS ? _testIosInterstitial : _testAndroidInterstitial;
    }
    if (Platform.isIOS) {
      const override = String.fromEnvironment('ADMOB_INTERSTITIAL_IOS');
      return override.isNotEmpty ? override : _testIosInterstitial;
    }
    const override = String.fromEnvironment('ADMOB_INTERSTITIAL_ANDROID');
    return override.isNotEmpty ? override : _testAndroidInterstitial;
  }

  bool _isSupportedPlatform() {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  /// Pre-load. Safe to call repeatedly; no-op if already loaded.
  Future<void> preload() async {
    if (_ad != null || _isLoading) return;
    if (!_isSupportedPlatform()) return;
    _isLoading = true;
    final completer = Completer<void>();
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoading = false;
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToLoad: (err) {
          _ad = null;
          _isLoading = false;
          if (kDebugMode) {
            debugPrint('Interstitial load failed: $err');
          }
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );
    return completer.future;
  }

  /// Call this when a match ENDS (a round, in the user-facing sense).
  /// Increments the persistent counter; if it hits a multiple of
  /// [_kRoundsPerAd] we show the interstitial. Otherwise no-op.
  ///
  /// Returns `true` if an ad was shown (or attempted).
  Future<bool> onMatchCompleted() async {
    if (!_isSupportedPlatform()) return false;
    final prefs = await SharedPreferences.getInstance();
    final n = (prefs.getInt(_kCounterKey) ?? 0) + 1;
    await prefs.setInt(_kCounterKey, n);
    if (n % _kRoundsPerAd != 0) {
      // Pre-load the NEXT ad in the background so the trigger is instant
      // when we hit the threshold.
      unawaited(preload());
      return false;
    }
    return _showNow();
  }

  Future<bool> _showNow() async {
    final ad = _ad;
    if (ad == null) {
      // Try a synchronous load — if AdMob doesn't fill in 6 seconds we
      // skip this cycle rather than block the user on a celebration.
      try {
        await preload().timeout(const Duration(seconds: 6));
      } catch (_) {}
    }
    final ready = _ad;
    if (ready == null) return false;
    _ad = null; // single-use — clear before show
    final completer = Completer<bool>();
    ready.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {},
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completer.isCompleted) completer.complete(true);
        // Pre-load the next one for the upcoming cycle.
        unawaited(preload());
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        if (!completer.isCompleted) completer.complete(false);
        unawaited(preload());
      },
    );
    await ready.show();
    return completer.future;
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}

/// Process-wide singleton — only one interstitial controller needed.
final interstitialAdServiceProvider = Provider<InterstitialAdService>((ref) {
  final svc = InterstitialAdService();
  ref.onDispose(svc.dispose);
  // Pre-load on first read.
  unawaited(svc.preload());
  return svc;
});
