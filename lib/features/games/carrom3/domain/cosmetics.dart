import 'dart:ui';

import '../engine/table_geometry.dart';

/// A coin's radial colour ramp + finish (drives the 3D-shaded rendering).
class CoinMaterial {
  const CoinMaterial({
    required this.highlight,
    required this.base,
    required this.edge,
    required this.rim,
    required this.engrave,
    required this.gloss,
  });

  final Color highlight;
  final Color base;
  final Color edge;
  final Color rim;
  final Color engrave;
  final Color gloss;
}

/// One selectable set of coin skins (white men, black men, striker). The queen
/// is always ruby for rule-readability, so it isn't part of the set.
class CoinSet {
  const CoinSet({
    required this.key,
    required this.nameAr,
    required this.white,
    required this.black,
    required this.striker,
  });

  final String key;
  final String nameAr;
  final CoinMaterial white;
  final CoinMaterial black;
  final CoinMaterial striker;

  CoinMaterial materialFor(DiscKind kind) {
    switch (kind) {
      case DiscKind.white:
        return white;
      case DiscKind.black:
        return black;
      case DiscKind.queen:
        return queenMaterial;
      case DiscKind.striker:
        return striker;
    }
  }
}

/// The shared ruby queen — identical across every coin set.
const CoinMaterial queenMaterial = CoinMaterial(
  highlight: Color(0xFFFF8A98),
  base: Color(0xFFD11332),
  edge: Color(0xFF7A0A1C),
  rim: Color(0xFF45050F),
  engrave: Color(0x66FFD0D6),
  gloss: Color(0x99FFFFFF),
);

/// A pearl-acrylic striker shared by every set (the brass grip ring takes the
/// board theme's accent at render time).
const CoinMaterial _pearlStriker = CoinMaterial(
  highlight: Color(0xFFFFFFFF),
  base: Color(0xFFEDE9E0),
  edge: Color(0xFF7C7568),
  rim: Color(0xFF241F1A),
  engrave: Color(0x332A2521),
  gloss: Color(0xAAFFFFFF),
);

/// One selectable board/table look.
class TableTheme {
  const TableTheme({
    required this.key,
    required this.nameAr,
    required this.frameTop,
    required this.frameBottom,
    required this.frameBevel,
    required this.feltCenter,
    required this.feltMid,
    required this.feltEdge,
    required this.line,
    required this.lineSoft,
    required this.pocketRimA,
    required this.pocketRimB,
  });

  final String key;
  final String nameAr;
  final Color frameTop;
  final Color frameBottom;
  final Color frameBevel; // light bevel highlight on the frame
  final Color feltCenter;
  final Color feltMid;
  final Color feltEdge;
  final Color line;
  final Color lineSoft;
  final Color pocketRimA; // brass/gold sweep
  final Color pocketRimB;
}

// ── Catalogue (local, no server) — premium + vibrant ─────────────────────

const List<TableTheme> kTableThemes = [
  TableTheme(
    key: 'walnut',
    nameAr: 'خشب فاخر',
    frameTop: Color(0xFF6A4426),
    frameBottom: Color(0xFF2E1B0C),
    frameBevel: Color(0x66E0B070),
    feltCenter: Color(0xFFF8EFD6),
    feltMid: Color(0xFFE6CC97),
    feltEdge: Color(0xFFC6A35F),
    line: Color(0xFFB8862F),
    lineSoft: Color(0x99B8862F),
    pocketRimA: Color(0xFFF6DA92),
    pocketRimB: Color(0xFF8A6520),
  ),
  TableTheme(
    key: 'sapphire',
    nameAr: 'أزرق ملكي',
    frameTop: Color(0xFF3E2A16),
    frameBottom: Color(0xFF180E06),
    frameBevel: Color(0x55D8A862),
    feltCenter: Color(0xFF3F8AD0),
    feltMid: Color(0xFF235E96),
    feltEdge: Color(0xFF14406B),
    line: Color(0xFFEBCB72),
    lineSoft: Color(0x99EBCB72),
    pocketRimA: Color(0xFFF6DA92),
    pocketRimB: Color(0xFF7A5618),
  ),
  TableTheme(
    key: 'emerald',
    nameAr: 'أخضر زمردي',
    frameTop: Color(0xFF3E2E14),
    frameBottom: Color(0xFF181206),
    frameBevel: Color(0x55D8B862),
    feltCenter: Color(0xFF24AE78),
    feltMid: Color(0xFF158056),
    feltEdge: Color(0xFF0C5638),
    line: Color(0xFFEBCB72),
    lineSoft: Color(0x99EBCB72),
    pocketRimA: Color(0xFFF6DA92),
    pocketRimB: Color(0xFF7A5618),
  ),
];

