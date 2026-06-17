import 'dart:ui';

/// Domain models لنظام الـ cosmetics.
///
/// السيرفر هو المرجع — نحن نعكس الـ catalogue عبر JSON ولا نبني keys
/// محلياً. كل entry يحمل اسم عربي + إنجليزي + الـ swatches اللازمة
/// للمعاينة بدون round-trip إضافي.

/// Helper — يحوّل "#RRGGBB" إلى [Color]. آمن مع null + قيم تالفة.
Color parseHex(String? raw, {Color fallback = const Color(0xFFFFFFFF)}) {
  if (raw == null) return fallback;
  var s = raw.trim();
  if (s.startsWith('#')) s = s.substring(1);
  if (s.length == 6) s = 'FF$s';
  if (s.length != 8) return fallback;
  final v = int.tryParse(s, radix: 16);
  if (v == null) return fallback;
  return Color(v);
}

// ── Board skin ────────────────────────────────────────────────────────

class BoardSkin {
  const BoardSkin({
    required this.key,
    required this.nameAr,
    required this.nameEn,
    required this.baseColor,
    required this.accentColor,
    this.accentColorAlt,
    required this.borderStyle,
    required this.texture,
    required this.locked,
  });

  final String key;
  final String nameAr;
  final String nameEn;

  /// اللون الرئيسي لسطح اللعب.
  final Color baseColor;

  /// لون الإطار / accent.
  final Color accentColor;

  /// لون ثانوي للـ neon (cyan + magenta) — اختياري.
  final Color? accentColorAlt;

  /// `wood` / `thin_gold` / `gold_crown` / `neon_glow` — يحدد كيف نرسم الإطار.
  final String borderStyle;

  /// `wood` / `marble` / `felt` / `neon` — texture للسطح.
  final String texture;

  final bool locked;

  factory BoardSkin.fromJson(Map<String, dynamic> j) => BoardSkin(
        key: '${j['key']}',
        nameAr: '${j['name_ar'] ?? ''}',
        nameEn: '${j['name_en'] ?? ''}',
        baseColor: parseHex(j['base_color']?.toString()),
        accentColor: parseHex(j['accent_color']?.toString()),
        accentColorAlt: j['accent_color_alt'] == null
            ? null
            : parseHex(j['accent_color_alt'].toString()),
        borderStyle: '${j['border_style'] ?? 'wood'}',
        texture: '${j['texture'] ?? 'wood'}',
        locked: j['locked'] == true,
      );
}

// ── Piece colour pair ─────────────────────────────────────────────────

class PieceSkinPair {
  const PieceSkinPair({
    required this.key,
    required this.nameAr,
    required this.nameEn,
    required this.colorA,
    required this.colorB,
    required this.finish,
    this.descriptionAr,
    required this.locked,
  });

  final String key;
  final String nameAr;
  final String nameEn;

  /// لون اللاعب A (دائماً يأخذه A).
  final Color colorA;

  /// لون اللاعب B (يُستخدم لو B اختار نفس الـ pair → contrast تلقائي).
  final Color colorB;

  /// `matte` / `metallic` / `jewel` / `gem` — يحدد الـ shader.
  final String finish;

  final String? descriptionAr;
  final bool locked;

  factory PieceSkinPair.fromJson(Map<String, dynamic> j) => PieceSkinPair(
        key: '${j['key']}',
        nameAr: '${j['name_ar'] ?? ''}',
        nameEn: '${j['name_en'] ?? ''}',
        colorA: parseHex(j['color_a']?.toString()),
        colorB: parseHex(j['color_b']?.toString()),
        finish: '${j['finish'] ?? 'matte'}',
        descriptionAr: j['description_ar']?.toString(),
        locked: j['locked'] == true,
      );
}

// ── Striker skin ──────────────────────────────────────────────────────

class StrikerSkin {
  const StrikerSkin({
    required this.key,
    required this.nameAr,
    required this.nameEn,
    required this.color,
    required this.special,
    this.descriptionAr,
    required this.locked,
  });

  final String key;
  final String nameAr;
  final String nameEn;
  final Color color;

  /// `default` / `shine_gradient` / `matte_black` / `translucent_sparkle`.
  final String special;
  final String? descriptionAr;
  final bool locked;

  factory StrikerSkin.fromJson(Map<String, dynamic> j) => StrikerSkin(
        key: '${j['key']}',
        nameAr: '${j['name_ar'] ?? ''}',
        nameEn: '${j['name_en'] ?? ''}',
        color: parseHex(j['color']?.toString()),
        special: '${j['special'] ?? 'default'}',
        descriptionAr: j['description_ar']?.toString(),
        locked: j['locked'] == true,
      );
}

// ── Catalogue + user selection ────────────────────────────────────────

class CosmeticsCatalog {
  const CosmeticsCatalog({
    required this.boards,
    required this.pieces,
    required this.strikers,
  });

