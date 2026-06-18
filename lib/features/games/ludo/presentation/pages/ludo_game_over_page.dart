import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router.dart';
import '../../../../../app/theme/app_theme.dart';
import '../../../../../core/providers/auth_providers.dart';
import '../../application/ludo_controllers.dart';
import '../../application/ludo_match_state.dart';

/// شاشة نهاية المباراة — confetti + rankings + rematch/sarhny actions.
class LudoGameOverPage extends ConsumerStatefulWidget {
  const LudoGameOverPage({
    super.key,
    required this.roomId,
    required this.outcome,
  });
  final String roomId;
  final LudoOutcome outcome;

  @override
  ConsumerState<LudoGameOverPage> createState() => _LudoGameOverPageState();
}

class _LudoGameOverPageState extends ConsumerState<LudoGameOverPage>
    with TickerProviderStateMixin {
  late final AnimationController _confetti = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );
  late final AnimationController _trophyBob = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.invalidate(ludoWalletProvider);
    });
    _confetti.forward();
  }

  @override
  void dispose() {
    _confetti.dispose();
    _trophyBob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final myUserId = ref.watch(authStateProvider).value?.userId;
    final youWon = myUserId != null && myUserId == widget.outcome.winnerId;

    final sortedRanks = [...widget.outcome.ranks]
      ..sort((a, b) => a.rank.compareTo(b.rank));

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // confetti
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _confetti,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ConfettiPainter(progress: _confetti.value),
                  );
                },
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 18),
                AnimatedBuilder(
                  animation: _trophyBob,
                  builder: (ctx, _) {
                    final lift = 6 * math.sin(_trophyBob.value * math.pi);
                    return Transform.translate(
                      offset: Offset(0, -lift),
                      child: Text(
                        youWon ? '🏆' : '🎲',
                        style: const TextStyle(fontSize: 84),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  youWon ? 'فوز ساحق!' : 'مباراة جميلة',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  youWon
                      ? 'كسبت ${widget.outcome.pot} نقطة'
                      : 'الفائز يأخذ ${widget.outcome.pot} نقطة',
                  style: TextStyle(
                    color: colors.crystal,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: sortedRanks.length,
                    itemBuilder: (ctx, i) {
                      final r = sortedRanks[i];
                      final isMe = r.userId == myUserId;
                      return _RankTile(
                        rank: r.rank,
                        payout: r.payout,
                        isMe: isMe,
                        colors: colors,
                      );
                    },
                  ),
                ),
                // Action buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                context.go(AppRoutes.ludoLobby);
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('مباراة جديدة'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                context.go(AppRoutes.gamesHub);
                              },
                              icon: const Icon(Icons.home_rounded),
                              label: const Text('الساحة'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RankTile extends StatelessWidget {
  const _RankTile({
    required this.rank,
    required this.payout,
    required this.isMe,
    required this.colors,
  });
  final int rank;
  final int payout;
  final bool isMe;
  final SarhnyColors colors;

  Color get _rankColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD54F);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return colors.textSecondary;
    }
  }

  String get _rankLabel {
    switch (rank) {
      case 1:
        return 'الأول';
      case 2:
        return 'الثاني';
      case 3:
        return 'الثالث';
      case 4:
        return 'الرابع';
      default:
        return '#$rank';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe
              ? colors.crystal.withValues(alpha: 0.6)
              : colors.border.withValues(alpha: 0.6),
          width: isMe ? 1.4 : 0.8,
        ),
        boxShadow: isMe
            ? [
                BoxShadow(
                  color: colors.crystal.withValues(alpha: 0.18),
                  blurRadius: 14,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _rankColor.withValues(alpha: 0.25),
              border: Border.all(color: _rankColor, width: 1.4),
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: TextStyle(
                color: _rankColor,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isMe ? '$_rankLabel · أنت' : _rankLabel,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            payout >= 0 ? '+$payout ✦' : '$payout ✦',
            style: TextStyle(
              color: payout >= 0 ? colors.crystal : colors.danger,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress});
  final double progress;

  static final _palette = [
    const Color(0xFFE53935),
    const Color(0xFF43A047),
    const Color(0xFFFDD835),
    const Color(0xFF1E88E5),
    const Color(0xFFD4AF37),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(7);
    for (int i = 0; i < 60; i++) {
      final x = rng.nextDouble() * size.width;
      final yStart = -20 + rng.nextDouble() * 40;
      final fall = progress * (size.height + 80);
      final y = yStart + fall * (0.6 + rng.nextDouble() * 0.6);
      final rot = progress * 4 + rng.nextDouble() * 6;
      final color = _palette[i % _palette.length];

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      canvas.drawRect(
        const Rect.fromLTWH(-4, -2, 8, 4),
        Paint()
          ..color = color.withValues(alpha: (1 - progress).clamp(0.0, 1.0)),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.progress != progress;
}
