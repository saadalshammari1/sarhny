// Adapted from fludo (https://github.com/smokelaboratory/fludo)
// Original copyright (c) 2020 smokelaboratory, Apache License 2.0.
// Port + theming for Sarhny: 2026, Sarhny team.

/// Ludo v2 — dice painters.
///
/// Hosts both [DicePaint] (renders the 1–6 face of a die) and
/// [DiceBasePainter] (the glowing rotating ring drawn beneath the die while
/// it's idle / animating). Merged into a single file per Sarhny conventions.
library;

import 'dart:math';

import 'package:flutter/material.dart';

/// Paints one of the six faces of a Ludo die. The face value is supplied
/// in the constructor; the painter draws a rounded-rectangle outline and the
/// appropriate pip layout for [_number].
class DicePaint extends CustomPainter {
  DicePaint(this._number);

  final int _number;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height),
            const Radius.circular(5)),
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5);

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final centerComponent = size.width / 2;
    final semiCenterComponent = size.width / 3.5;
    final semiComponent = size.width - size.width / 3.5;

    switch (_number) {
      case 1:
        canvas.drawCircle(Offset(centerComponent, centerComponent),
            size.width / 8, dotPaint);
        break;
      case 2:
        final radius = size.width / 10;
        canvas.drawCircle(
            Offset(semiCenterComponent, semiCenterComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiComponent, semiComponent), radius, dotPaint);
        break;
      case 3:
        final radius = size.width / 12;
        canvas.drawCircle(
            Offset(semiCenterComponent, semiCenterComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(centerComponent, centerComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiComponent, semiComponent), radius, dotPaint);
        break;
      case 4:
        final radius = size.width / 10;
        canvas.drawCircle(
            Offset(semiCenterComponent, semiCenterComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiComponent, semiCenterComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiComponent, semiComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiCenterComponent, semiComponent), radius, dotPaint);
        break;
      case 5:
        final radius = size.width / 12;
        canvas.drawCircle(
            Offset(semiCenterComponent, semiCenterComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiComponent, semiCenterComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiComponent, semiComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiCenterComponent, semiComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(centerComponent, centerComponent), radius, dotPaint);
        break;
      case 6:
        final radius = size.width / 15;
        canvas.drawCircle(
            Offset(semiComponent, centerComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiCenterComponent, centerComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiCenterComponent, semiCenterComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiComponent, semiCenterComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiComponent, semiComponent), radius, dotPaint);
        canvas.drawCircle(
            Offset(semiCenterComponent, semiComponent), radius, dotPaint);
        break;
      default:
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

/// Paints the rotating orange/white arc ring that sits beneath the die. The
/// caller advances [_startAngle] each frame to spin the ring.
class DiceBasePainter extends CustomPainter {
  DiceBasePainter(this._startAngle);

  double _startAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width;

    final center = Offset(size.width / 2, size.width / 2);
    final acrAngle = 30 * pi / 180;

    for (int arcIndex = 0; arcIndex < 12; arcIndex++) {
      canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          _startAngle,
          acrAngle,
          false,
          Paint()
            ..color = arcIndex % 2 == 0 ? Colors.orange : Colors.white
            ..strokeWidth = 7
            ..style = PaintingStyle.stroke);

      _startAngle += acrAngle;
    }

    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.orangeAccent
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
