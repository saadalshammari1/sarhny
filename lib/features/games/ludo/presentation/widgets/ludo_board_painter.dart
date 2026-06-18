import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/ludo_token.dart';
import 'ludo_board_geometry.dart';

/// CustomPainter للوحة لودو 15×15 بتصميم فاخر.
///
/// طبقات:
/// 1. خلفية radial glow في المنتصف.
/// 2. 4 home bases في الزوايا — gold frame + inner color tile.
/// 3. 52 outer-track cells + 4 entry cells ملوّنة + 8 safe stars.
/// 4. 4 home stretches (5 cells each, gradient).
/// 5. مثلث المركز (4 مثلثات + crown).
/// 6. depth shadow عام.
class LudoBoardPainter extends CustomPainter {
  LudoBoardPainter({
    required this.highlightSeat,
    this.brightness = Brightness.dark,
  });

  /// 0..3 = اللاعب الذي عليه الدور (لإضاءة home base قليلاً).
  final int highlightSeat;
  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    final boardSide = math.min(size.width, size.height);
    final cellSide = boardSide / LudoBoardGeometry.gridSize;
    final origin = Offset(
      (size.width - boardSide) / 2,
      (size.height - boardSide) / 2,
    );

    _paintBackground(canvas, origin, boardSide);
    _paintHomeBases(canvas, origin, cellSide);
    _paintOuterTrack(canvas, origin, cellSide);
    _paintHomeStretches(canvas, origin, cellSide);
    _paintCenterTriangle(canvas, origin, cellSide);
    _paintSafeStars(canvas, origin, cellSide);
  }

  // ────────── Background ──────────
  void _paintBackground(Canvas canvas, Offset origin, double side) {
    final rect = origin & Size(side, side);

    final bg = Paint()
      ..shader = RadialGradient(
        colors: brightness == Brightness.dark
            ? const [
                Color(0xFF1A1F2E),
                Color(0xFF0B0D14),
                Color(0xFF050709),
              ]
            : const [
                Color(0xFFFAF6EC),
                Color(0xFFEEE7D2),
                Color(0xFFE0D8BE),
              ],
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      bg,
    );

    // central glow halo
    final halo = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: brightness == Brightness.dark ? 0.04 : 0.18),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, halo);

    // gold frame
    final frame = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(1.1), const Radius.circular(10)),
      frame,
    );
  }

  // ────────── Home bases ──────────
  void _paintHomeBases(Canvas canvas, Offset origin, double cs) {
    final colors = LudoColor.values;
    for (int seat = 0; seat < 4; seat++) {
      final color = colors[seat];
      final c = LudoBoardGeometry.homeBaseCenter(color);
      final rect = Rect.fromCenter(
        center: Offset(origin.dx + (c.$1 + 0.5) * cs, origin.dy + (c.$2 + 0.5) * cs),
        width: cs * 6,
        height: cs * 6,
      );

      // outer tinted background
      final bg = Paint()
        ..color = color.primary.withValues(alpha: 0.18);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        bg,
      );

      // gold inner frame
      final frame = Paint()
        ..color = const Color(0xFFD4AF37).withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(6)),
        frame,
      );

      // inner 4-slot circle wells
      final wellSize = cs * 0.85;
      final slots = LudoBoardGeometry.homeBaseSlots(color);
      for (final s in slots) {
        final p = Offset(origin.dx + s.dx * cs * LudoBoardGeometry.gridSize,
            origin.dy + s.dy * cs * LudoBoardGeometry.gridSize);
        // well shadow
        canvas.drawCircle(
          p.translate(1, 1.5),
          wellSize / 2,
          Paint()..color = Colors.black.withValues(alpha: 0.35),
        );
        // well
        canvas.drawCircle(
          p,
          wellSize / 2,
          Paint()..color = color.dark.withValues(alpha: 0.95),
        );
        // highlight rim
        canvas.drawCircle(
          p,
          wellSize / 2,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.18)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      }

      // active glow pulse (subtle ring) when it's this seat's turn
      if (seat == highlightSeat) {
        final glow = Paint()
          ..color = color.primary.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(1.4), const Radius.circular(9)),
          glow,
        );
      }
    }
  }

  // ────────── Outer Track ──────────
  void _paintOuterTrack(Canvas canvas, Offset origin, double cs) {
    final base = brightness == Brightness.dark
        ? const Color(0xFFEDE6D2)
        : const Color(0xFFFFFAEB);
    final stroke = Paint()
      ..color = Colors.black.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (int i = 0; i < LudoBoardGeometry.trackCells.length; i++) {
      final c = LudoBoardGeometry.trackCells[i];
      final rect = Rect.fromLTWH(
        origin.dx + c.$1 * cs,
        origin.dy + c.$2 * cs,
        cs,
        cs,
      );
      Color fill = base;
      // colored entry cells per player
      if (i == 0) fill = LudoColor.red.primary.withValues(alpha: 0.85);
      if (i == 13) fill = LudoColor.green.primary.withValues(alpha: 0.85);
      if (i == 26) fill = LudoColor.yellow.primary.withValues(alpha: 0.85);
      if (i == 39) fill = LudoColor.blue.primary.withValues(alpha: 0.85);

      canvas.drawRect(rect.deflate(0.6), Paint()..color = fill);
      canvas.drawRect(rect.deflate(0.6), stroke);
    }
  }

  // ────────── Home Stretches ──────────
  void _paintHomeStretches(Canvas canvas, Offset origin, double cs) {
    for (final color in LudoColor.values) {
      final cells = LudoBoardGeometry.homeStretchCells(color);
      for (int i = 0; i < cells.length; i++) {
        final c = cells[i];
        final rect = Rect.fromLTWH(
          origin.dx + c.$1 * cs,
          origin.dy + c.$2 * cs,
          cs,
          cs,
        );
        final t = i / (cells.length - 1);
        final fill = Color.lerp(color.light, color.primary, t)!;
        canvas.drawRect(rect.deflate(0.6), Paint()..color = fill);
        canvas.drawRect(
          rect.deflate(0.6),
          Paint()
            ..color = Colors.black.withValues(alpha: 0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8,
        );
      }
    }
  }

  // ────────── Center triangle ──────────
  void _paintCenterTriangle(Canvas canvas, Offset origin, double cs) {
    // central 3×3 box.
    final left = origin.dx + 6 * cs;
    final top = origin.dy + 6 * cs;
    final size = 3 * cs;
    final center = Offset(left + size / 2, top + size / 2);

    final corners = [
      Offset(left, top),
      Offset(left + size, top),
      Offset(left + size, top + size),
      Offset(left, top + size),
    ];

    // 4 triangles converging to center
    final mapping = [
      (LudoColor.red, [corners[0], corners[3], center]),
      (LudoColor.green, [corners[0], corners[1], center]),
      (LudoColor.yellow, [corners[1], corners[2], center]),
      (LudoColor.blue, [corners[2], corners[3], center]),
    ];

    for (final m in mapping) {
      final color = m.$1;
      final pts = m.$2;
      final path = Path()
        ..moveTo(pts[0].dx, pts[0].dy)
        ..lineTo(pts[1].dx, pts[1].dy)
        ..lineTo(pts[2].dx, pts[2].dy)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            colors: [color.primary, color.dark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromPoints(pts[0], pts[1])),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }

    // crown badge at center
    final crownBg = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFE082),
          const Color(0xFFD4AF37),
          const Color(0xFF8C6E16),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: cs * 0.55));
    canvas.drawCircle(center, cs * 0.55, crownBg);
    canvas.drawCircle(
      center,
      cs * 0.55,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // crown glyph
    final tp = TextPainter(
      text: TextSpan(
        text: '♛',
        style: TextStyle(
          fontSize: cs * 0.9,
          color: Colors.black.withValues(alpha: 0.78),
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  // ────────── Safe stars (★) ──────────
  void _paintSafeStars(Canvas canvas, Offset origin, double cs) {
    for (final i in LudoBoardGeometry.safeTrackIndices) {
      if (i == 0 || i == 13 || i == 26 || i == 39) continue; // entry already colored
      final c = LudoBoardGeometry.trackCells[i];
      final center = Offset(
        origin.dx + (c.$1 + 0.5) * cs,
        origin.dy + (c.$2 + 0.5) * cs,
      );
      // small gold star
      _drawStar(canvas, center, cs * 0.32, const Color(0xFFD4AF37));
    }
  }

  void _drawStar(Canvas canvas, Offset center, double r, Color color) {
    final path = Path();
    const points = 5;
    for (int i = 0; i < points * 2; i++) {
      final isOuter = i.isEven;
      final radius = isOuter ? r : r * 0.45;
      final angle = -math.pi / 2 + i * math.pi / points;
      final p = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  @override
  bool shouldRepaint(covariant LudoBoardPainter old) =>
      old.highlightSeat != highlightSeat || old.brightness != brightness;
}
