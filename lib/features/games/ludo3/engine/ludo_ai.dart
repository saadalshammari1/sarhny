/// A lightweight heuristic Ludo bot. Given the legal moves for a roll, it
/// simulates each through the real rules and scores the outcome, so the bot
/// never plays an illegal move and makes human-plausible decisions: grab
/// captures, get tokens out, race the leader home, and dodge danger.
library;

import 'ludo_models.dart';
import 'ludo_rules.dart';

enum LudoDifficulty { easy, normal, hard }

class LudoAi {
  LudoAi(this.difficulty);
  final LudoDifficulty difficulty;

  /// Pick a token index from [legal] for [seat] rolling [dice]. Returns the
  /// first legal move as a safe fallback.
  int choose(LudoState state, int dice, int seat, List<int> legal) {
    if (legal.isEmpty) return -1;
    if (legal.length == 1) return legal.first;
    if (difficulty == LudoDifficulty.easy) {
      // Easy: mostly random, but still take an obvious capture sometimes.
      final caps = legal.where((i) {
        final r = applyMove(state, dice, seat, i);
        return r.captured.isNotEmpty;
      }).toList();
      if (caps.isNotEmpty && _coin(state, 0)) return caps.first;
      return legal[(state.seq + dice) % legal.length];
    }

    var best = legal.first;
    var bestScore = -1e9;
    for (final i in legal) {
      final s = _score(state, dice, seat, i);
      if (s > bestScore) {
        bestScore = s;
        best = i;
      }
    }
    return best;
  }

  bool _coin(LudoState state, int salt) => (state.seq + salt).isEven;

  double _score(LudoState state, int dice, int seat, int tokenIndex) {
    final me = state.playerBySeat(seat)!;
    final token = me.tokens[tokenIndex];
    final from = token.position;
    final result = applyMove(state, dice, seat, tokenIndex);
    var score = 0.0;

    // Capturing is huge — sending an opponent home is the strongest play.
    for (final c in result.captured) {
      // Reward by how far the captured token had travelled.
      score += 60 + _progress(c.color, _capturedFrom(state, c)) * 0.4;
    }

    // Finishing a token or reaching the home stretch.
    if (result.homeEntered) score += 55;
    if (result.toPosition >= kHomeStretchBase &&
        result.toPosition != kFinishedPosition) {
      score += 22;
    }

    // Getting a token out of base (on a 6) — valuable when few are out.
    if (from == kHomeBasePosition) {
      final out = me.tokens.where((t) => !t.inBase && !t.finished).length;
      score += 28 - out * 5;
    }

    // General forward progress.
    score += _progress(me.color, result.toPosition) * 0.25;

    // Landing on a safe star is good; staying exposed in front of a nearby
    // opponent is risky (hard bots weight this more).
    final landed = result.toPosition;
    if (landed >= 0 && landed < kTrackLength) {
      if (LudoGeometrySafe.isSafe(landed)) {
        score += 12;
      } else if (difficulty == LudoDifficulty.hard) {
        score -= _dangerAt(state, me.color, landed) * 14;
      }
    }

    // Move the rearmost token forward to spread risk a touch (tie-breaker).
    score += (51 - _progress(me.color, from)) * 0.02;
    return score;
  }

  /// 0..57-ish progress metric: base=0, track distance grows, stretch high,
  /// finished highest.
  double _progress(LudoColor color, int position) {
    if (position == kHomeBasePosition) return 0;
    if (position == kFinishedPosition) return 57;
    if (position >= kHomeStretchBase) {
      return 52 + (position - kHomeStretchBase).toDouble();
    }
    final entry = kColorEntry[color]!;
    return ((position - entry) % kTrackLength).toDouble();
  }

  int _capturedFrom(LudoState state, CapturedToken c) {
    for (final p in state.players) {
      if (p.color == c.color) {
        return p.tokens[c.tokenIndex].position;
      }
    }
    return 0;
  }

  /// Count opponent tokens 1..6 squares BEHIND [square] that could capture it
  /// next turn (rough danger estimate).
  double _dangerAt(LudoState state, LudoColor mine, int square) {
    var danger = 0.0;
    for (final p in state.players) {
      if (p.color == mine) continue;
      if (state.mode == LudoMode.team2v2 && teamOf(p.color) == teamOf(mine)) {
        continue;
      }
      for (final t in p.tokens) {
        if (!t.onTrack) continue;
        final dist = (square - t.position) % kTrackLength;
        if (dist >= 1 && dist <= 6) danger += 1;
      }
    }
    return danger;
  }
}

/// Tiny indirection so the AI file doesn't import the painter geometry directly
/// (keeps the engine layer free of UI imports while reusing the safe set).
class LudoGeometrySafe {
  static bool isSafe(int trackIndex) => kSafeSquares.contains(trackIndex);
}
