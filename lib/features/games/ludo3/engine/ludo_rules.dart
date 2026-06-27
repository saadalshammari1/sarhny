/// Pure Ludo rules — a faithful Dart port of `app/core/ludo_rules.py`.
///
/// Offline matches drive themselves through these functions; online matches
/// let the server be authoritative and only mirror its broadcasts. Keeping
/// the two in lockstep means the AI "thinks" with the exact rules the server
/// will enforce, so an offline strategy never produces an illegal online move.
library;

import 'ludo_models.dart';

class CapturedToken {
  CapturedToken({required this.color, required this.tokenIndex});
  final LudoColor color;
  final int tokenIndex;
}

class MoveResult {
  MoveResult({
    required this.state,
    required this.movedTokenIndex,
    required this.fromPosition,
    required this.toPosition,
    this.captured = const [],
    this.homeEntered = false,
    this.diceAgain = false,
    this.won = false,
    this.gameOver = false,
    this.winnerUserId,
    this.winnerTeam,
  });

  final LudoState state;
  final int movedTokenIndex;
  final int fromPosition;
  final int toPosition;
  final List<CapturedToken> captured;
  final bool homeEntered;
  final bool diceAgain;
  final bool won;
  final bool gameOver;
  final int? winnerUserId;
  final int? winnerTeam;
}

bool _onTrack(int p) => p >= 0 && p < kTrackLength;

/// Where a token of [color] lands when rolled [dice] from [current].
/// Returns null when the move is illegal (overshoot, finished token, or
/// leaving base without a 6).
int? projectPosition(LudoColor color, int current, int dice) {
  if (current == kHomeBasePosition) {
    return dice == 6 ? kColorEntry[color]! : null;
  }
  if (current == kFinishedPosition) return null;

  if (current >= kHomeStretchBase) {
    final idx = current - kHomeStretchBase;
    final next = idx + dice;
    if (next == kHomeStretchLength) return kFinishedPosition;
    if (next < kHomeStretchLength) return kHomeStretchBase + next;
    return null; // overshoot
  }

  // On the public track.
  final entry = kHomeStretchEntry[color]!;
  final stepsToEntry = (entry - current) % kTrackLength;
  if (dice <= stepsToEntry) {
    return (current + dice) % kTrackLength;
  }
  final remaining = dice - stepsToEntry - 1;
  if (remaining == kHomeStretchLength) return kFinishedPosition;
  if (remaining < kHomeStretchLength) return kHomeStretchBase + remaining;
  return null;
}

/// Token indices (0..3) the player at [seat] may legally move on [dice].
List<int> possibleMoves(LudoState state, int dice, int seat) {
  final p = state.playerBySeat(seat);
  if (p == null || p.finished) return const [];
  final out = <int>[];
  for (final t in p.tokens) {
    if (projectPosition(p.color, t.position, dice) != null) out.add(t.index);
  }
  return out;
}

List<({LudoPlayer player, LudoToken token})> _opponentsOnSquare(
    LudoState state, LudoColor moverColor, int square) {
  if (!_onTrack(square)) return const [];
  final out = <({LudoPlayer player, LudoToken token})>[];
  for (final p in state.players) {
    if (p.color == moverColor) continue;
    for (final t in p.tokens) {
      if (t.position == square) out.add((player: p, token: t));
    }
  }
  return out;
}

