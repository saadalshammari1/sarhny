import 'dart:ui';

/// Selectable cosmetics for Ludo: 3 board skins + 4 pawn ("knight") styles.
/// The player colours stay fixed for rule-readability; skins restyle the
/// frame / surface / neutral track / centre, and pawn styles swap the rendered
/// emblem on each colour. Modern, premium look across the board.

enum LudoBoardSkin { royal, neon, arabian }

enum LudoPawnStyle { classic, knight, sorcerer, crown }

extension LudoBoardSkinX on LudoBoardSkin {
  String get key => name;
  String get nameAr => switch (this) {
        LudoBoardSkin.royal => 'الملكية الكلاسيكية',
        LudoBoardSkin.neon => 'نيون سايبر',
        LudoBoardSkin.arabian => 'ليالٍ عربية',
      };
  static LudoBoardSkin fromKey(String k) =>
      LudoBoardSkin.values.firstWhere((s) => s.name == k,
          orElse: () => LudoBoardSkin.royal);
}

extension LudoPawnStyleX on LudoPawnStyle {
  String get key => name;
  String get nameAr => switch (this) {
        LudoPawnStyle.classic => 'كلاسيك',
        LudoPawnStyle.knight => 'درع الفارس',
        LudoPawnStyle.sorcerer => 'الساحر',
        LudoPawnStyle.crown => 'التاج الملكي',
      };
  static LudoPawnStyle fromKey(String k) =>
      LudoPawnStyle.values.firstWhere((s) => s.name == k,
          orElse: () => LudoPawnStyle.classic);
}

/// Palette + flags driving the board painter for a given skin.
class LudoBoardTheme {
  const LudoBoardTheme({
    required this.frameTop,
    required this.frameBottom,
    required this.frameBevel,
    required this.surfaceCenter,
    required this.surfaceEdge,
    required this.cellLight,
    required this.cellDark,
    required this.line,
    required this.star,
    required this.emblemInner,
    required this.emblemOuter,
    required this.emblemRim,
    required this.glow,
    this.glowColor = const Color(0x00000000),
  });

  final Color frameTop, frameBottom, frameBevel;
  final Color surfaceCenter, surfaceEdge;
  final Color cellLight, cellDark;
  final Color line, star;
  final Color emblemInner, emblemOuter, emblemRim;

  /// Neon-style glow on neutral cells.
  final bool glow;
  final Color glowColor;

  static LudoBoardTheme of(LudoBoardSkin skin) => switch (skin) {
        LudoBoardSkin.royal => const LudoBoardTheme(
            frameTop: Color(0xFF6E4A2A),
            frameBottom: Color(0xFF4A2F18),
            frameBevel: Color(0x55FFE0B0),
            surfaceCenter: Color(0xFFFBF7EC),
            surfaceEdge: Color(0xFFEDE5D2),
            cellLight: Color(0xFFFFFFFF),
            cellDark: Color(0xFFF0EAD9),
            line: Color(0x22000000),
            star: Color(0x66000000),
            emblemInner: Color(0xFFFFF4D6),
            emblemOuter: Color(0xFFE8C063),
            emblemRim: Color(0xFFB8902F),
            glow: false,
          ),
        LudoBoardSkin.neon => const LudoBoardTheme(
            frameTop: Color(0xFF15233A),
            frameBottom: Color(0xFF0A1120),
            frameBevel: Color(0x6600E5FF),
            surfaceCenter: Color(0xFF111A2B),
            surfaceEdge: Color(0xFF0A1018),
            cellLight: Color(0xFF1B2A44),
            cellDark: Color(0xFF132036),
            line: Color(0x5500E5FF),
            star: Color(0x9900E5FF),
            emblemInner: Color(0xFFB6FBFF),
            emblemOuter: Color(0xFF18C7E0),
            emblemRim: Color(0xFF00E5FF),
            glow: true,
            glowColor: Color(0xFF00E5FF),
          ),
        LudoBoardSkin.arabian => const LudoBoardTheme(
            frameTop: Color(0xFF5B2A6E),
            frameBottom: Color(0xFF3A1248),
            frameBevel: Color(0x66FFD56A),
            surfaceCenter: Color(0xFF2B1640),
            surfaceEdge: Color(0xFF1C0E2C),
            cellLight: Color(0xFF4A2E63),
            cellDark: Color(0xFF3A2350),
            line: Color(0x55FFD56A),
            star: Color(0xAAFFD56A),
            emblemInner: Color(0xFFFFE9A8),
            emblemOuter: Color(0xFFE0A93B),
            emblemRim: Color(0xFFC98A1E),
            glow: true,
            glowColor: Color(0x66FFD56A),
          ),
      };

  /// Whether the surface is dark (affects pawn shadow/contrast choices).
  bool get isDark => skinIsDark;
  bool get skinIsDark => surfaceCenter.computeLuminance() < 0.4;
}
