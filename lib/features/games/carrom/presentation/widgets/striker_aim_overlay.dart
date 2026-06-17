import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../app/theme/app_theme.dart';
import '../../domain/carrom_state.dart';
import '../../domain/piece.dart';
import '../../domain/shot_input.dart';
import 'carrom_board.dart';

/// Overlay شفاف فوق الـ FlameGame — يدير drag-to-aim + power meter.
///
/// تدفق التحكم:
/// 1. اللاعب يسحب أفقياً على baseline → يحرك الـ striker (إذا دوره).
/// 2. اللاعب يضغط ويسحب من الـ striker للداخل → يحدد زاوية + قوة.
/// 3. عند release: يستدعي onShoot(input).
class StrikerAimOverlay extends StatefulWidget {
  const StrikerAimOverlay({
    super.key,
    required this.state,
    required this.myUserId,
    required this.enabled,
    required this.onShoot,
  });

  final CarromState state;
  final int? myUserId;
  final bool enabled;
  final void Function(CarromShotInput input) onShoot;

  @override
  State<StrikerAimOverlay> createState() => _StrikerAimOverlayState();
}

class _StrikerAimOverlayState extends State<StrikerAimOverlay> {
  // الـ striker position بالـ virtual units (0..600).
  late double _strikerX;
  late double _strikerY;

