// Adapted from fludo (https://github.com/smokelaboratory/fludo)
// Original copyright (c) 2020 smokelaboratory, Apache License 2.0.
// Port + theming for Sarhny: 2026, Sarhny team.

/// Ludo v2 — players (pawn) painter.
///
/// Draws a single pawn as two concentric circles (outer in [playerColor],
/// inner white) at [playerCurrentSpot]. The painter declines hits so taps
/// pass through to the overlay surface beneath.
library;

import 'package:flutter/material.dart';

class PlayersPainter extends CustomPainter {
  PlayersPainter({
    required this.playerCurrentSpot,
    required this.playerColor,
  });

  final Offset playerCurrentSpot;
  final Color playerColor;

  late double _playerSize, _playerInnerSize, _stepSize;
  final Paint _playerPaint = Paint()..style = PaintingStyle.fill;
  final Paint _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5
    ..color = Colors.black;

  @override
  void paint(Canvas canvas, Size size) {
    _stepSize = size.width / 15;
    _playerSize = _stepSize / 3;
    _playerInnerSize = _playerSize / 2.5;

    _drawPlayerShape(canvas, playerCurrentSpot, playerColor);
  }

  void _drawPlayerShape(Canvas canvas, Offset pos, Color color) {
    _playerPaint.color = color;
    canvas.drawCircle(pos, _playerSize, _playerPaint);
    canvas.drawCircle(pos, _playerSize, _strokePaint);

    _playerPaint.color = Colors.white;
    canvas.drawCircle(pos, _playerInnerSize, _playerPaint);
    canvas.drawCircle(pos, _playerInnerSize, _strokePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  /// Pass touches through to the layer beneath (the overlay surface).
  @override
  bool hitTest(Offset position) => false;
}
