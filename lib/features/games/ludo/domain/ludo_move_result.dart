import 'ludo_token.dart';

/// قطعة خصم تم أكلها — ترجع للقاعدة.
class LudoCapture {
  const LudoCapture({
    required this.color,
    required this.tokenIndex,
  });
  final LudoColor color;
  final int tokenIndex;

  factory LudoCapture.fromJson(Map<String, dynamic> j) => LudoCapture(
        color: LudoColorParse.parse('${j['color']}'),
        tokenIndex: (j['index'] as num?)?.toInt() ?? 0,
      );
}

/// نتيجة تحريك token — مرسلة من السيرفر بعد كل move ناجح.
///
/// الـ board يأخذها ويشغّل animation: from_pos → to_pos، ثم
/// يلعب capture animation لكل عنصر في captured.
class LudoMoveResult {
  const LudoMoveResult({
    required this.bySeat,
    required this.tokenIndex,
    required this.fromPos,
    required this.toPos,
    required this.captured,
    required this.diceAgain,
    required this.stepsTraveled,
  });

  /// 0..3 — الجلسة التي حركت.
  final int bySeat;
  final int tokenIndex;
  final LudoTokenPosition fromPos;
  final LudoTokenPosition toPos;
  final List<LudoCapture> captured;

  /// true لو الـ player يحصل على رمية إضافية (مثلاً رمى 6).
  final bool diceAgain;

  /// كم خانة تحركت — للـ animation timing (60ms × steps).
  final int stepsTraveled;

  factory LudoMoveResult.fromJson(Map<String, dynamic> j) {
    final rawCaps = (j['captured'] as List?) ?? const [];
    final from = (j['from_pos'] as num?)?.toInt() ?? -1;
    final to = (j['to_pos'] as num?)?.toInt() ?? -1;
    return LudoMoveResult(
      bySeat: (j['by_seat'] as num?)?.toInt() ?? 0,
      tokenIndex: (j['token_index'] as num?)?.toInt() ?? 0,
      fromPos: LudoTokenPosition.fromWire(from),
      toPos: LudoTokenPosition.fromWire(to),
      captured: rawCaps
          .whereType<Map>()
          .map((m) => LudoCapture.fromJson(m.cast<String, dynamic>()))
          .toList(growable: false),
      diceAgain: j['dice_again'] == true,
      stepsTraveled: (j['steps'] as num?)?.toInt() ?? 1,
    );
  }
}

/// نتيجة رمي الزهر — مرسلة قبل الـ move.
class LudoDiceRolled {
  const LudoDiceRolled({
    required this.bySeat,
    required this.value,
    required this.canMove,
  });
  final int bySeat;
  final int value;

  /// indices (0..3) للـ tokens التي يمكن تحريكها بهذه القيمة.
  final List<int> canMove;

  factory LudoDiceRolled.fromJson(Map<String, dynamic> j) => LudoDiceRolled(
        bySeat: (j['by_seat'] as num?)?.toInt() ?? 0,
        value: (j['value'] as num?)?.toInt() ?? 1,
        canMove: ((j['can_move'] as List?) ?? const [])
            .map((v) => (v as num).toInt())
            .toList(growable: false),
      );
}