  // أثناء الـ aim: نقطة نهاية السحب لحساب الزاوية + القوة.
  Offset? _aimDelta; // direction vector in virtual units, من الـ striker للداخل
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _initStrikerFromState();
  }

  @override
  void didUpdateWidget(covariant StrikerAimOverlay old) {
    super.didUpdateWidget(old);
    // مع state جديد من السيرفر — أعد تموضع الـ striker (لو الخادم نقله).
    if (widget.state.seq != old.state.seq) {
      _initStrikerFromState();
    }
  }

  void _initStrikerFromState() {
    final striker = widget.state.pieces.firstWhere(
      (p) => p.color == CarromPieceColor.striker,
      orElse: () => const CarromPiece(
        id: -1,
        color: CarromPieceColor.striker,
        x: CarromBoardGame.boardUnits / 2,
        y: CarromBoardGame.boardUnits / 2,
      ),
    );
    _strikerX = striker.x;
    _strikerY = striker.y;
    // قرر أي baseline:
    // - لاعب A (أنت = اللاعب أ): baseline أسفل (y كبيرة)
    // - لاعب B: baseline أعلى (y صغيرة)
    if (widget.myUserId == widget.state.playerAId) {
      _strikerY = CarromBoardGame.boardUnits -
          (CarromBoardGame.frameMargin + 70);
    } else if (widget.myUserId == widget.state.playerBId) {
      _strikerY = CarromBoardGame.frameMargin + 70;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, c) {
      // عدد الـ pixels-per-virtual-unit
      final scale = c.maxWidth / CarromBoardGame.boardUnits;
      final pxStrikerX = _strikerX * scale;
      final pxStrikerY = _strikerY * scale;
      final pxStrikerR = CarromBoardGame.strikerRadius * scale;

      return AbsorbPointer(
        absorbing: !widget.enabled,
        child: Stack(
          children: [
            // طبقة شفافة تلتقط gestures
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (d) => _onPanStart(d, scale),
                onPanUpdate: (d) => _onPanUpdate(d, scale),
                onPanEnd: (_) => _onPanEnd(),
                child: const SizedBox.expand(),
              ),
            ),
            // الـ aim line + power ring
            if (_aimDelta != null)
              CustomPaint(
                size: Size(c.maxWidth, c.maxWidth),
                painter: _AimPainter(
                  strikerPx: Offset(pxStrikerX, pxStrikerY),
                  aimDelta: _aimDelta! * scale,
                  strikerRadiusPx: pxStrikerR,
                  brand: context.sarhnyColors.moment,
                  power: _power,
                ),
              ),
            // hint نصي
            if (widget.enabled && !_dragging)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'اسحب من الستراكر للداخل لتصويب',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  double get _power {
    if (_aimDelta == null) return 0;
    // طول السحب → قوة. 200 virtual units = full power.
    final mag = math.sqrt(_aimDelta!.dx * _aimDelta!.dx +
        _aimDelta!.dy * _aimDelta!.dy);
    return (mag / 200).clamp(0.0, 1.0);
  }

  bool _isOnStriker(Offset pxPos, double scale) {
    final dx = pxPos.dx - _strikerX * scale;
    final dy = pxPos.dy - _strikerY * scale;
    final dist = math.sqrt(dx * dx + dy * dy);
    // tolerance أكبر بـ 3× لـ tap easier
    return dist <= CarromBoardGame.strikerRadius * scale * 3;
  }

  void _onPanStart(DragStartDetails d, double scale) {
    if (!widget.enabled) return;
    final onStriker = _isOnStriker(d.localPosition, scale);
    if (onStriker) {
      setState(() {
        _dragging = true;
        _aimDelta = Offset.zero;
      });
    } else {
      // baseline movement — حرك الـ striker أفقياً لو السحب قرب الـ baseline
      _maybeMoveStrikerOnBaseline(d.localPosition, scale);
    }
  }

  void _onPanUpdate(DragUpdateDetails d, double scale) {
    if (!widget.enabled) return;
    if (_dragging) {
      // virtual units delta من الـ striker للنقطة الحالية، عكس الاتجاه
      // (نسحب للوراء = نصوّب للأمام).
      final virtX = d.localPosition.dx / scale - _strikerX;
      final virtY = d.localPosition.dy / scale - _strikerY;
      setState(() {
        _aimDelta = Offset(-virtX, -virtY);
      });
    } else {
      _maybeMoveStrikerOnBaseline(d.localPosition, scale);
    }
  }

  void _maybeMoveStrikerOnBaseline(Offset px, double scale) {
    // فقط لو y قريبة من baseline الخاصة بـ "أنا".
    final vy = px.dy / scale;
    final myBaselineY = widget.myUserId == widget.state.playerAId
        ? CarromBoardGame.boardUnits - (CarromBoardGame.frameMargin + 70)
        : CarromBoardGame.frameMargin + 70;
    if ((vy - myBaselineY).abs() > 60) return;
    final newX = (px.dx / scale).clamp(
      CarromBoardGame.frameMargin + 80,
      CarromBoardGame.boardUnits - (CarromBoardGame.frameMargin + 80),
    );
    setState(() {
      _strikerX = newX;
      _strikerY = myBaselineY;
    });
  }

  void _onPanEnd() {
    if (!_dragging || _aimDelta == null) {
      setState(() {
        _aimDelta = null;
        _dragging = false;
      });
      return;
    }
    final power = _power;
    if (power < 0.05) {
      // ضعيف جداً — تجاهل
      setState(() {
        _aimDelta = null;
        _dragging = false;
      });
      return;
    }
    final angle = math.atan2(_aimDelta!.dy, _aimDelta!.dx);
    HapticFeedback.lightImpact();
    widget.onShoot(CarromShotInput(
      strikerX: _strikerX,
      strikerY: _strikerY,
      angleRad: angle,
      power: power,
    ));
    setState(() {
      _aimDelta = null;
      _dragging = false;
    });
  }
}

class _AimPainter extends CustomPainter {
  _AimPainter({
    required this.strikerPx,
    required this.aimDelta,
    required this.strikerRadiusPx,
    required this.brand,
    required this.power,
  });

  final Offset strikerPx;
  final Offset aimDelta; // direction (already scaled to px)
  final double strikerRadiusPx;
  final Color brand;
  final double power;

  @override
  void paint(Canvas canvas, Size size) {
    final endPx = strikerPx + aimDelta;
    // dashed line
    final dashPaint = Paint()
      ..color = Color.lerp(Colors.green, Colors.red, power)!
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    const dashLen = 12.0;
    const gap = 6.0;
    final total = (endPx - strikerPx).distance;
    final segments = (total / (dashLen + gap)).floor();
    final dir = (endPx - strikerPx) / total;
    for (var i = 0; i < segments; i++) {
      final a = strikerPx + dir * (i * (dashLen + gap));
      final b = a + dir * dashLen;
      canvas.drawLine(a, b, dashPaint);
    }
    // pointer at end
    canvas.drawCircle(endPx, 6, dashPaint);

    // power ring حول الـ striker
    final ringPaint = Paint()
      ..color = brand.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final ringRadius = strikerRadiusPx + 6 + (power * 20);
    canvas.drawArc(
      Rect.fromCircle(center: strikerPx, radius: ringRadius),
      -math.pi / 2,
      2 * math.pi * power,
      false,
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(_AimPainter old) =>
      old.strikerPx != strikerPx ||
      old.aimDelta != aimDelta ||
      old.power != power;
}
