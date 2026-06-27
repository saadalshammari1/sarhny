/// Drives a LOCAL *Magic Ludo* match (vs AI) with FULLY AUTOMATIC magic: the
/// classic engine handles movement/capture/win, and landing on a board node
/// (Mystery Box 🎁 / Wormhole 🌀) triggers an instant, self-targeting effect —
/// a shield auto-goes to the pawn that needs it, a freeze auto-hits the leading
/// opponent. No mana, no costs, no manual choices.
library;

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../engine/ludo_ai.dart';
import '../engine/ludo_models.dart';
import '../engine/ludo_rules.dart';
import '../engine/magic.dart';
import 'ludo3_controller.dart' show LudoPhase;

class MagicController extends ChangeNotifier {
  MagicController({
    required this.state,
    required this.humanSeats,
    LudoDifficulty difficulty = LudoDifficulty.normal,
    Random? rng,
  })  : _ai = LudoAi(difficulty),
        _rng = rng ?? Random() {
    magic = MagicState.fresh(state);
    _beginTurn();
  }

  final LudoState state;
  final Set<int> humanSeats;
  final LudoAi _ai;
  final Random _rng;
  late final MagicState magic;

  static const int turnSeconds = 15;
  static const int maxTimeouts = 3;

  LudoPhase phase = LudoPhase.rollPending;
  int? dice;
  bool diceRolling = false;
  List<int> movable = const [];

  /// Banked dice values awaiting moves (bank-then-move; a 6 rolls again, up to
  /// 3, three 6s void). Shrinks as each value is consumed.
  List<int> pending = [];

  Timer? _turnTimer;
  int secondsLeft = turnSeconds;
  bool _autopilot = false;
  bool autopilotFlash = false;
  bool _disposed = false;
  final Map<int, int> _timeoutStreak = {};
  final Set<int> botConverted = {};

  // Callbacks.
  void Function()? onRollSfx;
  void Function()? onMoveSfx;
  void Function()? onCaptureSfx;
  void Function()? onFinishSfx;
  void Function(MagicEvent e)? onMagic;
  void Function(int seat, bool captured, bool finished, bool six)? onMoveApplied;
  void Function(int? winnerUserId, int? winnerTeam)? onGameOver;

  bool get isHumanTurn =>
      humanSeats.contains(state.turnSeat) && !botConverted.contains(state.turnSeat);
  LudoPlayer get current => state.current!;
  bool get canRoll =>
      phase == LudoPhase.rollPending && isHumanTurn && !diceRolling;
  bool get canSelect => phase == LudoPhase.movePending && isHumanTurn;
  bool get isMoving => phase == LudoPhase.movePending;
  bool get isRollingPhase => phase == LudoPhase.rollPending;

  // ── Turn lifecycle ──────────────────────────────────────────────────────

  void _beginTurn() {
    final seat = state.turnSeat;
    // Frozen? consume one frozen turn and skip the whole turn.
    if (magic.isFrozen(seat)) {
      magic.frozenTurns[seat] = magic.frozenTurns[seat]! - 1;
      onMagic?.call(MagicEvent('frozenSkip', detail: '$seat'));
      phase = LudoPhase.rollPending;
      notifyListeners();
      Future<void>.delayed(const Duration(milliseconds: 1100), _passTurn);
      return;
    }
    // Expire this seat's shields by one rotation.
    final p = state.playerBySeat(seat);
    if (p != null) {
      for (final t in p.tokens) {
        final k = tokenKey(p.color, t.index);
        if ((magic.shields[k] ?? 0) > 0) {
          magic.shields[k] = magic.shields[k]! - 1;
          if (magic.shields[k]! <= 0) magic.shields.remove(k);
        }
      }
    }
    phase = LudoPhase.rollPending;
    dice = null;
    notifyListeners();
    _maybeRunBot();
  }

  // ── Turn clock ──────────────────────────────────────────────────────────

