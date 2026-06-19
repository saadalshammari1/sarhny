import 'package:flutter/services.dart';

/// Canonical haptic-feedback wrapper for all games in Sarhny.
///
/// Static-only utility: call [GameHaptics.tap] / [diceRoll] / [capture] etc.
/// from any widget. Methods are safe on platforms without haptics — they
/// silently swallow errors so a failed haptic never crashes gameplay.
/// Toggle [enabled] (e.g. from a user setting) to disable all feedback.
class GameHaptics {
  GameHaptics._();

  /// Master switch — when false, every method short-circuits to a no-op.
  /// Wire to a user setting in the future.
  static bool enabled = true;

  /// UI interactions, lightest. Use for picker/selection-style taps.
  static Future<void> tap() async {
    if (!enabled) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Button taps and dialog pops — slightly heavier than [tap].
  static Future<void> uiPop() async {
    if (!enabled) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Dice landed on the board.
  static Future<void> diceRoll() async {
    if (!enabled) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Ludo capture — a "thud + click" two-beat sequence.
  static Future<void> capture() async {
    if (!enabled) return;
    try {
      await HapticFeedback.heavyImpact();
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Carrom striker hitting pieces — tight double-impact.
  static Future<void> strikerHit() async {
    if (!enabled) return;
    try {
      await HapticFeedback.heavyImpact();
      await Future<void>.delayed(const Duration(milliseconds: 40));
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Carrom piece pocketed.
  static Future<void> pocket() async {
    if (!enabled) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Game won — celebratory triple-beat (heavy, heavy, medium).
  static Future<void> win() async {
    if (!enabled) return;
    try {
      await HapticFeedback.heavyImpact();
      await Future<void>.delayed(const Duration(milliseconds: 120));
      await HapticFeedback.heavyImpact();
      await Future<void>.delayed(const Duration(milliseconds: 120));
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Carrom aim snap-to-angle — subtle tick.
  static Future<void> snap() async {
    if (!enabled) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }
}
