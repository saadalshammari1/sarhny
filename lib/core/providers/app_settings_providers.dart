import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'storage_providers.dart';

/// ───── Theme Mode ─────
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ref.read(prefsStorageProvider).themeMode;
  }

  Future<void> set(ThemeMode mode) async {
    await ref.read(prefsStorageProvider).setThemeMode(mode);
    state = mode;
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await set(next);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// ───── Locale ─────
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final code = ref.read(prefsStorageProvider).locale;
    return Locale(code);
  }

  Future<void> set(Locale locale) async {
    await ref.read(prefsStorageProvider).setLocale(locale.languageCode);
    state = locale;
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
