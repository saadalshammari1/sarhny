import 'package:flutter/material.dart';

/// مكتبة ألوان صارحني — مطابقة للـ prototype الأصلي.
class AppColors {
  AppColors._();

  // ────────── Light Mode (الوضع النهاري) ──────────
  static const Color lightBackground = Color(0xFFF4F1EA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFF3EFE7);
  static const Color lightTextPrimary = Color(0xFF1C1A17);
  static const Color lightTextSecondary = Color(0xFF6B6358);
  static const Color lightBorder = Color(0xFFE5DFD3);
  static const Color lightDivider = Color(0xFFEDE7D9);

  // ────────── Dark Mode (الوضع الداكن) ──────────
  static const Color darkBackground = Color(0xFF08090D);
  static const Color darkSurface = Color(0xFF141720);
  static const Color darkElevated = Color(0xFF1B1F2B);
  static const Color darkTextPrimary = Color(0xFFF1EDE6);
  static const Color darkTextSecondary = Color(0xFF8B90A0);
  static const Color darkBorder = Color(0xFF252A38);
  static const Color darkDivider = Color(0xFF1F2330);

  // ────────── Brand / Section Colors ──────────
  // الوضع الداكن — قيم أفتح
  static const Color momentDark = Color(0xFFD4A85F);   // ⚡ لحظات
  static const Color faceDark = Color(0xFF6DB4D8);     // 🎨 صور
  static const Color mindDark = Color(0xFFA896DC);     // 🧠 أفكار
  static const Color crystalDark = Color(0xFFECD9A8);  // ✦ متبلور

  // الوضع النهاري — قيم أغمق
  static const Color momentLight = Color(0xFFB8862F);
  static const Color faceLight = Color(0xFF3D8DB5);
  static const Color mindLight = Color(0xFF7A64C0);
  static const Color crystalLight = Color(0xFFC0A04A);

  // ────────── AA-contrast ink variants (للنصوص فقط) ──────────
  // مطابقة للويب: --moment-text / --face-text / --mind-text / --crystal-text
  static const Color momentInkLight = Color(0xFF8C5E15);
  static const Color faceInkLight = Color(0xFF1F5C80);
  static const Color mindInkLight = Color(0xFF533F8C);
  static const Color crystalInkLight = Color(0xFF7A5E1A);
  // في الوضع الداكن نستخدم نفس --*Dark — تباينها كافٍ

  // ────────── Status ──────────
  static const Color danger = Color(0xFFE2685A);
  static const Color success = Color(0xFF5FC486);
  static const Color warning = Color(0xFFE8B14C);
  static const Color info = Color(0xFF5A9FE2);

  // ────────── Glow / Gravity ──────────
  static const Color glowSoft = Color(0x33ECD9A8);
  static const Color gravityProgress = Color(0xFFD4A85F);
}

/// خريطة الألوان حسب القسم (تستخدم في PostCard, ComposePage).
enum PostSection { moment, face, mind }

extension PostSectionColor on PostSection {
  Color resolve(Brightness brightness) {
    switch (this) {
      case PostSection.moment:
        return brightness == Brightness.dark ? AppColors.momentDark : AppColors.momentLight;
      case PostSection.face:
        return brightness == Brightness.dark ? AppColors.faceDark : AppColors.faceLight;
      case PostSection.mind:
        return brightness == Brightness.dark ? AppColors.mindDark : AppColors.mindLight;
    }
  }

  String get arabicLabel {
    switch (this) {
      case PostSection.moment:
        return 'لحظة';
      case PostSection.face:
        return 'صورة';
      case PostSection.mind:
        return 'فكرة';
    }
  }

  String get glyph {
    switch (this) {
      case PostSection.moment:
        return '⚡';
      case PostSection.face:
        return '🎨';
      case PostSection.mind:
        return '🧠';
    }
  }

  Color ink(Brightness brightness) {
    if (brightness == Brightness.dark) return resolve(brightness);
    switch (this) {
      case PostSection.moment:
        return AppColors.momentInkLight;
      case PostSection.face:
        return AppColors.faceInkLight;
      case PostSection.mind:
        return AppColors.mindInkLight;
    }
  }
}

/// Section filter (يطابق SectionFilter في الويب) — يضيف Q&A.
enum SectionFilter { all, moment, face, mind, questions }

extension SectionFilterLabel on SectionFilter {
  String get arabicLabel {
    switch (this) {
      case SectionFilter.all:
        return 'الكل';
      case SectionFilter.moment:
        return 'لحظات';
      case SectionFilter.face:
        return 'صور';
      case SectionFilter.mind:
        return 'أفكار';
      case SectionFilter.questions:
        return 'أجوبة';
    }
  }

  String get englishLabel {
    switch (this) {
      case SectionFilter.all:
        return 'All';
      case SectionFilter.moment:
        return 'Moments';
      case SectionFilter.face:
        return 'Faces';
      case SectionFilter.mind:
        return 'Minds';
      case SectionFilter.questions:
        return 'Answers';
    }
  }

  String get glyph {
    switch (this) {
      case SectionFilter.all:
        return '✨';
      case SectionFilter.moment:
        return '⚡';
      case SectionFilter.face:
        return '🎨';
      case SectionFilter.mind:
        return '🧠';
      case SectionFilter.questions:
        return '🕶️';
    }
  }

  String get apiValue => name;
}

