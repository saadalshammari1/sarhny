import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/router.dart';
import '../theme/ludo_theme.dart';

/// Power-Ludo lobby. Two paths into a match — both flow through the
/// matchmaking screen so the user always feels like they're entering a
/// live game, never a "practice mode". Bots fill in transparently.
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
                          if (context.canPop()) context.pop();
                        },
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 4),
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
                  const SizedBox(height: 24),
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
                    title: l10n.ludoMode1v1,
                    subtitle: l10n.ludoMode1v1Sub,
                    icon: Icons.person_outline_rounded,
                    accent: const Color(0xFFF6C021),
                    onTap: () => context
                        .push('${AppRoutes.ludoPowerMatchmaking}?players=2'),
                  ),
                  const SizedBox(height: 12),
                  _ModeCard(
                    title: l10n.ludoMode4Party,
                    subtitle: l10n.ludoMode4PartySub,
                    icon: Icons.groups_2_outlined,
                    accent: const Color(0xFF9A3FE0),
                    onTap: () => context
                        .push('${AppRoutes.ludoPowerMatchmaking}?players=4'),
                  ),
                  const SizedBox(height: 22),
                  _RulesPanel(l10n: l10n),
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
                accent.withValues(alpha: 0.22),
                accent.withValues(alpha: 0.06),
              ],
            ),
            border: Border.all(color: accent.withValues(alpha: 0.55)),
            boxShadow: [
              BoxShadow(
                  color: accent.withValues(alpha: 0.15),
                  blurRadius: 18,
                  spreadRadius: 1)
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.28),
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
                        color: RoyalTheme.textLight.withValues(alpha: 0.7),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: RoyalTheme.textLight.withValues(alpha: 0.75),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RulesPanel extends StatelessWidget {
  const _RulesPanel({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RoyalTheme.panelSolid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RoyalTheme.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_rounded,
                  color: RoyalTheme.goldAccent, size: 16),
              const SizedBox(width: 6),
              Text(
                l10n.ludoLobbyHowToPlay,
                style: const TextStyle(
                  color: RoyalTheme.goldAccent,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ruleLine(l10n.ludoRule1),
          _ruleLine(l10n.ludoRule2),
          _ruleLine(l10n.ludoRule3),
          _ruleLine(l10n.ludoRule4),
        ],
      ),
    );
  }

  Widget _ruleLine(String txt) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• ',
                style: TextStyle(
                    color: RoyalTheme.textLight.withValues(alpha: 0.6))),
            Expanded(
              child: Text(
                txt,
                style: TextStyle(
                  color: RoyalTheme.textLight.withValues(alpha: 0.78),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
}
