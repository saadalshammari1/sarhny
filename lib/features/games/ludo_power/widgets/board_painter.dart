import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../logic/ludo_game.dart';
import '../theme/cosmetics.dart';
import '../theme/ludo_theme.dart';

/// يرسم اللوحة الثابتة (بدون القطع — القطع widgets منفصلة فوقها).
class BoardPainter extends CustomPainter {
  final LudoGame game;
  final SkinPalette palette;
  BoardPainter(this.game, {PowerSkin skin = PowerSkin.royal}) : palette = SkinPalette.of(skin);

  static const colorKeys = BoardScheme.playerColors;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 15.0;
    final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(s * 0.6));

    // Clean light play surface (skin-tinted).
    canvas.drawRRect(rrect, Paint()..color = palette.surface);

    // البيوت في الزوايا
    final yardRects = [
      [0, 0, 0], [9, 0, 1], [9, 9, 2], [0, 9, 3],
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
      final inner = Rect.fromLTWH((yr[0] + 0.7) * s, (yr[1] + 0.7) * s, 4.6 * s, 4.6 * s);
      canvas.drawRRect(RRect.fromRectAndRadius(inner, Radius.circular(s * 0.4)),
          Paint()..color = palette.homeInner);
      canvas.drawRRect(RRect.fromRectAndRadius(inner, Radius.circular(s * 0.4)),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = c.dark.withValues(alpha: 0.4));
      for (final sp in kYard[yr[2]]) {
        canvas.drawCircle(Offset(sp[0] * s, sp[1] * s), 0.5 * s,
            Paint()..color = c.base.withValues(alpha: 0.4));
        canvas.drawCircle(Offset(sp[0] * s, sp[1] * s), 0.5 * s,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5
              ..color = c.light);
      }
    }

    // خانات المسار — نظيفة بلون الطاولة
    final cellPaint = Paint()..color = palette.cell;
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = palette.line;
    for (final g in kPath) {
      _cell(canvas, g[0], g[1], s, cellPaint, edgePaint);
    }
    // خانات الانطلاق بلون اللاعب
    for (int p = 0; p < 4; p++) {
      final g = kPath[kStart[p]];
      final c = ludoColors[colorKeys[p]]!;
      _cell(canvas, g[0], g[1], s, Paint()..color = c.base, edgePaint);
    }
    // ممرات البيوت
    for (int p = 0; p < 4; p++) {
      final c = ludoColors[colorKeys[p]]!;
      for (final g in kHome[p]) {
        _cell(canvas, g[0], g[1], s, Paint()..color = c.base, edgePaint);
      }
    }

    // النجوم على الخانات الآمنة
    for (final idx in kSafe) {
      final g = kPath[idx];
      Color starCol = palette.star;
      for (int p = 0; p < 4; p++) {
        if (kStart[p] == idx) starCol = ludoColors[colorKeys[p]]!.light;
      }
      _star(canvas, (g[0] + 0.5) * s, (g[1] + 0.5) * s, 0.3 * s, starCol);
    }

    // الخانات الخاصة
    game.specials.forEach((idx, sp) {
      final g = kPath[idx];
      _specialTile(canvas, (g[0] + 0.5) * s, (g[1] + 0.5) * s, s, sp.type);
    });

    // المركز: 4 مثلثات ملوّنة
    final tris = <Map<String, dynamic>>[
      {'pts': [[6.0, 6.0], [7.5, 7.5], [9.0, 6.0]], 'ci': 0},
      {'pts': [[9.0, 6.0], [7.5, 7.5], [9.0, 9.0]], 'ci': 1},
      {'pts': [[6.0, 9.0], [7.5, 7.5], [9.0, 9.0]], 'ci': 2},
      {'pts': [[6.0, 6.0], [7.5, 7.5], [6.0, 9.0]], 'ci': 3},
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
    c.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(s * 0.2)),
        Paint()..shader = RadialGradient(colors: [p.light, p.base, p.dark]).createShader(rect));
    final glyph = {'rocket': '🚀', 'freeze': '❄', 'portal': '🌀', 'tornado': '🌪'}[key]!;
    final tp = TextPainter(
      text: TextSpan(text: glyph, style: TextStyle(fontSize: 0.55 * s)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant BoardPainter old) => true;
}
