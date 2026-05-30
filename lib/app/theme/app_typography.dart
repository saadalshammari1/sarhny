import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// نظام الخطوط — Tajawal للنص العربي العام، Playfair Display للعناوين الأنيقة.
class AppTypography {
  AppTypography._();

  /// خط النص الأساسي (عربي + لاتيني)
  static TextStyle tajawal({
    double? size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.tajawal(
      fontSize: size?.sp,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// خط العناوين الأنيقة (لاتيني — لشعار "صارحني" بالإنجليزية وما شابه)
  static TextStyle playfair({
    double? size,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double? height,
    FontStyle? style,
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: size?.sp,
      fontWeight: weight,
      color: color,
      height: height,
      fontStyle: style,
    );
  }

  /// مجموعة TextTheme كاملة (تُستخدم في ThemeData).
  static TextTheme textTheme(Color textColor) {
    return TextTheme(
      displayLarge: GoogleFonts.tajawal(fontSize: 32.sp, fontWeight: FontWeight.w700, color: textColor, height: 1.2),
      displayMedium: GoogleFonts.tajawal(fontSize: 28.sp, fontWeight: FontWeight.w700, color: textColor, height: 1.25),
      displaySmall: GoogleFonts.tajawal(fontSize: 24.sp, fontWeight: FontWeight.w600, color: textColor, height: 1.3),
      headlineLarge: GoogleFonts.tajawal(fontSize: 22.sp, fontWeight: FontWeight.w700, color: textColor),
      headlineMedium: GoogleFonts.tajawal(fontSize: 20.sp, fontWeight: FontWeight.w600, color: textColor),
      headlineSmall: GoogleFonts.tajawal(fontSize: 18.sp, fontWeight: FontWeight.w600, color: textColor),
      titleLarge: GoogleFonts.tajawal(fontSize: 17.sp, fontWeight: FontWeight.w600, color: textColor),
      titleMedium: GoogleFonts.tajawal(fontSize: 15.sp, fontWeight: FontWeight.w600, color: textColor),
      titleSmall: GoogleFonts.tajawal(fontSize: 13.sp, fontWeight: FontWeight.w600, color: textColor),
      bodyLarge: GoogleFonts.tajawal(fontSize: 16.sp, fontWeight: FontWeight.w400, color: textColor, height: 1.6),
      bodyMedium: GoogleFonts.tajawal(fontSize: 14.sp, fontWeight: FontWeight.w400, color: textColor, height: 1.55),
      bodySmall: GoogleFonts.tajawal(fontSize: 12.sp, fontWeight: FontWeight.w400, color: textColor, height: 1.5),
      labelLarge: GoogleFonts.tajawal(fontSize: 14.sp, fontWeight: FontWeight.w600, color: textColor),
      labelMedium: GoogleFonts.tajawal(fontSize: 12.sp, fontWeight: FontWeight.w500, color: textColor),
      labelSmall: GoogleFonts.tajawal(fontSize: 11.sp, fontWeight: FontWeight.w500, color: textColor),
    );
  }
}
