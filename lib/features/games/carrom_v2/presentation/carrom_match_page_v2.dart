import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/haptics/game_haptics.dart';
import '../world/board_dimensions.dart';
import '../world/carrom_world.dart';
import 'carrom_aim_overlay_v2.dart';

/// Carrom v2 match page — local-authoritative gameplay built on Box2D.
///
/// Design intent for this first cut:
///   * Client owns the physics + outcome (single-device demo + practice mode).
///   * After every shot, the page transitions through the WorldPhase state
///     machine and updates a local scoreboard.
///   * Multiplayer wiring (sending shot outcomes to the backend, applying
///     remote opponent shots) is a follow-up — kept the World API designed
///     for it so the seam is clean.
class CarromMatchPageV2 extends StatefulWidget {
  const CarromMatchPageV2({super.key});

  @override
  State<CarromMatchPageV2> createState() => _CarromMatchPageV2State();
}

class _CarromMatchPageV2State extends State<CarromMatchPageV2> {
  late final CarromWorld _world;
  int _myScore = 0;
  final int _opponentScore = 0;
  String? _lastFoulReason; // null = no foul
  bool _matchOver = false;

  @override
  void initState() {
    super.initState();
    // Solo / practice mode — both sides controlled by local seat A.
    _world = CarromWorld(mySeat: Seat.a);
  }

  Future<void> _confirmAndConcede() async {
    final colors = context.sarhnyColors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0x33D22F2F),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFD22F2F),
                  size: 36,
                ),
              ),
              const Gap(12),
              Text(
                'هل تخرج من المباراة؟',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Gap(6),
              Text(
                'سيتم احتساب الجولة الحالية كخسارة.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('متابعة'),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFD22F2F),
                      ),
                      onPressed: () {
                        GameHaptics.uiPop();
                        Navigator.of(ctx).pop(true);
                      },
                      icon: const Icon(Icons.flag_outlined, size: 16),
                      label: const Text('خروج'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (ok == true && mounted) {
      context.go(AppRoutes.gamesHub);
    }
  }

  void _onShotSettled(ShotOutcome out) {
    // Local rules — simple v1:
    //   * Striker pocketed → -1 score (foul), turn passes.
    //   * Queen (id 0) pocketed → +5.
    //   * Other piece pocketed → +1 each.
    //   * No piece hit → foul, turn passes.
    var delta = 0;
    String? foul;
    if (out.strikerPocketed) {
      delta -= 1;
      foul = 'striker_pocketed';
    }
    if (out.firstPieceHitId == -1) {
      foul ??= 'no_piece_hit';
    }
    for (final id in out.pocketedIds) {
      if (id == 0) {
        delta += 5;
      } else {
        delta += 1;
      }
    }

    setState(() {
      _myScore += delta;
      _lastFoulReason = foul;
    });

    // Re-arm striker at centre, stay on my turn (practice mode).
    _world.rearmFor(nextShooter: Seat.a, atX: 0);

    // First-to-25 wins in practice mode.
    if (_myScore >= 25) {
      setState(() => _matchOver = true);
    }
  }

  /// Listen for the world's current shot future once it appears, then
  /// hand the outcome back to the page.
  void _bindShotListener() {
    final f = _world.currentShotFuture;
    if (f == null) return;
    f.then((out) {
      if (mounted) _onShotSettled(out);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return PopScope(
      canPop: _matchOver,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_matchOver) {
          context.go(AppRoutes.gamesHub);
          return;
        }
        await _confirmAndConcede();
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close_rounded, color: colors.textPrimary),
            onPressed: () {
              GameHaptics.tap();
              _confirmAndConcede();
            },
          ),
          title: Text(
            'كيرم',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          centerTitle: false,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _ScoreChip(label: 'أنت', value: _myScore, accent: colors.moment),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (_lastFoulReason != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  child: _FoulBanner(reason: _lastFoulReason!),
                ),
              const Gap(8),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final pxSize = c.maxWidth;
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: GameWidget<CarromWorld>(game: _world),
                            ),
                            CarromAimOverlayV2(
                              world: _world,
                              boardPixelSize: pxSize,
                              enabled: !_matchOver &&
                                  _world.phase == WorldPhase.aiming,
                            ),
                            if (_matchOver)
                              _MatchOverOverlay(
                                myScore: _myScore,
                                opponentScore: _opponentScore,
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              const Gap(8),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatusPill(
                        text: _matchOver
                            ? 'انتهت المباراة'
                            : _world.phase == WorldPhase.shooting
                                ? 'في الهواء…'
                                : 'دورك — صوّب',
                        accent: colors.crystal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hook into phase transitions — bind a fresh shot listener after every
    // build so completed shots emit their outcome to this page.
    WidgetsBinding.instance.addPostFrameCallback((_) => _bindShotListener());
  }
}

// ─────────────────────────────────────────────────────────────────────
// Small score chip
// ─────────────────────────────────────────────────────────────────────

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.label, required this.value, required this.accent});
  final String label;
  final int value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.40), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(6),
          Text(
            '$value',
            style: TextStyle(
              color: accent,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Foul banner (translates server-stable keys to Arabic)
// ─────────────────────────────────────────────────────────────────────

class _FoulBanner extends StatelessWidget {
  const _FoulBanner({required this.reason});
  final String reason;

  static const Map<String, String> _map = {
    'striker_pocketed': 'خطأ: المضرب دخل في الجيب',
    'no_piece_hit': 'خطأ: لم تلمس قطعة',
    'wrong_color': 'خطأ: لمست قطعة الخصم أولاً',
    'queen_uncovered': 'خطأ: التاج بدون تغطية',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xCCD22F2F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.white, size: 14),
          const Gap(6),
          Text(
            _map[reason] ?? 'خطأ في الرمية',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Status pill (bottom)
// ─────────────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.accent});
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.30), width: 0.8),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: accent,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Game-over overlay
// ─────────────────────────────────────────────────────────────────────

class _MatchOverOverlay extends StatelessWidget {
  const _MatchOverOverlay({required this.myScore, required this.opponentScore});
  final int myScore;
  final int opponentScore;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.55),
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2421),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD4A85F), width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 48)),
            const Gap(8),
            const Text(
              'فزت!',
              style: TextStyle(
                color: Color(0xFFD4A85F),
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
            const Gap(6),
            Text(
              '$myScore × $opponentScore',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const Gap(16),
            FilledButton.icon(
              onPressed: () => GoRouter.of(context).go(AppRoutes.gamesHub),
              icon: const Icon(Icons.home_rounded, size: 16),
              label: const Text('العودة للوبي'),
            ),
          ],
        ),
      ),
    );
  }
}
