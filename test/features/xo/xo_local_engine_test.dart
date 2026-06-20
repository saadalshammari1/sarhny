import 'package:flutter_test/flutter_test.dart';
import 'package:sarhny/features/xo/application/xo_local_engine.dart';

/// Validates the rules engine end-to-end so we have CI-enforced
/// confidence the "I can't place the 3rd X to win" class of bug
/// can't regress. The tests cover the exact scenario the user
/// reported: place X, X, X in a row → engine must detect a win.
void main() {
  group('XoLocalEngine', () {
    test('opens with empty board, X to play', () {
      final e = XoLocalEngine();
      expect(e.turn, 'X');
      expect(e.winner, isNull);
      expect(e.movesMade, 0);
    });

    test('alternates turns after each successful move', () {
      final e = XoLocalEngine();
      expect(e.play(0, 0, 'X'), XoMoveOutcome.ok);
      expect(e.turn, 'O');
      expect(e.play(0, 1, 'O'), XoMoveOutcome.ok);
      expect(e.turn, 'X');
    });

    test('rejects move when not your turn', () {
      final e = XoLocalEngine();
      expect(e.play(0, 0, 'O'), XoMoveOutcome.notYourTurn);
      expect(e.cells[0][0], '');
    });

    test('rejects move on occupied cell', () {
      final e = XoLocalEngine();
      e.play(1, 1, 'X');
      expect(e.play(1, 1, 'O'), XoMoveOutcome.cellOccupied);
    });

    test('detects winning row', () {
      final e = XoLocalEngine();
      e.play(0, 0, 'X');
      e.play(1, 0, 'O');
      e.play(0, 1, 'X');
      e.play(1, 1, 'O');
      // The user-reported scenario: third X completes the win.
      expect(e.play(0, 2, 'X'), XoMoveOutcome.ok);
      expect(e.winner, 'X');
      expect(e.winningLine, [
        [0, 0], [0, 1], [0, 2],
      ]);
    });

    test('detects winning column', () {
      final e = XoLocalEngine();
      e.play(0, 0, 'X');
      e.play(0, 1, 'O');
      e.play(1, 0, 'X');
      e.play(1, 1, 'O');
      expect(e.play(2, 0, 'X'), XoMoveOutcome.ok);
      expect(e.winner, 'X');
    });

    test('detects winning diagonal', () {
      final e = XoLocalEngine();
      e.play(0, 0, 'X');
      e.play(0, 1, 'O');
      e.play(1, 1, 'X');
      e.play(0, 2, 'O');
      expect(e.play(2, 2, 'X'), XoMoveOutcome.ok);
      expect(e.winner, 'X');
      expect(e.winningLine.first, [0, 0]);
      expect(e.winningLine.last, [2, 2]);
    });

    test('refuses move after game ends', () {
      final e = XoLocalEngine();
      e.play(0, 0, 'X');
      e.play(1, 0, 'O');
      e.play(0, 1, 'X');
      e.play(1, 1, 'O');
      e.play(0, 2, 'X'); // X wins
      expect(e.play(2, 2, 'O'), XoMoveOutcome.gameOver);
    });

    test('detects draw at 9 moves with no winner', () {
      final e = XoLocalEngine();
      // Layout (no winning line):
      //  X O X
      //  X X O
      //  O X O
      e.play(0, 0, 'X');
      e.play(0, 1, 'O');
      e.play(0, 2, 'X');
      e.play(1, 2, 'O');
      e.play(1, 0, 'X');
      e.play(2, 0, 'O');
      e.play(1, 1, 'X');
      e.play(2, 2, 'O');
      e.play(2, 1, 'X');
      expect(e.winner, 'draw');
      expect(e.movesMade, 9);
    });

    test('AI takes the immediate win', () {
      final e = XoLocalEngine();
      // Set up: O has X X _ on row 0 — AI (O) should NOT block first,
      // it should WIN if it can. We put O O _ on row 2 so O can win.
      e.cells = [
        ['X', 'X', ''],
        ['', '', ''],
        ['O', 'O', ''],
      ];
      final pick = e.aiPick('O');
      expect(pick, isNotNull);
      expect(pick!.row, 2);
      expect(pick.col, 2);
    });

    test('AI blocks opponent win when no own win available', () {
      final e = XoLocalEngine();
      e.cells = [
        ['X', 'X', ''],
        ['', 'O', ''],
        ['', '', ''],
      ];
      final pick = e.aiPick('O');
      expect(pick, isNotNull);
      expect(pick!.row, 0);
      expect(pick.col, 2);
    });

    test('AI takes centre when board is empty', () {
      final e = XoLocalEngine();
      final pick = e.aiPick('X');
      expect(pick, isNotNull);
      expect(pick!.row, 1);
      expect(pick.col, 1);
    });
  });
}
