import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/ludo_move_result.dart';
import '../../domain/ludo_player.dart';
import '../../domain/ludo_state.dart';
import '../../domain/ludo_token.dart';
import 'ludo_board_geometry.dart';
import 'ludo_board_painter.dart';
import 'ludo_capture_animation.dart';
import 'ludo_token_widget.dart';

/// Container widget: paints board + lays out all tokens + handles moves.
///
/// Receives:
/// - [state]: current LudoState (re-applied on every change)
/// - [moveStream]: stream of move results to play animations from
/// - [onTokenTap]: invoked when a movable token is tapped
class LudoBoard extends StatefulWidget {
  const LudoBoard({
    super.key,
    required this.state,
    required this.moveStream,
    required this.onTokenTap,
    this.brightness = Brightness.dark,
  });

  final LudoState state;
  final Stream<LudoMoveResult> moveStream;
  final void Function(int tokenIndex) onTokenTap;
  final Brightness brightness;

  @override
  State<LudoBoard> createState() => _LudoBoardState();
}

class _LudoBoardState extends State<LudoBoard> {
  /// Map: (seat * 10 + tokenIndex) → controller
  /// (token controllers don't have to be per-color; seat suffices since
  /// each player has 4 tokens 0..3.)
  final Map<int, LudoTokenAnimController> _tokenCtrls = {};
  final Map<int, LudoTokenPosition> _localPositions = {};

  /// Active capture bursts to render.
  final List<_PendingBurst> _bursts = [];

  /// Selected token index for the local user (highlights).
  int? _selectedTokenIndex;

  StreamSubscription<LudoMoveResult>? _moveSub;

  @override
  void initState() {
    super.initState();
    _seedFromState();
    _moveSub = widget.moveStream.listen(_handleMove);
  }

  @override
  void didUpdateWidget(covariant LudoBoard old) {
    super.didUpdateWidget(old);
    if (old.moveStream != widget.moveStream) {
      _moveSub?.cancel();
      _moveSub = widget.moveStream.listen(_handleMove);
    }
    // Re-seed positions for any token we don't have a recorded local position
    // for (handles reconnect / late-binding).
    _syncFromState();
  }

  @override
  void dispose() {
    _moveSub?.cancel();
    super.dispose();
  }

  int _key(int seat, int tokenIndex) => seat * 10 + tokenIndex;

  void _seedFromState() {
    for (final p in widget.state.players) {
      for (int i = 0; i < p.tokens.length; i++) {
        _tokenCtrls[_key(p.seat, i)] = LudoTokenAnimController();
        _localPositions[_key(p.seat, i)] = p.tokens[i];
      }
    }
  }

  void _syncFromState() {
    for (final p in widget.state.players) {
      for (int i = 0; i < p.tokens.length; i++) {
        final k = _key(p.seat, i);
        _tokenCtrls.putIfAbsent(k, () => LudoTokenAnimController());
        _localPositions.putIfAbsent(k, () => p.tokens[i]);
      }
    }
  }

  Future<void> _handleMove(LudoMoveResult r) async {
    final byPlayer = widget.state.playerAt(r.bySeat);
    if (byPlayer == null) return;
    final key = _key(r.bySeat, r.tokenIndex);
    final ctrl = _tokenCtrls[key];
    if (ctrl == null) return;

    // Build path from→to and animate.
    final path = LudoBoardGeometry.stepwisePath(
      color: byPlayer.color,
      tokenIndex: r.tokenIndex,
      from: r.fromPos,
      to: r.toPos,
    );
    await ctrl.moveAlongPath(path);
    _localPositions[key] = r.toPos;

    // capture animations
    for (final cap in r.captured) {
      final capSeat = widget.state.players
          .firstWhere(
            (p) => p.color == cap.color,
            orElse: () => byPlayer,
          )
          .seat;
      final capKey = _key(capSeat, cap.tokenIndex);
      final capCtrl = _tokenCtrls[capKey];
      if (capCtrl == null) continue;
      // burst on the captured token's current position
      final curPos = _localPositions[capKey] ??
          const LudoTokenPosition(zone: LudoTokenZone.track, cell: 0);
      final burstCenter = LudoBoardGeometry.tokenPosition(
        color: cap.color,
        tokenIndex: cap.tokenIndex,
        pos: curPos,
      );
      setState(() {
        _bursts.add(_PendingBurst(
          id: DateTime.now().microsecondsSinceEpoch + _bursts.length,
          center: burstCenter,
          color: cap.color.primary,
        ));
      });
      // animate captured token returning home
      final homeSlot = LudoBoardGeometry.homeBaseSlots(cap.color)[cap.tokenIndex];
      unawaited(capCtrl.captureAndReturnHome(homeSlot));
      _localPositions[capKey] =
          const LudoTokenPosition(zone: LudoTokenZone.home, cell: 0);
    }

    // celebration hop on finish
    if (r.toPos.isFinished) {
      unawaited(ctrl.celebrationHop());
    }
  }

