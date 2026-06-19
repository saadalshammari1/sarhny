import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../core/haptics/game_haptics.dart';
import 'carrom/application/carrom_controllers.dart';

/// الساحة — Games hub, redesigned 2026-06 for a calm, modern look.
///
/// Design intent: a clean, low-noise list of games. Compact cards (≤140h),
/// no full-bleed pulsing gradients, no shimmer overlays, no live board
/// preview painters. Single accent per row, generous whitespace, one clear
/// CTA per card. Wallet sits as a small chip in the header instead of a
/// huge hero block.
class GamesHubPage extends ConsumerWidget {
  const GamesHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sarhnyColors;
    final walletAsync = ref.watch(carromWalletProvider);
    final balance = walletAsync.maybeWhen(
      data: (w) => w.points,
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
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
          'الساحة',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          _WalletChip(balance: balance, colors: colors),
          const Gap(12),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const Gap(8),
            _SectionLabel(text: 'الألعاب', colors: colors),
            const Gap(12),
            _GameCard(
              title: 'كيرم',
              subtitle: '١ ضد ١ — منافسة مباشرة',
              icon: Icons.album_rounded,
              accent: colors.moment,
              colors: colors,
              onTap: () {
                GameHaptics.uiPop();
                context.push(AppRoutes.carromLobby);
              },
            ),
            const Gap(10),
            _GameCard(
              title: 'لودو',
              subtitle: '٢ أو ٤ لاعبين — كلاسيكية',
              icon: Icons.casino_rounded,
              accent: colors.mind,
              colors: colors,
              onTap: () {
                GameHaptics.uiPop();
                context.push(AppRoutes.ludoLobby);
              },
            ),
            const Gap(10),
            _GameCard(
              title: 'تحدّى',
              subtitle: 'حجرة. ورقة. مقص — سؤال للفائز',
              icon: Icons.compare_arrows_rounded,
              accent: colors.face,
              colors: colors,
              onTap: () {
                GameHaptics.uiPop();
                context.push(AppRoutes.gameLobby);
              },
            ),
            const Gap(28),
            _SectionLabel(text: 'المزيد', colors: colors),
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: _MiniTile(
                    icon: Icons.palette_outlined,
                    label: 'تخصيص الطاولة',
                    accent: colors.moment,
                    colors: colors,
                    onTap: () {
                      GameHaptics.tap();
                      context.push(AppRoutes.carromCosmetics);
                    },
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: _MiniTile(
                    icon: Icons.auto_awesome_outlined,
                    label: 'كيف تربح نقاطاً',
                    accent: colors.crystal,
                    colors: colors,
                    onTap: () {
                      GameHaptics.tap();
                      _showEarnSheet(context, colors);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEarnSheet(BuildContext context, SarhnyColors colors) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        Widget row(IconData icon, String title, String delta, Color tint) =>
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: tint.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18, color: tint),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    delta,
                    style: TextStyle(
                      color: colors.crystal,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            );
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'كيف تربح النقاط',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Gap(8),
              row(Icons.card_giftcard_rounded, 'هدية التسجيل', '+300',
                  colors.moment),
              row(Icons.emoji_events_rounded, 'فوز في مباراة', '+600',
                  colors.crystal),
              row(Icons.mark_email_unread_rounded,
                  'استلمت رسالة صراحة', '+2', colors.face),
              row(Icons.play_circle_outline_rounded,
                  'مشاهدة إعلان (يومياً ١٠)', '+1', colors.mind),
              const Gap(12),
              Text(
                'النقاط رصيدك في الألعاب — لا تنزل عن ٣٠٠ مهما خسرت.',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
//  Section label
// ─────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.colors});
  final String text;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: colors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
//  Wallet chip (AppBar action)
// ─────────────────────────────────────────────────────────────────────

class _WalletChip extends StatelessWidget {
  const _WalletChip({required this.balance, required this.colors});
  final int? balance;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: colors.crystal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.crystal.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      alignment: Alignment.center,
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
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
//  Game card — primary list item, 96h compact
// ─────────────────────────────────────────────────────────────────────

class _GameCard extends StatefulWidget {
  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.colors,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final SarhnyColors colors;
  final VoidCallback onTap;

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = widget.colors.surface;
    final accent = widget.accent;
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          height: 96,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.colors.border.withValues(alpha: 0.5),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withValues(alpha: 0.22),
                      accent.withValues(alpha: 0.10),
                    ],
                  ),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.30),
                    width: 0.8,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(widget.icon, color: accent, size: 26),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: widget.colors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      widget.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.colors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded, // RTL: visually = play forward in Arabic
                  color: accent,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
//  Mini tile — secondary footer actions
// ─────────────────────────────────────────────────────────────────────

class _MiniTile extends StatelessWidget {
  const _MiniTile({
    required this.icon,
    required this.label,
    required this.accent,
    required this.colors,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final SarhnyColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.border.withValues(alpha: 0.5),
              width: 0.8,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: accent, size: 18),
              ),
              const Gap(10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
