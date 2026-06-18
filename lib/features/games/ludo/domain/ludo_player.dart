import 'ludo_token.dart';

/// لاعب واحد داخل المباراة — مع 4 tokens + رتبة (لو انتهى).
class LudoPlayer {
  const LudoPlayer({
    required this.userId,
    required this.color,
    required this.seat,
    required this.tokens,
    this.finished = false,
    this.rank,
  });

  /// userId من السيرفر — قد يكون 0 إذا الخصم لم يتصل بعد.
  final int userId;
  final LudoColor color;

  /// 0..3 = ترتيب الجلوس (يحدد attribute في الـ UI).
  final int seat;

  /// مواضع الـ 4 tokens.
  final List<LudoTokenPosition> tokens;
  final bool finished;

  /// 1..4 إذا انتهى، null خلاف ذلك.
  final int? rank;

  /// كم token وصل المثلث؟
  int get finishedCount =>
      tokens.where((t) => t.zone == LudoTokenZone.finished).length;

  /// كم token ما زال في القاعدة؟
  int get homeCount =>
      tokens.where((t) => t.zone == LudoTokenZone.home).length;

  /// progress 0..1 للـ player card.
  double get progress {
    // كل token: home=0, track=0.5, stretch=0.75, finished=1.0
    double total = 0;
    for (final t in tokens) {
      switch (t.zone) {
        case LudoTokenZone.home:
          total += 0;
          break;
        case LudoTokenZone.track:
          total += 0.5;
          break;
        case LudoTokenZone.homeStretch:
          total += 0.75 + (t.cell / 4) * 0.20;
          break;
        case LudoTokenZone.finished:
          total += 1.0;
          break;
      }
    }
    return (total / 4).clamp(0.0, 1.0);
  }

  LudoPlayer copyWith({
    List<LudoTokenPosition>? tokens,
    bool? finished,
    int? rank,
  }) =>
      LudoPlayer(
        userId: userId,
        color: color,
        seat: seat,
        tokens: tokens ?? this.tokens,
        finished: finished ?? this.finished,
        rank: rank ?? this.rank,
      );

  factory LudoPlayer.fromJson(Map<String, dynamic> j) {
    final rawTokens = (j['tokens'] as List?) ?? const [];
    return LudoPlayer(
      userId: (j['user_id'] as num?)?.toInt() ?? 0,
      color: LudoColorParse.parse('${j['color']}'),
      seat: (j['seat'] as num?)?.toInt() ?? 0,
      tokens: rawTokens
          .map((v) => LudoTokenPosition.fromWire((v as num).toInt()))
          .toList(growable: false),
      finished: j['finished'] == true,
      rank: (j['rank'] as num?)?.toInt(),
    );
  }
}
