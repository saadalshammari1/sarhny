import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/router.dart';
import '../theme/ludo_theme.dart';

/// Pre-match lobby that lets the user pick 2-player (1v1 vs bot) or
/// 4-player (1v3 vs bots). Kept dead simple — one tap launches the match.
class LudoPowerLobbyPage extends StatelessWidget {
  const LudoPowerLobbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RoyalTheme.appBgBottom,
        body: Container(
          decoration: const BoxDecoration(gradient: RoyalTheme.appBg),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: l10n.actionBack,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: RoyalTheme.textLight, size: 20),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          }
                        },
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.ludoPowerTitle,
                    style: const TextStyle(
                      color: RoyalTheme.textLight,
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.ludoPowerSubtitle,
                    style: TextStyle(
                      color: RoyalTheme.textLight.withValues(alpha: 0.65),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    l10n.ludoLobbyChooseMode,
                    style: TextStyle(
                      color: RoyalTheme.goldAccent.withValues(alpha: 0.85),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ModeCard(
                    title: l10n.ludoMode2Players,
                    subtitle: l10n.ludoMode2PlayersSub,
                    icon: Icons.person_outline,
                    accent: const Color(0xFFF6C021),
                    onTap: () => context.push(AppRoutes.ludoPowerMatch(2)),
                  ),
                  const SizedBox(height: 12),
                  _ModeCard(
                    title: l10n.ludoMode4Players,
                    subtitle: l10n.ludoMode4PlayersSub,
                    icon: Icons.groups_2_outlined,
                    accent: const Color(0xFF9A3FE0),
                    onTap: () => context.push(AppRoutes.ludoPowerMatch(4)),
                  ),
                  const Spacer(),
                  Center(
                    child: Wrap(
                      spacing: 14,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: const [
                        _PowerChip(label: 'Rocket', emoji: '🚀'),
                        _PowerChip(label: 'Freeze', emoji: '❄'),
                        _PowerChip(label: 'Portal', emoji: '🌀'),
                        _PowerChip(label: 'Tornado', emoji: '🌪'),
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

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                accent.withValues(alpha: 0.20),
                accent.withValues(alpha: 0.06),
              ],
            ),
            border: Border.all(color: accent.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: RoyalTheme.textLight,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: RoyalTheme.textLight.withValues(alpha: 0.65),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: RoyalTheme.textLight.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PowerChip extends StatelessWidget {
  const _PowerChip({required this.label, required this.emoji});
  final String label;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: RoyalTheme.panelSolid,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: RoyalTheme.panelBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: RoyalTheme.textLight.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
