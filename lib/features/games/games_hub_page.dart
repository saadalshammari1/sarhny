import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../app/localization/generated/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../core/haptics/game_haptics.dart';
import 'carrom/application/carrom_controllers.dart';
import 'carrom/data/admob_service.dart';

/// "الساحة" — the games entry surface.
///
/// Scope (intentionally narrow after a hard re-scope on 2026-06-20):
///   * RPS (تحدّى) — existing online matchmaking, winner asks a question
///     and the loser answers
///   * XO (إكس-أو) — same flow, 3×3 board instead of best-of-5 rounds
///   * One prominent "watch ad → +1 point" tile so users who don't want
///     to play can still grow their wallet
///
/// Carrom and Ludo deliberately do NOT surface here — those flows still
/// exist at their routes for back-compat, but the entry points are
/// removed until they reach a quality bar worth showing.
class GamesHubPage extends ConsumerStatefulWidget {
  const GamesHubPage({super.key});
  @override
  ConsumerState<GamesHubPage> createState() => _GamesHubPageState();
}

class _GamesHubPageState extends ConsumerState<GamesHubPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  AdMobRewardService? _adService;
  bool _watchingAd = false;

  @override
  void dispose() {
    _shimmer.dispose();
    _adService?.dispose();
    super.dispose();
  }

  Future<void> _watchAdForPoint() async {
    if (_watchingAd) return;
    setState(() => _watchingAd = true);
    GameHaptics.uiPop();
    final svc = _adService ??= AdMobRewardService(ref.read(carromApiProvider));
    final l10n = AppLocalizations.of(context);
    try {
      final grant = await svc.showRewardedAd();
      if (!mounted) return;
      if (grant == null) {
        Fluttertoast.showToast(msg: l10n.adIncomplete);
      } else {
        ref.invalidate(carromWalletProvider);
        Fluttertoast.showToast(msg: l10n.adRewardEarned);
      }
    } on AdRewardException catch (e) {
      Fluttertoast.showToast(msg: _adErr(l10n, e.code));
    } catch (_) {
      Fluttertoast.showToast(msg: l10n.adUnavailable);
    } finally {
      if (mounted) setState(() => _watchingAd = false);
    }
  }

  String _adErr(AppLocalizations l10n, String code) {
    switch (code) {
      case 'ads_unsupported_platform':
      case 'ad_unavailable':
        return l10n.adUnavailable;
      case 'daily_cap_reached':
        return l10n.adDailyCap;
      case 'already_granted':
        return l10n.adRewardEarned;
      default:
        return l10n.adUnavailable;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final l10n = AppLocalizations.of(context);
    final walletAsync = ref.watch(carromWalletProvider);
    final balance =
        walletAsync.maybeWhen(data: (w) => w.points, orElse: () => null);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          tooltip: l10n.actionBack,
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: colors.textPrimary, size: 20),
          onPressed: () {
            GameHaptics.tap();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.feed);
            }
          },
        ),
        title: Text(
          l10n.labelGamesHome,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        actions: [
          _WalletPill(balance: balance, colors: colors),
          const Gap(12),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            const Gap(12),
            _SectionLabel(text: l10n.hubSectionPlay, colors: colors),
            const Gap(10),
            _GameTile(
              title: l10n.hubGameRps,
              subtitle: l10n.hubGameRpsSub,
              icon: Icons.compare_arrows_rounded,
              tag: l10n.hubTagOnline,
              accent: colors.moment,
              colors: colors,
              shimmer: _shimmer,
              decoration: _GameTileDecoration.shapes,
              onTap: () {
                GameHaptics.uiPop();
                context.push(AppRoutes.gameLobby);
              },
            ),
            const Gap(12),
            _GameTile(
              title: l10n.hubGameXo,
              subtitle: l10n.hubGameXoSub,
              icon: Icons.grid_3x3_rounded,
              tag: l10n.hubTagAdNew,
              accent: colors.face,
              colors: colors,
              shimmer: _shimmer,
              decoration: _GameTileDecoration.grid,
              onTap: () {
                GameHaptics.uiPop();
                context.push(AppRoutes.xoLobby);
              },
            ),
            const Gap(22),
            _SectionLabel(text: l10n.hubSectionEarn, colors: colors),
            const Gap(10),
            _AdEarnTile(
              l10n: l10n,
              colors: colors,
              busy: _watchingAd,
              onTap: _watchAdForPoint,
            ),
            const Gap(10),
            _HintRow(l10n: l10n, colors: colors),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.colors});
  final String text;
  final SarhnyColors colors;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        text,
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Wallet pill (AppBar action)
// ─────────────────────────────────────────────────────────────────────

