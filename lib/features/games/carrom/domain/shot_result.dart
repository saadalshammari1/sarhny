import 'piece.dart';

/// إطار واحد من نتيجة الـ shot: مواقع كل القطع في لحظة زمنية معينة.
class CarromFrame {
  const CarromFrame({required this.pieces});
  final List<CarromPiece> pieces;

  factory CarromFrame.fromJson(Map<String, dynamic> j) {
    final raw = (j['pieces'] as List?) ?? const [];
    return CarromFrame(
      pieces: raw
          .whereType<Map>()
          .map((m) => CarromPiece.fromJson(m.cast<String, dynamic>()))
          .toList(growable: false),
    );
  }
}

/// نتيجة الـ shot المرسلة من السيرفر — تحتوي 60 frame + ملخص.
class CarromShotResult {
  const CarromShotResult({
    required this.frames,
    required this.finalPieces,
    required this.scoredIds,
    required this.nextTurnPlayerId,
    required this.aScore,
    required this.bScore,
    required this.queenCovered,
    required this.foul,
    this.foulReason,
    this.queenPending = false,
  });

  final List<CarromFrame> frames;
  final List<CarromPiece> finalPieces;
  final List<int> scoredIds; // معرفات القطع التي دخلت
  final int nextTurnPlayerId;
  final int aScore;
  final int bScore;
  final bool queenCovered;
  final bool foul;
  /// Server-stamped foul classification. One of: striker_pocketed,
  /// no_piece_hit, wrong_color, queen_uncovered, opponent_color_pocketed,
  /// queen_pocketed_without_cover. null when foul == false.
  final String? foulReason;
  /// Queen is pocketed but not yet covered — UI shows a warning.
  final bool queenPending;

  factory CarromShotResult.fromJson(Map<String, dynamic> j) {
    final framesRaw = (j['frames'] as List?) ?? const [];
    final finalRaw = (j['final_pieces'] as List?) ?? const [];
    final scoredRaw = (j['scored'] as List?) ?? const [];
    return CarromShotResult(
      frames: framesRaw
          .whereType<Map>()
          .map((m) => CarromFrame.fromJson(m.cast<String, dynamic>()))
          .toList(growable: false),
      finalPieces: finalRaw
          .whereType<Map>()
          .map((m) => CarromPiece.fromJson(m.cast<String, dynamic>()))
          .toList(growable: false),
      scoredIds: scoredRaw.map((v) => (v as num).toInt()).toList(growable: false),
      nextTurnPlayerId: (j['next_turn'] as num?)?.toInt() ?? 0,
      aScore: (j['a_score'] as num?)?.toInt() ?? 0,
      bScore: (j['b_score'] as num?)?.toInt() ?? 0,
      queenCovered: j['queen_covered'] == true,
      foul: j['foul'] == true,
      foulReason: j['foul_reason']?.toString(),
      queenPending: j['queen_pending'] == true,
    );
  }
}
