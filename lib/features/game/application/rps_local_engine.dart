/// Pure-Dart Rock-Paper-Scissors engine + simple AI.
///
/// Mirrors the server-side rules so the local vs-AI mode plays the
/// same way as online RPS — same best-of-5 race, same "your choice +
/// your guess of the opponent's choice" mechanic.
///
/// Scoring rules (match the backend):
///   * Win the RPS hand: +1
///   * Correctly guess opponent's hand: +1
///   * Both can happen in the same round (max +2 / -2 swing).
///   * First to [winScore] points wins the match.
library;

import 'dart:math' as math;

enum RpsHand { rock, paper, scissors }

extension RpsHandX on RpsHand {
  String get key {
    switch (this) {
      case RpsHand.rock:
        return 'rock';
      case RpsHand.paper:
        return 'paper';
      case RpsHand.scissors:
        return 'scissors';
    }
  }

  String get glyph {
    switch (this) {
      case RpsHand.rock:
        return '✊';
      case RpsHand.paper:
        return '✋';
      case RpsHand.scissors:
        return '✌️';
    }
  }
}

class RpsRound {
  RpsRound({
    required this.myHand,
    required this.myGuess,
    required this.oppHand,
    required this.oppGuess,
    required this.myPoints,
    required this.oppPoints,
  });
  final RpsHand myHand;
  final RpsHand myGuess;
  final RpsHand oppHand;
  final RpsHand oppGuess;
  /// Points scored in this round by me / opp.
  final int myPoints;
  final int oppPoints;
}

class RpsLocalEngine {
  RpsLocalEngine({int? seed, this.winScore = 5})
      : _rng = math.Random(seed);

  final math.Random _rng;
  final int winScore;

  int myScore = 0;
  int oppScore = 0;
  int roundNumber = 1;
  final List<RpsRound> history = [];
  /// Becomes non-null once one side reaches [winScore].
  /// 'me' | 'opp'
  String? winner;

  bool get isOver => winner != null;

  /// Beats relation: 0 = tie, +1 = a wins, -1 = b wins.
  static int _compare(RpsHand a, RpsHand b) {
    if (a == b) return 0;
    final winsAgainst = {
      RpsHand.rock: RpsHand.scissors,
      RpsHand.paper: RpsHand.rock,
      RpsHand.scissors: RpsHand.paper,
    };
    return winsAgainst[a] == b ? 1 : -1;
  }

  /// AI picks its hand + guess. Fair strategy:
  ///   * If the user has shown a strong preference for one hand in the
  ///     last 3 rounds, exploit it with the counter.
  ///   * Otherwise random with mild "anti-pattern" bias.
  ({RpsHand hand, RpsHand guess}) aiPick() {
    final last3 = history.length > 3
        ? history.sublist(history.length - 3)
        : history;
    // Count user's recent hands.
    final counts = <RpsHand, int>{
      RpsHand.rock: 0,
      RpsHand.paper: 0,
      RpsHand.scissors: 0,
    };
    for (final r in last3) {
      counts[r.myHand] = counts[r.myHand]! + 1;
    }
    final mostUsed = counts.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
    // 60% counter their pattern, 40% random — keeps it beatable.
    RpsHand aiHand;
    if (mostUsed.value >= 2 && _rng.nextDouble() < 0.60) {
      aiHand = _beats(mostUsed.key);
    } else {
      aiHand = RpsHand.values[_rng.nextInt(3)];
    }
    // Guess: random — emulates the opponent not knowing our move.
    final aiGuess = RpsHand.values[_rng.nextInt(3)];
    return (hand: aiHand, guess: aiGuess);
  }

  static RpsHand _beats(RpsHand hand) {
    switch (hand) {
      case RpsHand.rock:
        return RpsHand.paper;
      case RpsHand.paper:
        return RpsHand.scissors;
      case RpsHand.scissors:
        return RpsHand.rock;
    }
  }

  /// Apply a finished round. Returns the resolved RpsRound so the UI
  /// can show the reveal. Caller is responsible for calling [aiPick]
  /// to get the opponent's hand/guess BEFORE calling this.
  RpsRound playRound({
    required RpsHand myHand,
    required RpsHand myGuess,
    required RpsHand oppHand,
    required RpsHand oppGuess,
  }) {
    if (isOver) {
      throw StateError('match already finished');
    }
    var my = 0;
    var op = 0;
    final cmp = _compare(myHand, oppHand);
    if (cmp > 0) my += 1;
    if (cmp < 0) op += 1;
    if (myGuess == oppHand) my += 1;
    if (oppGuess == myHand) op += 1;

    myScore += my;
    oppScore += op;

    final round = RpsRound(
      myHand: myHand,
      myGuess: myGuess,
      oppHand: oppHand,
      oppGuess: oppGuess,
      myPoints: my,
      oppPoints: op,
    );
    history.add(round);
    roundNumber += 1;

    if (myScore >= winScore && myScore > oppScore) {
      winner = 'me';
    } else if (oppScore >= winScore && oppScore > myScore) {
      winner = 'opp';
    } else if (myScore >= winScore && oppScore >= winScore) {
      // Both hit threshold on the same round — break the tie by lead;
      // if dead even, the next round decides.
      winner = myScore > oppScore
          ? 'me'
          : (oppScore > myScore ? 'opp' : null);
    }
    return round;
  }

  void reset() {
    myScore = 0;
    oppScore = 0;
    roundNumber = 1;
    history.clear();
    winner = null;
  }
}
