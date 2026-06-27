import 'package:flutter_test/flutter_test.dart';
import 'package:sarhny/features/games/ludo3/engine/ludo_models.dart';
import 'package:sarhny/features/games/ludo3/engine/ludo_rules.dart';

void main() {
  group('projectPosition', () {
    test('leaves base only on a 6, landing on the colour entry', () {
      expect(projectPosition(LudoColor.red, kHomeBasePosition, 6), 0);
      expect(projectPosition(LudoColor.red, kHomeBasePosition, 3), isNull);
      expect(projectPosition(LudoColor.green, kHomeBasePosition, 6), 13);
      expect(projectPosition(LudoColor.blue, kHomeBasePosition, 6), 39);
    });

    test('walks the track and wraps modulo 52', () {
      expect(projectPosition(LudoColor.green, 13, 5), 18);
      expect(projectPosition(LudoColor.red, 49, 1), 50); // red stretch entry
    });

    test('swings into the home stretch and finishes on an exact roll', () {
      // Red stretch entry is 50; +1 → stretch[0] = 100.
      expect(projectPosition(LudoColor.red, 50, 1), 100);
      expect(projectPosition(LudoColor.red, 50, 5), 104);
      // From last stretch square, exact +1 finishes; overshoot is illegal.
      expect(projectPosition(LudoColor.red, 104, 1), kFinishedPosition);
      expect(projectPosition(LudoColor.red, 104, 2), isNull);
      // Finished tokens never move.
      expect(projectPosition(LudoColor.red, kFinishedPosition, 3), isNull);
    });
  });

  group('applyMove captures & wins', () {
    LudoState twoPlayer() => LudoState.local(mode: LudoMode.p2, names: ['A', 'B']);

    test('landing on an opponent on a non-safe square sends it home', () {
      final s = twoPlayer();
      final me = s.playerBySeat(0)!;
      final opp = s.playerBySeat(1)!;
      me.tokens[0].position = 18; // on track, non-safe
      opp.tokens[0].position = 20;
      s.turnSeat = 0;
      final r = applyMove(s, 2, 0, 0); // seat0 18 -> 20, captures the opponent
      expect(r.captured.length, 1);
      expect(r.captured.first.color, opp.color);
      expect(r.diceAgain, isTrue); // capture grants another roll
      final oppAfter = r.state.playerBySeat(1)!.tokens[0].position;
      expect(oppAfter, kHomeBasePosition);
    });

    test('safe squares cannot be captured on', () {
      final s = twoPlayer();
      s.playerBySeat(0)!.tokens[0].position = 6;
      s.playerBySeat(1)!.tokens[0].position = 8; // a safe star
      s.turnSeat = 0;
      final r = applyMove(s, 2, 0, 0); // red 6 -> 8 (safe), no capture
      expect(r.captured, isEmpty);
      expect(r.state.playerBySeat(1)!.tokens[0].position, 8);
    });

    test('finishing all four tokens wins the match', () {
      final s = twoPlayer();
      final red = s.playerBySeat(0)!;
      for (final t in red.tokens) {
        t.position = kFinishedPosition;
      }
      red.tokens[3].position = 104; // last one a step away
      s.turnSeat = 0;
      final r = applyMove(s, 1, 0, 3);
      expect(r.won, isTrue);
      expect(r.gameOver, isTrue);
      expect(r.winnerUserId, red.userId);
    });
  });

  group('possibleMoves', () {
    test('only a 6 can move tokens stuck in base', () {
      final s = LudoState.local(mode: LudoMode.p2, names: ['A', 'B']);
      expect(possibleMoves(s, 3, 0), isEmpty);
      expect(possibleMoves(s, 6, 0).length, 4);
    });
  });

  group('team 2v2', () {
    test('never captures a teammate', () {
      final s = LudoState.local(mode: LudoMode.team2v2, names: ['A', 'B', 'C', 'D']);
      // seats: 0 red, 1 green, 2 yellow, 3 blue. red+yellow = team 0.
      final red = s.players.firstWhere((p) => p.color == LudoColor.red);
      final yellow = s.players.firstWhere((p) => p.color == LudoColor.yellow);
      red.tokens[0].position = 18;
      yellow.tokens[0].position = 20;
      s.turnSeat = red.seat;
      final r = applyMove(s, 2, red.seat, 0); // would land on teammate yellow
      expect(r.captured, isEmpty);
      expect(r.state.players.firstWhere((p) => p.color == LudoColor.yellow)
          .tokens[0].position, 20);
    });
  });
}
