/// Wire-format mirror of `app/api/tictactoe_api.py::_public_state`.
///
/// We keep the shape close to the server JSON so the repository can be a
/// thin pass-through. The state notifier wraps this snapshot with derived
/// flags + animation hooks; this file is pure data.
class XoSnapshot {
  const XoSnapshot({
    required this.gameId,
    required this.role,
    required this.status,
    required this.phase,
    required this.mood,
    required this.cells,
    required this.turn,
    required this.myTurn,
    required this.myMark,
    required this.oppMark,
    required this.movesMade,
    required this.isDraw,
    required this.winningLine,
    required this.isWinner,
    required this.winnerKnown,
    required this.finalQuestionText,
    required this.finalQuestionPickedAt,
    required this.finalQuestionDeadline,
    required this.finalAnswerStartedAt,
    required this.finalAnswerDeadline,
    required this.finalAnswer,
    required this.finalSkipUsed,
    required this.isInvite,
    required this.inviteCode,
    required this.waitingForOpponent,
  });

  /// Unique room id (24-char base64). Used as the URL slug.
  final String gameId;

  /// Whose seat we are — "a" (X, opener) or "b" (O).
  final String role;

  /// Game lifecycle. See server XOState.Status enum.
  /// waiting | playing | final | answering | answered | abandoned
  final String status;

  /// Sub-phase within `status`. Mirrors RPS so we can re-use widgets.
  /// null | writing_question | waiting_winner_question | answer | answered
  final String? phase;

  /// Question pool tier. light | bold | funny.
  final String mood;

  /// 3×3 board, row-major. Each cell is "" | "X" | "O".
  final List<List<String>> cells;

  /// Whose turn ("a" or "b") — only meaningful when status == playing.
  final String turn;

  /// Convenience derived flag — "is it my turn right now to place a mark?"
  final bool myTurn;

  /// "X" or "O" — what I draw.
  final String myMark;

  /// "X" or "O" — what the opponent draws.
  final String oppMark;

  /// 0..9 — how many cells have been filled. Used for "moves left" UX.
  final int movesMade;

  /// True only on draws (no winning line possible). Drives the
  /// "🤝 تعادل" badge on the game-over screen.
  final bool isDraw;

  /// Three coordinates [[r, c], [r, c], [r, c]] for the winning line.
  /// Empty if no winner yet.
  final List<List<int>> winningLine;

  /// True if `winner_id == me`, false if opponent won, null while pending.
  final bool? isWinner;

  /// True once status indicates the match is decided (winner OR draw).
  final bool winnerKnown;

  /// The post-game question shown to the loser. Server forcibly returns
  /// null during `final` phase (anti-cheat: loser must not preview the
  /// question while the winner is composing).
  final String? finalQuestionText;
  final double? finalQuestionPickedAt;
  final double? finalQuestionDeadline;
  final double? finalAnswerStartedAt;
  final double? finalAnswerDeadline;
  final String? finalAnswer;

  /// True after the loser used their one-shot question swap.
  final bool finalSkipUsed;

  /// True if this room was created via invite code (waits for friend).
  final bool isInvite;
  final String? inviteCode;
  final bool waitingForOpponent;

  factory XoSnapshot.fromJson(Map<String, dynamic> j) {
    final cellsRaw = (j['cells'] as List?) ?? const [];
    final lineRaw = (j['winning_line'] as List?) ?? const [];
    return XoSnapshot(
      gameId: j['game_id']?.toString() ?? '',
      role: j['role']?.toString() ?? 'a',
      status: j['status']?.toString() ?? 'waiting',
      phase: j['phase']?.toString(),
      mood: j['mood']?.toString() ?? 'light',
      cells: cellsRaw
          .map<List<String>>(
            (r) => (r as List).map((c) => c?.toString() ?? '').toList(growable: false),
          )
          .toList(growable: false),
      turn: j['turn']?.toString() ?? 'a',
      myTurn: j['my_turn'] == true,
      myMark: j['my_mark']?.toString() ?? 'X',
      oppMark: j['opp_mark']?.toString() ?? 'O',
      movesMade: (j['moves_made'] as num?)?.toInt() ?? 0,
      isDraw: j['is_draw'] == true,
      winningLine: lineRaw
          .map<List<int>>(
            (rc) => (rc as List).map((v) => (v as num).toInt()).toList(growable: false),
          )
          .toList(growable: false),
      isWinner: j['is_winner'] is bool ? j['is_winner'] as bool : null,
      winnerKnown: j['winner_known'] == true,
      finalQuestionText: j['final_question_text']?.toString(),
      finalQuestionPickedAt: (j['final_question_picked_at'] as num?)?.toDouble(),
      finalQuestionDeadline: (j['final_question_deadline'] as num?)?.toDouble(),
      finalAnswerStartedAt: (j['final_answer_started_at'] as num?)?.toDouble(),
      finalAnswerDeadline: (j['final_answer_deadline'] as num?)?.toDouble(),
      finalAnswer: j['final_answer']?.toString(),
      finalSkipUsed: j['final_skip_used'] == true,
      isInvite: j['is_invite'] == true,
      inviteCode: j['invite_code']?.toString(),
      waitingForOpponent: j['waiting_for_opponent'] == true,
    );
  }

  /// True only while both seats are filled but no one has won yet —
  /// the actual play surface should be interactive.
  bool get isPlaying => status == 'playing';

  /// True once the post-game flow has begun (question/answer/done).
  bool get isInPostGame => status == 'final' || status == 'answering' || status == 'answered';

  /// Convenience accessor — mark at a cell, or "" if empty.
  String cellAt(int r, int c) => cells[r][c];
}
