import 'package:flutter/material.dart';
import '../theme/ludo_theme.dart';
import 'ludo_dice.dart';

/// HUD pill for one player: anonymous name + mini 3-D dice + status
/// indicator (your turn / thinking / waiting).
///
/// Placed in each board corner so the user can scan the table at a glance
/// and see who's next without reading a status line.
class PlayerSeat extends StatelessWidget {
  const PlayerSeat({
    super.key,
    required this.label,
    required this.colorKey,
    required this.diceValue,
    required this.isCurrent,
    required this.isThinking,
    required this.isRolling,
    required this.alignment,
  });

  /// Pre-resolved display name ("You", "Opponent 2", etc.) — already
  /// localized & anonymous by the page.
  final String label;
  final String colorKey;
  final int diceValue;
  final bool isCurrent;
  final bool isThinking;
  final bool isRolling;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final c = ludoColors[colorKey]!;
    // Layout: dice on the side closest to the corner, label next to it.
    final isRight = alignment.x > 0;
    final children = <Widget>[
      _NameChip(label: label, color: c, isCurrent: isCurrent),
      const SizedBox(width: 6),
      LudoMiniDice(
        value: diceValue,
        size: 36,
        glowColor: c.light,
        active: isCurrent,
      ),
    ];
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: isCurrent || !isThinking ? 1.0 : 0.92,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isRight ? children.reversed.toList() : children,
      ),
    );
  }
}

class _NameChip extends StatelessWidget {
  const _NameChip({
    required this.label,
    required this.color,
    required this.isCurrent,
  });
  final String label;
  final LudoColor color;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: isCurrent
            ? color.base.withValues(alpha: 0.95)
            : RoyalTheme.panelSolid,
        border: Border.all(
          color: isCurrent ? color.light : RoyalTheme.panelBorder,
          width: isCurrent ? 1.6 : 1.0,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                    color: color.light.withValues(alpha: 0.55),
                    blurRadius: 14,
                    spreadRadius: 1)
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrent ? Colors.white : color.base,
              boxShadow: isCurrent
                  ? [
                      const BoxShadow(
                          color: Color(0xCCFFFFFF),
                          blurRadius: 6,
                          spreadRadius: 1)
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isCurrent ? Colors.white : RoyalTheme.textLight,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