  void _removeBurst(int id) {
    setState(() {
      _bursts.removeWhere((b) => b.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final side = constraints.biggest.shortestSide;
      final boardSize = side;

      final canMoveSet = (widget.state.dice != null)
          ? <int>{...?_canMoveForYou()}
          : <int>{};

      return Center(
        child: SizedBox(
          width: boardSize,
          height: boardSize,
          child: Stack(
            children: [
              // 1. Painted board
              Positioned.fill(
                child: CustomPaint(
                  painter: LudoBoardPainter(
                    highlightSeat: widget.state.turnSeat,
                    brightness: widget.brightness,
                  ),
                ),
              ),

              // 2. Tokens
              for (final p in widget.state.players)
                for (int i = 0; i < p.tokens.length; i++)
                  _tokenFor(
                    player: p,
                    tokenIndex: i,
                    boardSize: boardSize,
                    canMove: p.seat == widget.state.yourSeat &&
                        widget.state.yourTurn &&
                        canMoveSet.contains(i),
                  ),

              // 3. Capture bursts
              for (final b in _bursts)
                LudoCaptureBurst(
                  key: ValueKey(b.id),
                  normalizedCenter: b.center,
                  boardSize: boardSize,
                  color: b.color,
                  onDone: () => _removeBurst(b.id),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _tokenFor({
    required LudoPlayer player,
    required int tokenIndex,
    required double boardSize,
    required bool canMove,
  }) {
    final key = _key(player.seat, tokenIndex);
    final ctrl = _tokenCtrls.putIfAbsent(key, () => LudoTokenAnimController());
    final pos = _localPositions[key] ?? player.tokens[tokenIndex];
    final isYours = player.seat == widget.state.yourSeat;
    return LudoTokenWidget(
      key: ValueKey('tok-$key'),
      color: player.color,
      tokenIndex: tokenIndex,
      initialPosition: pos,
      boardSize: boardSize,
      controller: ctrl,
      selectable: isYours && widget.state.yourTurn,
      canMove: canMove,
      selected: _selectedTokenIndex == tokenIndex && isYours,
      onTap: () {
        if (!canMove) return;
        setState(() => _selectedTokenIndex = tokenIndex);
        widget.onTokenTap(tokenIndex);
      },
    );
  }

  Iterable<int>? _canMoveForYou() {
    final mySeat = widget.state.yourSeat;
    final me = widget.state.playerAt(mySeat);
    if (me == null) return null;
    final dice = widget.state.dice;
    if (dice == null) return null;
    // Local heuristic: a token can move if it's not finished. The server
    // is authoritative — the WS event provides exact list via lastDiceRoll,
    // and the controller's move() already validates against that set. Here
    // we simply highlight any non-finished token as a candidate.
    final cands = <int>[];
    for (int i = 0; i < me.tokens.length; i++) {
      final t = me.tokens[i];
      if (t.isFinished) continue;
      if (t.isHome && dice != 6) continue;
      cands.add(i);
    }
    return cands;
  }
}

class _PendingBurst {
  _PendingBurst({required this.id, required this.center, required this.color});
  final int id;
  final Offset center;
  final Color color;
}
