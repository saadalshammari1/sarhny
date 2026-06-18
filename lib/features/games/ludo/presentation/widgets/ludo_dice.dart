import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../app/theme/app_theme.dart';

/// زهر لودو 3D-feel — مع animation rolling/spring + face highlight.
///
/// - استخدم controller لـ trigger الـ roll: `controller.rollTo(value)`.
/// - يبيّن glow ring لو دوري.
/// - حجم القاعدة 72×72.
class LudoDice extends StatefulWidget {
  const LudoDice({
    super.key,
    required this.controller,
    required this.myTurn,
    required this.onTap,
    this.initialValue,
  });

  final LudoDiceController controller;

  /// عدد العين الأخيرة (1..6) أو null.
  final int? initialValue;
  final bool myTurn;
  final VoidCallback onTap;

  @override
  State<LudoDice> createState() => _LudoDiceState();
}

class LudoDiceController {
  _LudoDiceState? _state;

  /// Trigger a roll animation that lands on [value] (1..6).
  Future<void> rollTo(int value) async {
    final s = _state;
    if (s == null) return;
    await s._rollTo(value);
  }
}

class _LudoDiceState extends State<LudoDice>
    with TickerProviderStateMixin {
  int? _displayValue;
  late final AnimationController _rollCtrl;
  late final AnimationController _glowCtrl;

  // 0..1: how far through the roll
  double _spin = 0;
  // 1..6 changing per frame during the roll
  int _flashValue = 1;

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
    _displayValue = widget.initialValue;
    _rollCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant LudoDice old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller._state = null;
      widget.controller._state = this;
    }
    if (widget.initialValue != old.initialValue &&
        widget.initialValue != null) {
      _displayValue = widget.initialValue;
    }
  }

  @override
  void dispose() {
    widget.controller._state = null;
    _rollCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  Future<void> _rollTo(int value) async {
    final rng = math.Random();
    final completer = Completer<void>();
    _rollCtrl.reset();
    void tick() {
      setState(() {
        _spin = _rollCtrl.value;
        // mostly random while spinning, then snap to actual value at end
        if (_rollCtrl.value < 0.85) {
          _flashValue = 1 + rng.nextInt(6);
        } else {
          _flashValue = value;
        }
      });
    }

    _rollCtrl.addListener(tick);
    _rollCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() {
          _displayValue = value;
          _spin = 0;
        });
        completer.complete();
      }
    });
    await _rollCtrl.forward();
    if (!completer.isCompleted) completer.complete();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return GestureDetector(
      onTap: widget.myTurn ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _glowCtrl,
        builder: (context, _) {
          final glowAlpha = widget.myTurn
              ? 0.35 + 0.25 * math.sin(_glowCtrl.value * math.pi * 2)
              : 0.0;
          return Container(
            width: 86,
            height: 86,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.myTurn)
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.crystal.withValues(alpha: glowAlpha),
                          blurRadius: 22,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                Transform.rotate(
                  angle: _spin == 0 ? 0 : _spin * math.pi * 4,
                  child: Transform.scale(
                    scale: _spin == 0
                        ? 1.0
                        : 1.0 + 0.06 * math.sin(_spin * math.pi * 6),
                    child: CustomPaint(
                      size: const Size(72, 72),
                      painter: _DiceFacePainter(
                        value: _spin > 0
                            ? _flashValue
                            : (_displayValue ?? 1),
                        idle: !widget.myTurn && _spin == 0,
                        dim: _displayValue == null && _spin == 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DiceFacePainter extends CustomPainter {
  _DiceFacePainter({required this.value, this.idle = false, this.dim = false});
  final int value;
  final bool idle;
  final bool dim;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    // shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.translate(1.5, 3.0),
        const Radius.circular(14),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.45),
    );

    // body 3D gradient
    final body = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dim
            ? const [Color(0xFFD8D4C5), Color(0xFFA9A48E)]
            : const [Color(0xFFFFFAEB), Color(0xFFE8DFC4), Color(0xFFB8A971)],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(14)),
      body,
    );

    // bevel inset
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(3),
        const Radius.circular(11),
      ),
      Paint()
        ..color = const Color(0xFFD4AF37).withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // top highlight
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(4, 4, w - 8, h * 0.35),
        topLeft: const Radius.circular(11),
        topRight: const Radius.circular(11),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.5),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(4, 4, w - 8, h * 0.35)),
    );

    // pips
    final pipPaint = Paint()
      ..color = idle
          ? const Color(0xFF635A4D)
          : const Color(0xFF1A1A1A);
    final r = w * 0.075;
    final positions = _pipPositions(value, w, h);
    for (final p in positions) {
      // pip well shadow
      canvas.drawCircle(
        p.translate(0.6, 0.8),
        r,
        Paint()..color = Colors.black.withValues(alpha: 0.55),
      );
      canvas.drawCircle(p, r, pipPaint);
      // pip highlight
      canvas.drawCircle(
        p.translate(-r * 0.3, -r * 0.3),
        r * 0.35,
        Paint()..color = Colors.white.withValues(alpha: 0.55),
      );
    }
  }

  List<Offset> _pipPositions(int value, double w, double h) {
    final l = w * 0.27;
    final m = w * 0.50;
    final r = w * 0.73;
    final t = h * 0.27;
    final c = h * 0.50;
    final b = h * 0.73;
    switch (value) {
      case 1:
        return [Offset(m, c)];
      case 2:
        return [Offset(l, t), Offset(r, b)];
      case 3:
        return [Offset(l, t), Offset(m, c), Offset(r, b)];
      case 4:
        return [Offset(l, t), Offset(r, t), Offset(l, b), Offset(r, b)];
      case 5:
        return [
          Offset(l, t),
          Offset(r, t),
          Offset(m, c),
          Offset(l, b),
          Offset(r, b),
        ];
      case 6:
        return [
          Offset(l, t),
          Offset(r, t),
          Offset(l, c),
          Offset(r, c),
          Offset(l, b),
          Offset(r, b),
        ];
    }
    return const [];
  }

  @override
  bool shouldRepaint(covariant _DiceFacePainter old) =>
      old.value != value || old.idle != idle || old.dim != dim;
}
