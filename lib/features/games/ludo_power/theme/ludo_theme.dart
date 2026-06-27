import 'package:flutter/material.dart';

/// ألوان اللاعبين — تدرّج 5 درجات لكل لون (glossy).
class LudoColor {
  final Color base, light, mid, dark, deep;
  const LudoColor(this.base, this.light, this.mid, this.dark, this.deep);
}

const Map<String, LudoColor> ludoColors = {
  'red': LudoColor(
      Color(0xFFE23B32), Color(0xFFFF7A6E), Color(0xFFD12A22), Color(0xFF8C1310), Color(0xFF5E0A08)),
  'green': LudoColor(
      Color(0xFF43BD3F), Color(0xFF8EF07A), Color(0xFF2EA63A), Color(0xFF1C7D27), Color(0xFF0D5018)),
  'blue': LudoColor(
      Color(0xFF2F9BF0), Color(0xFF7FCCFF), Color(0xFF1F7FDA), Color(0xFF155FB0), Color(0xFF0A3C78)),
  'yellow': LudoColor(
      Color(0xFFF6C021), Color(0xFFFFE27A), Color(0xFFEAA90C), Color(0xFFB07C00), Color(0xFF6E4D00)),
  'purple': LudoColor(
      Color(0xFF9043CF), Color(0xFFCD8FF0), Color(0xFF7D34BD), Color(0xFF5E2098), Color(0xFF3E1268)),
};

/// القدرات الأربع — من POWERS الأصلي.
class PowerDef {
  final String nameAr, sub;
  final Color base, light, dark, glow;
  const PowerDef(this.nameAr, this.sub, this.base, this.light, this.dark, this.glow);
}

const Map<String, PowerDef> powers = {
  'rocket': PowerDef('صاروخ', 'انطلق للأمام', Color(0xFFFF5A2A), Color(0xFFFFD25A),
      Color(0xFFB81E0A), Color(0xD9FF6E28)),
  'freeze': PowerDef('تجميد', 'جمّد خصمك', Color(0xFF46C6FF), Color(0xFFBFF0FF),
      Color(0xFF1466B0), Color(0xD95AC8FF)),
  'portal': PowerDef('بوابة', 'انتقل آنياً', Color(0xFF9A3FE0), Color(0xFFD49CFF),
      Color(0xFF5A1D9E), Color(0xD9AA50F0)),
  'tornado': PowerDef('إعصار', 'اقذف الخصوم', Color(0xFF22D6C0), Color(0xFF9AF5E8),
      Color(0xFF0E8F86), Color(0xCC3CE1C8)),
};

/// الثيم الملكي الذهبي (royal) — الخلفيات والإطارات.
class RoyalTheme {
  static const Color appBgTop = Color(0xFF2A2012);
  static const Color appBgMid = Color(0xFF170F06);
  static const Color appBgBottom = Color(0xFF0C0905);
  static const Color boardBg = Color(0xFF140E06);
  static const Color panelSolid = Color(0xFF1C1409);
  static const Color panelBorder = Color(0x73D6AA54);
  static const Color trackCell = Color(0xFF241A0C);
  static const Color textLight = Color(0xFFF4ECD6);

  static const List<Color> goldWarm = [
    Color(0xFF6E4A12), Color(0xFFC59B41), Color(0xFFF7E6AB), Color(0xFFE3BD5E),
    Color(0xFF9C7322), Color(0xFFF0D488), Color(0xFFB8893A), Color(0xFF7A531A),
  ];
  static const Color goldEdgeLight = Color(0xFFFFF0C2);
  static const Color goldEdgeDark = Color(0xFF5A3D0E);

  static const Gradient appBg = RadialGradient(
    center: Alignment(0, -1.1), radius: 1.2,
    colors: [appBgTop, appBgMid, appBgBottom], stops: [0, 0.42, 1.0],
  );
  static LinearGradient get goldFrame => const LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight, colors: goldWarm,
  );
}

/// مخطّط الألوان — اللاعب البشري (3) أسفل-يسار، والخصوم حوله.
/// الزوايا: 0=TL، 1=TR، 2=BR، 3=BL.
class BoardScheme {
  static const List<String> playerColors = ['yellow', 'blue', 'purple', 'green'];
  static const List<String> playerNamesAr = [
    'الذهبي', 'الأزرق', 'البنفسجي', 'أنت',
  ];
  static const List<Alignment> corners = [
    Alignment.topLeft, Alignment.topRight, Alignment.bottomRight, Alignment.bottomLeft
  ];
}
