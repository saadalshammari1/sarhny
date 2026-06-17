import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob banner slot used across feed / profile / mirrors / inbox.
///
/// Renders a **MediumRectangle (300×250)** instead of the old anchored
/// adaptive banner (320×50-ish). The MREC pays 3-5× higher CPM in the
/// MENA market because it captures more viewable surface and supports
/// rich-media creatives the standard banner doesn't.
///
/// If the ad fails to load (no network, no fill, policy disabled), the
/// widget collapses to zero-height so the surrounding list doesn't jump.
class BannerAdSlot extends StatefulWidget {
  const BannerAdSlot({super.key});

  // Production MREC ad units (300×250 — higher-CPM than the legacy 320×50
  // banner). One unit per platform — AdMob bills + tracks them separately.
  // Test IDs (for local iteration):
  //   iOS:     ca-app-pub-3940256099942544/4411468910
  //   Android: ca-app-pub-3940256099942544/1033173712
  static const String _prodIosBanner =
      'ca-app-pub-6938029578060572/9088873757';
  static const String _prodAndroidBanner =
      'ca-app-pub-6938029578060572/1705207758';

  static String get _adUnitId =>
      Platform.isIOS ? _prodIosBanner : _prodAndroidBanner;

  @override
  State<BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends State<BannerAdSlot> {
  BannerAd? _ad;
  bool _loaded = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // AdMob banners are only available on iOS + Android. Other platforms
    // (web preview, desktop) silently render nothing.
    if (!_isSupportedPlatform()) {
      setState(() => _failed = true);
      return;
    }
    // MediumRectangle: fixed 300×250. Higher viewability, richer creatives,
    // significantly better CPM than the anchored adaptive banner we used
    // before — the owner reported the previous slot was "غير مجدية أبداً".
    final ad = BannerAd(
      adUnitId: BannerAdSlot._adUnitId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          if (mounted) setState(() => _failed = true);
        },
      ),
    );
    _ad = ad;
    await ad.load();
  }

  bool _isSupportedPlatform() {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return const SizedBox.shrink();
    if (!_loaded || _ad == null) {
      // Reserve approximate MREC height while the request is in flight so
      // the surrounding list doesn't jump when the banner appears.
      return const SizedBox(height: 260);
    }
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      width: AdSize.mediumRectangle.width.toDouble(),
      height: AdSize.mediumRectangle.height.toDouble(),
      child: AdWidget(ad: _ad!),
    );
  }
}
