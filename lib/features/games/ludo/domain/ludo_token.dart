/// لون لاعب لودو — يقابل moveable seat (0..3).
enum LudoColor { red, green, yellow, blue }

extension LudoColorParse on LudoColor {
  static LudoColor parse(String raw) {
    switch (raw.toLowerCase()) {
      case 'red':
        return LudoColor.red;
      case 'green':
        return LudoColor.green;
      case 'yellow':
        return LudoColor.yellow;
      case 'blue':
        return LudoColor.blue;
      default:
        return LudoColor.red;
    }
  }

  String get wire {
    switch (this) {
      case LudoColor.red:
        return 'red';
      case LudoColor.green:
        return 'green';
      case LudoColor.yellow:
        return 'yellow';
      case LudoColor.blue:
        return 'blue';
    }
  }

  /// نقطة دخول كل لون على الـ outer track (52 خانة).
  int get entryIndex {
    switch (this) {
      case LudoColor.red:
        return 0;
      case LudoColor.green:
        return 13;
      case LudoColor.yellow:
        return 26;
      case LudoColor.blue:
        return 39;
    }
  }

  /// ترجمة عربية للون.
  String get arabicLabel {
    switch (this) {
      case LudoColor.red:
        return 'الأحمر';
      case LudoColor.green:
        return 'الأخضر';
      case LudoColor.yellow:
        return 'الأصفر';
      case LudoColor.blue:
        return 'الأزرق';
    }
  }
}

/// موقع رمز اللعبة (token) مع semantics واضحة:
///
/// - `home`         → في القاعدة (position = -1).
/// - `track`        → على المسار الخارجي (0..51).
/// - `homeStretch`  → على المسار الملوّن نحو المركز (0..4).
/// - `finished`     → في المثلث المركزي (200).
enum LudoTokenZone { home, track, homeStretch, finished }

class LudoTokenPosition {
  const LudoTokenPosition({required this.zone, required this.cell});

  /// المنطقة المنطقية.
  final LudoTokenZone zone;

  /// قيمة فرعية حسب الـ zone:
  /// - home: 0 (موحّد)
  /// - track: 0..51 (الموضع المطلق)
  /// - homeStretch: 0..4
  /// - finished: 0
  final int cell;

  /// صنع من قيمة wire من السيرفر (-1, 0..51, 100..104, 200).
  factory LudoTokenPosition.fromWire(int v) {
    if (v < 0) {
      return const LudoTokenPosition(zone: LudoTokenZone.home, cell: 0);
    }
    if (v >= 200) {
      return const LudoTokenPosition(zone: LudoTokenZone.finished, cell: 0);
    }
    if (v >= 100) {
      return LudoTokenPosition(
        zone: LudoTokenZone.homeStretch,
        cell: (v - 100).clamp(0, 4),
      );
    }
    return LudoTokenPosition(
      zone: LudoTokenZone.track,
      cell: v.clamp(0, 51),
    );
  }

  int toWire() {
    switch (zone) {
      case LudoTokenZone.home:
        return -1;
      case LudoTokenZone.track:
        return cell;
      case LudoTokenZone.homeStretch:
        return 100 + cell;
      case LudoTokenZone.finished:
        return 200;
    }
  }

  bool get isHome => zone == LudoTokenZone.home;
  bool get isOnTrack => zone == LudoTokenZone.track;
  bool get isHomeStretch => zone == LudoTokenZone.homeStretch;
  bool get isFinished => zone == LudoTokenZone.finished;
}
