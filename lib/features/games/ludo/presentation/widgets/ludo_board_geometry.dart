import 'package:flutter/material.dart';

import '../../domain/ludo_token.dart';

/// Geometry pure-Dart للوحة لودو 15×15.
///
/// تستخدم coordinate normalized (0..1, 0..1) — الـ Painter يضرب في الـ
/// board size الفعلي. هكذا نضمن مطابقة 100% بين الـ board background و
/// الـ token positions، وأي override من الـ widget الأب يعمل تلقائياً.
///
/// تخطيط اللوحة:
/// - 15×15 grid → كل خانة = 1/15.
/// - 4 home bases: 6×6 في الزوايا (red TL, green TR, yellow BR, blue BL).
/// - Center: 3×3 → 4 مثلثات + المركز.
/// - Track: 52 خانة على شكل صليب.
/// - Home stretch: 5 خانات ملوّنة لكل لون نحو المركز.
class LudoBoardGeometry {
  LudoBoardGeometry._();

  /// عدد خانات في كل بُعد.
  static const int gridSize = 15;

  /// تحويل grid cell (col, row) لـ normalized center.
  static Offset cellCenter(int col, int row) {
    return Offset(
      (col + 0.5) / gridSize,
      (row + 0.5) / gridSize,
    );
  }

  /// نصف قطر القطعة (نسبة من الـ board).
  static const double tokenRadius = 0.026;

  /// نصف قطر مربع خانة (للـ painter).
  static const double cellHalf = 0.5 / gridSize;

  /// 52 cell على outer track — index 0..51.
  ///
  /// Path يبدأ من الخانة الحمراء (red entry = 0) وينتقل clockwise.
  /// الـ layout الكلاسيكي للودو:
  ///   - red entry = column 1, row 6 (يسار، الصف الأوسط العلوي)
  /// Index → (col, row).
  static const List<(int, int)> trackCells = [
    // 0: red entry (left mid, upper)
    (1, 6),
    // 1..5: غرب → جنوب الـ vertical home column
    (2, 6),
    (3, 6),
    (4, 6),
    (5, 6),
    (6, 5),
    // 6..10: north column up to top-left of upper bar
    (6, 4),
    (6, 3),
    (6, 2),
    (6, 1),
    (6, 0),
    // 11..12: cross to green entry
    (7, 0),
    (8, 0),
    // 13: green entry (top mid, right)
    (8, 1),
    // 14..18: green column going down
    (8, 2),
    (8, 3),
    (8, 4),
    (8, 5),
    (9, 6),
    // 19..23: east row
    (10, 6),
    (11, 6),
    (12, 6),
    (13, 6),
    (14, 6),
    // 24..25: cross to yellow entry
    (14, 7),
    (14, 8),
    // 26: yellow entry (right mid, lower)
    (13, 8),
    // 27..31: yellow row going left
    (12, 8),
    (11, 8),
    (10, 8),
    (9, 8),
    (8, 9),
    // 32..36: south column
    (8, 10),
    (8, 11),
    (8, 12),
    (8, 13),
    (8, 14),
    // 37..38: cross to blue entry
    (7, 14),
    (6, 14),
    // 39: blue entry (bottom mid, left)
    (6, 13),
    // 40..44: blue column going up
    (6, 12),
    (6, 11),
    (6, 10),
    (6, 9),
    (5, 8),
    // 45..49: west row back to red
    (4, 8),
    (3, 8),
    (2, 8),
    (1, 8),
    (0, 8),
    // 50..51: cross back to red entry
    (0, 7),
    (0, 6),
  ];

  /// 5 خانات home stretch لكل لون — تنتهي قبل المركز.
  static List<(int, int)> homeStretchCells(LudoColor color) {
    switch (color) {
      // Red enters from left-mid (col 0, row 7) into row 7 going right.
      case LudoColor.red:
        return const [(1, 7), (2, 7), (3, 7), (4, 7), (5, 7)];
      // Green enters from top-mid (col 7, row 0) into col 7 going down.
      case LudoColor.green:
        return const [(7, 1), (7, 2), (7, 3), (7, 4), (7, 5)];
      // Yellow enters from right-mid (col 14, row 7) into row 7 going left.
      case LudoColor.yellow:
        return const [(13, 7), (12, 7), (11, 7), (10, 7), (9, 7)];
      // Blue enters from bottom-mid (col 7, row 14) into col 7 going up.
      case LudoColor.blue:
        return const [(7, 13), (7, 12), (7, 11), (7, 10), (7, 9)];
    }
  }

  /// مركز home base لكل لون (الزوايا).
  static (int, int) homeBaseCenter(LudoColor color) {
    switch (color) {
      case LudoColor.red:
        return (3, 3); // top-left
      case LudoColor.green:
        return (11, 3); // top-right
      case LudoColor.yellow:
        return (11, 11); // bottom-right
      case LudoColor.blue:
        return (3, 11); // bottom-left
    }
  }

  /// مواضع الـ 4 tokens داخل home base — 2×2 grid mini.
  static List<Offset> homeBaseSlots(LudoColor color) {
    final c = homeBaseCenter(color);
    final col = c.$1;
    final row = c.$2;
    // 4 موضعين: top-left, top-right, bottom-left, bottom-right حول المركز
    return [
      cellCenter(col - 1, row - 1),
      cellCenter(col + 1, row - 1),
      cellCenter(col - 1, row + 1),
      cellCenter(col + 1, row + 1),
    ];
  }

  /// المثلث المركزي (مكان finished tokens) — center cell.
  static Offset finishCenter(LudoColor color) {
    // كل لون يقف داخل المثلث الخاص به في المركز (3×3 cell).
    switch (color) {
      case LudoColor.red:
        return cellCenter(6, 7);
      case LudoColor.green:
        return cellCenter(7, 6);
      case LudoColor.yellow:
        return cellCenter(8, 7);
      case LudoColor.blue:
        return cellCenter(7, 8);
    }
  }

