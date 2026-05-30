import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  /// ───────── Light Theme ─────────
  static ThemeData light() {
    final scheme = FlexColorScheme.light(
      colors: const FlexSchemeColor(
        primary: AppColors.momentLight,
        primaryContainer: Color(0xFFFFE9C5),
        secondary: AppColors.faceLight,
        secondaryContainer: Color(0xFFD5EAF6),
        tertiary: AppColors.mindLight,
        tertiaryContainer: Color(0xFFE3DEF6),
        appBarColor: AppColors.lightSurface,
        error: AppColors.danger,
      ),
      scaffoldBackground: AppColors.lightBackground,
      surface: AppColors.lightSurface,
      appBarStyle: FlexAppBarStyle.surface,
      appBarElevation: 0,
      bottomAppBarElevation: 0,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 5,
      subThemesData: const FlexSubThemesData(
        defaultRadius: 14,
        elevatedButtonRadius: 14,
        outlinedButtonRadius: 14,
        filledButtonRadius: 14,
        textButtonRadius: 14,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 14,
        inputDecoratorFocusedHasBorder: true,
        cardRadius: 18,
        bottomNavigationBarElevation: 0,
        navigationBarElevation: 0,
        bottomSheetRadius: 22,
        bottomSheetElevation: 0,
        dialogRadius: 20,
        chipRadius: 999,
        useM2StyleDividerInM3: false,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
    ).toScheme;

    return _build(
      brightness: Brightness.light,
      scheme: scheme,
      background: AppColors.lightBackground,
      surface: AppColors.lightSurface,
      elevated: AppColors.lightElevated,
      textPrimary: AppColors.lightTextPrimary,
      textSecondary: AppColors.lightTextSecondary,
      border: AppColors.lightBorder,
      divider: AppColors.lightDivider,
    );
  }

  /// ───────── Dark Theme ─────────
  static ThemeData dark() {
    final scheme = FlexColorScheme.dark(
      colors: const FlexSchemeColor(
        primary: AppColors.momentDark,
        primaryContainer: Color(0xFF3A2F1A),
        secondary: AppColors.faceDark,
        secondaryContainer: Color(0xFF1F3848),
        tertiary: AppColors.mindDark,
        tertiaryContainer: Color(0xFF2D2747),
        appBarColor: AppColors.darkSurface,
        error: AppColors.danger,
      ),
      scaffoldBackground: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      appBarStyle: FlexAppBarStyle.surface,
      appBarElevation: 0,
      bottomAppBarElevation: 0,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 8,
      darkIsTrueBlack: false,
      subThemesData: const FlexSubThemesData(
        defaultRadius: 14,
        elevatedButtonRadius: 14,
        outlinedButtonRadius: 14,
        filledButtonRadius: 14,
        textButtonRadius: 14,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 14,
        inputDecoratorFocusedHasBorder: true,
        cardRadius: 18,
        bottomNavigationBarElevation: 0,
        navigationBarElevation: 0,
        bottomSheetRadius: 22,
        bottomSheetElevation: 0,
        dialogRadius: 20,
        chipRadius: 999,
        useM2StyleDividerInM3: false,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
    ).toScheme;

    return _build(
      brightness: Brightness.dark,
      scheme: scheme,
      background: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      elevated: AppColors.darkElevated,
      textPrimary: AppColors.darkTextPrimary,
      textSecondary: AppColors.darkTextSecondary,
      border: AppColors.darkBorder,
      divider: AppColors.darkDivider,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color background,
    required Color surface,
    required Color elevated,
    required Color textPrimary,
    required Color textSecondary,
    required Color border,
    required Color divider,
  }) {
    final textTheme = AppTypography.textTheme(textPrimary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      dividerColor: divider,
      dividerTheme: DividerThemeData(color: divider, thickness: 0.6, space: 1),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.rXl),
          side: BorderSide(color: border, width: 0.6),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevated,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.hmd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.rLg),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.rLg),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.rLg),
          borderSide: BorderSide(
            color: brightness == Brightness.dark ? AppColors.momentDark : AppColors.momentLight,
            width: 1.4,
          ),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textSecondary.withValues(alpha: 0.6)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.rLg),
          ),
          textStyle: textTheme.titleMedium,
          elevation: 0,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: brightness == Brightness.dark ? AppColors.momentDark : AppColors.momentLight,
        unselectedItemColor: textSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      extensions: <ThemeExtension<dynamic>>[
        SarhnyColors(
          background: background,
          surface: surface,
          elevated: elevated,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          border: border,
          divider: divider,
          moment: brightness == Brightness.dark ? AppColors.momentDark : AppColors.momentLight,
          face: brightness == Brightness.dark ? AppColors.faceDark : AppColors.faceLight,
          mind: brightness == Brightness.dark ? AppColors.mindDark : AppColors.mindLight,
          crystal: brightness == Brightness.dark ? AppColors.crystalDark : AppColors.crystalLight,
          danger: AppColors.danger,
          success: AppColors.success,
        ),
      ],
    );
  }
}

/// ThemeExtension يعرض ألوان صارحني المخصصة عبر context.
class SarhnyColors extends ThemeExtension<SarhnyColors> {
  const SarhnyColors({
    required this.background,
    required this.surface,
    required this.elevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.divider,
    required this.moment,
    required this.face,
    required this.mind,
    required this.crystal,
    required this.danger,
    required this.success,
  });

  final Color background;
  final Color surface;
  final Color elevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color divider;
  final Color moment;
  final Color face;
  final Color mind;
  final Color crystal;
  final Color danger;
  final Color success;

  @override
  SarhnyColors copyWith({
    Color? background,
    Color? surface,
    Color? elevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? divider,
    Color? moment,
    Color? face,
    Color? mind,
    Color? crystal,
    Color? danger,
    Color? success,
  }) {
    return SarhnyColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      elevated: elevated ?? this.elevated,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      moment: moment ?? this.moment,
      face: face ?? this.face,
      mind: mind ?? this.mind,
      crystal: crystal ?? this.crystal,
      danger: danger ?? this.danger,
      success: success ?? this.success,
    );
  }

  @override
  SarhnyColors lerp(ThemeExtension<SarhnyColors>? other, double t) {
    if (other is! SarhnyColors) return this;
    return SarhnyColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      elevated: Color.lerp(elevated, other.elevated, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      moment: Color.lerp(moment, other.moment, t)!,
      face: Color.lerp(face, other.face, t)!,
      mind: Color.lerp(mind, other.mind, t)!,
      crystal: Color.lerp(crystal, other.crystal, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

extension SarhnyThemeContext on BuildContext {
  SarhnyColors get sarhnyColors => Theme.of(this).extension<SarhnyColors>()!;
  TextTheme get textStyles => Theme.of(this).textTheme;
}
