import 'package:flutter_test/flutter_test.dart';
import 'package:sarhny/features/game/application/rps_local_engine.dart';

void main() {
  group('RpsLocalEngine', () {
    test('opens with zero scores', () {
      final e = RpsLocalEngine(seed: 42);
      expect(e.myScore, 0);
      expect(e.oppScore, 0);
      expect(e.isOver, isFalse);
      expect(e.roundNumber, 1);
    });

    test('rock beats scissors gives me +1', () {
      final e = RpsLocalEngine(seed: 1);
      final r = e.playRound(
        myHand: RpsHand.rock,
        myGuess: RpsHand.rock, // wrong guess
        oppHand: RpsHand.scissors,
        oppGuess: RpsHand.rock,
      );
      expect(r.myPoints, 1); // I won the hand
      expect(r.oppPoints, 1); // opp guessed my rock correctly
      expect(e.myScore, 1);
      expect(e.oppScore, 1);
    });

    test('tie hands gives no hand points, guesses still count', () {
      final e = RpsLocalEngine(seed: 1);
      e.playRound(
        myHand: RpsHand.paper,
        myGuess: RpsHand.paper, // correct
        oppHand: RpsHand.paper,
        oppGuess: RpsHand.rock, // wrong
      );
      expect(e.myScore, 1);
      expect(e.oppScore, 0);
    });

    test('first to 5 wins', () {
      final e = RpsLocalEngine(seed: 1);
      // Force-play 5 rounds where I score 2 each.
      for (var i = 0; i < 3; i++) {
        e.playRound(
          myHand: RpsHand.rock,
          myGuess: RpsHand.scissors,
          oppHand: RpsHand.scissors,
          oppGuess: RpsHand.paper,
        );
        // hand: rock beats scissors → +1 me
        // guess: my scissors guess matches → +1 me
        // opp guess: paper guess wrong → 0 opp
      }
      // After 3 rounds: my=6, opp=0 → match won by me on round 3.
      expect(e.isOver, isTrue);
      expect(e.winner, 'me');
    });

    test('reset clears state', () {
      final e = RpsLocalEngine(seed: 1);
      e.playRound(
        myHand: RpsHand.rock,
        myGuess: RpsHand.rock,
        oppHand: RpsHand.scissors,
        oppGuess: RpsHand.rock,
      );
      e.reset();
      expect(e.myScore, 0);
      expect(e.history, isEmpty);
      expect(e.winner, isNull);
    });

    test('AI picks return a valid (hand, guess) pair', () {
      final e = RpsLocalEngine(seed: 7);
      final pick = e.aiPick();
      expect(RpsHand.values, contains(pick.hand));
      expect(RpsHand.values, contains(pick.guess));
    });
  });
}