const List<CoinSet> kCoinSets = [
  CoinSet(
    key: 'classic',
    nameAr: 'كلاسيكي',
    white: CoinMaterial(
      highlight: Color(0xFFFFFEF8),
      base: Color(0xFFF3EAD2),
      edge: Color(0xFFCBBA8C),
      rim: Color(0xFF8E7A4E),
      engrave: Color(0x33715A2A),
      gloss: Color(0x99FFFFFF),
    ),
    black: CoinMaterial(
      highlight: Color(0xFF7C746A),
      base: Color(0xFF2E2925),
      edge: Color(0xFF14110D),
      rim: Color(0xFF000000),
      engrave: Color(0x55C9B98F),
      gloss: Color(0x66FFFFFF),
    ),
    striker: _pearlStriker,
  ),
  CoinSet(
    key: 'royal',
    nameAr: 'ملكي ذهبي',
    white: CoinMaterial(
      highlight: Color(0xFFFFF6D6),
      base: Color(0xFFF0C455),
      edge: Color(0xFFB07E22),
      rim: Color(0xFF6E4E14),
      engrave: Color(0x66FFFFFF),
      gloss: Color(0xAAFFFFFF),
    ),
    black: CoinMaterial(
      highlight: Color(0xFF49566E),
      base: Color(0xFF1E2434),
      edge: Color(0xFF0C0F18),
      rim: Color(0xFF03050A),
      engrave: Color(0x6688A0D0),
      gloss: Color(0x77FFFFFF),
    ),
    striker: _pearlStriker,
  ),
  CoinSet(
    key: 'vivid',
    nameAr: 'زاهي',
    white: CoinMaterial(
      highlight: Color(0xFFD2ECFF),
      base: Color(0xFF3D9BE8),
      edge: Color(0xFF1C5F9E),
      rim: Color(0xFF0E3A66),
      engrave: Color(0x66FFFFFF),
      gloss: Color(0xAAFFFFFF),
    ),
    black: CoinMaterial(
      highlight: Color(0xFFFFCBAC),
      base: Color(0xFFF0703C),
      edge: Color(0xFFA8421A),
      rim: Color(0xFF6E2A0E),
      engrave: Color(0x66FFFFFF),
      gloss: Color(0x99FFFFFF),
    ),
    striker: _pearlStriker,
  ),
  CoinSet(
    key: 'candy',
    nameAr: 'حلوى',
    white: CoinMaterial(
      highlight: Color(0xFFFFC8E8),
      base: Color(0xFFE85AAE),
      edge: Color(0xFF9E2E6E),
      rim: Color(0xFF661A46),
      engrave: Color(0x66FFFFFF),
      gloss: Color(0xAAFFFFFF),
    ),
    black: CoinMaterial(
      highlight: Color(0xFFAEF2E4),
      base: Color(0xFF2FC4A8),
      edge: Color(0xFF12806E),
      rim: Color(0xFF0A4E42),
      engrave: Color(0x66FFFFFF),
      gloss: Color(0x99FFFFFF),
    ),
    striker: _pearlStriker,
  ),
];

TableTheme tableByKey(String? key) =>
    kTableThemes.firstWhere((t) => t.key == key, orElse: () => kTableThemes[0]);

CoinSet coinSetByKey(String? key) =>
    kCoinSets.firstWhere((c) => c.key == key, orElse: () => kCoinSets[0]);
