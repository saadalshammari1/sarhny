/// Ludo domain model — a faithful Dart mirror of the server's
/// `app/core/ludo_state.py`. The SAME position encoding is used on both
/// sides so an online match (server-authoritative) and an offline match
/// (this engine drives itself) share one rules layer.
///
/// Token position encoding (identical to the backend):
///   -1        → parked in this colour's home base.
///    0..51    → on the 52-square outer track (ABSOLUTE index, shared
///               across colours so capture detection is one integer
///               equality).
///    100..104 → in the colour's 5-square private home stretch.
///    200      → finished, inside the centre home triangle (immovable).
library;

import 'dart:ui' show Color;

// ── Position constants (mirror ludo_state.py) ──────────────────────────

const int kTrackLength = 52;
const int kHomeStretchLength = 5;

/// Per-cell hop duration for token movement animation (ms). The board walks a
/// token cell-by-cell along its path; controllers wait roughly steps×this so
/// the model stays in step with the visible motion.
const int kStepMs = 210;
const int kHomeBasePosition = -1;
const int kHomeStretchBase = 100;
const int kFinishedPosition = 200;
const int kMaxConsecutiveSixes = 3;

/// Where each colour ENTERS the main track on a rolled 6.
const Map<LudoColor, int> kColorEntry = {
  LudoColor.red: 0,
  LudoColor.green: 13,
  LudoColor.yellow: 26,
  LudoColor.blue: 39,
};

/// Where each colour LEAVES the track and swings into its home stretch.
/// A token on this square rolling N lands on stretch[N-1].
const Map<LudoColor, int> kHomeStretchEntry = {
  LudoColor.red: 50,
  LudoColor.green: 11,
  LudoColor.yellow: 24,
  LudoColor.blue: 37,
};

/// Star / safe squares — captures cannot happen here.
const Set<int> kSafeSquares = {0, 8, 13, 21, 26, 34, 39, 47};

enum LudoColor { red, green, yellow, blue }

extension LudoColorX on LudoColor {
  String get wire => switch (this) {
        LudoColor.red => 'red',
        LudoColor.green => 'green',
        LudoColor.yellow => 'yellow',
        LudoColor.blue => 'blue',
      };

  static LudoColor fromWire(String s) => switch (s) {
        'red' => LudoColor.red,
        'green' => LudoColor.green,
        'yellow' => LudoColor.yellow,
        'blue' => LudoColor.blue,
        _ => LudoColor.red,
      };

  /// Rich 5-stop colour ramp (light → base → mid → dark → deep) for glossy,
  /// 3D-shaded rendering of pieces, homes and tracks.
  Color get base => switch (this) {
        LudoColor.red => const Color(0xFFE23B32),
        LudoColor.green => const Color(0xFF43BD3F),
        LudoColor.yellow => const Color(0xFFF6C021),
        LudoColor.blue => const Color(0xFF2F9BF0),
      };

  Color get light => switch (this) {
        LudoColor.red => const Color(0xFFFF7A6E),
        LudoColor.green => const Color(0xFF8EF07A),
        LudoColor.yellow => const Color(0xFFFFE27A),
        LudoColor.blue => const Color(0xFF7FCCFF),
      };

  Color get mid => switch (this) {
        LudoColor.red => const Color(0xFFD12A22),
        LudoColor.green => const Color(0xFF2EA63A),
        LudoColor.yellow => const Color(0xFFEAA90C),
        LudoColor.blue => const Color(0xFF1F7FDA),
      };

  Color get dark => switch (this) {
        LudoColor.red => const Color(0xFF8C1310),
        LudoColor.green => const Color(0xFF1C7D27),
        LudoColor.yellow => const Color(0xFFB07C00),
        LudoColor.blue => const Color(0xFF155FB0),
      };

  Color get deep => switch (this) {
        LudoColor.red => const Color(0xFF5E0A08),
        LudoColor.green => const Color(0xFF0D5018),
        LudoColor.yellow => const Color(0xFF6E4D00),
        LudoColor.blue => const Color(0xFF0A3C78),
      };
}

/// Game mode. 2p = 1v1 (red+yellow, opposite corners). 4p = 4 free-for-all.
/// 2v2 = teams (red+yellow vs green+blue) — added in the teams phase.
enum LudoMode { p2, p4, team2v2 }

extension LudoModeX on LudoMode {
  String get wire => switch (this) {
        LudoMode.p2 => '2p',
        LudoMode.p4 => '4p',
        LudoMode.team2v2 => '2v2',
      };

  int get seats => this == LudoMode.p2 ? 2 : 4;

  static LudoMode fromWire(String s) => switch (s) {
        '2p' => LudoMode.p2,
        '4p' => LudoMode.p4,
        '2v2' => LudoMode.team2v2,
        _ => LudoMode.p2,
      };
}

/// Seat → colour order, mirroring `colors_for_mode` on the server.
List<LudoColor> colorsForMode(LudoMode mode) => switch (mode) {
      LudoMode.p2 => const [LudoColor.red, LudoColor.yellow],
      LudoMode.p4 => const [
          LudoColor.red,
          LudoColor.green,
          LudoColor.yellow,
          LudoColor.blue,
        ],
      // Teams seat order: red & yellow on team 0, green & blue on team 1,
      // interleaved by seat so turn order alternates teams.
      LudoMode.team2v2 => const [
          LudoColor.red,
          LudoColor.green,
          LudoColor.yellow,
          LudoColor.blue,
        ],
    };

