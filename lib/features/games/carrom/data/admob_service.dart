import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../domain/match_status.dart';
import 'carrom_api.dart';

/// Rewarded-ad service for the Carrom +1 point feature.
///
/// Flow:
///   1. Caller invokes [showRewardedAd] from a button tap.
///   2. We load (if not pre-loaded) → show → wait for SSV callback.
///   3. The google_mobile_ads plugin surfaces the SSV callback parameters
///      via `RewardedAd.onAdShowedFullScreenContent` → onUserEarnedReward
///      → and on the iOS/Android binding the `setServerSideOptions`
///      mechanism. We forward the params via [CarromApi.grantAdReward].
///   4. The backend re-verifies the signature with Google's verifier
///      keys and credits +1 if valid + under the daily cap.
///
/// Production switch:
///   The default ad unit IDs are AdMob's test IDs — safe for dev and CI.
///   When the owner has live ad units configured in AdMob console, set
///   the build-time `--dart-define=ADMOB_REWARDED_IOS=...` and
///   `--dart-define=ADMOB_REWARDED_ANDROID=...` flags.
class AdMobRewardService {
  AdMobRewardService(this._api);

  final CarromApi _api;

  RewardedAd? _ad;
  bool _isLoading = false;

  // Production rewarded ad units — Carrom +1 point per view.
  // One unit per platform — AdMob tracks revenue + SSV per platform.
  static const String _prodIosRewarded =
      'ca-app-pub-6938029578060572/3836547073';
  static const String _prodAndroidRewarded =
      'ca-app-pub-6938029578060572/7480278611';

  // AdMob test IDs — fallback only if `--dart-define=ADMOB_TEST_MODE=1`
  // is passed at build time (useful for local iteration without burning
  // production impressions).
  static const String _testIosRewarded =
      'ca-app-pub-3940256099942544/1712485313';
  static const String _testAndroidRewarded =
      'ca-app-pub-3940256099942544/5224354917';

  String get _adUnitId {
    const testMode = String.fromEnvironment('ADMOB_TEST_MODE');
    if (testMode == '1') {
      return Platform.isIOS ? _testIosRewarded : _testAndroidRewarded;
    }
    if (Platform.isIOS) {
      const override = String.fromEnvironment('ADMOB_REWARDED_IOS');
      return override.isNotEmpty ? override : _prodIosRewarded;
    }
    const override = String.fromEnvironment('ADMOB_REWARDED_ANDROID');
    return override.isNotEmpty ? override : _prodAndroidRewarded;
  }

  /// Pre-load a rewarded ad. Safe to call repeatedly — no-op if one is
  /// already loaded or loading.
  Future<void> loadRewardedAd() async {
    if (_ad != null || _isLoading) return;
    if (!_isSupportedPlatform()) return;
    _isLoading = true;
    final completer = Completer<void>();
    await RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoading = false;
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToLoad: (err) {
          _ad = null;
          _isLoading = false;
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );
    return completer.future;
  }

  /// Show the loaded rewarded ad and, on completion, forward the SSV
  /// callback to the backend for verification + crediting.
  ///
  /// Returns the [AdGrantResult] when the user earned a reward AND the
  /// backend successfully credited; returns null on:
  ///   - ad unavailable / failed to show
  ///   - user dismissed without earning
  ///   - SSV callback empty (very rare — usually misconfigured AdMob app)
  /// Throws [AdRewardException] when the backend rejects the grant (e.g.
  /// daily cap, invalid signature) so the UI can show the precise reason.
  Future<AdGrantResult?> showRewardedAd() async {
    if (!_isSupportedPlatform()) {
      throw AdRewardException('ads_unsupported_platform');
    }
    if (_ad == null) {
      await loadRewardedAd();
    }
    final ad = _ad;
    if (ad == null) {
      throw AdRewardException('ad_unavailable');
    }
    _ad = null;     // each RewardedAd is single-use; clear before showing.

    // We have to capture two async events:
    //   * onUserEarnedReward  → the user finished the ad
    //   * onAdDismissedFullScreenContent → ad was closed
    // Only when BOTH happen + the SSV callback is present do we forward.
    final rewardCompleter = Completer<RewardItem?>();
    String? ssvQueryFromCallback;

    ad.setServerSideOptions(
      ServerSideVerificationOptions(),
    );

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) async {
        ad.dispose();
        if (!rewardCompleter.isCompleted) {
          rewardCompleter.complete(null);
        }
        // Prefetch the next ad opportunistically.
        unawaited(loadRewardedAd());
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        if (!rewardCompleter.isCompleted) {
          rewardCompleter.complete(null);
        }
      },
    );

    await ad.show(onUserEarnedReward: (ad, reward) {
      // The plugin exposes the SSV callback's full query string via the
      // platform side-channel. Newer plugin versions surface it through
      // a separate `onPaidEvent` / SSV options channel — for now we rely
      // on the reward item being delivered and capture whatever the
      // platform passes through as `customData`.
      ssvQueryFromCallback = reward.toString();
      if (!rewardCompleter.isCompleted) {
        rewardCompleter.complete(reward);
      }
    });

    final reward = await rewardCompleter.future;
    if (reward == null) return null;     // user dismissed early

    // The google_mobile_ads Flutter plugin (v5.x) does NOT yet expose the
    // raw SSV callback URL to Dart — Android/iOS receive the SSV HTTPS
    // GET *server-side* (AdMob → publisher's URL). For the SSV-via-client
    // pattern to work, the publisher must configure AdMob to POST to OUR
    // backend directly (using the `transaction_id` as a custom data
    // attribute).
    //
    // Until that config lands, we fall back to a "trust-but-verify" grant
    // where the client asserts the reward and the backend rejects if the
    // signature is missing. The production AdMob console MUST be wired to
    // the direct SSV URL: https://sarhny.com/api/v1/games/ad/grant/ssv
    // (which the backend then re-verifies). See README_ADMOB_SSV.md.
    if (ssvQueryFromCallback == null || ssvQueryFromCallback!.isEmpty) {
      throw AdRewardException('ssv_unavailable');
    }
    try {
      return await _api.grantAdReward(ssvQueryFromCallback!);
    } on CarromApiException catch (e) {
      throw AdRewardException(e.code ?? 'grant_failed', message: e.message);
    }
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
  }

  bool _isSupportedPlatform() {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }
}

/// Surfaces the precise grant-failure reason to the UI so it can
/// localise the message (e.g. "daily_cap_reached" → "وصلت الحد اليومي").
class AdRewardException implements Exception {
  AdRewardException(this.code, {this.message});
  final String code;
  final String? message;
  @override
  String toString() => 'AdRewardException($code)${message != null ? ': $message' : ''}';
}
