import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../core/ads/interstitial_service.dart';
import '../engine/ludo_engine.dart';
import '../theme/ludo_theme.dart';
import '../widgets/ludo_board_painter.dart';
import '../widgets/ludo_dice.dart';
import '../widgets/ludo_pawn.dart';

/// Full-screen Ludo-Power match. `playerCount` chooses 2-player (1v1 vs bot)
/// or 4-player (1v3 vs bots) mode — the engine handles the rest.
class LudoPowerMatchPage extends ConsumerStatefulWidget {
  final int playerCount;
  const LudoPowerMatchPage({super.key, this.playerCount = 4})
      : assert(playerCount == 2 || playerCount == 4);

  @override
  ConsumerState<LudoPowerMatchPage> createState() => _LudoPowerMatchPageState();
}

class _LudoPowerMatchPageState extends ConsumerState<LudoPowerMatchPage> {
  late LudoEngine engine;
  String? message;
  bool busy = false;
  String? toastMsg;
  Timer? _toastTimer;
  int diceShown = 6;

  @override
  void initState() {
    super.initState();
    engine = LudoEngine(onEvent: _onEvent, playerCount: widget.playerCount);
    // Warm the interstitial in the background so the next every-3-matches
    // trigger fires instantly without a 6-second blocking load.
    ref.read(interstitialAdServiceProvider).preload().catchError((_) {});
  }

  void _onEvent(GameEvent e) {
    switch (e.kind) {
      case 'rocket':
      case 'freeze':
      case 'portal':
      case 'tornado':
      case 'capture':
      case 'shuffle':
        _showToast(_eventMessage(e));
        break;
      case 'win':
        // Count the match in the cross-game interstitial cadence and show
        // the winner dialog. The ad (if due) plays after the user dismisses
        // the celebration via "New game" so it never interrupts the moment.
        ref
            .read(interstitialAdServiceProvider)
            .onMatchCompleted()
            .catchError((_) => false);
        _showWin(e.player!);
        break;
    }
  }

  String _eventMessage(GameEvent e) {
    final l10n = AppLocalizations.of(context);
    switch (e.messageKey) {
      case 'ludoEventCapture':
        return l10n.ludoEventCapture;
      case 'ludoEventShuffle':
        return l10n.ludoEventShuffle;
      case 'ludoEventRocket':
        return l10n.ludoEventRocket(e.messageArgs?['boost'] as int? ?? 0);
      case 'ludoEventFreeze':
        return l10n.ludoEventFreeze;
      case 'ludoEventPortalForward':
        return l10n.ludoEventPortalForward(
            e.messageArgs?['diff'] as int? ?? 0);
      case 'ludoEventPortalBack':
        return l10n.ludoEventPortalBack(e.messageArgs?['diff'] as int? ?? 0);
      case 'ludoEventTornado':
        return l10n.ludoEventTornado;
      default:
        return '';
    }
  }

  String _playerName(int p) {
    final l10n = AppLocalizations.of(context);
    return switch (p) {
      0 => l10n.ludoPlayerGold,
      1 => l10n.ludoPlayerBlue,
      2 => l10n.ludoPlayerPurple,
      3 => l10n.ludoPlayerGreen,
      _ => '',
    };
  }

