// Adapted from fludo (https://github.com/smokelaboratory/fludo)
// Original copyright (c) 2020 smokelaboratory, Apache License 2.0.
// Port + theming for Sarhny: 2026, Sarhny team.

/// Ludo v2 — palette constants.
///
/// Renamed from fludo's `AppColors` to `LudoV2Colors` to avoid clashes with
/// any other `AppColors` in the Sarhny codebase. Player accent colours are
/// nudged toward Sarhny's brand palette (crimson + moment gold), while the
/// structural values from the original are preserved.
library;

import 'package:flutter/material.dart';

class LudoV2Colors {
  const LudoV2Colors._();

  /// Player 1 — Sarhny crimson.
  static const Color home1 = Color(0xFFB8001F);

  /// Player 2 — green.
  static const Color home2 = Color(0xFF2D8B5C);

  /// Player 3 — yellow.
  static const Color home3 = Color(0xFFE0B341);

  /// Player 4 — blue.
  static const Color home4 = Color(0xFF3E7DD4);

  static const Color player1 = Colors.red;
  static const Color player2 = Colors.green;
  static const Color player3 = Colors.yellow;
  static const Color player4 = Colors.blue;

  /// Safe-spot marker — Sarhny moment gold.
  static const Color safeSpot = Color(0xFFD4A85F);
}
