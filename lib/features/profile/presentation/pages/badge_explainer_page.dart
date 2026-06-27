import 'package:flutter/material.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_theme.dart';

/// What a single badge explainer screen displays. Driven by the badge kind
/// the user tapped on the profile so we can render one focused page instead
/// of three near-identical pages.
enum BadgeKind { crystals, streak, mirrors }

class BadgeExplainerPage extends StatelessWidget {
  const BadgeExplainerPage({super.key, required this.kind});

  factory BadgeExplainerPage.fromName(String name) {
    return BadgeExplainerPage(
      kind: switch (name) {
        'crystals' => BadgeKind.crystals,
        'streak' => BadgeKind.streak,
        'mirrors' => BadgeKind.mirrors,
        _ => BadgeKind.crystals,
      },
    );
  }

  final BadgeKind kind;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.sarhnyColors;
    final (icon, accent, title, lead, steps, tip) = _content(colors, l);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: accent.withValues(alpha: 0.30)),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
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
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lead,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            l.profileBadgeHowToGet,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          for (final step in steps) ...[
            _StepRow(text: step, accent: accent, colors: colors),
            const SizedBox(height: 8),
          ],
          if (tip != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.elevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border, width: 0.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: accent, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  (IconData, Color, String, String, List<String>, String?) _content(
      SarhnyColors c, AppLocalizations l) {
    switch (kind) {
      case BadgeKind.crystals:
        return (
          Icons.diamond_outlined,
          c.crystal,
          l.profileBadgeCrystalsTitle,
          l.profileBadgeCrystalsLead,
          <String>[
            l.profileBadgeCrystalsStep1,
            l.profileBadgeCrystalsStep2,
            l.profileBadgeCrystalsStep3,
            l.profileBadgeCrystalsStep4,
          ],
          l.profileBadgeCrystalsTip,
        );
      case BadgeKind.streak:
        return (
          Icons.local_fire_department_outlined,
          c.moment,
          l.profileBadgeStreakTitle,
          l.profileBadgeStreakLead,
          <String>[
            l.profileBadgeStreakStep1,
            l.profileBadgeStreakStep2,
            l.profileBadgeStreakStep3,
            l.profileBadgeStreakStep4,
          ],
          l.profileBadgeStreakTip,
        );
      case BadgeKind.mirrors:
        return (
          Icons.auto_awesome_outlined,
          c.mind,
          l.profileBadgeMirrorsTitle,
          l.profileBadgeMirrorsLead,
          <String>[
            l.profileBadgeMirrorsStep1,
            l.profileBadgeMirrorsStep2,
            l.profileBadgeMirrorsStep3,
            l.profileBadgeMirrorsStep4,
          ],
          l.profileBadgeMirrorsTip,
        );
    }
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.text,
    required this.accent,
    required this.colors,
  });
  final String text;
  final Color accent;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
