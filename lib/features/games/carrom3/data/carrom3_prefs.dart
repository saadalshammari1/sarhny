import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence for carrom3 choices: board theme, coin set, and mute.
/// Self-contained (own SharedPreferences handle) so the game module doesn't
/// depend on the app-wide Riverpod prefs provider.
class Carrom3Prefs {
  Carrom3Prefs._(this._p);
  final SharedPreferences _p;

  static Carrom3Prefs? _instance;
  static Future<Carrom3Prefs> instance() async {
    return _instance ??= Carrom3Prefs._(await SharedPreferences.getInstance());
  }

  static const _kBoard = 'c3_board';
  static const _kCoin = 'c3_coin';
  static const _kMute = 'c3_mute';

  String get boardKey => _p.getString(_kBoard) ?? 'walnut';
  String get coinKey => _p.getString(_kCoin) ?? 'classic';
  bool get muted => _p.getBool(_kMute) ?? false;

  Future<void> setBoard(String key) => _p.setString(_kBoard, key);
  Future<void> setCoin(String key) => _p.setString(_kCoin, key);
  Future<void> setMuted(bool v) => _p.setBool(_kMute, v);
}