/// Team index for a colour in 2v2 (red+yellow = 0, green+blue = 1).
int teamOf(LudoColor c) =>
    (c == LudoColor.red || c == LudoColor.yellow) ? 0 : 1;

// ── Mutable game model ─────────────────────────────────────────────────

class LudoToken {
  LudoToken({
    required this.color,
    required this.index,
    this.position = kHomeBasePosition,
  });

  final LudoColor color;
  final int index; // 0..3, stable within a match
  int position;

  bool get inBase => position == kHomeBasePosition;
  bool get onTrack => position >= 0 && position < kTrackLength;
  bool get inStretch => position >= kHomeStretchBase && position < kFinishedPosition;
  bool get finished => position == kFinishedPosition;

  LudoToken clone() =>
      LudoToken(color: color, index: index, position: position);

  Map<String, dynamic> toJson() =>
      {'player_color': color.wire, 'index': index, 'position': position};

  factory LudoToken.fromJson(Map<String, dynamic> j) => LudoToken(
        color: LudoColorX.fromWire(j['player_color'] as String),
        index: j['index'] as int,
        position: j['position'] as int,
      );
}

class LudoPlayer {
  LudoPlayer({
    required this.userId,
    required this.color,
    required this.seat,
    required this.tokens,
    this.name,
    this.isBot = false,
    this.finished = false,
    this.rank,
  });

  final int userId;
  final LudoColor color;
  final int seat;
  final List<LudoToken> tokens;
  String? name;
  bool isBot;
  bool finished;
  int? rank;

  int get team => teamOf(color);

  factory LudoPlayer.fresh({
    required int userId,
    required LudoColor color,
    required int seat,
    String? name,
    bool isBot = false,
  }) =>
      LudoPlayer(
        userId: userId,
        color: color,
        seat: seat,
        name: name,
        isBot: isBot,
        tokens: List.generate(
          4,
          (i) => LudoToken(color: color, index: i),
        ),
      );

  LudoPlayer clone() => LudoPlayer(
        userId: userId,
        color: color,
        seat: seat,
        name: name,
        isBot: isBot,
        finished: finished,
        rank: rank,
        tokens: tokens.map((t) => t.clone()).toList(),
      );

  factory LudoPlayer.fromJson(Map<String, dynamic> j) => LudoPlayer(
        userId: j['user_id'] as int,
        color: LudoColorX.fromWire(j['color'] as String),
        seat: j['seat'] as int,
        finished: j['finished'] as bool? ?? false,
        rank: j['rank'] as int?,
        tokens: ((j['tokens'] as List?) ?? const [])
            .map((t) => LudoToken.fromJson((t as Map).cast<String, dynamic>()))
            .toList(),
      );
}

enum LudoStatus { waiting, playing, finished, abandoned }

class LudoState {
  LudoState({
    required this.mode,
    required this.players,
    this.status = LudoStatus.playing,
    this.turnSeat = 0,
    this.dice,
    this.consecutiveSixes = 0,
    this.seq = 0,
    this.winnerUserId,
    this.winnerTeam,
  });

  final LudoMode mode;
  final List<LudoPlayer> players;
  LudoStatus status;
  int turnSeat;
  int? dice;
  int consecutiveSixes;
  int seq;
  int? winnerUserId;
  int? winnerTeam;

  LudoPlayer? playerBySeat(int seat) {
    for (final p in players) {
      if (p.seat == seat) return p;
    }
    return null;
  }

  LudoPlayer? get current => playerBySeat(turnSeat);

  LudoState clone() => LudoState(
        mode: mode,
        players: players.map((p) => p.clone()).toList(),
        status: status,
        turnSeat: turnSeat,
        dice: dice,
        consecutiveSixes: consecutiveSixes,
        seq: seq,
        winnerUserId: winnerUserId,
        winnerTeam: winnerTeam,
      );

  /// Local seat→colour order, chosen so the HUMAN (seat 0) always sits at the
  /// bottom-left (blue) for a consistent, pleasant layout: the 2nd player faces
  /// them at the top-right (green); 4-player fills clockwise BL→TL→TR→BR. In
  /// 2v2 this also makes the human + their teammate the blue/green pair (one
  /// team) sitting on the two diagonals, opponents red/yellow on the others.
  static List<LudoColor> _localSeatColors(LudoMode mode) => switch (mode) {
        LudoMode.p2 => const [LudoColor.blue, LudoColor.green],
        _ => const [
            LudoColor.blue, // BL — human
            LudoColor.red, // TL
            LudoColor.green, // TR
            LudoColor.yellow, // BR
          ],
      };

  /// Build a fresh local match (offline). Seat 0 is the human; the rest bots
  /// unless [humanSeats] says otherwise.
  factory LudoState.local({
    required LudoMode mode,
    required List<String> names,
  }) {
    final colors = _localSeatColors(mode);
    final seats = mode.seats;
    final players = <LudoPlayer>[];
    for (var s = 0; s < seats; s++) {
      players.add(LudoPlayer.fresh(
        userId: -(s + 1),
        color: colors[s],
        seat: s,
        name: s < names.length ? names[s] : null,
        isBot: s != 0,
      ));
    }
    return LudoState(mode: mode, players: players);
  }
}
