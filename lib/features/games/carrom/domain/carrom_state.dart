import 'cosmetics.dart';
import 'piece.dart';

/// حالة المباراة كما يرسلها السيرفر.
enum CarromStatus { waiting, playing, finished }

CarromStatus _parseStatus(String? s) {
  switch (s) {
    case 'playing':
      return CarromStatus.playing;
    case 'finished':
      return CarromStatus.finished;
    default:
      return CarromStatus.waiting;
  }
}

/// Snapshot كامل للوحة + النقاط + الدور.
class CarromState {
  const CarromState({
    required this.roomId,
    required this.status,
    required this.playerAId,
    required this.playerBId,
    required this.aScore,
    required this.bScore,
    required this.aQueenCovered,
    required this.bQueenCovered,
    required this.turnPlayerId,
    required this.yourTurn,
    required this.seq,
    required this.pieces,
    required this.pot,
    this.cosmetics = MatchCosmetics.defaults,
  });

  final String roomId;
  final CarromStatus status;
  final int playerAId;
  final int playerBId;
  final int aScore;
  final int bScore;
  final bool aQueenCovered;
  final bool bQueenCovered;
  final int turnPlayerId;
  final bool yourTurn;
  final int seq;
  final List<CarromPiece> pieces;
  final int pot;

  /// Resolved per-match cosmetics — السيرفر يرسلها جاهزة بعد الـ
  /// conflict resolution، فالـ board widget يقرأها مباشرة.
  final MatchCosmetics cosmetics;

  /// من هو "أنا"؟ — السيرفر يبعث yourTurn فقط؛ هوية اللاعب نأخذها من
  /// JWT side. هنا نحفظ نقاط me/opp مباشرة عبر helper.
  int scoreFor(int? userId) {
    if (userId == null) return 0;
    if (userId == playerAId) return aScore;
    if (userId == playerBId) return bScore;
    return 0;
  }

  int opponentScoreFor(int? userId) {
    if (userId == null) return 0;
    if (userId == playerAId) return bScore;
    if (userId == playerBId) return aScore;
    return 0;
  }

  int? opponentIdOf(int? me) {
    if (me == null) return null;
    if (me == playerAId) return playerBId;
    if (me == playerBId) return playerAId;
    return null;
  }

  CarromState copyWith({
    CarromStatus? status,
    int? aScore,
    int? bScore,
    int? turnPlayerId,
    bool? yourTurn,
    int? seq,
    List<CarromPiece>? pieces,
  }) =>
      CarromState(
        roomId: roomId,
        status: status ?? this.status,
        playerAId: playerAId,
        playerBId: playerBId,
        aScore: aScore ?? this.aScore,
        bScore: bScore ?? this.bScore,
        aQueenCovered: aQueenCovered,
        bQueenCovered: bQueenCovered,
        turnPlayerId: turnPlayerId ?? this.turnPlayerId,
        yourTurn: yourTurn ?? this.yourTurn,
        seq: seq ?? this.seq,
        pieces: pieces ?? this.pieces,
        pot: pot,
        cosmetics: cosmetics,
      );

  factory CarromState.fromJson(Map<String, dynamic> j) {
    final rawPieces = (j['pieces'] as List?) ?? const [];
    final rawCosm = (j['cosmetics'] as Map?)?.cast<String, dynamic>();
    return CarromState(
      roomId: '${j['room_id'] ?? ''}',
      status: _parseStatus(j['status']?.toString()),
      playerAId: (j['player_a_id'] as num?)?.toInt() ?? 0,
      playerBId: (j['player_b_id'] as num?)?.toInt() ?? 0,
      aScore: (j['a_score'] as num?)?.toInt() ?? 0,
      bScore: (j['b_score'] as num?)?.toInt() ?? 0,
      aQueenCovered: j['a_queen_covered'] == true,
      bQueenCovered: j['b_queen_covered'] == true,
      turnPlayerId: (j['turn_player_id'] as num?)?.toInt() ?? 0,
      yourTurn: j['your_turn'] == true,
      seq: (j['seq'] as num?)?.toInt() ?? 0,
      pieces: rawPieces
          .whereType<Map>()
          .map((m) => CarromPiece.fromJson(m.cast<String, dynamic>()))
          .toList(growable: false),
      pot: (j['pot'] as num?)?.toInt() ?? 0,
      cosmetics: rawCosm == null
          ? MatchCosmetics.defaults
          : MatchCosmetics.fromJson(rawCosm),
    );
  }
}
