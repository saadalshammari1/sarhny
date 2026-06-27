import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../domain/cosmetics.dart';
import '../engine/carrom_engine.dart';
import '../engine/disc.dart';
import '../engine/table_geometry.dart';
import '../engine/vec2.dart';

/// The live carrom board: drives the engine via a [Ticker], renders the
/// themed table + skinned discs with a [CustomPainter], and owns the
/// drag-to-aim gesture. Striker placement is handled separately (a track
/// under the board) so aiming is never ambiguous.
class Carrom3BoardView extends StatefulWidget {
  const Carrom3BoardView({
    super.key,
    required this.engine,
    required this.theme,
    required this.coinSet,
    required this.aimEnabled,
    required this.onSettled,
    required this.onFire,
    this.flip = false,
  });

  final CarromEngine engine;
  final TableTheme theme;
  final CoinSet coinSet;
  final bool aimEnabled;
  final void Function(ShotOutcome) onSettled;

  /// Fired on release with the shot direction (in ENGINE/absolute coords) +
  /// power [0..1]. The page sets the shooter and forwards to the engine.
  final void Function(Vec2 direction, double power) onFire;

  /// Render the board rotated 180° (for the online seat B, so the local
  /// player always appears at the bottom). Input + aim are converted to
  /// engine coords accordingly.
  final bool flip;

  @override
  State<Carrom3BoardView> createState() => _Carrom3BoardViewState();
}

class _Carrom3BoardViewState extends State<Carrom3BoardView>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ValueNotifier<int> _frame = ValueNotifier(0);
  Duration _last = Duration.zero;
  double _t = 0; // accumulated time, drives the idle pulse

  // Aim state (widget-local pixels).
  Offset? _start;
  Offset? _current;
  bool _aiming = false;
  double _pxSize = 1;

  static const double _minPower = 0.06;
  double get _maxPull => 0.42 * _pxSize; // long pull → fine power control

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    var dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (dt > 0) {
      // Clamp (never skip) so a slow/throttled frame still advances the sim
      // instead of leaving it stuck mid-shot. The engine sub-steps internally.
      if (dt > 1 / 30) dt = 1 / 30;
      _t += dt;
      final out = widget.engine.update(dt);
      if (out != null) widget.onSettled(out);
    }
    // Repaint every frame while the board is "live" (pieces moving or the user
    // is aiming). When fully idle, throttle to ~20fps for the subtle striker
    // pulse — repainting the whole table (gradients, blurred coins, pockets)
    // at 60fps while nothing moves is a needless GPU/battery drain.
    final live = widget.engine.phase == EnginePhase.simulating || _aiming;
    _idleSkip = (_idleSkip + 1) % 3;
    if (live || _idleSkip == 0) _frame.value++;
  }

  int _idleSkip = 0;

  // ── Aim gesture ─────────────────────────────────────────────────────────

  bool get _canAim =>
      widget.aimEnabled && widget.engine.phase == EnginePhase.idle;

  void _onPanStart(DragStartDetails d) {
    if (!_canAim) return;
    _start = d.localPosition;
    _current = d.localPosition;
    _aiming = true;
    setState(() {}); // rebuild so the painter receives the live aim state
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (!_aiming) return;
    _current = d.localPosition;
    setState(() {}); // critical: without this the aim line never updates
  }

  void _onPanEnd(DragEndDetails _) {
    if (!_aiming) return;
    final power = _power();
    if (_canAim && power >= _minPower) {
      final pull = _current! - _start!;
      // Slingshot: flick FORWARD (opposite the pull). When the board is
      // flipped (seat B), screen↔engine axes are negated, so the engine-space
      // direction is +pull instead of -pull.
      final dir = widget.flip
          ? Vec2(pull.dx, pull.dy)
          : Vec2(-pull.dx, -pull.dy);
      widget.onFire(dir, power);
    }
    _start = null;
    _current = null;
    _aiming = false;
    setState(() {});
  }

  double _power() {
    if (_start == null || _current == null) return 0;
    final pull = _current! - _start!;
    return (pull.distance / _maxPull).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        _pxSize = c.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: CustomPaint(
            size: Size.square(_pxSize),
            painter: _BoardPainter(
              engine: widget.engine,
              theme: widget.theme,
              coinSet: widget.coinSet,
              aiming: _aiming,
              aimEnabled: _canAim,
              flip: widget.flip,
              pulse: (math.sin(_t * 3.5) + 1) / 2,
              power: _power(),
              pullDir: _aiming && _start != null && _current != null
                  ? (_current! - _start!)
                  : null,
              repaint: _frame,
            ),
          ),
        );
      },
    );
  }
}

