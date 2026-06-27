/// Drives a LOCAL Ludo match (vs AI or pass-and-play). Owns the turn loop,
/// dice rolling (local RNG), bot auto-play and the win settle.
///
/// Dice rule (bank-then-move): you ROLL first and bank the values — a 6 makes
/// you roll again (up to 3 rolls). A non-6 stops the rolling. Three 6s in a row
/// void the turn (no move, pass). After rolling stops you have a set of values
/// (e.g. [6,6,5]); you then move a pawn for EACH value, one at a time, and the
/// value disappears as it is used. No bonus rolls from captures in this variant.
library;

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../engine/ludo_ai.dart';
import '../engine/ludo_models.dart';
import '../engine/ludo_rules.dart';

enum LudoPhase { rollPending, movePending, animating, gameOver }

class Ludo3Controller extends ChangeNotifier {
  Ludo3Controller({
    required this.state,
    required this.humanSeats,
    LudoDifficulty difficulty = LudoDifficulty.normal,
    Random? rng,
  })  : _ai = LudoAi(difficulty),
        _rng = rng ?? Random() {
    _maybeRunBot();
  }

  final LudoState state;
  final Set<int> humanSeats;
  final LudoAi _ai;
  final Random _rng;

  LudoPhase phase = LudoPhase.rollPending;
  int? dice; // the value shown on the die (last rolled, or the active move value)
  bool diceRolling = false;
  List<int> movable = const [];

  /// Banked dice values for this turn awaiting moves (e.g. [6,6,5]). Shown
  /// beside the die; shrinks as each value is consumed by a move.
  List<int> pending = [];

  static const int turnSeconds = 15;
  static const int maxTimeouts = 3;
  Timer? _turnTimer;
  int secondsLeft = turnSeconds;
  bool _autopilot = false;
  bool autopilotFlash = false;
  bool _disposed = false;
  final Map<int, int> _timeoutStreak = {};
  final Set<int> botConverted = {};

  void Function()? onRollSfx;
  void Function()? onMoveSfx;
  void Function()? onCaptureSfx;
  void Function()? onFinishSfx;
  void Function(int? winnerUserId, int? winnerTeam)? onGameOver;
  void Function(int seat, bool captured, bool finished, bool six)? onMoveApplied;

  bool get isHumanTurn =>
      humanSeats.contains(state.turnSeat) && !botConverted.contains(state.turnSeat);
  LudoPlayer get current => state.current!;
  bool get canRoll => phase == LudoPhase.rollPending && isHumanTurn && !diceRolling;
  bool get canSelect => phase == LudoPhase.movePending && isHumanTurn;
  bool get isMoving => phase == LudoPhase.movePending;
  bool get isRollingPhase => phase == LudoPhase.rollPending;

  // ── Turn clock ────────────────────────────────────────────────────────────

