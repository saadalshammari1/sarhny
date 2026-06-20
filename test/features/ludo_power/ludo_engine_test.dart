import 'package:flutter_test/flutter_test.dart';
import 'package:sarhny/features/games/ludo_power/engine/ludo_engine.dart';

/// Sanity coverage for the Ludo-Power engine. The board geometry was
/// previously validated via 5000-game JS simulation; these tests pin the
/// Dart port so subtle refactors can't silently break path math, capture
/// rules, the 2-player ring, or extra-turn detection.
void main() {
  group('LudoEngine — defaults & structure', () {
    test('opens fresh with human active, no roll yet', () {
      final e = LudoEngine();
      expect(e.current, LudoEngine.humanPlayer);
      expect(e.rolled, isFalse);
      expect(e.gameOver, isFalse);
      expect(e.pieces.length, 4);
      for (final row in e.pieces) {
        expect(row, [0, 0, 0, 0]);
      }
    });

    test('exposes 4 active players by default', () {
      final e = LudoEngine();
      expect(e.activePlayers, [0, 1, 2, 3]);
      expect(e.isActivePlayer(0), isTrue);
      expect(e.isActivePlayer(2), isTrue);
    });

    test('2-player mode exposes only diagonal seats', () {
      final e = LudoEngine(playerCount: 2);
      expect(e.activePlayers, [0, 2]);
      expect(e.isActivePlayer(0), isTrue);
      expect(e.isActivePlayer(1), isFalse);
      expect(e.isActivePlayer(2), isTrue);
      expect(e.isActivePlayer(3), isFalse);
    });

    test('asserts player count is 2 or 4', () {
      expect(() => LudoEngine(playerCount: 3), throwsA(isA<AssertionError>()));
    });
  });

  group('LudoEngine — special tiles', () {
    test('exactly 6 power tiles laid out (2 portals + 2 rockets + 1 freeze + 1 tornado)',
        () {
      final e = LudoEngine();
      expect(e.specials.length, 6);
      final byType = <PowerType, int>{};
      for (final sp in e.specials.values) {
        byType[sp.type] = (byType[sp.type] ?? 0) + 1;
      }
      expect(byType[PowerType.portal], 2);
      expect(byType[PowerType.rocket], 2);
      expect(byType[PowerType.freeze], 1);
      expect(byType[PowerType.tornado], 1);
    });

    test('powers never land on a safe cell', () {
      // 100 reseeds: pure-random shuffle should never place a power on
      // a safe star — the shuffle algorithm filters them out explicitly.
      for (int i = 0; i < 100; i++) {
        final e = LudoEngine();
        for (final idx in e.specials.keys) {
          expect(kSafe.contains(idx), isFalse,
              reason: 'tile $idx is in kSafe but holds a power');
        }
      }
    });
  });

  group('LudoEngine — legal moves', () {
    test('home pieces only legal on roll of 6', () {
      final e = LudoEngine();
      for (int d = 1; d <= 5; d++) {
        expect(e.legalMoves(0, d), isEmpty,
            reason: 'no piece should move from home on roll $d');
      }
      final six = e.legalMoves(0, 6);
      expect(six.length, 4); // all 4 home pieces can come out
      for (final m in six) {
        expect(m.from, 0);
        expect(m.to, 1);
      }
    });

    test('moves capped at progress 57', () {
      final e = LudoEngine();
      e.pieces[0][0] = 56; // one square from centre
      final moves = e.legalMoves(0, 5);
      expect(moves, isEmpty,
          reason: 'roll 5 from prog 56 overshoots centre, must be filtered');
      final exact = e.legalMoves(0, 1);
      expect(exact.first.to, 57);
    });

    test('finished pieces do not move', () {
      final e = LudoEngine();
      e.pieces[0][0] = 57;
      final moves = e.legalMoves(0, 3);
      // Only pieces 1,2,3 are at home (need 6); finished piece 0 is excluded.
      expect(moves.where((m) => m.piece == 0), isEmpty);
    });
  });

  group('LudoEngine — capture', () {
    test('lands on opponent on unsafe cell → opponent sent home', () {
      final events = <GameEvent>[];
      final e = LudoEngine(onEvent: events.add);
      // Drop random power tiles so they cannot teleport/rocket the piece
      // away from the target cell before capture resolves. These tests
      // exercise capture mechanics in isolation.
      e.specials.clear();
      final targetCell = (kStart[0] + 4) % 52; // 16
      final opp1Prog = e.progFromMain(1, targetCell)!;
      e.pieces[1][0] = opp1Prog;
      final captured = e.applyMove(0, Move(0, 0, 5));
      expect(captured, isTrue, reason: 'capture grants extra turn');
      expect(e.pieces[1][0], 0, reason: 'captured opponent returns home');
      expect(events.any((ev) => ev.kind == 'capture'), isTrue);
    });

    test('safe-cell landing does NOT capture', () {
      final e = LudoEngine();
      e.specials.clear();
      final safe = 21;
      expect(kSafe.contains(safe), isTrue);
      final p0Prog = e.progFromMain(0, safe)!;
      final p1Prog = e.progFromMain(1, safe)!;
      e.pieces[1][0] = p1Prog;
      e.pieces[0][0] = p0Prog - 2;
      final extraTurn = e.applyMove(0, Move(0, p0Prog - 2, p0Prog));
      expect(e.pieces[1][0], p1Prog,
          reason: 'opponent on safe cell must NOT be captured');
      expect(extraTurn, isFalse,
          reason: 'no capture + no 6 + not centre → no extra turn');
    });
  });

  group('LudoEngine — turn rotation', () {
    test('4-player ring goes 0→1→2→3→0', () {
      final e = LudoEngine();
      expect(e.current, 0);
      e.rollDice();
      e.endTurn();
      expect(e.current, 1);
      e.rollDice();
      e.endTurn();
      expect(e.current, 2);
      e.rollDice();
      e.endTurn();
      expect(e.current, 3);
      e.rollDice();
      e.endTurn();
      expect(e.current, 0);
    });

    test('2-player ring skips inactive seats: 0→2→0', () {
      final e = LudoEngine(playerCount: 2);
      expect(e.current, 0);
      e.rollDice();
      e.endTurn();
      expect(e.current, 2,
          reason: 'must hop straight to player 2 (skip blue/green)');
      e.rollDice();
      e.endTurn();
      expect(e.current, 0);
    });

    test('frozen seat consumes one freeze tick then is skipped this round',
        () {
      final e = LudoEngine();
      e.frozen[1] = 1; // player 1 has one frozen tick
      e.rollDice();
      e.endTurn();
      // Player 1 was next — they get skipped, tick decremented.
      expect(e.current, 2);
      expect(e.frozen[1], 0);
    });
  });

  group('LudoEngine — win', () {
    test('all 4 pieces at 57 → gameOver + win event fires', () {
      final events = <GameEvent>[];
      final e = LudoEngine(onEvent: events.add);
      // Put 3 of player 0's pieces at the centre, then move the 4th in.
      e.pieces[0][0] = 56;
      e.pieces[0][1] = 57;
      e.pieces[0][2] = 57;
      e.pieces[0][3] = 57;
      final extraTurn = e.applyMove(0, Move(0, 56, 57));
      expect(e.gameOver, isTrue);
      expect(extraTurn, isFalse,
          reason: 'returns false once gameOver fires (no extra turn after win)');
      final win = events.where((ev) => ev.kind == 'win').toList();
      expect(win.length, 1);
      expect(win.first.player, 0);
    });
  });

  group('LudoEngine — bot scoring', () {
    test('bot prefers a move that captures over an idle hop', () {
      final e = LudoEngine();
      e.specials.clear();
      e.current = 1;
      e.dice = 3;
      // Pick a destination cell on player 1's lane that's NOT safe.
      int shift = 6;
      int destCell = (kStart[1] + shift - 1) % 52;
      while (kSafe.contains(destCell) && shift < 15) {
        shift++;
        destCell = (kStart[1] + shift - 1) % 52;
      }
      // Park player 0 on that cell so player 1 can capture by hopping 3.
      e.pieces[0][0] = e.progFromMain(0, destCell)!;
      // Two candidate moves for player 1: piece[0] hops to capture, piece[1]
      // hops alone (no capture).
      e.pieces[1][0] = shift - 3;
      e.pieces[1][1] = 1;
      final moves = e.legalMoves(1, 3);
      final pick = e.botChoose(moves);
      expect(pick.piece, 0,
          reason: 'bot must choose the capturing move, not the idle hop');
    });
  });
}
