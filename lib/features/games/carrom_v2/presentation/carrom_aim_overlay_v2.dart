import 'dart:math' as math;

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../world/board_dimensions.dart';
import '../world/carrom_world.dart';

/// Aim overlay V2 — drag-to-place, drag-to-aim, release-to-shoot.
///
/// Sits as a transparent Stack child above the Flame GameWidget. The widget
/// must be told the on-screen pixel size of the board (Pixels per metre)
/// so it can map gestures into the Box2D world space without doing a
/// round-trip through the camera.
///
/// State machine:
///   IDLE        → fingers off the board; striker glows on baseline.
///   PLACING     → finger down inside the baseline band; striker follows X.
///   AIMING      → finger has pulled away from the baseline by more than
///                 the trigger distance; shows slingshot lines + power bar.
///   COMMITTED   → release at power > minPower fires the shot. We then
///                 wait for the world's phase to leave WorldPhase.aiming.
class CarromAimOverlayV2 extends StatefulWidget {
  const CarromAimOverlayV2({
    super.key,
    required this.world,
    required this.boardPixelSize,
    required this.enabled,
  });

  /// The live Forge2D world.
  final CarromWorld world;

  /// On-screen square size of the board in physical pixels. The overlay
  /// uses this to convert finger positions in widget coords to world metres.
  final double boardPixelSize;

  /// Disabled when it's not the local player's turn or a shot is mid-flight.
  final bool enabled;

  @override
  State<CarromAimOverlayV2> createState() => _CarromAimOverlayV2State();
}

