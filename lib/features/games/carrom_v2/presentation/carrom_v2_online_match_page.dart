import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/haptics/game_haptics.dart';
import '../application/carrom_v2_controller.dart';
import '../world/board_dimensions.dart';
import '../world/carrom_world.dart';
import 'carrom_aim_overlay_v2.dart';

/// Online Carrom v2 match — wraps the Forge2D world in WS-driven state.
/// Each local shot is submitted to the server; remote shots are replayed
/// via World.applyRemoteOutcome.
class CarromV2OnlineMatchPage extends ConsumerStatefulWidget {
  const CarromV2OnlineMatchPage({
    super.key,
    required this.roomId,
    required this.mySeat,
  });
  final String roomId;
  final Seat mySeat;

  @override
  ConsumerState<CarromV2OnlineMatchPage> createState() =>
      _CarromV2OnlineMatchPageState();
}

class _CarromV2OnlineMatchPageState
    extends ConsumerState<CarromV2OnlineMatchPage> {
  late final CarromWorld _world;
  StreamSubscription<CarromV2RemoteShot>? _remoteSub;
  StreamSubscription<ShotOutcome>? _localSub;
  bool _navigatedToOver = false;

  @override
  void initState() {
    super.initState();
    _world = CarromWorld(mySeat: widget.mySeat);
    // Subscribe to local shot outcomes — forward to the server.
    _localSub = _world.outcomes.listen((out) {
      if (!mounted) return;
      final params = CarromV2WsParams(
        roomId: widget.roomId,
        mySeat: widget.mySeat,
      );
      final ctrl = ref.read(carromV2ControllerProvider(params).notifier);
      ctrl.submitLocalShot(
        pocketedIds: out.pocketedIds,
        strikerPocketed: out.strikerPocketed,
        queenPocketed: out.queenPocketed,
        firstPieceHitId: out.firstPieceHitId,
      );
      // Pre-emptively re-arm so the user sees their striker reset
      // immediately; the server's `state` echo corrects turn assignment.
      _world.rearmFor(nextShooter: widget.mySeat);
    });
  }

  @override
  void dispose() {
    _remoteSub?.cancel();
    _localSub?.cancel();
    super.dispose();
  }

  void _bindStreamsIfNeeded() {
    final params = CarromV2WsParams(
      roomId: widget.roomId,
      mySeat: widget.mySeat,
    );
    final ctrl = ref.read(carromV2ControllerProvider(params).notifier);
    _remoteSub ??= ctrl.remoteShots.listen((shot) {
      _world.applyRemoteOutcome(
        pocketedIds: shot.pocketedIds,
        strikerPocketed: shot.strikerPocketed,
        nextShooter: shot.nextTurnIsMine ? widget.mySeat : _oppSeat,
      );
    });
  }

  Seat get _oppSeat => widget.mySeat == Seat.a ? Seat.b : Seat.a;

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final params = CarromV2WsParams(
      roomId: widget.roomId,
      mySeat: widget.mySeat,
    );
    final snap = ref.watch(carromV2ControllerProvider(params));
    _bindStreamsIfNeeded();

    // Game over → navigate.
    if (snap.isFinished && !_navigatedToOver) {
      _navigatedToOver = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // Inline simple game-over: show a SnackBar then route to hub.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snap.iWon ? 'فزت! 🏆' : 'لقد خسرت'),
            backgroundColor:
                snap.iWon ? const Color(0xFF2D8B5C) : const Color(0xFFD22F2F),
          ),
        );
        Future<void>.delayed(const Duration(milliseconds: 1500), () {
          if (!mounted) return;
          if (!context.mounted) return;
          context.go(AppRoutes.gamesHub);
        });
      });
    }

    return PopScope(
      canPop: snap.isFinished,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (snap.isFinished) {
          if (!context.mounted) return;
          context.go(AppRoutes.gamesHub);
          return;
        }
        final confirmed = await _confirmConcede(context, colors);
        if (!confirmed) return;
        if (!context.mounted) return;
        // Fire-and-forget; server will broadcast a state update.
        await ref.read(carromV2ApiProvider).concede(widget.roomId);
        if (!context.mounted) return;
        context.go(AppRoutes.gamesHub);
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close_rounded, color: colors.textPrimary),
            onPressed: () async {
              GameHaptics.tap();
              if (snap.isFinished) {
                context.go(AppRoutes.gamesHub);
                return;
              }
              final confirmed = await _confirmConcede(context, colors);
              if (!confirmed) return;
              if (!context.mounted) return;
              await ref.read(carromV2ApiProvider).concede(widget.roomId);
              if (!context.mounted) return;
              context.go(AppRoutes.gamesHub);
            },
          ),
          title: Text(
            'كيرم — أونلاين',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _Score(label: 'أنت', value: snap.myScore, color: colors.moment),
                  const Gap(6),
                  _Score(label: 'خصم', value: snap.oppScore, color: colors.face),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (!snap.connectionUp)
                Container(
                  width: double.infinity,
                  color: const Color(0xFFD22F2F).withValues(alpha: 0.15),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  alignment: Alignment.center,
                  child: const Text(
                    'إعادة الاتصال…',
                    style: TextStyle(
                      color: Color(0xFFD22F2F),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              if (snap.opponentLeft)
                Container(
                  width: double.infinity,
                  color: const Color(0xFFD89A2D).withValues(alpha: 0.15),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  alignment: Alignment.center,
                  child: const Text(
                    'خصمك غادر — تنتظر العودة',
                    style: TextStyle(
                      color: Color(0xFFB8741F),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
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
                              enabled: snap.isMyTurn &&
                                  _world.phase == WorldPhase.aiming &&
                                  !snap.isFinished,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              const Gap(10),
              _TurnPill(
                isMyTurn: snap.isMyTurn,
                isFinished: snap.isFinished,
                colors: colors,
              ),
              const Gap(12),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmConcede(BuildContext ctx, SarhnyColors colors) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (c) => Dialog(
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
                child: const Icon(Icons.flag_outlined,
                    color: Color(0xFFD22F2F), size: 32),
              ),
              const Gap(12),
              Text(
                'الاستسلام؟',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const Gap(6),
              Text(
                'سيفوز خصمك بهذه المباراة.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(c).pop(false),
                      child: const Text('متابعة'),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFD22F2F),
                      ),
                      onPressed: () => Navigator.of(c).pop(true),
                      child: const Text('استسلم'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return ok == true;
  }
}

class _Score extends StatelessWidget {
  const _Score({required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.40), width: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              )),
          const Gap(4),
          Text('$value',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              )),
        ],
      ),
    );
  }
}

class _TurnPill extends StatelessWidget {
  const _TurnPill({
    required this.isMyTurn,
    required this.isFinished,
    required this.colors,
  });
  final bool isMyTurn;
  final bool isFinished;
  final SarhnyColors colors;
  @override
  Widget build(BuildContext context) {
    final String text;
    final Color accent;
    if (isFinished) {
      text = 'انتهت المباراة';
      accent = colors.textSecondary;
    } else if (isMyTurn) {
      text = 'دورك — صوّب';
      accent = colors.crystal;
    } else {
      text = 'انتظار خصمك…';
      accent = colors.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.30), width: 0.8),
      ),
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