  void _startTurnTimer() {
    _turnTimer?.cancel();
    if (_disposed) return;
    if (!isHumanTurn ||
        (phase != LudoPhase.rollPending && phase != LudoPhase.movePending)) {
      return;
    }
    secondsLeft = turnSeconds;
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      secondsLeft -= 1;
      if (secondsLeft <= 0) {
        _turnTimer?.cancel();
        _onTimeout();
      }
      notifyListeners();
    });
  }

  void _stopTurnTimer() {
    _turnTimer?.cancel();
    _turnTimer = null;
  }

  Future<void> _onTimeout() async {
    if (!isHumanTurn) return;
    final seat = state.turnSeat;
    _timeoutStreak[seat] = (_timeoutStreak[seat] ?? 0) + 1;
    if (_timeoutStreak[seat]! >= maxTimeouts) {
      botConverted.add(seat);
      state.playerBySeat(seat)?.isBot = true;
    }
    _autopilot = true;
    autopilotFlash = true;
    notifyListeners();
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      autopilotFlash = false;
      if (!_disposed) notifyListeners();
    });
    if (phase == LudoPhase.rollPending) {
      await _doRoll();
    } else if (phase == LudoPhase.movePending && movable.isNotEmpty) {
      await applyTokenMove(_ai.choose(state, dice ?? 1, state.turnSeat, movable));
    }
  }

  // ── Rolling (bank the values) ──────────────────────────────────────────────

  Future<void> humanRoll() async {
    if (!canRoll) return;
    _autopilot = false;
    _timeoutStreak[state.turnSeat] = 0;
    _stopTurnTimer();
    await _doRoll();
  }

  Future<void> _doRoll() async {
    diceRolling = true;
    onRollSfx?.call();
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 520));
    final value = _rng.nextInt(6) + 1;
    dice = value;
    diceRolling = false;
    pending.add(value);
    notifyListeners();

    if (value == 6) {
      if (pending.length >= 3) {
        // Three 6s in a row → void the turn.
        await Future<void>.delayed(const Duration(milliseconds: 850));
        pending.clear();
        _passTurn();
        return;
      }
      // Bank the 6 and roll again.
      await Future<void>.delayed(const Duration(milliseconds: 360));
      _maybeRunBot();
      return;
    }

    // A non-6 stops the rolling — now move a pawn for each banked value.
    await Future<void>.delayed(const Duration(milliseconds: 260));
    await _advance();
  }

  // ── Moving (consume banked values one at a time) ───────────────────────────

  Future<void> _advance() async {
    while (pending.isNotEmpty) {
      final v = pending.first;
      final legal = possibleMoves(state, v, state.turnSeat);
      if (legal.isEmpty) {
        // No move for this value — forfeit it and try the next.
        pending.removeAt(0);
        notifyListeners();
        continue;
      }
      dice = v;
      movable = legal;
      phase = LudoPhase.movePending;
      notifyListeners();

      if (!isHumanTurn) {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        await applyTokenMove(_ai.choose(state, v, state.turnSeat, legal));
      } else if (legal.length == 1) {
        await Future<void>.delayed(const Duration(milliseconds: 380));
        if (phase == LudoPhase.movePending) await applyTokenMove(legal.first);
      } else if (_autopilot) {
        await Future<void>.delayed(const Duration(milliseconds: 420));
        if (phase == LudoPhase.movePending) {
          await applyTokenMove(_ai.choose(state, v, state.turnSeat, legal));
        }
      } else {
        _startTurnTimer();
      }
      return;
    }
    // All banked values used.
    _passTurn();
  }

  Future<void> applyTokenMove(int tokenIndex) async {
    if (phase != LudoPhase.movePending) return;
    final value = dice;
    if (value == null || !movable.contains(tokenIndex)) return;

    _stopTurnTimer();
    final mover = state.playerBySeat(state.turnSeat)!.tokens[tokenIndex];
    final walkMs = _walkDuration(mover.color, mover.position, value);
    phase = LudoPhase.animating;
    movable = const [];
    notifyListeners();

    final result = applyMove(state, value, state.turnSeat, tokenIndex);
    _commit(result);
    onMoveSfx?.call();
    notifyListeners();

    await Future<void>.delayed(Duration(milliseconds: walkMs + 140));
    if (result.captured.isNotEmpty) onCaptureSfx?.call();
    if (result.homeEntered) onFinishSfx?.call();
    onMoveApplied?.call(state.turnSeat, result.captured.isNotEmpty, result.homeEntered, value == 6);

    if (result.gameOver) {
      state.status = LudoStatus.finished;
      phase = LudoPhase.gameOver;
      dice = null;
      pending.clear();
      notifyListeners();
      onGameOver?.call(result.winnerUserId, result.winnerTeam);
      return;
    }

    // Consume the used value, settle, then move the next banked value.
    if (pending.isNotEmpty) pending.removeAt(0);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    await _advance();
  }

  int _walkDuration(LudoColor color, int from, int value) {
    var steps = 0;
    for (var k = 1; k <= value; k++) {
      if (projectPosition(color, from, k) != null) steps++;
    }
    if (steps < 1) steps = 1;
    return steps * kStepMs;
  }

  void _commit(MoveResult r) {
    final src = r.state;
    for (final sp in src.players) {
      final dp = state.playerBySeat(sp.seat)!;
      dp.finished = sp.finished;
      dp.rank = sp.rank;
      for (var i = 0; i < dp.tokens.length; i++) {
        dp.tokens[i].position = sp.tokens[i].position;
      }
    }
    state.seq = src.seq;
    state.winnerUserId = src.winnerUserId;
    state.winnerTeam = src.winnerTeam;
  }

  void _passTurn() {
    final (next, over) = nextTurn(state);
    if (over) {
      state.status = LudoStatus.finished;
      phase = LudoPhase.gameOver;
      notifyListeners();
      onGameOver?.call(state.winnerUserId, state.winnerTeam);
      return;
    }
    state.turnSeat = next;
    state.consecutiveSixes = 0;
    dice = null;
    pending = [];
    _autopilot = false;
    phase = LudoPhase.rollPending;
    notifyListeners();
    _maybeRunBot();
  }

  void _maybeRunBot() {
    if (phase != LudoPhase.rollPending) return;
    if (isHumanTurn) {
      if (_autopilot) {
        Future<void>.delayed(const Duration(milliseconds: 420), () {
          if (phase == LudoPhase.rollPending && isHumanTurn && _autopilot) _doRoll();
        });
      } else {
        _startTurnTimer();
      }
      return;
    }
    Future<void>.delayed(const Duration(milliseconds: 1300), () {
      if (phase == LudoPhase.rollPending && !isHumanTurn) _doRoll();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _stopTurnTimer();
    super.dispose();
  }
}
