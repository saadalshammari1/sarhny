import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../engine/ludo_engine.dart';
import '../theme/ludo_theme.dart';

/// Renders the static board (cells, yards, safe stars, power tiles, centre).
/// Pieces are drawn as widgets on top by the page, not by this painter.
class LudoBoardPainter extends CustomPainter {
  final LudoEngine engine;
  LudoBoardPainter(this.engine);

  static const colorKeys = BoardScheme.playerColors;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 15.0;
    final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(s * 0.6));

    canvas.drawRRect(rrect, Paint()..color = RoyalTheme.boardBg);

    final yardRects = [
      [0, 0, 0],
      [9, 0, 1],
      [9, 9, 2],
      [0, 9, 3],
    ];
    for (final yr in yardRects) {
      final c = ludoColors[colorKeys[yr[2]]]!;
      final rect = Rect.fromLTWH(yr[0] * s, yr[1] * s, 6 * s, 6 * s);
      final rr = RRect.fromRectAndRadius(rect, Radius.circular(s * 0.5));
      canvas.drawRRect(
          rr,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [c.light, c.base, c.dark],
            ).createShader(rect));
      final inner = Rect.fromLTWH(
          (yr[0] + 0.7) * s, (yr[1] + 0.7) * s, 4.6 * s, 4.6 * s);
      canvas.drawRRect(
          RRect.fromRectAndRadius(inner, Radius.circular(s * 0.4)),
          Paint()..color = RoyalTheme.boardBg.withValues(alpha: 0.55));
      for (final sp in kYard[yr[2]]) {
        canvas.drawCircle(Offset(sp[0] * s, sp[1] * s), 0.5 * s,
            Paint()..color = c.base.withValues(alpha: 0.4));
        canvas.drawCircle(
            Offset(sp[0] * s, sp[1] * s),
            0.5 * s,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5
              ..color = c.light);
      }
    }

    final cellPaint = Paint()..color = RoyalTheme.trackCell;
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x33D6AA54);
    for (final g in kPath) {
      _cell(canvas, g[0], g[1], s, cellPaint, edgePaint);
    }
    for (int p = 0; p < 4; p++) {
      final g = kPath[kStart[p]];
      final c = ludoColors[colorKeys[p]]!;
      _cell(canvas, g[0], g[1], s, Paint()..color = c.base, edgePaint);
    }
    for (int p = 0; p < 4; p++) {
      final c = ludoColors[colorKeys[p]]!;
      for (final g in kHome[p]) {
        _cell(canvas, g[0], g[1], s, Paint()..color = c.base, edgePaint);
      }
    }

    for (final idx in kSafe) {
      final g = kPath[idx];
      Color starCol = const Color(0xFFD6AA54);
      for (int p = 0; p < 4; p++) {
        if (kStart[p] == idx) starCol = ludoColors[colorKeys[p]]!.light;
      }
      _star(canvas, (g[0] + 0.5) * s, (g[1] + 0.5) * s, 0.3 * s, starCol);
    }

    engine.specials.forEach((idx, sp) {
      final g = kPath[idx];
      _specialTile(canvas, (g[0] + 0.5) * s, (g[1] + 0.5) * s, s, sp.type);
    });

    final tris = <Map<String, dynamic>>[
      {
        'pts': [
          [6.0, 6.0],
          [7.5, 7.5],
          [9.0, 6.0]
        ],
        'ci': 0,
      },
      {
        'pts': [
          [9.0, 6.0],
          [7.5, 7.5],
          [9.0, 9.0]
        ],
        'ci': 1,
      },
      {
        'pts': [
          [6.0, 9.0],
          [7.5, 7.5],
          [9.0, 9.0]
        ],
        'ci': 2,
      },
      {
        'pts': [
          [6.0, 6.0],
          [7.5, 7.5],
          [6.0, 9.0]
        ],
        'ci': 3,
      },
    ];
    for (final t in tris) {
      final pts = t['pts'] as List<List<double>>;
      final ci = t['ci'] as int;
      final path = Path()
        ..moveTo(pts[0][0] * s, pts[0][1] * s)
        ..lineTo(pts[1][0] * s, pts[1][1] * s)
        ..lineTo(pts[2][0] * s, pts[2][1] * s)
        ..close();
      canvas.drawPath(path, Paint()..color = ludoColors[colorKeys[ci]]!.base);
    }
  }

  void _cell(Canvas c, int cx, int cy, double s, Paint fill, Paint edge) {
    final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx * s, cy * s, s, s), Radius.circular(s * 0.18));
    c.drawRRect(r, fill);
    c.drawRRect(r, edge);
  }

  void _star(Canvas c, double cx, double cy, double r, Color col) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / 5;
      final a2 = a + math.pi / 5;
      if (i == 0) {
        path.moveTo(cx + r * math.cos(a), cy + r * math.sin(a));
      } else {
        path.lineTo(cx + r * math.cos(a), cy + r * math.sin(a));
      }
      path.lineTo(cx + r * 0.45 * math.cos(a2), cy + r * 0.45 * math.sin(a2));
    }
    path.close();
    c.drawPath(path, Paint()..color = col);
  }

  void _specialTile(Canvas c, double cx, double cy, double s, PowerType type) {
    final key = {
      PowerType.rocket: 'rocket',
      PowerType.freeze: 'freeze',
      PowerType.portal: 'portal',
      PowerType.tornado: 'tornado',
    }[type]!;
    final p = powers[key]!;
    final r = 0.46 * s;
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 2);
    c.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(s * 0.2)),
        Paint()
          ..shader = RadialGradient(
                  colors: [p.light, p.base, p.dark])
              .createShader(rect));
    final glyph = {
      'rocket': '🚀',
      'freeze': '❄',
      'portal': '🌀',
      'tornado': '🌪',
    }[key]!;
    final tp = TextPainter(
      text: TextSpan(text: glyph, style: TextStyle(fontSize: 0.55 * s)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant LudoBoardPainter old) => true;
}
