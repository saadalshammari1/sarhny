import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/localization/generated/app_localizations.dart';
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
///
/// Resolution priority on every cold start:
///   1. The user's saved choice (set via Settings → Language). Highest
///      precedence — once they pick, we never override it.
///   2. The device's current locale, if Sarhny supports it.
///   3. English. Sarhny launches with the same default everywhere, so
///      a Spanish or Japanese user (no native translation yet) starts
///      in English instead of Arabic — which used to be the silent
///      fallback and made the app feel "locked to Arabic".
///
/// Arabic was the original default because the app shipped Arabic-first;
/// preserving that "ar" default after we go international means a brand-
/// new user in Berlin lands on an RTL Arabic UI they can't read. Hence
/// the rewrite below.
class LocaleNotifier extends Notifier<Locale> {
  static const Locale _englishFallback = Locale('en');

  @override
  Locale build() {
    final stored = ref.read(prefsStorageProvider).locale;
    if (stored != null && stored.isNotEmpty) {
      return _normalize(Locale(stored));
    }
    return _detectFromDevice();
  }

  /// Walk the platform locale chain and pick the first one Sarhny
  /// supports. Falls back to English. Pure function of the current
  /// platform — never persisted (user has not chosen yet).
  Locale _detectFromDevice() {
    final supported = AppLocalizations.supportedLocales;
    final platform = WidgetsBinding.instance.platformDispatcher.locales;
    for (final l in platform) {
      final match = _bestMatch(l, supported);
      if (match != null) return match;
    }
    return _englishFallback;
  }

  /// First try an exact language+country match (e.g. pt_BR over pt),
  /// then fall back to language-only. Mirrors Flutter's own resolution
  /// strategy and gives reasonable picks for regional variants.
  Locale? _bestMatch(Locale wanted, List<Locale> supported) {
    for (final s in supported) {
      if (s.languageCode == wanted.languageCode &&
          s.countryCode == wanted.countryCode) {
        return s;
      }
    }
    for (final s in supported) {
      if (s.languageCode == wanted.languageCode) {
        return s;
      }
    }
    return null;
  }

  /// Make sure whatever we return is actually one of [supportedLocales].
  /// A user who saved a now-unsupported language (e.g. a removed dialect)
  /// shouldn't crash the app — fall back to English silently.
  Locale _normalize(Locale wanted) {
    final supported = AppLocalizations.supportedLocales;
    final match = _bestMatch(wanted, supported);
    return match ?? _englishFallback;
  }

  Future<void> set(Locale locale) async {
    final resolved = _normalize(locale);
    await ref.read(prefsStorageProvider).setLocale(resolved.languageCode);
    state = resolved;
  }

  /// Forget the user's choice and revert to device auto-detection.
  Future<void> resetToDevice() async {
    await ref.read(prefsStorageProvider).clearLocale();
    state = _detectFromDevice();
  }

  /// All supported locales for use by language-picker UIs.
  List<Locale> get supported => AppLocalizations.supportedLocales;

  /// True when the user has NOT explicitly picked a language — i.e. the
  /// current locale comes from device auto-detection. The picker uses
  /// this to highlight the "Auto (device language)" row.
  bool get isAuto =>
      (ref.read(prefsStorageProvider).locale ?? '').isEmpty;
}

/// Human-readable name of each supported language in its OWN script.
/// Used by the in-app language picker so a Japanese user sees "日本語"
/// rather than "Japanese".
const Map<String, String> kLanguageDisplayNames = {
  'ar': 'العربية',
  'en': 'English',
  'tr': 'Türkçe',
  'fa': 'فارسی',
  'hi': 'हिन्दी',
  'pt': 'Português (Brasil)',
  'zh': '简体中文',
  'ko': '한국어',
  'ja': '日本語',
  'fr': 'Français',
  'es': 'Español',
  'de': 'Deutsch',
  'ru': 'Русский',
  'id': 'Bahasa Indonesia',
};

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

/// RTL language whitelist. Used by [SarhnyApp] to set the canonical
/// directionality. Centralised so any future RTL language (Urdu, Hebrew,
/// Pashto, …) only needs one edit.
const Set<String> _kRtlLanguageCodes = {'ar', 'fa', 'he', 'ur', 'ps'};
bool isRtl(Locale locale) =>
    _kRtlLanguageCodes.contains(locale.languageCode);