class _BoardPainter extends CustomPainter {
  _BoardPainter({
    required this.engine,
    required this.theme,
    required this.coinSet,
    required this.aiming,
    required this.aimEnabled,
    required this.flip,
    required this.pulse,
    required this.power,
    required this.pullDir,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final CarromEngine engine;
  final TableTheme theme;
  final CoinSet coinSet;
  final bool aiming;
  final bool aimEnabled;
  final bool flip;
  final double pulse;
  final double power;
  final Offset? pullDir;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / TableGeometry.size;
    canvas.save();
    canvas.scale(scale);
    if (flip) {
      // Rotate the whole board 180° (seat B sees itself at the bottom).
      canvas.translate(TableGeometry.size, TableGeometry.size);
      canvas.scale(-1, -1);
    }
    _drawTable(canvas);
    _drawDiscs(canvas);
    if (aiming) {
      _drawAim(canvas);
    } else if (aimEnabled) {
      _drawIdleIndicator(canvas);
    }
    canvas.restore();
  }

  /// Persistent striker indicator shown whenever it's the player's turn — a
  /// pulsing ring + "pull back" chevrons, so the striker and how to aim are
  /// always obvious even before touching the board.
  void _drawIdleIndicator(Canvas canvas) {
    final s = engine.striker;
    if (s.potted) return;
    final c = Offset(s.pos.x, s.pos.y);
    const gold = Color(0xFFFFD75A);

    // Default aim guide pointing toward the centre pack (engine coords), so the
    // line from the striker to the coin is ALWAYS visible before dragging.
    _paintGuide(
        canvas, flip ? Vec2(0, 1) : Vec2(0, -1), gold, 360, 0.5 + 0.18 * pulse);

    // Pulsing halo + baseline track.
    canvas.drawCircle(
      c,
      s.radius + 6 + 5 * pulse,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = gold.withValues(alpha: 0.4 + 0.4 * pulse),
    );
    canvas.drawLine(
      Offset(TableGeometry.strikerMinX, s.pos.y),
      Offset(TableGeometry.strikerMaxX, s.pos.y),
      Paint()
        ..color = gold.withValues(alpha: 0.18 + 0.12 * pulse)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  /// Shared aim-trajectory renderer (solid first segment → dashed reflections →
  /// ghost ball + target-coin highlight + push arrow). Used dim as the default
  /// idle guide and at full strength while aiming.
  void _paintGuide(
      Canvas canvas, Vec2 dir, Color color, double maxLen, double alpha) {
    final s = engine.striker;
    final d = dir.normalized;
    if (d.length2 < 1e-6) return;
    final pred = engine.predict(s.pos, d, maxLen: maxLen);
    const yellow = Color(0xFFFFD75A);

    if (pred.points.length >= 2) {
      final a = Offset(pred.points[0].x, pred.points[0].y);
      final b = Offset(pred.points[1].x, pred.points[1].y);
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = color.withValues(alpha: alpha * 0.3)
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = color.withValues(alpha: alpha)
          ..strokeWidth = 3.8
          ..strokeCap = StrokeCap.round,
      );
    }
    final dash = Paint()
      ..color = color.withValues(alpha: alpha * 0.85)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 1; i < pred.points.length - 1; i++) {
      final a = Offset(pred.points[i].x, pred.points[i].y);
      final b = Offset(pred.points[i + 1].x, pred.points[i + 1].y);
      canvas.drawCircle(
          a, 3.6, Paint()..color = yellow.withValues(alpha: alpha));
      _dash(canvas, a, b, dash);
    }

    final hc = pred.hitPieceCentre;
    final sa = pred.strikerAtHit;
    if (hc != null && sa != null) {
      final g = Offset(sa.x, sa.y);
      canvas.drawCircle(g, TableGeometry.strikerRadius,
          Paint()..color = Colors.white.withValues(alpha: 0.2 * alpha));
      canvas.drawCircle(
        g,
        TableGeometry.strikerRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withValues(alpha: 0.9 * alpha),
      );
      canvas.drawCircle(
        Offset(hc.x, hc.y),
        TableGeometry.coinRadius + 3,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..color = yellow.withValues(alpha: alpha),
      );
      final push = Vec2(hc.x - sa.x, hc.y - sa.y).normalized;
      final from = Offset(hc.x, hc.y);
      final to = from + Offset(push.x, push.y) * (TableGeometry.coinRadius * 2.6);
      final ap = Paint()
        ..color = yellow.withValues(alpha: alpha)
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(from, to, ap);
      final ang = math.atan2(push.y, push.x);
      for (final off in [2.6, -2.6]) {
        canvas.drawLine(
          to,
          to - Offset(math.cos(ang + off), math.sin(ang + off)) * 8,
          ap,
        );
      }
    }
  }

  // ── Table (themed) ──────────────────────────────────────────────────────

  void _drawTable(Canvas canvas) {
    const s = TableGeometry.size;
    final full = Rect.fromLTWH(0, 0, s, s);

    // Frame.
    canvas.drawRect(
      full,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.frameTop, theme.frameBottom],
        ).createShader(full),
    );
    // Bevel highlight on the frame edge (premium turned-wood look).
    canvas.drawRect(
      full.deflate(7),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = theme.frameBevel,
    );
    canvas.drawRect(
      full.deflate(TableGeometry.frame - 3),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0x55000000),
    );

    // Felt play area.
    final play = Rect.fromLTRB(
      TableGeometry.playMin,
      TableGeometry.playMin,
      TableGeometry.playMax,
      TableGeometry.playMax,
    );
    final playR = RRect.fromRectAndRadius(play, const Radius.circular(16));
    canvas.drawRRect(
      playR,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.15, -0.2),
          radius: 0.95,
          colors: [theme.feltCenter, theme.feltMid, theme.feltEdge],
          stops: const [0.0, 0.62, 1.0],
        ).createShader(play),
    );

    // Grain striations.
    canvas.save();
    canvas.clipRRect(playR);
    final grain = Paint()
      ..color = const Color(0x0E000000)
      ..strokeWidth = 0.7;
    for (var y = TableGeometry.playMin; y <= TableGeometry.playMax; y += 14) {
      final w = 3 * math.sin(y * 0.5);
      canvas.drawLine(Offset(TableGeometry.playMin, y + w),
          Offset(TableGeometry.playMax, y - w), grain);
    }
    canvas.restore();

    // Soft sheen highlight (top-left) — gives the felt a polished look.
    canvas.drawRRect(
      playR,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.5, -0.6),
          radius: 0.8,
          colors: [Color(0x24FFFFFF), Color(0x00FFFFFF)],
        ).createShader(play),
    );

    // Edge vignette.
    canvas.drawRRect(
      playR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = TableGeometry.frame * 0.8
        ..color = const Color(0x3A000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Border line.
    final border = play.deflate(22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(border, const Radius.circular(12)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = theme.lineSoft,
    );

    // Corner service rings + arrows.
    for (final c in TableGeometry.pockets()) {
      final inX = c.x < TableGeometry.half ? 1.0 : -1.0;
      final inY = c.y < TableGeometry.half ? 1.0 : -1.0;
      final rc = Offset(c.x + inX * 62, c.y + inY * 62);
      canvas.drawCircle(
        rc,
        30,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = theme.lineSoft,
      );
      canvas.drawLine(
        Offset(rc.dx + inX * 42, rc.dy + inY * 42),
        Offset(rc.dx + inX * 100, rc.dy + inY * 100),
        Paint()
          ..color = theme.lineSoft
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }

    _drawRosette(canvas);

    for (final c in TableGeometry.pockets()) {
      _drawPocket(canvas, Offset(c.x, c.y));
    }

    _drawBaseline(canvas, TableGeometry.baselineY(Seat.you));
    _drawBaseline(canvas, TableGeometry.baselineY(Seat.opponent));
  }

  void _drawRosette(Canvas canvas) {
    final center = Offset(TableGeometry.playCenter, TableGeometry.playCenter);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = theme.lineSoft;
    canvas.drawCircle(center, TableGeometry.coinRadius * 1.9, ring);
    canvas.drawCircle(center, TableGeometry.coinRadius * 1.45, ring);

    final star = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = theme.lineSoft;
    final rO = TableGeometry.coinRadius * 1.9;
    final rI = TableGeometry.coinRadius * 1.1;
    final path = Path();
    for (var i = 0; i < 16; i++) {
      final r = i.isEven ? rO : rI;
      final a = (math.pi / 8) * i - math.pi / 2;
      final p = Offset(center.dx + r * math.cos(a), center.dy + r * math.sin(a));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, star);
    canvas.drawCircle(center, 5, Paint()..color = theme.line);
  }

  void _drawPocket(Canvas canvas, Offset c) {
    canvas.drawCircle(
      c,
      TableGeometry.pocketVisualRadius * 1.18,
      Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    final hole =
        Rect.fromCircle(center: c, radius: TableGeometry.pocketVisualRadius);
    canvas.drawCircle(
      c,
      TableGeometry.pocketVisualRadius,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF000000), Color(0xFF160B03)],
        ).createShader(hole),
    );
    canvas.drawCircle(
      c,
      TableGeometry.pocketVisualRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..shader = SweepGradient(
          colors: [
            theme.pocketRimA,
            theme.pocketRimB,
            theme.pocketRimA,
            theme.pocketRimB,
            theme.pocketRimA,
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        ).createShader(hole),
    );
    // Brass-rim specular glint (top-left).
    canvas.drawCircle(
      c + const Offset(-9, -9),
      4,
      Paint()..color = const Color(0x66FFFFFF),
    );
  }

  void _drawBaseline(Canvas canvas, double y) {
    final paint = Paint()
      ..color = theme.lineSoft
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    const off = 16.0;
    canvas.drawLine(Offset(TableGeometry.strikerMinX, y - off),
        Offset(TableGeometry.strikerMaxX, y - off), paint);
    canvas.drawLine(Offset(TableGeometry.strikerMinX, y + off),
        Offset(TableGeometry.strikerMaxX, y + off), paint);
    for (final sx in [TableGeometry.strikerMinX, TableGeometry.strikerMaxX]) {
      canvas.drawCircle(
        Offset(sx, y),
        off,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = theme.lineSoft,
      );
    }
  }

  // ── Discs ───────────────────────────────────────────────────────────────

  void _drawDiscs(Canvas canvas) {
    for (final p in engine.pieces) {
      if (p.potted && p.sink <= 0) continue;
      _drawCoin(canvas, p);
    }
    final s = engine.striker;
    if (!(s.potted && s.sink <= 0)) _drawStriker(canvas, s);
  }

  void _drawCoin(Canvas canvas, Disc d) {
    final r = d.radius * d.sink;
    final m = coinSet.materialFor(d.kind);
    final ctr = Offset(d.pos.x, d.pos.y);

    canvas.drawCircle(
      ctr + Offset(r * 0.16, r * 0.20),
      r * 0.98,
      Paint()
        ..color = const Color(0x44000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.18),
    );
    final rect = Rect.fromCircle(center: ctr, radius: r);
    canvas.drawCircle(
      ctr,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 1.05,
          colors: [m.highlight, m.base, m.edge],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect),
    );
    canvas.drawCircle(
      ctr,
      r * 0.965,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.07
        ..color = m.rim,
    );
    // Bevel rim-light along the top-left — reads as a polished raised edge.
    canvas.drawArc(
      Rect.fromCircle(center: ctr, radius: r * 0.92),
      -2.5,
      1.9,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.07
        ..strokeCap = StrokeCap.round
        ..color = m.highlight.withValues(alpha: 0.55),
    );
    canvas.drawCircle(
      ctr,
      r * 0.62,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.03
        ..color = m.engrave,
    );
    if (d.isQueen) {
      for (var i = 0; i < 3; i++) {
        canvas.drawCircle(
          ctr + Offset(0, (i - 1) * r * 0.26),
          r * 0.085,
          Paint()..color = const Color(0xFFFFE9C2),
        );
      }
    }
    canvas.drawCircle(
      ctr + Offset(-r * 0.34, -r * 0.40),
      r * 0.40,
      Paint()
        ..color = m.gloss
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.16),
    );
    canvas.drawCircle(ctr + Offset(-r * 0.42, -r * 0.46), r * 0.12,
        Paint()..color = const Color(0xCCFFFFFF));
  }

  void _drawStriker(Canvas canvas, Disc d) {
    final r = d.radius * d.sink;
    final m = coinSet.striker;
    final ctr = Offset(d.pos.x, d.pos.y);

    canvas.drawCircle(
      ctr + Offset(r * 0.16, r * 0.22),
      r,
      Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.20),
    );
    final rect = Rect.fromCircle(center: ctr, radius: r);
    canvas.drawCircle(
      ctr,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 1.05,
          colors: [m.highlight, m.base, m.edge, m.rim],
          stops: const [0.0, 0.42, 0.82, 1.0],
        ).createShader(rect),
    );
    canvas.drawCircle(
      ctr,
      r * 0.74,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.10
        ..shader = SweepGradient(
          colors: [
            theme.pocketRimA,
            theme.pocketRimB,
            theme.pocketRimA,
            theme.pocketRimB,
            theme.pocketRimA,
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        ).createShader(rect),
    );
    canvas.drawCircle(
      ctr,
      r * 0.97,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.06
        ..color = const Color(0xFF2A2521),
    );
    canvas.drawCircle(ctr, r * 0.13, Paint()..color = const Color(0xFFB8001F));
    canvas.drawCircle(
      ctr + Offset(-r * 0.36, -r * 0.42),
      r * 0.40,
      Paint()
        ..color = const Color(0x80FFFFFF)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.16),
    );
  }

  // ── Aim overlay ─────────────────────────────────────────────────────────

  void _drawAim(Canvas canvas) {
    final pull = pullDir;
    if (pull == null) return;
    final s = engine.striker;
    // Slingshot guide in ENGINE coords (negated again when the view is flipped).
    final dir =
        (flip ? Vec2(pull.dx, pull.dy) : Vec2(-pull.dx, -pull.dy)).normalized;
    if (dir.length2 < 1e-6) return;

    final color = power > 0.85
        ? const Color(0xFFE24B4A)
        : power > 0.5
            ? const Color(0xFFE6A23C)
            : const Color(0xFF6CC36A);
    final sc = Offset(s.pos.x, s.pos.y);

    canvas.drawCircle(
      sc,
      s.radius + 6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = color.withValues(alpha: 0.85),
    );

    // Pull-back handle (the "rubber band" you're stretching backward). It sits
    // opposite the aim, so it's obvious you pull back to launch forward.
    final back = Offset(sc.dx - dir.x * power * 95, sc.dy - dir.y * power * 95);
    canvas.drawLine(
      sc,
      back,
      Paint()
        ..color = color.withValues(alpha: 0.55)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
        back, s.radius * 0.5, Paint()..color = color.withValues(alpha: 0.5));

    _paintGuide(canvas, dir, color, 160 + power * 560, 1.0);
  }

  void _dash(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 10.0;
    const gap = 7.0;
    final total = (b - a).distance;
    if (total < 0.5) return;
    final dir = (b - a) / total;
    var t = 0.0;
    while (t < total) {
      final t2 = math.min(t + dash, total);
      canvas.drawLine(a + dir * t, a + dir * t2, paint);
      t = t2 + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _BoardPainter old) => true;
}
