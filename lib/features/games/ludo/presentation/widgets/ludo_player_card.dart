import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../app/theme/app_theme.dart';
import '../../domain/ludo_player.dart';
import '../../domain/ludo_token.dart';
import 'ludo_board_geometry.dart';

/// كرت لاعب في إحدى زوايا الشاشة — avatar مجهول + اسم + progress.
class LudoPlayerCard extends StatefulWidget {
  const LudoPlayerCard({
    super.key,
    required this.player,
    required this.isYou,
    required this.isCurrentTurn,
    required this.isOnline,
    this.turnTimeLeft,
    this.turnTimeTotal,
  });
  final LudoPlayer? player;
  final bool isYou;
  final bool isCurrentTurn;
  final bool isOnline;
  final int? turnTimeLeft;
  final int? turnTimeTotal;

  @override
  State<LudoPlayerCard> createState() => _LudoPlayerCardState();
}

class _LudoPlayerCardState extends State<LudoPlayerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final p = widget.player;
    if (p == null) {
      return _EmptySlotCard(colors: colors);
    }
    final accent = p.color.primary;
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, _) {
        final pulse = widget.isCurrentTurn
            ? 0.4 + 0.4 * math.sin(_glow.value * 2 * math.pi)
            : 0.0;
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isCurrentTurn
                  ? accent.withValues(alpha: 0.85)
                  : colors.border.withValues(alpha: 0.6),
              width: widget.isCurrentTurn ? 1.5 : 1,
            ),
            boxShadow: widget.isCurrentTurn
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: pulse),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Anonymous avatar with colored border
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              accent.withValues(alpha: 0.85),
                              p.color.dark,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: const Color(0xFFD4AF37),
                            width: 1.2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (!widget.isOnline)
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colors.danger,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.surface,
                                width: 1.4,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.isYou ? 'أنت' : p.color.arabicLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 11,
                              color: accent,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${p.finishedCount}/4',
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: p.progress,
                  minHeight: 4,
                  backgroundColor: colors.elevated,
                  valueColor: AlwaysStoppedAnimation(accent),
                ),
              ),
              if (widget.isCurrentTurn &&
                  widget.turnTimeLeft != null &&
                  widget.turnTimeTotal != null &&
                  widget.turnTimeTotal! > 0) ...[
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: widget.turnTimeLeft! / widget.turnTimeTotal!,
                    minHeight: 2,
                    backgroundColor: colors.elevated,
                    valueColor: AlwaysStoppedAnimation(colors.crystal),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _EmptySlotCard extends StatelessWidget {
  const _EmptySlotCard({required this.colors});
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.elevated,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.hourglass_empty_rounded,
              size: 16,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'بانتظار…',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
