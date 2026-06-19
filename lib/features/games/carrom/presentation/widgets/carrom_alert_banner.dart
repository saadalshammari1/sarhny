import 'dart:async';

import 'package:flutter/material.dart';

/// Pill-shaped, self-managing banner used by the carrom screen to flash
/// transient warnings/info above the board — foul events, queen-coverage
/// pending warnings, or generic info notices.
///
/// Designed as a fully self-contained widget:
///   • fades in over 180ms,
///   • holds at full opacity for 1800ms,
///   • fades out over 240ms,
///   • removes its internal timer in [dispose].
///
/// `kind` is one of: `"foul"`, `"queen"`, `"info"`. Anything else falls
/// back to `info` styling.
///
/// Color/icon styling is intentionally chosen to be recognisable across
/// themes and at any board scale (the parent decides where to place it,
/// typically `Align(alignment: Alignment.topCenter)` above the
/// [CarromBoardGame] `GameWidget`).
class CarromAlertBanner extends StatefulWidget {
  const CarromAlertBanner({
    super.key,
    required this.kind,
    required this.message,
  });

  /// One of `foul` | `queen` | `info`. Drives color + icon.
  final String kind;

  /// Already-localized text to show inside the pill.
  final String message;

  /// Maps a server `foul_reason` (or the synthetic `queen_pending` key)
  /// to a localized Arabic message. Keys mirror what the carrom backend
  /// emits in `CarromShotResultEvent`.
  ///
  /// Unknown keys fall back to a generic foul message so a UI built
  /// against a newer server still shows *something* meaningful.
  static String localizedFoul(String reason) {
    switch (reason) {
      case 'striker_pocketed':
        return 'خطأ: المضرب دخل في الجيب';
      case 'no_piece_hit':
        return 'خطأ: لم تلمس قطعة';
      case 'wrong_color':
        return 'خطأ: لمست قطعة الخصم أولاً';
      case 'queen_uncovered':
        return 'خطأ: التاج بدون تغطية';
      case 'opponent_color_pocketed':
        return 'خطأ: قطعة الخصم في الجيب';
      case 'queen_pocketed_without_cover':
        return 'غطّ التاج بقطعة من لونك';
      case 'queen_pending':
        return 'غطّ التاج في رميتك التالية';
      default:
        return 'خطأ في الرمية';
    }
  }

  @override
  State<CarromAlertBanner> createState() => _CarromAlertBannerState();
}

class _CarromAlertBannerState extends State<CarromAlertBanner> {
  static const Duration _fadeIn = Duration(milliseconds: 180);
  static const Duration _hold = Duration(milliseconds: 1800);
  static const Duration _fadeOut = Duration(milliseconds: 240);

  /// Tri-state opacity target controlling the AnimatedOpacity:
  /// 0 (initial → fade in target=1) → 1 (hold) → 0 (fade out).
  double _opacity = 0.0;
  Duration _currentDuration = _fadeIn;
  Timer? _holdTimer;
  Timer? _fadeOutTimer;

  @override
  void initState() {
    super.initState();
    // Trigger fade-in on next frame so AnimatedOpacity sees the change.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _opacity = 1.0;
        _currentDuration = _fadeIn;
      });
      _holdTimer = Timer(_fadeIn + _hold, () {
        if (!mounted) return;
        setState(() {
          _opacity = 0.0;
          _currentDuration = _fadeOut;
        });
      });
    });
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _fadeOutTimer?.cancel();
    super.dispose();
  }

  // ── Styling lookups ────────────────────────────────────────────────
  // Semi-transparent (0xCC alpha) backgrounds keep the board visible
  // through the banner — fouls/warnings shouldn't fully obscure play.

  Color _bgColor() {
    switch (widget.kind) {
      case 'foul':
        return const Color(0xCCD22F2F);
      case 'queen':
        return const Color(0xCCE4B94B);
      case 'info':
      default:
        return const Color(0xCC3E7DD4);
    }
  }

  IconData _icon() {
    switch (widget.kind) {
      case 'foul':
        return Icons.warning_amber;
      case 'queen':
        return Icons.star;
      case 'info':
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: _currentDuration,
      curve: Curves.easeInOut,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _bgColor(),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon(), color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