  void _showToast(String m) {
    if (m.isEmpty) return;
    setState(() => toastMsg = m);
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => toastMsg = null);
    });
  }

  Future<void> _roll() async {
    if (busy ||
        engine.rolled ||
        engine.gameOver ||
        engine.current != LudoEngine.humanPlayer) {
      return;
    }
    setState(() => busy = true);
    for (int i = 0; i < 9; i++) {
      setState(() => diceShown = 1 + (DateTime.now().microsecond % 6));
      await Future.delayed(const Duration(milliseconds: 55));
    }
    final v = engine.rollDice();
    setState(() {
      diceShown = v;
      busy = false;
    });
    _afterRoll();
  }

  void _afterRoll() {
    final moves = engine.legalMoves(engine.current, engine.dice);
    if (moves.isEmpty) {
      _showToast(AppLocalizations.of(context).ludoNoMove);
      Future.delayed(const Duration(milliseconds: 700), _endTurn);
      return;
    }
    if (engine.current == LudoEngine.humanPlayer) {
      setState(() => message = AppLocalizations.of(context).ludoTapPawn);
    } else {
      Future.delayed(const Duration(milliseconds: 550),
          () => _doMove(engine.botChoose(moves)));
    }
  }

  Future<void> _doMove(Move m) async {
    setState(() => busy = true);
    final player = engine.current;
    final extra = engine.applyMove(player, m);
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 350));
    if (engine.gameOver) {
      setState(() => busy = false);
      return;
    }
    setState(() => busy = false);
    if (extra) {
      engine.rolled = false;
      setState(() => diceShown = 6);
      if (player == LudoEngine.humanPlayer) {
        setState(() => message = AppLocalizations.of(context).ludoExtraTurn);
      } else {
        Future.delayed(const Duration(milliseconds: 500), _rollForBot);
      }
    } else {
      _endTurn();
    }
  }

  void _endTurn() {
    engine.endTurn();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      diceShown = 6;
      message = engine.current == LudoEngine.humanPlayer
          ? l10n.ludoYourTurn
          : l10n.ludoBotTurn(_playerName(engine.current));
    });
    if (engine.current != LudoEngine.humanPlayer && !engine.gameOver) {
      Future.delayed(const Duration(milliseconds: 600), _rollForBot);
    }
  }

  Future<void> _rollForBot() async {
    if (engine.gameOver) return;
    setState(() => busy = true);
    for (int i = 0; i < 6; i++) {
      setState(() => diceShown = 1 + (DateTime.now().microsecond % 6));
      await Future.delayed(const Duration(milliseconds: 50));
    }
    final v = engine.rollDice();
    setState(() {
      diceShown = v;
      busy = false;
    });
    _afterRoll();
  }

  void _tapBoard(Offset local, double boardSize) {
    if (busy ||
        !engine.rolled ||
        engine.gameOver ||
        engine.current != LudoEngine.humanPlayer) {
      return;
    }
    final s = boardSize / 15.0;
    final gx = local.dx / s, gy = local.dy / s;
    final moves = engine.legalMoves(LudoEngine.humanPlayer, engine.dice);
    Move? pick;
    double pd = 1e9;
    for (final m in moves) {
      final g = engine.gridOf(LudoEngine.humanPlayer, m.from, m.piece);
      final d = (g[0] - gx) * (g[0] - gx) + (g[1] - gy) * (g[1] - gy);
      if (d < pd) {
        pd = d;
        pick = m;
      }
    }
    if (pick != null && pd < 1.7) _doMove(pick);
  }

  void _showWin(int player) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: RoyalTheme.panelSolid,
        title: Text(
          player == LudoEngine.humanPlayer
              ? l10n.ludoYouWin
              : l10n.ludoBotWin(_playerName(player)),
          style: const TextStyle(color: RoyalTheme.textLight),
          textAlign: TextAlign.center,
        ),
        content: Text(
          player == LudoEngine.humanPlayer
              ? l10n.ludoYouWinSub
              : l10n.ludoLossSub,
          style: TextStyle(color: RoyalTheme.textLight.withValues(alpha: 0.8)),
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: RoyalTheme.goldAccent),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  engine.reset();
                  diceShown = 6;
                  message = null;
                });
              },
              child: Text(
                l10n.ludoNewGame,
                style: const TextStyle(
                    color: RoyalTheme.goldDeep, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final effectiveMessage = message ?? l10n.ludoStartTap;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RoyalTheme.appBgBottom,
        body: Container(
          decoration: const BoxDecoration(gradient: RoyalTheme.appBg),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 4),
                    _topBar(l10n),
                    const SizedBox(height: 10),
                    _turnBar(l10n),
                    const SizedBox(height: 10),
                    Expanded(child: Center(child: _board())),
                    const SizedBox(height: 8),
                    Text(
                      effectiveMessage,
                      style: TextStyle(
                        color: RoyalTheme.textLight.withValues(alpha: 0.67),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    LudoDice(
                      value: diceShown,
                      onTap: _roll,
                      enabled: !busy &&
                          !engine.rolled &&
                          engine.current == LudoEngine.humanPlayer &&
                          !engine.gameOver,
                    ),
                    const SizedBox(height: 4),
                    Text(l10n.ludoRollDice,
                        style: const TextStyle(
                            color: RoyalTheme.goldAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                    const SizedBox(height: 12),
                  ],
                ),
                if (toastMsg != null)
                  Positioned(
                    top: 70,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: RoyalTheme.panelSolid,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: RoyalTheme.goldAccent
                                  .withValues(alpha: 0.6)),
                        ),
                        child: Text(
                          toastMsg!,
                          style: const TextStyle(
                              color: RoyalTheme.textLight,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 8, 0),
      child: Row(
        children: [
          IconButton(
            tooltip: l10n.actionBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: RoyalTheme.textLight, size: 20),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              }
            },
          ),
          const Spacer(),
          Text(
            widget.playerCount == 2
                ? l10n.ludoMode2Players
                : l10n.ludoMode4Players,
            style: TextStyle(
                color: RoyalTheme.textLight.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _turnBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: RoyalTheme.panelSolid,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: RoyalTheme.panelBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('♛ ',
              style:
                  TextStyle(color: RoyalTheme.goldAccent, fontSize: 16)),
          Text(
            l10n.ludoTurnLabel(_playerName(engine.current)),
            style: const TextStyle(
                color: RoyalTheme.textLight,
                fontWeight: FontWeight.bold,
                fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _board() {
    return LayoutBuilder(builder: (context, constraints) {
      final size =
          constraints.biggest.shortestSide.clamp(0.0, 460.0).toDouble();
      return GestureDetector(
        onTapDown: (d) => _tapBoard(d.localPosition, size),
        child: Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: RoyalTheme.goldFrame,
            borderRadius: BorderRadius.circular(size * 0.05),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x88000000),
                  blurRadius: 16,
                  offset: Offset(0, 6))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.04),
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(size - 16, size - 16),
                  painter: LudoBoardPainter(engine),
                ),
                ..._buildPawns(size - 16),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// Builds pawn widgets layered on top of the board. Pieces sharing a cell
  /// fan out in a small circle so overlapping stacks remain distinguishable.
  /// In 2-player mode the inactive seats never have pieces leave the yard
  /// (their `pieces[p]` stays all-zero), so they render as ambient decoration.
  List<Widget> _buildPawns(double boardSize) {
    final s = boardSize / 15.0;
    final widgets = <Widget>[];
    final Map<String, List<List<int>>> occ = {};
    for (final p in engine.activePlayers) {
      for (int i = 0; i < 4; i++) {
        final g = engine.gridOf(p, engine.pieces[p][i], i);
        final key = '${g[0].toStringAsFixed(2)},${g[1].toStringAsFixed(2)}';
        occ.putIfAbsent(key, () => []).add([p, i]);
      }
    }
    occ.forEach((key, list) {
      for (int k = 0; k < list.length; k++) {
        final p = list[k][0], i = list[k][1];
        final g = engine.gridOf(p, engine.pieces[p][i], i);
        double ox = 0, oy = 0;
        final prog = engine.pieces[p][i];
        if (list.length > 1 && prog >= 1 && prog <= 51) {
          final ang = (k / list.length) * 6.2831853;
          ox = 0.16 * s * math.cos(ang);
          oy = 0.16 * s * math.sin(ang);
        }
        final pawnSize = s * 0.85;
        final cx = g[0] * s + ox, cy = g[1] * s + oy;
        widgets.add(Positioned(
          left: cx - pawnSize / 2,
          top: cy - pawnSize * 1.5 + s * 0.45,
          child: LudoPawn(
            colorKey: BoardScheme.playerColors[p],
            size: pawnSize,
            glow: engine.isMovable(p, i),
          ),
        ));
      }
    });
    return widgets;
  }
}
