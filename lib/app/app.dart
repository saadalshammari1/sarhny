import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/providers/app_settings_providers.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'localization/generated/app_localizations.dart';

class SarhnyApp extends ConsumerWidget {
  const SarhnyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844), // مرجع iPhone 14 (نفس نسبة Pixel 7 تقريباً)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return MaterialApp.router(
          title: 'صارحني',
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          themeAnimationDuration: const Duration(milliseconds: 250),
          themeAnimationCurve: Curves.easeInOutCubic,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          builder: (context, child) {
            // فرض RTL/LTR حسب اللغة المختارة.
            final direction =
                locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
            return Directionality(textDirection: direction, child: child!);
          },
        );
      },
    );
  }
}
