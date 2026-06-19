import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late final AnimationController _spiral = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );
  late final AnimationController _trophyBob = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  bool _reducedMotion = false;
  bool _haptifiedWin = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.invalidate(ludoWalletProvider);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    _reducedMotion = disableAnimations;
    _applyMotionPrefs();
  }

  void _applyMotionPrefs() {
    if (_reducedMotion) {
      _confetti.stop();
      _spiral.stop();
      _trophyBob.stop();
    } else {
      if (!_confetti.isAnimating &&
          _confetti.status != AnimationStatus.completed) {
        _confetti.forward();
      }
      if (!_spiral.isAnimating &&
          _spiral.status != AnimationStatus.completed) {
        _spiral.forward();
      }
      if (!_trophyBob.isAnimating) {
        _trophyBob.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    _spiral.dispose();
    _trophyBob.dispose();
    super.dispose();
  }

  void _maybeWinHaptic({required bool youWon}) {
    if (!youWon || _haptifiedWin) return;
    _haptifiedWin = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        HapticFeedback.heavyImpact();
      });
    });
  }

  Future<void> _tapHaptic() async {
    await HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final myUserId = ref.watch(authStateProvider).value?.userId;
    final youWon = myUserId != null && myUserId == widget.outcome.winnerId;

    // Trigger heavy haptic once on winner path.
    _maybeWinHaptic(youWon: youWon);

    final sortedRanks = [...widget.outcome.ranks]
      ..sort((a, b) => a.rank.compareTo(b.rank));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.go(AppRoutes.ludoLobby);
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Stack(
            children: [
              // confetti (skipped under reduced motion)
              if (!_reducedMotion)
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
              // spiral confetti layer (skipped under reduced motion)
              if (!_reducedMotion)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _spiral,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _SpiralConfettiPainter(
                          progress: _spiral.value,
                        ),
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
                      // Reduced motion → static (no bob, no rotation).
                      if (_reducedMotion) {
                        return Text(
                          youWon ? '🏆' : '🎲',
                          style: const TextStyle(fontSize: 84),
                        );
                      }
                      // Bob: ±10px sine.
                      final lift = 10 * math.sin(_trophyBob.value * math.pi);
                      // Rotation: ±3° on a sine wave 1.5× slower than the
                      // bob. Period_bob = 2× ctrl_dur, so rotation period =
                      // 1.5× that → angular frequency = (1/1.5) × bob freq.
                      final rotDeg = 3 *
                          math.sin(_trophyBob.value * math.pi / 1.5);
                      final rotRad = rotDeg * math.pi / 180.0;
                      return Transform.translate(
                        offset: Offset(0, -lift),
                        child: Transform.rotate(
                          angle: rotRad,
                          child: Text(
                            youWon ? '🏆' : '🎲',
                            style: const TextStyle(fontSize: 84),
                          ),
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
                  // Action buttons — two-row layout.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      children: [
                        // PRIMARY: back to lobby — full-width, height 56.
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton.icon(
                            onPressed: () async {
                              await _tapHaptic();
                              if (!context.mounted) return;
                              context.go(AppRoutes.ludoLobby);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: colors.crystal,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(56),
                            ),
                            icon: const Icon(Icons.home_rounded),
                            label: const Text(
                              'العودة للوبي',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // SECONDARY: side-by-side text buttons, ≥ 48dp tap
                        // targets.
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: TextButton.icon(
                                  onPressed: () async {
                                    await _tapHaptic();
                                    if (!context.mounted) return;
                                    context.go(AppRoutes.ludoLobby);
                                  },
                                  icon: const Icon(Icons.replay_rounded),
                                  label: const Text('مباراة جديدة'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: TextButton.icon(
                                  onPressed: () async {
                                    await _tapHaptic();
                                    if (!context.mounted) return;
                                    context.go(AppRoutes.gamesHub);
                                  },
                                  icon: const Icon(Icons.grid_view_rounded),
                                  label: const Text('الساحة'),
                                ),
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
    // 4th place → 70% opacity to communicate "last".
    final tile = Container(
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
          // Rank badge with subtle gold glow for 1st place.
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _rankColor.withValues(alpha: 0.25),
              border: Border.all(color: _rankColor, width: 1.4),
              boxShadow: rank == 1
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.30),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
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
    if (rank == 4) {
      return Opacity(opacity: 0.70, child: tile);
    }
    return tile;
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
    // Doubled density: 60 → 120.
    for (int i = 0; i < 120; i++) {
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

/// Secondary confetti layer: 40 particles that follow an Archimedean
/// spiral path inward from the screen edges. r(θ) = a + b·θ, traced
/// in reverse over the 3-second life. Color palette mirrors the main
/// confetti for cohesion.
class _SpiralConfettiPainter extends CustomPainter {
  _SpiralConfettiPainter({required this.progress});
  final double progress;

  static const int _count = 40;

  static final _palette = [
    const Color(0xFFE53935),
    const Color(0xFF43A047),
    const Color(0xFFFDD835),
    const Color(0xFF1E88E5),
    const Color(0xFFD4AF37),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Outer radius = distance from center to a corner.
    final outerR = math.sqrt(
          size.width * size.width + size.height * size.height,
        ) /
        2;
    // Archimedean spiral params: r = a + b·θ. Sweep ~3 turns inward.
    const turns = 3.0;
    final thetaMax = 2 * math.pi * turns;
    final a = 6.0;
    final b = (outerR - a) / thetaMax;
    final fade = (1 - progress).clamp(0.0, 1.0);

    for (int i = 0; i < _count; i++) {
      // Each particle has a small θ-phase offset so they spiral as a
      // distributed swarm rather than a line.
      final phase = (i / _count) * 2 * math.pi;
      // Inward: at t=0 → θ_max (edge), at t=1 → 0 (center).
      final theta = thetaMax * (1 - progress) + phase * 0.5;
      final r = a + b * theta;
      final pos = Offset(
        center.dx + r * math.cos(theta + phase),
        center.dy + r * math.sin(theta + phase),
      );
      if (pos.dx < -10 ||
          pos.dx > size.width + 10 ||
          pos.dy < -10 ||
          pos.dy > size.height + 10) {
        continue;
      }
      final color = _palette[i % _palette.length];
      final rot = theta + phase;
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(rot);
      canvas.drawRect(
        const Rect.fromLTWH(-3, -1.5, 6, 3),
        Paint()..color = color.withValues(alpha: fade),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SpiralConfettiPainter old) =>
      old.progress != progress;
}
