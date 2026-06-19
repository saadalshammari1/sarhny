// Adapted from fludo (https://github.com/smokelaboratory/fludo)
// Original copyright (c) 2020 smokelaboratory, Apache License 2.0.
// Port + theming for Sarhny: 2026, Sarhny team.

/// Ludo v2 — overlay surface for click handling and active-home highlighting.
///
/// Sits above the board and tints the currently active player's home with
/// [highlightColor]. Every pointer event is forwarded to [clickOffset] so the
/// game controller can resolve which spot / pawn was tapped.
library;

import 'package:flutter/material.dart';

class OverlaySurface extends CustomPainter {
  OverlaySurface({
    required this.clickOffset,
    required this.selectedHomeIndex,
    required this.highlightColor,
  });

  final void Function(Offset offset) clickOffset;
  final int selectedHomeIndex;
  final Color highlightColor;

  final Paint _fillPaint = Paint()..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final stepSize = size.width / 15;
    final homeStartOffset = stepSize * 9;
    final homeSize = stepSize * 6;

    final Rect home;
    switch (selectedHomeIndex) {
      case 0:
        home = Rect.fromLTWH(0, 0, homeSize, homeSize);
        break;
      case 1:
        home = Rect.fromLTWH(homeStartOffset, 0, homeSize, homeSize);
        break;
      case 2:
        home = Rect.fromLTWH(
            homeStartOffset, homeStartOffset, homeSize, homeSize);
        break;
      default:
        home = Rect.fromLTWH(0, homeStartOffset, homeSize, homeSize);
    }

    _fillPaint.color = highlightColor;
    canvas.drawRect(home, _fillPaint);
  }

  @override
  bool hitTest(Offset position) {
    clickOffset(position);
    return true;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
