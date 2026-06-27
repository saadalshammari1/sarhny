/// Board geometry — maps the abstract position encoding (shared with the
/// server) onto a 15×15 grid of cells. Everything is expressed in CELL units
/// (the board is 15 units wide); the painter multiplies by `size / 15`.
///
/// The 52-square track, the four 5-square home columns, the safe stars and the
/// home-base parking slots are all derived once here so the painter and the
/// hit-testing share a single source of truth. The four inner corners of the
/// loop are diagonal steps (cells that touch at a corner) — that's the standard
/// Ludo turn and renders cleanly.
library;

import 'dart:ui';

import 'ludo_models.dart';

class LudoGeometry {
  LudoGeometry._();

  static const int grid = 15;

  /// Absolute track cells, index 0..51 (col, row). Verified against the
  /// server's COLOR_ENTRY / SAFE_SQUARES / HOME_STRETCH_ENTRY constants.
  static const List<(int, int)> track = [
    (1, 6), (2, 6), (3, 6), (4, 6), (5, 6), // 0-4   red arm
    (6, 5), (6, 4), (6, 3), (6, 2), (6, 1), (6, 0), // 5-10
    (7, 0), // 11  green stretch entry
    (8, 0), (8, 1), (8, 2), (8, 3), (8, 4), (8, 5), // 12-17  green entry@13
    (9, 6), (10, 6), (11, 6), (12, 6), (13, 6), (14, 6), // 18-23
    (14, 7), // 24  yellow stretch entry
    (14, 8), (13, 8), (12, 8), (11, 8), (10, 8), (9, 8), // 25-30  yellow entry@26
    (8, 9), (8, 10), (8, 11), (8, 12), (8, 13), (8, 14), // 31-36
    (7, 14), // 37  blue stretch entry
    (6, 14), (6, 13), (6, 12), (6, 11), (6, 10), (6, 9), // 38-43  blue entry@39
    (5, 8), (4, 8), (3, 8), (2, 8), (1, 8), (0, 8), // 44-49
    (0, 7), // 50  red stretch entry
    (0, 6), // 51
  ];

  /// Home-column cells (positions 100..104) per colour, leading to centre.
  static const Map<LudoColor, List<(int, int)>> homeColumn = {
    LudoColor.red: [(1, 7), (2, 7), (3, 7), (4, 7), (5, 7)],
    LudoColor.green: [(7, 1), (7, 2), (7, 3), (7, 4), (7, 5)],
    LudoColor.yellow: [(13, 7), (12, 7), (11, 7), (10, 7), (9, 7)],
    LudoColor.blue: [(7, 13), (7, 12), (7, 11), (7, 10), (7, 9)],
  };

  /// The four base parking slots per colour (cell-centre coordinates).
  static const Map<LudoColor, List<Offset>> baseSlots = {
    LudoColor.red: [
      Offset(2.0, 2.0), Offset(4.0, 2.0), Offset(2.0, 4.0), Offset(4.0, 4.0),
    ],
    LudoColor.green: [
      Offset(11.0, 2.0), Offset(13.0, 2.0), Offset(11.0, 4.0), Offset(13.0, 4.0),
    ],
    LudoColor.yellow: [
      Offset(11.0, 11.0), Offset(13.0, 11.0), Offset(11.0, 13.0), Offset(13.0, 13.0),
    ],
    LudoColor.blue: [
      Offset(2.0, 11.0), Offset(4.0, 11.0), Offset(2.0, 13.0), Offset(4.0, 13.0),
    ],
  };

  /// The 6×6 home-base square (in cell units) per colour.
  static const Map<LudoColor, Rect> baseRect = {
    LudoColor.red: Rect.fromLTWH(0, 0, 6, 6),
    LudoColor.green: Rect.fromLTWH(9, 0, 6, 6),
    LudoColor.yellow: Rect.fromLTWH(9, 9, 6, 6),
    LudoColor.blue: Rect.fromLTWH(0, 9, 6, 6),
  };

  /// Direction the finished token sits from centre, so the centre triangle
  /// shows each colour's parked-home tokens fanned toward its arm.
  static const Map<LudoColor, Offset> finishOffset = {
    LudoColor.red: Offset(-1.1, 0),
    LudoColor.green: Offset(0, -1.1),
    LudoColor.yellow: Offset(1.1, 0),
    LudoColor.blue: Offset(0, 1.1),
  };

  static Offset _center(int col, int row) =>
      Offset(col + 0.5, row + 0.5);

  /// Cell-unit centre for a single token (handles base / track / stretch /
  /// finished). [slot] disambiguates the four base parking spots.
  static Offset tokenCenter(LudoColor color, int position, int tokenIndex) {
    if (position == kHomeBasePosition) {
      return baseSlots[color]![tokenIndex];
    }
    if (position == kFinishedPosition) {
      final o = finishOffset[color]!;
      return Offset(7.5 + o.dx, 7.5 + o.dy);
    }
    if (position >= kHomeStretchBase) {
      final cell = homeColumn[color]![position - kHomeStretchBase];
      return _center(cell.$1, cell.$2);
    }
    final cell = track[position];
    return _center(cell.$1, cell.$2);
  }

  static Offset trackCenter(int position) {
    final cell = track[position];
    return _center(cell.$1, cell.$2);
  }

  /// Colour that owns a track cell's tint (entry squares get their colour),
  /// or null for a neutral white cell.
  static LudoColor? entryColorAt(int trackIndex) {
    for (final e in kColorEntry.entries) {
      if (e.value == trackIndex) return e.key;
    }
    return null;
  }

  static bool isSafe(int trackIndex) => kSafeSquares.contains(trackIndex);
}
