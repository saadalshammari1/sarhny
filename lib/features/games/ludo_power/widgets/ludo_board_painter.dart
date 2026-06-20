import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../engine/ludo_engine.dart';
import '../theme/ludo_theme.dart';

/// Classic-Ludo board painter. Renders:
///   • 4 corner yards with deep inset wells and 4 "parking spots" each
///   • A clean white track with crisp dividing lines (the canonical
///     cross-pattern that defines Ludo visually)
///   • Coloured launch arrows out of each yard
///   • The 6 home-stretch lanes converging on a 4-triangle centre
///   • Subtle gold safe-stars and power-tile glyphs
///
/// Designed to read like a premium board you'd unfold on a table, not a
/// procedurally-generated grid. All measurements derive from `cell = w/15`
/// so the layout scales perfectly to any board size.
class LudoBoardPainter extends CustomPainter {
  final LudoEngine engine;
  LudoBoardPainter(this.engine);

  static const colorKeys = BoardScheme.playerColors;

  // Track surface: warm parchment/ivory rather than gunmetal — closer to
  // a printed board, much higher contrast against the gold frame.
  static const Color _trackBase = Color(0xFFF7EFDA);
  static const Color _trackLine = Color(0xFF1B140A);
  static const Color _yardWell = Color(0xFF12090A);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 15.0;

