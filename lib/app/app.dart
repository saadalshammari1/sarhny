import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/providers/app_settings_providers.dart' show themeModeProvider, localeProvider, isRtl;
import '../core/providers/auth_providers.dart';
import '../features/notifications/data/fcm_provider.dart';
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

    // FCM register/dispose on auth transitions. Handles BOTH directions:
    //   unauthed → authed: register a fresh device token for the new session
    //   authed → unauthed: dispose subscriptions + invalidate the provider so
    //                       the next sign-in gets a clean FcmService instance
    //                       (without the stale `_registered` / `_lastSentToken`
    //                       cache from the previous user).
    ref.listen<AsyncValue<AuthState>>(authStateProvider, (prev, next) {
      final wasAuthed = prev?.value?.status == AuthStatus.authenticated;
      final isAuthed = next.value?.status == AuthStatus.authenticated;
      if (!wasAuthed && isAuthed) {
        ref.read(fcmServiceProvider).register();
      } else if (wasAuthed && !isAuthed) {
        final fcm = ref.read(fcmServiceProvider);
        // Drop the device token server-side first, then tear down subscriptions.
        unawaited(fcm.unregister());
        fcm.dispose();
        ref.invalidate(fcmServiceProvider);
      }
    });

    return ScreenUtilInit(
      designSize: const Size(390, 844), // مرجع iPhone 14 (نفس نسبة Pixel 7 تقريباً)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context).appName,
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
            // RTL detection is no longer hard-coded to Arabic — Persian,
            // Hebrew, Urdu, Pashto are all RTL too. `isRtl()` consults a
            // central language-code whitelist in app_settings_providers.
            final direction =
                isRtl(locale) ? TextDirection.rtl : TextDirection.ltr;
            return Directionality(textDirection: direction, child: child!);
          },
        );
      },
    );
  }
}
