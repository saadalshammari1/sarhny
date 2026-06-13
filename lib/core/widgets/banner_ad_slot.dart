import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob banner slot used across feed / profile / mirrors / inbox.
///
/// Renders a single anchored adaptive banner. If the ad fails to load (no
/// network, disabled in policy, no fill), it collapses to a zero-height
/// SizedBox so layout never shifts visibly.
class BannerAdSlot extends StatefulWidget {
  const BannerAdSlot({super.key});

  // Real production banner ad unit (provided by the user).
  // Replace with the AdMob test ID when iterating locally:
  //   iOS:     ca-app-pub-3940256099942544/2934735716
  //   Android: ca-app-pub-3940256099942544/6300978111
  static const String _prodAdUnitId =
      'ca-app-pub-6938029578060572/8983235770';

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
    final width = MediaQuery.of(context).size.width.truncate();
    final size = await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      width,
    );
    if (size == null) {
      if (mounted) setState(() => _failed = true);
      return;
    }
    final ad = BannerAd(
      adUnitId: BannerAdSlot._prodAdUnitId,
      size: size,
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
      // Reserve a small placeholder while the request is in flight so the
      // surrounding list doesn't jump when the banner appears.
      return const SizedBox(height: 60);
    }
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      width: _ad!.size.width.toDouble(),
      height: _ad!.size.height.toDouble(),
      child: AdWidget(ad: _ad!),
    );
  }
}
