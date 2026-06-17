import 'package:flutter/material.dart';

import '../../../../../app/theme/app_theme.dart';

/// بطاقة الخصم — مجهول حتى نهاية المباراة (DNA الصراحة).
class CarromOpponentCard extends StatelessWidget {
  const CarromOpponentCard({
    super.key,
    required this.score,
    required this.isTurn,
    required this.online,
    this.isYou = false,
    this.revealedName,
  });

  final int score;
  final bool isTurn;
  final bool online;
  final bool isYou;
  final String? revealedName;

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final label =
        revealedName ?? (isYou ? 'أنت' : 'خصم مجهول');
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isTurn ? colors.moment : colors.border,
          width: isTurn ? 1.4 : 0.6,
        ),
        boxShadow: isTurn
            ? [
                BoxShadow(
                  color: colors.moment.withValues(alpha: 0.25),
                  blurRadius: 12,
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.elevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.border, width: 0.6),
                ),
                alignment: Alignment.center,
                child: Text(
                  revealedName != null ? revealedName![0] : '?',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: online ? colors.success : colors.textSecondary,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: colors.surface, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  isTurn ? 'دوره الآن' : 'بانتظار الدور',
                  style: TextStyle(
                    color: isTurn ? colors.moment : colors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$score',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
