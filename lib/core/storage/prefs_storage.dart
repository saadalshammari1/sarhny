import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// تفضيلات المستخدم غير الحساسة: الوضع، اللغة، إلخ.
class PrefsStorage {
  PrefsStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _kThemeMode = 'theme_mode';
  static const _kLocale = 'locale';
  static const _kOnboarded = 'onboarded';
  static const _kBiometricEnabled = 'biometric_enabled';

  static Future<PrefsStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PrefsStorage(prefs);
  }

  // ───── Theme ─────
  ThemeMode get themeMode {
    final raw = _prefs.getString(_kThemeMode);
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) {
    return _prefs.setString(_kThemeMode, mode.name);
  }

  // ───── Locale ─────
  String get locale => _prefs.getString(_kLocale) ?? 'ar';
  Future<void> setLocale(String code) => _prefs.setString(_kLocale, code);

  // ───── Onboarding ─────
  bool get hasOnboarded => _prefs.getBool(_kOnboarded) ?? false;
  Future<void> setOnboarded(bool v) => _prefs.setBool(_kOnboarded, v);

  // ───── Biometric ─────
  bool get biometricEnabled => _prefs.getBool(_kBiometricEnabled) ?? false;
  Future<void> setBiometricEnabled(bool v) =>
      _prefs.setBool(_kBiometricEnabled, v);
}
