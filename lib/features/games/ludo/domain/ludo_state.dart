import 'ludo_player.dart';

/// وضع المباراة الحالي.
enum LudoStatus { waiting, playing, finished }

LudoStatus _parseStatus(String? s) {
  switch (s) {
    case 'playing':
      return LudoStatus.playing;
    case 'finished':
      return LudoStatus.finished;
    default:
      return LudoStatus.waiting;
  }
}

/// نمط اللعب — 2 لاعبين (1v1 بألوان متقابلة) أو 4 لاعبين (الكل ضد الكل).
enum LudoMode { twoPlayer, fourPlayer }

extension LudoModeParse on LudoMode {
  static LudoMode parse(String raw) {
    return raw == '4p' ? LudoMode.fourPlayer : LudoMode.twoPlayer;
  }

  String get wire => this == LudoMode.fourPlayer ? '4p' : '2p';

  String get arabicLabel =>
      this == LudoMode.fourPlayer ? '٤ لاعبين' : '٢ لاعبين';

  int get seats => this == LudoMode.fourPlayer ? 4 : 2;
}

/// Snapshot كامل للوحة لودو من السيرفر.
class LudoState {
  const LudoState({
    required this.roomId,
    required this.mode,
    required this.status,
    required this.players,
    required this.turnSeat,
    required this.yourSeat,
    required this.yourTurn,
    required this.seq,
    required this.pot,
    this.dice,
  });

  final String roomId;
  final LudoMode mode;
  final LudoStatus status;
  final List<LudoPlayer> players;

  /// 0..3 — الجلسة التي عليها الدور الآن.
  final int turnSeat;

  /// قيمة الزهر الأخيرة (1..6) أو null لو لم يُرمَ بعد.
  final int? dice;

  /// 0..3 — موقعي.
  final int yourSeat;

  /// true لو الدور دوري ومسموح لي بالرمي/الحركة.
  final bool yourTurn;

  /// تسلسل تصاعدي — للـ out-of-order detection.
  final int seq;

  /// مجموع الـ pot (مجموع entry fees لكل اللاعبين).
  final int pot;

  /// يرجع اللاعب الذي يجلس في seat معين (لو موجود).
  LudoPlayer? playerAt(int seat) {
    for (final p in players) {
      if (p.seat == seat) return p;
    }
    return null;
  }

  /// أنا.
  LudoPlayer? get me => playerAt(yourSeat);

  /// الذي يلعب الآن.
  LudoPlayer? get current => playerAt(turnSeat);

  LudoState copyWith({
    LudoStatus? status,
    List<LudoPlayer>? players,
    int? turnSeat,
    bool? yourTurn,
    int? seq,
    int? dice,
    bool clearDice = false,
  }) =>
      LudoState(
        roomId: roomId,
        mode: mode,
        status: status ?? this.status,
        players: players ?? this.players,
        turnSeat: turnSeat ?? this.turnSeat,
        yourSeat: yourSeat,
        yourTurn: yourTurn ?? this.yourTurn,
        seq: seq ?? this.seq,
        pot: pot,
        dice: clearDice ? null : (dice ?? this.dice),
      );

  factory LudoState.fromJson(Map<String, dynamic> j) {
    final rawPlayers = (j['players'] as List?) ?? const [];
    return LudoState(
      roomId: '${j['room_id'] ?? ''}',
      mode: LudoModeParse.parse('${j['mode'] ?? '2p'}'),
      status: _parseStatus(j['status']?.toString()),
      players: rawPlayers
          .whereType<Map>()
          .map((m) => LudoPlayer.fromJson(m.cast<String, dynamic>()))
          .toList(growable: false),
      turnSeat: (j['turn_seat'] as num?)?.toInt() ?? 0,
      yourSeat: (j['your_seat'] as num?)?.toInt() ?? 0,
      yourTurn: j['your_turn'] == true,
      seq: (j['seq'] as num?)?.toInt() ?? 0,
      pot: (j['pot'] as num?)?.toInt() ?? 0,
      dice: (j['dice'] as num?)?.toInt(),
    );
  }
}