/// Apply a move on a CLONE of [state] and resolve captures, bonuses and win
/// detection. Mirrors `apply_move` including the 2v2 team-win extension.
MoveResult applyMove(LudoState state, int dice, int seat, int tokenIndex) {
  final s = state.clone();
  final player = s.playerBySeat(seat);
  if (player == null) {
    return MoveResult(
      state: s,
      movedTokenIndex: tokenIndex,
      fromPosition: kHomeBasePosition,
      toPosition: kHomeBasePosition,
    );
  }
  final token = player.tokens[tokenIndex];
  final from = token.position;
  final to = projectPosition(player.color, from, dice);
  if (to == null) {
    return MoveResult(
      state: s,
      movedTokenIndex: tokenIndex,
      fromPosition: from,
      toPosition: from,
    );
  }
  token.position = to;

  // Capture resolution.
  final caps = <CapturedToken>[];
  if (_onTrack(to) && !kSafeSquares.contains(to)) {
    for (final hit in _opponentsOnSquare(s, player.color, to)) {
      // In 2v2 you never capture your own teammate.
      if (s.mode == LudoMode.team2v2 &&
          teamOf(hit.player.color) == player.team) {
        continue;
      }
      hit.token.position = kHomeBasePosition;
      caps.add(CapturedToken(
          color: hit.player.color, tokenIndex: hit.token.index));
    }
  }

  final homeEntered = to == kFinishedPosition;
  final won = player.tokens.every((t) => t.position == kFinishedPosition);
  if (won) {
    player.finished = true;
    final alreadyRanked = s.players.where((p) => p.rank != null).length;
    player.rank = alreadyRanked + 1;
  }

  var diceAgain = dice == 6 || caps.isNotEmpty || homeEntered;
  if (dice == 6) {
    s.consecutiveSixes += 1;
    if (s.consecutiveSixes >= kMaxConsecutiveSixes) diceAgain = false;
  } else {
    s.consecutiveSixes = 0;
  }

  s.dice = null;
  s.seq += 1;

  final over = _checkGameOver(s);
  if (over.$1) {
    s.status = LudoStatus.finished;
    s.winnerUserId = over.$2;
    s.winnerTeam = over.$3;
    var nextRank = s.players.where((p) => p.rank != null).length + 1;
    for (final p in s.players) {
      p.rank ??= nextRank++;
    }
  }

  return MoveResult(
    state: s,
    movedTokenIndex: tokenIndex,
    fromPosition: from,
    toPosition: to,
    captured: caps,
    homeEntered: homeEntered,
    diceAgain: diceAgain && !over.$1,
    won: won,
    gameOver: over.$1,
    winnerUserId: over.$2,
    winnerTeam: over.$3,
  );
}

/// (gameOver, winnerUserId, winnerTeam).
///
/// Free-for-all (2p/4p): first player to finish all 4 tokens wins outright.
/// Teams (2v2): the match ends when BOTH members of a team have finished.
(bool, int?, int?) _checkGameOver(LudoState s) {
  if (s.mode == LudoMode.team2v2) {
    for (final team in const [0, 1]) {
      final members = s.players.where((p) => teamOf(p.color) == team).toList();
      if (members.isNotEmpty && members.every((p) => p.finished)) {
        return (true, members.first.userId, team);
      }
    }
    return (false, null, null);
  }
  final winners = s.players.where((p) => p.rank == 1).toList();
  if (winners.isNotEmpty) return (true, winners.first.userId, null);
  return (false, null, null);
}

/// Advance to the next seat. Returns (nextSeat, gameOver). Skips finished
/// players. In 2v2 a finished player's turn is skipped but the match keeps
/// going until a whole team is done.
(int, bool) nextTurn(LudoState state) {
  final unfinished = state.players.where((p) => !p.finished).toList();
  if (state.mode == LudoMode.team2v2) {
    for (final team in const [0, 1]) {
      final members =
          state.players.where((p) => teamOf(p.color) == team).toList();
      if (members.isNotEmpty && members.every((p) => p.finished)) {
        return (state.turnSeat, true);
      }
    }
  } else if (unfinished.length <= 1) {
    return (state.turnSeat, true);
  }

  final nSeats =
      state.players.map((p) => p.seat).fold(-1, (a, b) => a > b ? a : b) + 1;
  if (nSeats <= 0) return (state.turnSeat, true);
  for (var off = 1; off <= nSeats; off++) {
    final cand = (state.turnSeat + off) % nSeats;
    for (final p in state.players) {
      if (p.seat == cand && !p.finished) return (cand, false);
    }
  }
  return (state.turnSeat, true);
}