  void _startTurnTimer() {
    _turnTimer?.cancel();
    if (_disposed || !isHumanTurn) return;
    if (phase != LudoPhase.rollPending && phase != LudoPhase.movePending) return;
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

  // ── Rolling ─────────────────────────────────────────────────────────────

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
    await Future<void>.delayed(const Duration(milliseconds: 560));
    final value = _rng.nextInt(6) + 1;
    dice = value;
    diceRolling = false;
    pending.add(value);
    notifyListeners();

    if (value == 6) {
      if (pending.length >= 3) {
        await Future<void>.delayed(const Duration(milliseconds: 900));
        pending.clear();
        _passTurn();
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 380));
      _maybeRunBot();
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 280));
    await _advance();
  }

  Future<void> _advance() async {
    while (pending.isNotEmpty) {
      final v = pending.first;
      final legal = possibleMoves(state, v, state.turnSeat);
      if (legal.isEmpty) {
        pending.removeAt(0);
        notifyListeners();
        continue;
      }
      dice = v;
      movable = legal;
      phase = LudoPhase.movePending;
      notifyListeners();

      if (!isHumanTurn) {
        await Future<void>.delayed(const Duration(milliseconds: 650));
        await applyTokenMove(_ai.choose(state, v, state.turnSeat, legal));
      } else if (legal.length == 1) {
        await Future<void>.delayed(const Duration(milliseconds: 400));
        if (phase == LudoPhase.movePending) await applyTokenMove(legal.first);
      } else if (_autopilot) {
        await Future<void>.delayed(const Duration(milliseconds: 450));
        if (phase == LudoPhase.movePending) {
          await applyTokenMove(_ai.choose(state, v, state.turnSeat, legal));
        }
      } else {
        _startTurnTimer();
      }
      return;
    }
    _passTurn();
  }

  // ── Moving ──────────────────────────────────────────────────────────────

  Future<void> applyTokenMove(int tokenIndex) async {
    if (phase != LudoPhase.movePending) return;
    final value = dice;
    if (value == null || !movable.contains(tokenIndex)) return;

    _stopTurnTimer();
    final seat = state.turnSeat;
    final mover0 = state.playerBySeat(seat)!.tokens[tokenIndex];
    final walkMs = _walkDuration(mover0.color, mover0.position, value);
    phase = LudoPhase.animating;
    movable = const [];
    notifyListeners();

    // Snapshot shielded enemy positions for break-on-contact handling.
    final shieldedBefore = <String, int>{};
    for (final p in state.players) {
      for (final t in p.tokens) {
        if (magic.isShielded(p.color, t.index)) {
          shieldedBefore[tokenKey(p.color, t.index)] = t.position;
        }
      }
    }

    final fromPos = mover0.position;
    final result = applyMove(state, value, seat, tokenIndex);
    _commit(result);

    // Divine Shield — break on contact: a shielded pawn "captured" by this move
    // is restored, its shield breaks, and the attacker simply stops (no kill).
    final realCaptures = result.captured.toList();
    var shieldBroke = false;
    for (final c in result.captured) {
      final k = tokenKey(c.color, c.tokenIndex);
      if (shieldedBefore.containsKey(k)) {
        state.players.firstWhere((p) => p.color == c.color).tokens[c.tokenIndex]
            .position = shieldedBefore[k]!;
        magic.shields.remove(k);
        realCaptures.remove(c);
        shieldBroke = true;
        onMagic?.call(MagicEvent('shieldBreak', detail: k));
      }
    }
    // If the move's ONLY "capture" was a shielded pawn, the attacker doesn't
    // kill and must NOT occupy the defender's cell — revert it to its origin,
    // otherwise the attacker and the restored shielded pawn illegally share one
    // cell. (When a real kill also happened, the attacker keeps the cell.)
    if (shieldBroke && realCaptures.isEmpty) {
      state.playerBySeat(seat)!.tokens[tokenIndex].position = fromPos;
    }

    onMoveSfx?.call();
    notifyListeners();
    await Future<void>.delayed(Duration(milliseconds: walkMs + 160));

    // Board nodes on the landing cell (wormhole → mystery), auto-resolved.
    var extraRoll = false;
    final mover = state.playerBySeat(seat)!.tokens[tokenIndex];
    final events = resolveLanding(state, magic, seat, mover, _rng,
        grantExtraRoll: () => extraRoll = true);
    for (final e in events) {
      onMagic?.call(e);
    }
    if (events.isNotEmpty) {
      notifyListeners();
      await Future<void>.delayed(const Duration(milliseconds: 650));
    }

    if (realCaptures.isNotEmpty) onCaptureSfx?.call();
    if (result.homeEntered) onFinishSfx?.call();
    onMoveApplied?.call(seat, realCaptures.isNotEmpty, result.homeEntered, value == 6);

    if (result.gameOver) {
      state.status = LudoStatus.finished;
      phase = LudoPhase.gameOver;
      dice = null;
      pending.clear();
      notifyListeners();
      onGameOver?.call(result.winnerUserId, result.winnerTeam);
      return;
    }

    // Consume the used value; a Mystery extra-roll banks one more value.
    if (pending.isNotEmpty) pending.removeAt(0);
    if (extraRoll) pending.add(_rng.nextInt(6) + 1);
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
    state.consecutiveSixes = src.consecutiveSixes;
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
    _autopilot = false;
    pending = [];
    _beginTurn();
  }

  void _maybeRunBot() {
    if (phase != LudoPhase.rollPending) return;
    if (isHumanTurn) {
      if (_autopilot) {
        Future<void>.delayed(const Duration(milliseconds: 520), () {
          if (phase == LudoPhase.rollPending && isHumanTurn && _autopilot) _doRoll();
        });
      } else {
        _startTurnTimer();
      }
      return;
    }
    // Slower bot cadence so the human can follow the switch.
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
