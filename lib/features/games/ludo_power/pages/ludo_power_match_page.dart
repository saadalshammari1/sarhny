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
import '../widgets/player_seat.dart';

/// Pacing constants — chosen so the table feels deliberate, not frantic.
/// Each bot's turn becomes a small choreographed beat the user can watch:
/// "X is thinking" → roll animation → 800ms dwell on dice → move → 600ms
/// post-move dwell → next seat. The full bot loop sits at ~3.5s rather
/// than the ~1s it used to be — closer to a real table game.
const Duration _kRollSpinDuration = Duration(milliseconds: 1200);
const Duration _kBotThinkDuration = Duration(milliseconds: 1100);
const Duration _kPostRollDwell = Duration(milliseconds: 800);
const Duration _kPostMoveDwell = Duration(milliseconds: 650);
const Duration _kTurnHandoffDwell = Duration(milliseconds: 450);

/// Full-screen Ludo-Power match.
/// `playerCount` chooses 2-player (1v1 vs anonymous opponent) or 4-player
/// (1v3) mode. Opponents are addressed anonymously as "الخصم ١/٢/٣"
/// regardless of whether they're bots — keeps the user's mental model
/// consistent with Sarhny's anonymity ethos and ports cleanly when real
/// online opponents land.
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
  bool _isRollingDice = false; // drives the dice spin animation
  String? toastMsg;
  Timer? _toastTimer;
  int diceShown = 6;
  // Per-player last-dice values for the corner mini-dice indicators.
  // 6 is the visual neutral state before the player has rolled.
  final List<int> _lastDicePerPlayer = [6, 6, 6, 6];

  @override
  void initState() {
    super.initState();
    engine = LudoEngine(onEvent: _onEvent, playerCount: widget.playerCount);
    ref.read(interstitialAdServiceProvider).preload().catchError((_) {});
  }

  // ─── Event handling ────────────────────────────────────────────────────
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

  /// Anonymous names: the user is "You" (`أنت`) and every opponent is
  /// numbered. In 4-player mode we number them 1,2,3 based on their seat
  /// index relative to the human (so the player above is "1", to the side
  /// "2", diagonal "3"). In 2-player there's just one opponent.
  String _playerName(int p) {
    final l10n = AppLocalizations.of(context);
    if (p == LudoEngine.humanPlayer) return l10n.ludoPlayerYou;
    if (widget.playerCount == 2) {
      // Single opponent — drop the number to keep the chip uncluttered.
      return l10n.ludoOpponentN(1);
    }
    // 4-player: number opponents 1,2,3 in the engine's clockwise order.
    final activeOpponents = engine.activePlayers
        .where((x) => x != LudoEngine.humanPlayer)
        .toList();
    final idx = activeOpponents.indexOf(p);
    return l10n.ludoOpponentN(idx + 1);
  }

  void _showToast(String m) {
    if (m.isEmpty) return;
    setState(() => toastMsg = m);
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => toastMsg = null);
    });
  }

  // ─── Roll & move flow ─────────────────────────────────────────────────
  Future<void> _roll() async {
    if (busy ||
        engine.rolled ||
        engine.gameOver ||
        engine.current != LudoEngine.humanPlayer) {
      return;
    }
    await _animateRollAndCommit(LudoEngine.humanPlayer);
    _afterRoll();
  }

  /// Centralised roll choreography for both human + bot. Starts the spin
  /// animation, plays it for the full duration, locks the result, briefly
  /// dwells so the user can READ the value, then returns.
  Future<void> _animateRollAndCommit(int player) async {
    setState(() {
      busy = true;
      _isRollingDice = true;
    });
    // Animate "fake" dice values during the spin so the corner mini-dice
    // shimmers too.
    final spinFrames = (_kRollSpinDuration.inMilliseconds / 80).round();
    for (int i = 0; i < spinFrames; i++) {
      if (!mounted) return;
      setState(() {
        final fake = 1 + (DateTime.now().microsecond % 6);
        diceShown = fake;
        _lastDicePerPlayer[player] = fake;
      });
      await Future.delayed(const Duration(milliseconds: 80));
    }
    final v = engine.rollDice();
    if (!mounted) return;
    setState(() {
      diceShown = v;
      _lastDicePerPlayer[player] = v;
      _isRollingDice = false;
    });
    await Future.delayed(_kPostRollDwell);
    setState(() => busy = false);
  }

  void _afterRoll() {
    final moves = engine.legalMoves(engine.current, engine.dice);
    if (moves.isEmpty) {
      _showToast(AppLocalizations.of(context).ludoNoMove);
      Future.delayed(_kTurnHandoffDwell, _endTurn);
      return;
    }
    if (engine.current == LudoEngine.humanPlayer) {
      setState(() => message = AppLocalizations.of(context).ludoTapPawn);
    } else {
      Future.delayed(const Duration(milliseconds: 700),
          () => _doMove(engine.botChoose(moves)));
    }
  }

  Future<void> _doMove(Move m) async {
    setState(() => busy = true);
    final player = engine.current;
    final extra = engine.applyMove(player, m);
    setState(() {});
    await Future.delayed(_kPostMoveDwell);
    if (engine.gameOver) {
      setState(() => busy = false);
      return;
    }
    setState(() => busy = false);
    if (extra) {
      engine.rolled = false;
      if (player == LudoEngine.humanPlayer) {
        setState(() => message = AppLocalizations.of(context).ludoExtraTurn);
      } else {
        Future.delayed(_kTurnHandoffDwell, _rollForBot);
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
          : l10n.ludoBotThinking;
    });
    if (engine.current != LudoEngine.humanPlayer && !engine.gameOver) {
      Future.delayed(_kBotThinkDuration, _rollForBot);
    }
  }

  Future<void> _rollForBot() async {
    if (engine.gameOver || !mounted) return;
    await _animateRollAndCommit(engine.current);
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
                  for (int i = 0; i < 4; i++) {
                    _lastDicePerPlayer[i] = 6;
                  }
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

  // ─── Build ────────────────────────────────────────────────────────────
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
                    _topBar(l10n),
                    const SizedBox(height: 6),
                    Expanded(child: Center(child: _boardWithSeats(l10n))),
                    const SizedBox(height: 8),
                    Text(
                      effectiveMessage,
                      style: TextStyle(
                        color: RoyalTheme.textLight.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LudoDice(
                      value: diceShown,
                      rolling: _isRollingDice &&
                          engine.current == LudoEngine.humanPlayer,
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
                    const SizedBox(height: 14),
                  ],
                ),
                if (toastMsg != null) _toastBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 6, 8, 0),
      child: Row(
        children: [
          IconButton(
            tooltip: l10n.actionBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: RoyalTheme.textLight, size: 20),
            onPressed: () {
              if (context.canPop()) context.pop();
            },
          ),
          const Spacer(),
          Text(
            widget.playerCount == 2 ? l10n.ludoMode1v1 : l10n.ludoMode4Party,
            style: TextStyle(
                color: RoyalTheme.textLight.withValues(alpha: 0.75),
                fontSize: 12,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _toastBanner() {
    return Positioned(
      top: 56,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: RoyalTheme.panelSolid,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: RoyalTheme.goldAccent.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                  color: RoyalTheme.goldAccent.withValues(alpha: 0.25),
                  blurRadius: 18,
                  spreadRadius: 1),
            ],
          ),
          child: Text(
            toastMsg!,
            style: const TextStyle(
                color: RoyalTheme.textLight,
                fontWeight: FontWeight.w800,
                fontSize: 14),
          ),
        ),
      ),
    );
  }

  /// Stacks player-seat HUD pills in the 4 corners around the board.
  /// In 2-player mode only the human (TL) + the diagonal opponent (BR)
  /// seats render — the empty corners remain visually quiet.
  Widget _boardWithSeats(AppLocalizations l10n) {
    return LayoutBuilder(builder: (context, constraints) {
      final size =
          constraints.biggest.shortestSide.clamp(0.0, 460.0).toDouble();
      return SizedBox(
        width: size,
        height: size + 70, // extra room for the seat pills sitting outside
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              top: 30,
              child: _boardOnly(size),
            ),
            // Seat TL: human (player 0, yellow)
            Positioned(
              top: 0,
              left: 0,
              child: PlayerSeat(
                label: _playerName(0),
                colorKey: BoardScheme.playerColors[0],
                diceValue: _lastDicePerPlayer[0],
                isCurrent: engine.current == 0 && !engine.gameOver,
                isThinking:
                    engine.current == 0 && _isRollingDice,
                isRolling: _isRollingDice && engine.current == 0,
                alignment: Alignment.topLeft,
              ),
            ),
            // Seat TR: player 1 (blue) — only in 4-player
            if (engine.isActivePlayer(1))
              Positioned(
                top: 0,
                right: 0,
                child: PlayerSeat(
                  label: _playerName(1),
                  colorKey: BoardScheme.playerColors[1],
                  diceValue: _lastDicePerPlayer[1],
                  isCurrent: engine.current == 1 && !engine.gameOver,
                  isThinking:
                      engine.current == 1 && _isRollingDice,
                  isRolling: _isRollingDice && engine.current == 1,
                  alignment: Alignment.topRight,
                ),
              ),
            // Seat BR: player 2 (purple) — active in both modes
            Positioned(
              bottom: 0,
              right: 0,
              child: PlayerSeat(
                label: _playerName(2),
                colorKey: BoardScheme.playerColors[2],
                diceValue: _lastDicePerPlayer[2],
                isCurrent: engine.current == 2 && !engine.gameOver,
                isThinking:
                    engine.current == 2 && _isRollingDice,
                isRolling: _isRollingDice && engine.current == 2,
                alignment: Alignment.bottomRight,
              ),
            ),
            // Seat BL: player 3 (green) — only in 4-player
            if (engine.isActivePlayer(3))
              Positioned(
                bottom: 0,
                left: 0,
                child: PlayerSeat(
                  label: _playerName(3),
                  colorKey: BoardScheme.playerColors[3],
                  diceValue: _lastDicePerPlayer[3],
                  isCurrent: engine.current == 3 && !engine.gameOver,
                  isThinking:
                      engine.current == 3 && _isRollingDice,
                  isRolling: _isRollingDice && engine.current == 3,
                  alignment: Alignment.bottomLeft,
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _boardOnly(double size) {
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
                color: Color(0x99000000),
                blurRadius: 22,
                offset: Offset(0, 8))
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
  }

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
        widgets.add(AnimatedPositioned(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOutCubic,
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