  /// safe squares — gold star positions.
  ///
  /// التقليد: entry لكل لون + 4 squares معينة على الـ outer track.
  /// 0: red entry, 8: pre-green-entry safe, 13: green entry,
  /// 21: pre-yellow safe, 26: yellow entry, 34: pre-blue safe,
  /// 39: blue entry, 47: pre-red safe.
  static const Set<int> safeTrackIndices = {0, 8, 13, 21, 26, 34, 39, 47};

  /// النقطة المعروضة لـ token معين على اللوحة (normalized).
  static Offset tokenPosition({
    required LudoColor color,
    required int tokenIndex, // 0..3 — لتحديد موقع داخل home base
    required LudoTokenPosition pos,
  }) {
    switch (pos.zone) {
      case LudoTokenZone.home:
        final slots = homeBaseSlots(color);
        return slots[tokenIndex.clamp(0, slots.length - 1)];
      case LudoTokenZone.track:
        final c = trackCells[pos.cell.clamp(0, trackCells.length - 1)];
        return cellCenter(c.$1, c.$2);
      case LudoTokenZone.homeStretch:
        final cells = homeStretchCells(color);
        final c = cells[pos.cell.clamp(0, cells.length - 1)];
        return cellCenter(c.$1, c.$2);
      case LudoTokenZone.finished:
        return finishCenter(color);
    }
  }

  /// مسار "خطوة بخطوة" للحركة من → إلى. كل عنصر = position وسطية.
  /// مفيد لـ animation: نمشي خانة خانة مع bounce.
  static List<Offset> stepwisePath({
    required LudoColor color,
    required int tokenIndex,
    required LudoTokenPosition from,
    required LudoTokenPosition to,
  }) {
    final path = <Offset>[];
    path.add(tokenPosition(color: color, tokenIndex: tokenIndex, pos: from));

    // أربع حالات:
    // 1) home → track (entry): قفزة واحدة.
    if (from.isHome && to.isOnTrack) {
      path.add(tokenPosition(color: color, tokenIndex: tokenIndex, pos: to));
      return path;
    }

    // 2) track → track: نمشي عبر outer indices.
    if (from.isOnTrack && to.isOnTrack) {
      final n = trackCells.length;
      int cur = from.cell;
      while (cur != to.cell) {
        cur = (cur + 1) % n;
        path.add(tokenPosition(
          color: color,
          tokenIndex: tokenIndex,
          pos: LudoTokenPosition(zone: LudoTokenZone.track, cell: cur),
        ));
      }
      return path;
    }

    // 3) track → home stretch.
    if (from.isOnTrack && to.isHomeStretch) {
      // أكمل المسار حتى يصل آخر outer track ثم ينعطف.
      final n = trackCells.length;
      final entryBeforeStretch = (color.entryIndex - 1 + n) % n;
      int cur = from.cell;
      while (cur != entryBeforeStretch) {
        cur = (cur + 1) % n;
        path.add(tokenPosition(
          color: color,
          tokenIndex: tokenIndex,
          pos: LudoTokenPosition(zone: LudoTokenZone.track, cell: cur),
        ));
        if (path.length > n) break; // safety
      }
      // ادخل home stretch خانة خانة حتى to.cell.
      for (int i = 0; i <= to.cell; i++) {
        path.add(tokenPosition(
          color: color,
          tokenIndex: tokenIndex,
          pos: LudoTokenPosition(zone: LudoTokenZone.homeStretch, cell: i),
        ));
      }
      return path;
    }

    // 4) home stretch → home stretch / finished.
    if (from.isHomeStretch &&
        (to.isHomeStretch || to.isFinished)) {
      final stretchLen = homeStretchCells(color).length;
      for (int i = from.cell + 1; i < stretchLen; i++) {
        path.add(tokenPosition(
          color: color,
          tokenIndex: tokenIndex,
          pos: LudoTokenPosition(zone: LudoTokenZone.homeStretch, cell: i),
        ));
        if (to.isHomeStretch && i == to.cell) {
          return path;
        }
      }
      // finished
      path.add(tokenPosition(
        color: color,
        tokenIndex: tokenIndex,
        pos: const LudoTokenPosition(zone: LudoTokenZone.finished, cell: 0),
      ));
      return path;
    }

    // fallback: قفزة مباشرة.
    path.add(tokenPosition(color: color, tokenIndex: tokenIndex, pos: to));
    return path;
  }
}

/// لون لاعب لودو → لون قطعة وعرض UI.
extension LudoColorUI on LudoColor {
  Color get primary {
    switch (this) {
      case LudoColor.red:
        return const Color(0xFFE53935);
      case LudoColor.green:
        return const Color(0xFF43A047);
      case LudoColor.yellow:
        return const Color(0xFFFDD835);
      case LudoColor.blue:
        return const Color(0xFF1E88E5);
    }
  }

  Color get dark {
    switch (this) {
      case LudoColor.red:
        return const Color(0xFF8E1A18);
      case LudoColor.green:
        return const Color(0xFF1B5E20);
      case LudoColor.yellow:
        return const Color(0xFFB28704);
      case LudoColor.blue:
        return const Color(0xFF0D47A1);
    }
  }

  Color get light {
    switch (this) {
      case LudoColor.red:
        return const Color(0xFFEF9A9A);
      case LudoColor.green:
        return const Color(0xFFA5D6A7);
      case LudoColor.yellow:
        return const Color(0xFFFFF59D);
      case LudoColor.blue:
        return const Color(0xFF90CAF9);
    }
  }
}
