import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// الطاولات (٣) والفرسان (٤) القابلة للاختيار — مستوحاة من العمل السابق ومطبّقة
/// على لوحة اللودو الملكية.

enum PowerSkin { royal, neon, arabian }

enum KnightStyle { classic, knight, sorcerer, crown }

extension PowerSkinX on PowerSkin {
  String get key => name;
  String get nameAr => switch (this) {
        PowerSkin.royal => 'الملكية الذهبية',
        PowerSkin.neon => 'نيون سايبر',
        PowerSkin.arabian => 'ليالٍ عربية',
      };
  static PowerSkin fromKey(String k) =>
      PowerSkin.values.firstWhere((s) => s.name == k, orElse: () => PowerSkin.royal);
}

extension KnightStyleX on KnightStyle {
  String get key => name;
  String get nameAr => switch (this) {
        KnightStyle.classic => 'كلاسيك',
        KnightStyle.knight => 'الفارس',
        KnightStyle.sorcerer => 'الساحر',
        KnightStyle.crown => 'التاج',
      };
  static KnightStyle fromKey(String k) =>
      KnightStyle.values.firstWhere((s) => s.name == k, orElse: () => KnightStyle.classic);
}

/// ألوان اللوحة لكل طاولة.
class SkinPalette {
  const SkinPalette({
    required this.frame,
    required this.surface,
    required this.cell,
    required this.line,
    required this.homeInner,
    required this.star,
  });
  final List<Color> frame;
  final Color surface, cell, line, homeInner, star;

  static SkinPalette of(PowerSkin s) => switch (s) {
        PowerSkin.royal => const SkinPalette(
            frame: [
              Color(0xFF6E4A12), Color(0xFFC59B41), Color(0xFFF7E6AB), Color(0xFFE3BD5E),
              Color(0xFF9C7322), Color(0xFFF0D488), Color(0xFFB8893A), Color(0xFF7A531A),
            ],
            surface: Color(0xFFFBF7EC),
            cell: Color(0xFFFFFFFF),
            line: Color(0x33000000),
            homeInner: Color(0xFFFFFFFF),
            star: Color(0xFFD6AA54),
          ),
        PowerSkin.neon => const SkinPalette(
            frame: [
              Color(0xFF0E2336), Color(0xFF1C4A6E), Color(0xFF3FB6FF), Color(0xFF18C7E0),
              Color(0xFF0E2336), Color(0xFF3FB6FF), Color(0xFF1C4A6E), Color(0xFF0A1A28),
            ],
            surface: Color(0xFFEAF4FF),
            cell: Color(0xFFFFFFFF),
            line: Color(0x4400AEEF),
            homeInner: Color(0xFFEAF4FF),
            star: Color(0xFF1499D6),
          ),
        PowerSkin.arabian => const SkinPalette(
            frame: [
              Color(0xFF3A1248), Color(0xFF5B2A6E), Color(0xFFE3BD5E), Color(0xFFC98A1E),
              Color(0xFF3A1248), Color(0xFFFFD56A), Color(0xFF5B2A6E), Color(0xFF2A0E36),
            ],
            surface: Color(0xFFFBF2DC),
            cell: Color(0xFFFFFBF0),
            line: Color(0x55B07C00),
            homeInner: Color(0xFFFFFBF0),
            star: Color(0xFFC98A1E),
          ),
      };
}

/// تخزين اختيار الطاولة/الفارس.
class LudoPowerPrefs {
  LudoPowerPrefs._(this._p);
  final SharedPreferences _p;

  static LudoPowerPrefs? _instance;
  static Future<LudoPowerPrefs> instance() async =>
      _instance ??= LudoPowerPrefs._(await SharedPreferences.getInstance());

  static const _kSkin = 'lp_skin';
  static const _kKnight = 'lp_knight';

  PowerSkin get skin => PowerSkinX.fromKey(_p.getString(_kSkin) ?? 'royal');
  KnightStyle get knight => KnightStyleX.fromKey(_p.getString(_kKnight) ?? 'classic');

  Future<void> setSkin(PowerSkin s) => _p.setString(_kSkin, s.key);
  Future<void> setKnight(KnightStyle s) => _p.setString(_kKnight, s.key);
}
