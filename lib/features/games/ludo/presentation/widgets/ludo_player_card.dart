import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../app/theme/app_theme.dart';
import '../../../../../core/haptics/game_haptics.dart';
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
    this.onTap,
  });
  final LudoPlayer? player;
  final bool isYou;
  final bool isCurrentTurn;
  final bool isOnline;
  final int? turnTimeLeft;
  final int? turnTimeTotal;

  /// تابع اختياري عند الضغط على الكرت — يطلق [GameHaptics.uiPop].
  final VoidCallback? onTap;

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
  void didUpdateWidget(covariant LudoPlayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Haptic pulse عند بدء دور هذا اللاعب.
    if (!oldWidget.isCurrentTurn && widget.isCurrentTurn) {
      GameHaptics.tap();
    }
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  void _handleTap() {
    final cb = widget.onTap;
    if (cb == null) return;
    GameHaptics.uiPop();
    cb();
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
        final card = Container(
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
              const SizedBox(height: 6),
              // Token-state summary: 4 small indicators (one per token).
              _TokenStateRow(tokens: p.tokens, accent: accent),
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
        if (widget.onTap != null) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _handleTap,
            child: card,
          );
        }
        return card;
      },
    );
  }
}

/// صفّ من 4 indicators صغيرة (12×12) — يعرض حالة كل token.
class _TokenStateRow extends StatelessWidget {
  const _TokenStateRow({required this.tokens, required this.accent});
  final List<LudoTokenPosition> tokens;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    // padded إلى 4 دائماً (في حال السيرفر أرسل أقل لأي سبب).
    final list = List<LudoTokenPosition?>.from(tokens);
    while (list.length < 4) {
      list.add(null);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 4; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          _TokenStateDot(token: list[i], accent: accent),
        ],
      ],
    );
  }
}

class _TokenStateDot extends StatelessWidget {
  const _TokenStateDot({required this.token, required this.accent});
  final LudoTokenPosition? token;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final zone = token?.zone ?? LudoTokenZone.home;
    const gold = Color(0xFFD4AF37);

    Color fill;
    Color border;
    double borderWidth;
    Widget? inner;

    switch (zone) {
      case LudoTokenZone.home:
        fill = Colors.transparent;
        border = accent;
        borderWidth = 1.0;
        break;
      case LudoTokenZone.track:
        fill = accent;
        border = accent;
        borderWidth = 1.0;
        break;
      case LudoTokenZone.homeStretch:
        fill = accent;
        border = accent;
        borderWidth = 1.0;
        inner = Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
        );
        break;
      case LudoTokenZone.finished:
        fill = gold;
        border = gold;
        borderWidth = 1.0;
        inner = const Icon(
          Icons.check,
          size: 9,
          color: Colors.white,
        );
        break;
    }

    return _TokenStateDotAnimated(
      fill: fill,
      border: border,
      borderWidth: borderWidth,
      inner: inner,
      onChanged: () => GameHaptics.tap(),
      zoneKey: zone.index,
    );
  }
}

/// AnimatedContainer wrapper — يطلق [onChanged] عند تغيّر state.
class _TokenStateDotAnimated extends StatefulWidget {
  const _TokenStateDotAnimated({
    required this.fill,
    required this.border,
    required this.borderWidth,
    required this.inner,
    required this.onChanged,
    required this.zoneKey,
  });
  final Color fill;
  final Color border;
  final double borderWidth;
  final Widget? inner;
  final VoidCallback onChanged;
  final int zoneKey;

  @override
  State<_TokenStateDotAnimated> createState() =>
      _TokenStateDotAnimatedState();
}

class _TokenStateDotAnimatedState extends State<_TokenStateDotAnimated> {
  @override
  void didUpdateWidget(covariant _TokenStateDotAnimated oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.zoneKey != widget.zoneKey) {
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      width: 12,
      height: 12,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.fill,
        shape: BoxShape.circle,
        border: Border.all(color: widget.border, width: widget.borderWidth),
      ),
      child: widget.inner,
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