  final List<BoardSkin> boards;
  final List<PieceSkinPair> pieces;
  final List<StrikerSkin> strikers;

  BoardSkin? boardByKey(String key) {
    for (final b in boards) {
      if (b.key == key) return b;
    }
    return null;
  }

  PieceSkinPair? pieceByKey(String key) {
    for (final p in pieces) {
      if (p.key == key) return p;
    }
    return null;
  }

  StrikerSkin? strikerByKey(String key) {
    for (final s in strikers) {
      if (s.key == key) return s;
    }
    return null;
  }

  factory CosmeticsCatalog.fromJson(Map<String, dynamic> j) {
    List<T> arr<T>(String key, T Function(Map<String, dynamic>) f) =>
        ((j[key] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => f(e.cast<String, dynamic>()))
            .toList(growable: false);
    return CosmeticsCatalog(
      boards: arr('boards', BoardSkin.fromJson),
      pieces: arr('pieces', PieceSkinPair.fromJson),
      strikers: arr('strikers', StrikerSkin.fromJson),
    );
  }
}

class UserCosmetics {
  const UserCosmetics({
    required this.boardSkin,
    required this.pieceSkin,
    required this.strikerSkin,
  });

  final String boardSkin;
  final String pieceSkin;
  final String strikerSkin;

  UserCosmetics copyWith({
    String? boardSkin,
    String? pieceSkin,
    String? strikerSkin,
  }) =>
      UserCosmetics(
        boardSkin: boardSkin ?? this.boardSkin,
        pieceSkin: pieceSkin ?? this.pieceSkin,
        strikerSkin: strikerSkin ?? this.strikerSkin,
      );

  factory UserCosmetics.fromJson(Map<String, dynamic> j) => UserCosmetics(
        boardSkin: '${j['board_skin'] ?? 'classic_wood'}',
        pieceSkin: '${j['piece_skin'] ?? 'classic'}',
        strikerSkin: '${j['striker_skin'] ?? 'silver'}',
      );

  static const defaults = UserCosmetics(
    boardSkin: 'classic_wood',
    pieceSkin: 'classic',
    strikerSkin: 'silver',
  );
}

/// Response shape للـ GET /cosmetics.
class CosmeticsResponse {
  const CosmeticsResponse({required this.catalog, required this.current});
  final CosmeticsCatalog catalog;
  final UserCosmetics current;

  factory CosmeticsResponse.fromJson(Map<String, dynamic> j) {
    final catRaw = (j['catalog'] as Map?)?.cast<String, dynamic>() ?? const {};
    final curRaw = (j['current'] as Map?)?.cast<String, dynamic>() ?? const {};
    return CosmeticsResponse(
      catalog: CosmeticsCatalog.fromJson(catRaw),
      current: UserCosmetics.fromJson(curRaw),
    );
  }
}

// ── Resolved match cosmetics (from server) ────────────────────────────
//
// السيرفر يحسب الـ conflict resolution ويرسل النتيجة جاهزة في كل state
// snapshot. الـ widget الأساسي للوحة يقرأ من هنا فقط — لا تكرار لمنطق
// الـ resolver في الـ client.

class MatchCosmetics {
  const MatchCosmetics({
    required this.boardSkin,
    required this.aPieceColor,
    required this.bPieceColor,
    required this.aPieceSkin,
    required this.bPieceSkin,
    required this.aStriker,
    required this.bStriker,
  });

  final String boardSkin;

  /// لون قطع اللاعب A (white side).
  final Color aPieceColor;

  /// لون قطع اللاعب B (black side).
  final Color bPieceColor;

  final String aPieceSkin;
  final String bPieceSkin;
  final String aStriker;
  final String bStriker;

  static const defaults = MatchCosmetics(
    boardSkin: 'classic_wood',
    aPieceColor: Color(0xFFFFFFFF),
    bPieceColor: Color(0xFF1A1A1A),
    aPieceSkin: 'classic',
    bPieceSkin: 'classic',
    aStriker: 'silver',
    bStriker: 'silver',
  );

  factory MatchCosmetics.fromJson(Map<String, dynamic> j) => MatchCosmetics(
        boardSkin: '${j['board_skin'] ?? 'classic_wood'}',
        aPieceColor: parseHex(
          j['a_piece_color']?.toString(),
          fallback: const Color(0xFFFFFFFF),
        ),
        bPieceColor: parseHex(
          j['b_piece_color']?.toString(),
          fallback: const Color(0xFF1A1A1A),
        ),
        aPieceSkin: '${j['a_piece_skin'] ?? 'classic'}',
        bPieceSkin: '${j['b_piece_skin'] ?? 'classic'}',
        aStriker: '${j['a_striker'] ?? 'silver'}',
        bStriker: '${j['b_striker'] ?? 'silver'}',
      );
}
