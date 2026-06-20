/// Pure-Dart Tic-Tac-Toe engine + simple AI.
///
/// Standalone (no Riverpod, no network) so it can power the local "play
/// vs AI" mode AND act as the rules reference for the online flow.
///
/// State invariants the engine guarantees:
///   * `cells` always reflects the actual board (no race with server)
///   * `winner` is one of: null (game ongoing) / 'X' / 'O' / 'draw'
///   * `winningLine` is populated only when winner is 'X' or 'O'
///   * `play()` is idempotent against illegal moves — returns false
///     instead of mutating state
library;

/// Engine outcome of a play attempt — handy for the UI to know exactly
/// why a tap was rejected.
enum XoMoveOutcome {
  ok,
  gameOver,
  cellOccupied,
  notYourTurn,
}

class XoLocalEngine {
  /// Row-major 3×3 board. Empty string = unplayed. 'X' or 'O' otherwise.
  List<List<String>> cells = [
    ['', '', ''],
    ['', '', ''],
    ['', '', ''],
  ];

  /// Whose turn it is — 'X' opens.
  String turn = 'X';

  /// 'X', 'O', 'draw', or null while in progress.
  String? winner;

  /// The 3 coordinates of the winning line, e.g. [[0,0],[1,1],[2,2]].
  /// Empty when no winner.
  List<List<int>> winningLine = const [];

  /// Move count 0..9.
  int get movesMade {
    var n = 0;
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        if (cells[r][c].isNotEmpty) n++;
      }
    }
    return n;
  }

  bool get isOver => winner != null;

  /// Attempt to play [symbol] at (row, col). Returns the precise reason
  /// it succeeded or failed so the UI can surface the right feedback.
  XoMoveOutcome play(int row, int col, String symbol) {
    if (winner != null) return XoMoveOutcome.gameOver;
    if (turn != symbol) return XoMoveOutcome.notYourTurn;
    if (cells[row][col].isNotEmpty) return XoMoveOutcome.cellOccupied;
    cells[row][col] = symbol;
    _checkOutcome();
    if (winner == null) turn = symbol == 'X' ? 'O' : 'X';
    return XoMoveOutcome.ok;
  }

  /// Reset for a new round.
  void reset() {
    cells = [
      ['', '', ''],
      ['', '', ''],
      ['', '', ''],
    ];
    turn = 'X';
    winner = null;
    winningLine = const [];
  }

  // ── Win detection ──────────────────────────────────────────────

  static const List<List<List<int>>> _lines = [
    // rows
    [[0, 0], [0, 1], [0, 2]],
    [[1, 0], [1, 1], [1, 2]],
    [[2, 0], [2, 1], [2, 2]],
    // cols
    [[0, 0], [1, 0], [2, 0]],
    [[0, 1], [1, 1], [2, 1]],
    [[0, 2], [1, 2], [2, 2]],
    // diagonals
    [[0, 0], [1, 1], [2, 2]],
    [[0, 2], [1, 1], [2, 0]],
  ];

  void _checkOutcome() {
    for (final line in _lines) {
      final a = cells[line[0][0]][line[0][1]];
      if (a.isEmpty) continue;
      if (a == cells[line[1][0]][line[1][1]] &&
          a == cells[line[2][0]][line[2][1]]) {
        winner = a;
        winningLine = line;
        return;
      }
    }
    if (movesMade == 9) {
      winner = 'draw';
      winningLine = const [];
    }
  }

  // ── AI ─────────────────────────────────────────────────────────

  /// Pick the AI's next move. Strategy:
  ///   1. Take the immediate win if available.
  ///   2. Block the opponent's immediate win.
  ///   3. Take centre if free.
  ///   4. Take a corner.
  ///   5. Take any edge.
  ///
  /// Deterministic — gives a "fair" opponent (winnable, not crushing).
  /// Returns null only if no cells remain (game already over — caller
  /// should have detected that via [isOver]).
  ({int row, int col})? aiPick(String aiSymbol) {
    if (isOver) return null;
    final oppSymbol = aiSymbol == 'X' ? 'O' : 'X';

    // 1. Win if possible.
    final win = _findCompletingMove(aiSymbol);
    if (win != null) return win;

    // 2. Block opponent's win.
    final block = _findCompletingMove(oppSymbol);
    if (block != null) return block;

    // 3. Centre.
    if (cells[1][1].isEmpty) return (row: 1, col: 1);

    // 4. Corner.
    const corners = [(0, 0), (0, 2), (2, 0), (2, 2)];
    for (final (r, c) in corners) {
      if (cells[r][c].isEmpty) return (row: r, col: c);
    }

    // 5. Any edge.
    const edges = [(0, 1), (1, 0), (1, 2), (2, 1)];
    for (final (r, c) in edges) {
      if (cells[r][c].isEmpty) return (row: r, col: c);
    }
    return null;
  }

  /// Helper: find an empty cell that would complete a 3-in-a-row for
  /// [symbol]. Returns null if no immediate win exists.
  ({int row, int col})? _findCompletingMove(String symbol) {
    for (final line in _lines) {
      var emptyCount = 0;
      var symbolCount = 0;
      late int emptyR;
      late int emptyC;
      for (final cell in line) {
        final v = cells[cell[0]][cell[1]];
        if (v.isEmpty) {
          emptyCount++;
          emptyR = cell[0];
          emptyC = cell[1];
        } else if (v == symbol) {
          symbolCount++;
        }
      }
      if (emptyCount == 1 && symbolCount == 2) {
        return (row: emptyR, col: emptyC);
      }
    }
    return null;
  }
}