    // Outer base: ivory parchment for the whole board.
    final outer = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(s * 0.6));
    canvas.drawRRect(outer, Paint()..color = _trackBase);

    _drawYards(canvas, s);
    _drawTrack(canvas, s);
    _drawLaunchArrows(canvas, s);
    _drawHomeStretches(canvas, s);
    _drawCentre(canvas, s);
    _drawSafeStars(canvas, s);
    _drawPowerTiles(canvas, s);
  }

  // ─── Yards ────────────────────────────────────────────────────────────
  void _drawYards(Canvas canvas, double s) {
    final yardSpecs = [
      [0, 0, 0], [9, 0, 1], [9, 9, 2], [0, 9, 3],
    ];
    for (final ys in yardSpecs) {
      final c = ludoColors[colorKeys[ys[2]]]!;
      final rect = Rect.fromLTWH(ys[0] * s, ys[1] * s, 6 * s, 6 * s);
      // Outer colored quadrant with a subtle gradient.
      canvas.drawRect(
          rect,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [c.light, c.base, c.dark],
            ).createShader(rect));
      // Inner dark well — the "parking lot" frame.
      final wellPad = 0.85;
      final well = Rect.fromLTWH((ys[0] + wellPad) * s,
          (ys[1] + wellPad) * s, (6 - 2 * wellPad) * s, (6 - 2 * wellPad) * s);
      canvas.drawRRect(
          RRect.fromRectAndRadius(well, Radius.circular(s * 0.35)),
          Paint()..color = _yardWell);
      // 4 parking spots (where home pieces sit).
      for (final sp in kYard[ys[2]]) {
        final centre = Offset(sp[0] * s, sp[1] * s);
        // Outer ring (yard color).
        canvas.drawCircle(centre, 0.55 * s, Paint()..color = c.base);
        // Inner depression for the pawn.
        canvas.drawCircle(centre, 0.42 * s, Paint()..color = c.deep);
        // Highlight rim.
        canvas.drawCircle(
            centre,
            0.55 * s,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4
              ..color = c.light);
      }
    }
  }

  // ─── Track (the cross) ────────────────────────────────────────────────
  void _drawTrack(Canvas canvas, double s) {
    // Cross-shape: vertical 3×15 + horizontal 15×3 intersecting in the
    // middle. Draw all 52 path cells as parchment squares with a thin
    // black border for the canonical Ludo look.
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = _trackLine;
    for (final g in kPath) {
      final r = Rect.fromLTWH(g[0] * s, g[1] * s, s, s);
      canvas.drawRect(r, Paint()..color = _trackBase);
      canvas.drawRect(r, line);
    }
    // Player launch cells are painted in their colour so spawn points
    // read immediately.
    for (int p = 0; p < 4; p++) {
      final g = kPath[kStart[p]];
      final c = ludoColors[colorKeys[p]]!;
      final r = Rect.fromLTWH(g[0] * s, g[1] * s, s, s);
      canvas.drawRect(r, Paint()..color = c.base);
      canvas.drawRect(r, line);
    }
  }

  void _drawLaunchArrows(Canvas canvas, double s) {
    // Small arrow inside each launch cell pointing in the direction the
    // pawn travels. Gives the board its "this is where you go" cue.
    final arrowSpecs = [
      [kStart[0], Offset(0.5, 0.0)],   // yellow → right
      [kStart[1], Offset(0.0, 0.5)],   // blue → down
      [kStart[2], Offset(-0.5, 0.0)],  // purple → left
      [kStart[3], Offset(0.0, -0.5)],  // green → up
    ];
    for (final spec in arrowSpecs) {
      final idx = spec[0] as int;
      final dir = spec[1] as Offset;
      final g = kPath[idx];
      final cx = (g[0] + 0.5) * s;
      final cy = (g[1] + 0.5) * s;
      _drawArrowGlyph(canvas, cx, cy, dir, 0.25 * s);
    }
  }

  void _drawArrowGlyph(Canvas c, double cx, double cy, Offset dir, double size) {
    final tip = Offset(cx + dir.dx * size, cy + dir.dy * size);
    final back = Offset(cx - dir.dx * size * 0.6, cy - dir.dy * size * 0.6);
    final perp = Offset(-dir.dy, dir.dx) * (size * 0.55);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(back.dx + perp.dx, back.dy + perp.dy)
      ..lineTo(back.dx - perp.dx, back.dy - perp.dy)
      ..close();
    c.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.92)
          ..style = PaintingStyle.fill);
    c.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF1B140A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);
  }

  // ─── Home stretches ───────────────────────────────────────────────────
  void _drawHomeStretches(Canvas canvas, double s) {
    // 6 lanes from each yard converging on the centre. These are the
    // "final approach" — paint them in solid player colour so the
    // stretch is immediately readable.
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = _trackLine.withValues(alpha: 0.55);
    for (int p = 0; p < 4; p++) {
      final c = ludoColors[colorKeys[p]]!;
      for (int k = 0; k < kHome[p].length; k++) {
        final g = kHome[p][k];
        final rect = Rect.fromLTWH(g[0] * s, g[1] * s, s, s);
        // Gradient from light → base so the last cell (centre-adjacent)
        // is the brightest — guides the eye to the goal.
        final t = k / (kHome[p].length - 1);
        canvas.drawRect(
            rect,
            Paint()..color = Color.lerp(c.base, c.light, t * 0.55)!);
        canvas.drawRect(rect, line);
      }
    }
  }

  // ─── Centre (4-triangle goal) ─────────────────────────────────────────
  void _drawCentre(Canvas canvas, double s) {
    // Background medallion behind the triangles for premium feel.
    final centre = Offset(7.5 * s, 7.5 * s);
    canvas.drawCircle(
        centre,
        2.2 * s,
        Paint()
          ..shader = RadialGradient(
            colors: [
              RoyalTheme.goldAccent,
              const Color(0xFF8A6624),
              const Color(0xFF4A330F),
            ],
            stops: const [0, 0.5, 1],
          ).createShader(
              Rect.fromCircle(center: centre, radius: 2.2 * s)));
    canvas.drawCircle(
        centre,
        2.2 * s,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF2A1B05));

    // 4 colored triangles — the iconic Ludo "X" pattern at the centre.
    final tris = [
      [Offset(6, 6), Offset(7.5, 7.5), Offset(9, 6), 0],
      [Offset(9, 6), Offset(7.5, 7.5), Offset(9, 9), 1],
      [Offset(6, 9), Offset(7.5, 7.5), Offset(9, 9), 2],
      [Offset(6, 6), Offset(7.5, 7.5), Offset(6, 9), 3],
    ];
    for (final t in tris) {
      final a = t[0] as Offset, b = t[1] as Offset, d = t[2] as Offset;
      final ci = t[3] as int;
      final c = ludoColors[colorKeys[ci]]!;
      final path = Path()
        ..moveTo(a.dx * s, a.dy * s)
        ..lineTo(b.dx * s, b.dy * s)
        ..lineTo(d.dx * s, d.dy * s)
        ..close();
      canvas.drawPath(
          path,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [c.light, c.base, c.dark],
            ).createShader(Rect.fromLTWH(
                (a.dx < d.dx ? a.dx : d.dx) * s,
                (a.dy < d.dy ? a.dy : d.dy) * s,
                3 * s,
                3 * s)));
      canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..color = const Color(0xFF12080A));
    }
    // Crown glyph in the centre — the "victory" marker.
    final tp = TextPainter(
      text: TextSpan(
        text: '♛',
        style: TextStyle(
            fontSize: s * 1.0,
            color: Colors.white.withValues(alpha: 0.95)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(centre.dx - tp.width / 2, centre.dy - tp.height / 2));
  }

  // ─── Safe stars ───────────────────────────────────────────────────────
  void _drawSafeStars(Canvas canvas, double s) {
    for (final idx in kSafe) {
      // Skip stars on launch cells — they already carry their colour.
      if (kStart.contains(idx)) continue;
      final g = kPath[idx];
      _star(canvas, (g[0] + 0.5) * s, (g[1] + 0.5) * s, 0.32 * s,
          const Color(0xFFB88A2A));
    }
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
    c.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = const Color(0xFF5C3D0E));
  }

  // ─── Power tiles ──────────────────────────────────────────────────────
  void _drawPowerTiles(Canvas canvas, double s) {
    engine.specials.forEach((idx, sp) {
      final g = kPath[idx];
      _specialTile(canvas, (g[0] + 0.5) * s, (g[1] + 0.5) * s, s, sp.type);
    });
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
    // Soft glow halo.
    c.drawCircle(
        Offset(cx, cy),
        r * 1.15,
        Paint()
          ..color = p.glow.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    // Tile body.
    c.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(s * 0.22)),
        Paint()
          ..shader = RadialGradient(colors: [p.light, p.base, p.dark])
              .createShader(rect));
    c.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(s * 0.22)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = const Color(0xFF12080A));
    // Glyph.
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
