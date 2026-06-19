// Adapted from fludo (https://github.com/smokelaboratory/fludo)
// Original copyright (c) 2020 smokelaboratory, Apache License 2.0.
// Port + theming for Sarhny: 2026, Sarhny team.

/// Ludo v2 — end-game result overlay painter.
///
/// Given a list of final ranks per player (index = player, value = rank, 0
/// meaning "did not finish"), draws a translucent black square over each
/// finished player's home quadrant with their rank text (1st, 2nd, …) in
/// the centre.
library;

import 'package:flutter/material.dart';

class ResultPainter extends CustomPainter {
  ResultPainter(this._ranks);

  final List<int> _ranks;

  @override
  void paint(Canvas canvas, Size size) {
    final stepSize = size.width / 15;
    final homeStartOffset = stepSize * 9;
    final homeSize = stepSize * 6;

    for (int playerIndex = 0; playerIndex < _ranks.length; playerIndex++) {
      final rank = _ranks[playerIndex];
      if (rank != 0) {
        double left, top;
        switch (playerIndex) {
          case 0:
            left = 0;
            top = 0;
            break;
          case 1:
            left = homeStartOffset;
            top = 0;
            break;
          case 2:
            left = homeStartOffset;
            top = homeStartOffset;
            break;
          default:
            left = 0;
            top = homeStartOffset;
        }
        _drawRank(canvas, Rect.fromLTWH(left, top, homeSize, homeSize), rank);
      }
    }
  }

  void _drawRank(Canvas canvas, Rect rect, int rank) {
    canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.black54);

    final rankTextPainter = TextPainter(
        text: TextSpan(
          text: _getRankText(rank),
          style: const TextStyle(
            fontSize: 50.0,
            color: Colors.white,
            fontFamily: 'LuckiestGuy',
            height: 1.5,
          ),
        ),
        textDirection: TextDirection.ltr)
      ..layout();

    rankTextPainter.paint(
        canvas,
        Offset(rect.center.dx - rankTextPainter.width / 2,
            rect.center.dy - rankTextPainter.height / 2));
  }

  String _getRankText(int rank) {
    final String suffix;

    switch (rank) {
      case 1:
        suffix = 'st';
        break;
      case 2:
        suffix = 'nd';
        break;
      case 3:
        suffix = 'rd';
        break;
      default:
        suffix = 'th';
    }

    return '$rank$suffix';
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  /// Pass touches through to the layer beneath.
  @override
  bool hitTest(Offset position) => false;
}
