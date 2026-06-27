import 'package:shared_preferences/shared_preferences.dart';

import '../domain/ludo_cosmetics.dart';

/// Local persistence for Ludo cosmetic choices (board skin + pawn style).
/// Self-contained (own SharedPreferences handle), mirroring Carrom3Prefs.
class Ludo3Prefs {
  Ludo3Prefs._(this._p);
  final SharedPreferences _p;

  static Ludo3Prefs? _instance;
  static Future<Ludo3Prefs> instance() async {
    return _instance ??= Ludo3Prefs._(await SharedPreferences.getInstance());
  }

  static const _kBoard = 'ludo3_board';
  static const _kPawn = 'ludo3_pawn';

  LudoBoardSkin get boardSkin =>
      LudoBoardSkinX.fromKey(_p.getString(_kBoard) ?? 'royal');
  LudoPawnStyle get pawnStyle =>
      LudoPawnStyleX.fromKey(_p.getString(_kPawn) ?? 'classic');

  Future<void> setBoard(LudoBoardSkin s) => _p.setString(_kBoard, s.key);
  Future<void> setPawn(LudoPawnStyle s) => _p.setString(_kPawn, s.key);
}