class _CarromAimOverlayV2State extends State<CarromAimOverlayV2>
    with SingleTickerProviderStateMixin {
  static const double _minPowerToFire = 0.06;
  static const double _maxPullPx = 140; // 100% power at this drag distance
  static const double _placementTriggerDistance = 0.25; // metres
  static const double _snapToleranceRad = 0.07; // ~4°
  static const List<double> _snapAngles = [
    0,
    math.pi / 4,
    math.pi / 2,
    3 * math.pi / 4,
    math.pi,
    -3 * math.pi / 4,
    -math.pi / 2,
    -math.pi / 4,
  ];

  late final AnimationController _pulse;

  Offset? _pointerStart;
  Offset? _pointerCurrent;
  _Stage _stage = _Stage.idle;
  bool _wasSnapped = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  // ── Coordinate conversions ────────────────────────────────────────

  /// Convert a widget-local pixel point into world metres centred at (0,0).
  Vector2 _pxToWorld(Offset px) {
    final s = widget.boardPixelSize;
    final mx = (px.dx / s - 0.5) * BoardDims.size;
    final my = (px.dy / s - 0.5) * BoardDims.size;
    return Vector2(mx, my);
  }

  /// Convert a world point back into widget-local pixels.
  Offset _worldToPx(Vector2 w) {
    final s = widget.boardPixelSize;
    final px = (w.x / BoardDims.size + 0.5) * s;
    final py = (w.y / BoardDims.size + 0.5) * s;
    return Offset(px, py);
  }

  // ── Gesture handlers ──────────────────────────────────────────────

  void _onPanStart(DragStartDetails d) {
    if (!widget.enabled || widget.world.phase != WorldPhase.aiming) return;
    final worldP = _pxToWorld(d.localPosition);
    final baseline = widget.world.mySeat == Seat.a
        ? BoardDims.playerABaselineY
        : BoardDims.playerBBaselineY;
    if ((worldP.y - baseline).abs() <= BoardDims.baselineSnapTolerance + 0.15) {
      _pointerStart = d.localPosition;
      _pointerCurrent = d.localPosition;
      _stage = _Stage.placing;
      _wasSnapped = false;
      HapticFeedback.selectionClick();
      setState(() {});
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (!widget.enabled || _stage == _Stage.idle) return;
    _pointerCurrent = d.localPosition;

    if (_stage == _Stage.placing) {
      // Move striker along baseline X.
      final worldP = _pxToWorld(d.localPosition);
      widget.world.placeStriker(worldP.x);

      // If the pull has moved off the baseline significantly, switch to aiming.
      final baseline = widget.world.mySeat == Seat.a
          ? BoardDims.playerABaselineY
          : BoardDims.playerBBaselineY;
      final dy = (worldP.y - baseline).abs();
      if (dy > _placementTriggerDistance) {
        _stage = _Stage.aiming;
        HapticFeedback.selectionClick();
      }
    }

    // Snap-angle haptic feedback (only fires on entry into snap zone).
    if (_stage == _Stage.aiming) {
      final ang = _currentAngle();
      final snapped = _isNearSnap(ang);
      if (snapped && !_wasSnapped) {
        HapticFeedback.lightImpact();
      }
      _wasSnapped = snapped;
    }

    setState(() {});
  }

  void _onPanEnd(DragEndDetails _) {
    if (!widget.enabled) {
      _resetGesture();
      return;
    }
    if (_stage == _Stage.aiming) {
      final power = _currentPower();
      if (power >= _minPowerToFire) {
        // Direction = away from pointer (slingshot release).
        final striker = widget.world.striker;
        if (striker != null) {
          final pull = _currentPullPixels();
          final shotDir = Vector2(-pull.dx, -pull.dy)..normalize();
          HapticFeedback.heavyImpact();
          widget.world.fireShot(direction: shotDir, power: power);
        }
      } else {
        HapticFeedback.selectionClick(); // cancelled silently
      }
    }
    _resetGesture();
  }

  void _onPanCancel() {
    _resetGesture();
  }

  void _resetGesture() {
    _pointerStart = null;
    _pointerCurrent = null;
    _stage = _Stage.idle;
    _wasSnapped = false;
    setState(() {});
  }

  // ── Aim math ──────────────────────────────────────────────────────

  /// Pull vector in widget-local pixels (start → current).
  Offset _currentPullPixels() {
    if (_pointerStart == null || _pointerCurrent == null) return Offset.zero;
    return _pointerCurrent! - _pointerStart!;
  }

  double _currentPower() {
    final p = _currentPullPixels();
    final len = math.sqrt(p.dx * p.dx + p.dy * p.dy);
    return (len / _maxPullPx).clamp(0.0, 1.0);
  }

  double _currentAngle() {
    final p = _currentPullPixels();
    return math.atan2(-p.dy, -p.dx); // shot direction (opposite of pull)
  }

  bool _isNearSnap(double angle) {
    for (final a in _snapAngles) {
      var diff = (angle - a).abs();
      if (diff > math.pi) diff = 2 * math.pi - diff;
      if (diff < _snapToleranceRad) return true;
    }
    return false;
  }

  // ── Render ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onPanCancel: _onPanCancel,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: widget.enabled ? 1.0 : 0.45,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Baseline glow + striker indicator + pull visualization.
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) => CustomPaint(
                painter: _AimPainter(
                  world: widget.world,
                  boardPixelSize: widget.boardPixelSize,
                  pointerStart: _pointerStart,
                  pointerCurrent: _pointerCurrent,
                  stage: _stage,
                  power: _currentPower(),
                  angle: _currentAngle(),
                  isSnapped: _wasSnapped,
                  pulse: _pulse.value,
                  worldToPx: _worldToPx,
                ),
              ),
            ),
            // Top hint pill.
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _HintPill(stage: _stage, power: _currentPower(), angle: _currentAngle()),
              ),
            ),
            // Right-side vertical power bar — only visible while aiming.
            if (_stage == _Stage.aiming)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _PowerBar(power: _currentPower()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum _Stage { idle, placing, aiming }

// ─────────────────────────────────────────────────────────────────────
// Hint pill (top of overlay)
// ─────────────────────────────────────────────────────────────────────

class _HintPill extends StatelessWidget {
  const _HintPill({required this.stage, required this.power, required this.angle});
  final _Stage stage;
  final double power;
  final double angle;

  @override
  Widget build(BuildContext context) {
    String text;
    Color bg;
    if (stage == _Stage.placing) {
      text = 'حرّك الستراكر يميناً ويساراً';
      bg = const Color(0xCC2E2A22);
    } else if (stage == _Stage.aiming) {
      final deg = (angle * 180 / math.pi).round();
      final pct = (power * 100).round();
      text = 'زاوية $deg° · قوة $pct%';
      bg = power > 0.85
          ? const Color(0xCCD22F2F)
          : power > 0.5
              ? const Color(0xCCD89A2D)
              : const Color(0xCC3E7DD4);
    } else {
      text = 'اسحب الستراكر للتصويب';
      bg = const Color(0x99000000);
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: Container(
        key: ValueKey(text),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Vertical power bar
// ─────────────────────────────────────────────────────────────────────

class _PowerBar extends StatelessWidget {
  const _PowerBar({required this.power});
  final double power;

  @override
  Widget build(BuildContext context) {
    final color = power > 0.85
        ? const Color(0xFFD22F2F)
        : power > 0.5
            ? const Color(0xFFD89A2D)
            : const Color(0xFF6CC36A);
    return Container(
      width: 18,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0x55000000),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x77FFFFFF), width: 0.6),
      ),
      padding: const EdgeInsets.all(2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 120),
              heightFactor: power,
              widthFactor: 1.0,
              child: Container(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Custom painter — baseline + striker halo + slingshot bands + ray
// ─────────────────────────────────────────────────────────────────────

class _AimPainter extends CustomPainter {
  _AimPainter({
    required this.world,
    required this.boardPixelSize,
    required this.pointerStart,
    required this.pointerCurrent,
    required this.stage,
    required this.power,
    required this.angle,
    required this.isSnapped,
    required this.pulse,
    required this.worldToPx,
  });

  final CarromWorld world;
  final double boardPixelSize;
  final Offset? pointerStart;
  final Offset? pointerCurrent;
  final _Stage stage;
  final double power;
  final double angle;
  final bool isSnapped;
  final double pulse;
  final Offset Function(Vector2) worldToPx;

  @override
  void paint(Canvas canvas, Size size) {
    final striker = world.striker;
    if (striker == null) return;

    // 1. Baseline glow.
    final baselineY = world.mySeat == Seat.a
        ? BoardDims.playerABaselineY
        : BoardDims.playerBBaselineY;
    final baseLeft = worldToPx(Vector2(-BoardDims.strikerXRange, baselineY));
    final baseRight = worldToPx(Vector2(BoardDims.strikerXRange, baselineY));
    final basePaint = Paint()
      ..color = const Color(0xFFD4A85F).withValues(alpha: 0.55 + 0.20 * pulse)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawLine(baseLeft, baseRight, basePaint);

    // 2. Striker halo (pulsing ring).
    final strikerPx = worldToPx(striker.body.position);
    final strikerRpx = BoardDims.strikerRadius / BoardDims.size * boardPixelSize;
    final haloPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..color = const Color(0xFFD4A85F).withValues(alpha: 0.45 + 0.25 * pulse);
    canvas.drawCircle(strikerPx, strikerRpx + 6 + 3 * pulse, haloPaint);

    // 3. Slingshot bands (only while aiming).
    if (stage == _Stage.aiming && pointerStart != null && pointerCurrent != null) {
      final pull = pointerCurrent! - pointerStart!;
      final thickness = 2 + power * 4;
      final color = power > 0.85
          ? const Color(0xFFD22F2F)
          : power > 0.5
              ? const Color(0xFFD89A2D)
              : const Color(0xFF6CC36A);
      final bandPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round
        ..color = color;
      // Two curved bands forming a slingshot, offset perpendicular to pull dir.
      final perp = Offset(-pull.dy, pull.dx) / math.max(1.0, pull.distance);
      final pullEnd = strikerPx + pull;
      for (final dir in [-1.0, 1.0]) {
        final off1 = strikerPx + perp * (strikerRpx * 0.5 * dir);
        final off2 = pullEnd + perp * (4 * dir);
        final mid = (off1 + off2) / 2 + perp * (8 * dir);
        final path = Path()
          ..moveTo(off1.dx, off1.dy)
          ..quadraticBezierTo(mid.dx, mid.dy, off2.dx, off2.dy);
        canvas.drawPath(path, bandPaint);
      }

      // Snap-angle ring + glowing aim line on snap.
      if (isSnapped) {
        canvas.drawCircle(
          strikerPx,
          strikerRpx + 18,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5
            ..color = const Color(0xFFFFD75A),
        );
      }

      // 4. Trajectory dotted ray (in shot direction).
      _drawDottedRay(
        canvas,
        from: strikerPx,
        angle: angle,
        lengthPx: 50 + power * 220,
        color: color.withValues(alpha: 0.65),
      );
    }
  }

  void _drawDottedRay(Canvas canvas, {
    required Offset from,
    required double angle,
    required double lengthPx,
    required Color color,
  }) {
    const dash = 8.0;
    const gap = 6.0;
    final dir = Offset(math.cos(angle), math.sin(angle));
    var t = 14.0; // start a bit past the striker rim
    while (t < lengthPx) {
      final t2 = math.min(t + dash, lengthPx);
      final p1 = from + dir * t;
      final p2 = from + dir * t2;
      final alpha = (1.0 - t / lengthPx).clamp(0.0, 1.0);
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = color.withValues(alpha: alpha * color.a)
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round,
      );
      t = t2 + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _AimPainter old) {
    return old.pointerStart != pointerStart ||
        old.pointerCurrent != pointerCurrent ||
        old.stage != stage ||
        old.pulse != pulse ||
        old.isSnapped != isSnapped;
  }
}