class _WalletPill extends StatelessWidget {
  const _WalletPill({required this.balance, required this.colors});
  final int? balance;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: colors.crystal.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.crystal.withValues(alpha: 0.40),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.diamond_outlined, size: 14, color: colors.crystal),
          const Gap(6),
          Text(
            balance == null ? '—' : '$balance',
            style: TextStyle(
              color: colors.crystal,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Game tile — the premium hero cards
// ─────────────────────────────────────────────────────────────────────

enum _GameTileDecoration { shapes, grid }

class _GameTile extends StatefulWidget {
  const _GameTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tag,
    required this.accent,
    required this.colors,
    required this.shimmer,
    required this.decoration,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String tag;
  final Color accent;
  final SarhnyColors colors;
  final Animation<double> shimmer;
  final _GameTileDecoration decoration;
  final VoidCallback onTap;

  @override
  State<_GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<_GameTile> {
  bool _pressed = false;

  void _press(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press(true),
      onTapUp: (_) => _press(false),
      onTapCancel: () => _press(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: AnimatedBuilder(
          animation: widget.shimmer,
          builder: (context, _) => Container(
            height: 132,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: widget.colors.surface,
              border: Border.all(
                color: widget.accent.withValues(alpha: 0.50),
                width: 0.9,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.accent.withValues(alpha: 0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _TileBackgroundPainter(
                        accent: widget.accent,
                        shimmer: widget.shimmer.value,
                        decoration: widget.decoration,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                widget.accent.withValues(alpha: 0.32),
                                widget.accent.withValues(alpha: 0.12),
                              ],
                            ),
                            border: Border.all(
                              color: widget.accent.withValues(alpha: 0.55),
                              width: 0.8,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(widget.icon,
                              color: widget.accent, size: 30),
                        ),
                        const Gap(14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    widget.title,
                                    style: TextStyle(
                                      color: widget.colors.textPrimary,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const Gap(8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: widget.accent
                                          .withValues(alpha: 0.20),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      widget.tag,
                                      style: TextStyle(
                                        color: widget.accent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(4),
                              Text(
                                widget.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: widget.colors.textSecondary,
                                  fontSize: 12.5,
                                  height: 1.45,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(10),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: widget.accent.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: widget.accent,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Subtle motif behind each game tile — rotating shapes for RPS, a
/// floating grid for XO. Adds depth without screaming.
class _TileBackgroundPainter extends CustomPainter {
  _TileBackgroundPainter({
    required this.accent,
    required this.shimmer,
    required this.decoration,
  });

  final Color accent;
  final double shimmer;
  final _GameTileDecoration decoration;

  @override
  void paint(Canvas canvas, Size size) {
    final fadeColor = accent.withValues(alpha: 0.08);
    final lineColor = accent.withValues(alpha: 0.15);
    final glowColor = accent.withValues(alpha: 0.10 + 0.05 * shimmer);

    // Soft glow disc on the right side.
    canvas.drawCircle(
      Offset(size.width - 30, size.height / 2),
      90 + 10 * shimmer,
      Paint()
        ..color = glowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );

    if (decoration == _GameTileDecoration.grid) {
      // Light 3-line grid floating right side.
      final stroke = Paint()
        ..color = lineColor
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;
      const slot = 26.0;
      final cx = size.width - 50;
      final cy = size.height / 2;
      for (var i = 1; i <= 2; i++) {
        canvas.drawLine(
          Offset(cx - 1.5 * slot, cy - 1.5 * slot + i * slot),
          Offset(cx + 1.5 * slot, cy - 1.5 * slot + i * slot),
          stroke,
        );
        canvas.drawLine(
          Offset(cx - 1.5 * slot + i * slot, cy - 1.5 * slot),
          Offset(cx - 1.5 * slot + i * slot, cy + 1.5 * slot),
          stroke,
        );
      }
      // A subtle X mark in one cell.
      final pad = slot * 0.30;
      final cellCx = cx + slot / 2;
      final cellCy = cy - slot / 2;
      final xPaint = Paint()
        ..color = accent.withValues(alpha: 0.45)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(cellCx - slot / 2 + pad, cellCy - slot / 2 + pad),
        Offset(cellCx + slot / 2 - pad, cellCy + slot / 2 - pad),
        xPaint,
      );
      canvas.drawLine(
        Offset(cellCx + slot / 2 - pad, cellCy - slot / 2 + pad),
        Offset(cellCx - slot / 2 + pad, cellCy + slot / 2 - pad),
        xPaint,
      );
    } else {
      // Rotating triangle (RPS = three choices) motif.
      final cx = size.width - 50;
      final cy = size.height / 2;
      final r = 36.0;
      final t = shimmer * 2 * math.pi;
      final path = Path();
      for (var i = 0; i < 3; i++) {
        final a = t + i * (2 * math.pi / 3);
        final p = Offset(cx + r * math.cos(a), cy + r * math.sin(a));
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = lineColor,
      );
      canvas.drawPath(path, Paint()..color = fadeColor);
    }
  }

  @override
  bool shouldRepaint(covariant _TileBackgroundPainter old) =>
      old.shimmer != shimmer ||
      old.accent != accent ||
      old.decoration != decoration;
}

// ─────────────────────────────────────────────────────────────────────
// Watch-ad-for-point tile — primary visible CTA per the new product brief
// ─────────────────────────────────────────────────────────────────────

class _AdEarnTile extends StatelessWidget {
  const _AdEarnTile({
    required this.l10n,
    required this.colors,
    required this.busy,
    required this.onTap,
  });
  final AppLocalizations l10n;
  final SarhnyColors colors;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.crystal.withValues(alpha: 0.20),
                colors.crystal.withValues(alpha: 0.08),
              ],
            ),
            border: Border.all(
              color: colors.crystal.withValues(alpha: 0.55),
              width: 0.9,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.crystal.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  color: colors.crystal,
                  size: 30,
                ),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.hubAdEarnTitle,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Gap(8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: colors.crystal.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.hubAdPointBadge,
                            style: TextStyle(
                              color: colors.crystal,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(4),
                    Text(
                      l10n.hubAdEarnSub,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              if (busy)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                )
              else
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colors.crystal.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: colors.crystal,
                    size: 13,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HintRow extends StatelessWidget {
  const _HintRow({required this.l10n, required this.colors});
  final AppLocalizations l10n;
  final SarhnyColors colors;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.lightbulb_outline_rounded,
            color: colors.textSecondary, size: 14),
        const Gap(6),
        Expanded(
          child: Text(
            l10n.hubAbstainHint,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
