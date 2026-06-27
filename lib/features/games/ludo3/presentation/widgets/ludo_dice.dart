import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../engine/ludo_models.dart';

/// A real 3D cube die. Six pip faces are laid out in 3D with [Matrix4]
/// transforms and a perspective projection; rolling tumbles the cube through
/// several spins and settles at a resting tilt that shows three faces — the
/// premium "die at rest" look. The front face flickers through values during
/// the tumble, then locks to [value]. Tinted by the active player's colour.
class LudoDice extends StatefulWidget {
  const LudoDice({
    super.key,
    required this.value,
    required this.rolling,
    required this.enabled,
    required this.color,
    this.onTap,
    this.size = 56,
  });

  final int? value;
  final bool rolling;
  final bool enabled;
  final LudoColor color;
  final VoidCallback? onTap;
  final double size;

  @override
  State<LudoDice> createState() => _LudoDiceState();
}

class _LudoDiceState extends State<LudoDice> with TickerProviderStateMixin {
  late final AnimationController _roll;
  late final AnimationController _idle;
  final _rng = math.Random();

  int _display = 1;
  double _turnsX = 2, _turnsY = 3;

  @override
  void initState() {
    super.initState();
    _display = widget.value ?? 1;
    _roll = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _idle = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _roll.addListener(_onRollTick);
    if (widget.rolling) _begin();
  }

  void _onRollTick() {
    final t = _roll.value;
    if (t < 0.82) {
      final f = _rng.nextInt(6) + 1;
      if (f != _display) setState(() => _display = f);
    } else if (widget.value != null && _display != widget.value) {
      setState(() => _display = widget.value!);
    }
  }

  @override
  void didUpdateWidget(LudoDice old) {
    super.didUpdateWidget(old);
    if (widget.rolling && !old.rolling) _begin();
    if (!widget.rolling && widget.value != null && !_roll.isAnimating) {
      _display = widget.value!;
    }
  }

  void _begin() {
    _turnsX = 2 + _rng.nextInt(2).toDouble();
    _turnsY = 3 + _rng.nextInt(2).toDouble();
    _roll.forward(from: 0);
  }

  @override
  void dispose() {
    _roll.dispose();
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([_roll, _idle]),
        builder: (context, _) {
          final eased = Curves.easeOutCubic.transform(_roll.value);
          // Tumble in 3D only WHILE rolling; settle perfectly flat (front face
          // square-on) so the result number is unmistakable.
          final spin = _roll.isAnimating ? (1 - eased) : 0.0;
          final rx = spin * _turnsX * 2 * math.pi;
          final ry = spin * _turnsY * 2 * math.pi;

          // Drop bounce while rolling.
          final drop = _roll.isAnimating
              ? (1 - Curves.easeOutBack.transform(_roll.value)) * -14
              : 0.0;
          final scale = widget.enabled && !_roll.isAnimating
              ? 1 + 0.03 * math.sin(_idle.value * math.pi * 2)
              : 1.0;

          return Transform.translate(
            offset: Offset(0, drop),
            child: Transform.scale(
              scale: scale,
              child: _cube(rx, ry),
            ),
          );
        },
      ),
    );
  }

  Widget _cube(double rx, double ry) {
    final s = widget.size;
    final h = s / 2;
    final glow = widget.enabled && !_roll.isAnimating;

    Widget face(int value, Matrix4 m) => Transform(
          alignment: Alignment.center,
          transform: m,
          child: _DieFace(value: value, size: s, accent: widget.color),
        );

    final shadow = Transform.translate(
      offset: Offset(0, h * 0.9),
      child: Container(
        width: s * 0.9,
        height: s * 0.32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(s),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
          color: Colors.black.withValues(alpha: 0.001),
        ),
      ),
    );

    final cube = Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0016)
        ..rotateX(rx)
        ..rotateY(ry),
      child: Stack(
        alignment: Alignment.center,
        children: [
          face(6, Matrix4.identity()..rotateY(math.pi)..translateByDouble(0.0, 0.0, h, 1.0)),
          face(2, Matrix4.identity()..rotateX(math.pi / 2)..translateByDouble(0.0, 0.0, h, 1.0)),
          face(5, Matrix4.identity()..rotateX(-math.pi / 2)..translateByDouble(0.0, 0.0, h, 1.0)),
          face(3, Matrix4.identity()..rotateY(math.pi / 2)..translateByDouble(0.0, 0.0, h, 1.0)),
          face(4, Matrix4.identity()..rotateY(-math.pi / 2)..translateByDouble(0.0, 0.0, h, 1.0)),
          // Front face = live display value.
          face(_display, Matrix4.identity()..translateByDouble(0.0, 0.0, h, 1.0)),
        ],
      ),
    );

    return SizedBox(
      width: s * 1.25,
      height: s * 1.25,
      child: Stack(
        alignment: Alignment.center,
        children: [
          shadow,
          if (glow)
            Container(
              width: s * 1.1,
              height: s * 1.1,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.base.withValues(alpha: 0.5),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          cube,
        ],
      ),
    );
  }
}

class _DieFace extends StatelessWidget {
  const _DieFace({required this.value, required this.size, required this.accent});
  final int value;
  final double size;
  final LudoColor accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.2),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFEDE6D4)],
        ),
        border: Border.all(color: const Color(0xFFCFC4A8), width: size * 0.02),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: size * 0.05,
          ),
        ],
      ),
      child: CustomPaint(painter: _PipsPainter(value, accent.dark)),
    );
  }
}

class _PipsPainter extends CustomPainter {
  _PipsPainter(this.value, this.pipColor);
  final int value;
  final Color pipColor;

  static const Map<int, List<Offset>> _layout = {
    1: [Offset(0.5, 0.5)],
    2: [Offset(0.3, 0.3), Offset(0.7, 0.7)],
    3: [Offset(0.28, 0.28), Offset(0.5, 0.5), Offset(0.72, 0.72)],
    4: [Offset(0.3, 0.3), Offset(0.7, 0.3), Offset(0.3, 0.7), Offset(0.7, 0.7)],
    5: [
      Offset(0.28, 0.28), Offset(0.72, 0.28), Offset(0.5, 0.5),
      Offset(0.28, 0.72), Offset(0.72, 0.72),
    ],
    6: [
      Offset(0.3, 0.26), Offset(0.7, 0.26), Offset(0.3, 0.5),
      Offset(0.7, 0.5), Offset(0.3, 0.74), Offset(0.7, 0.74),
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final pips = _layout[value] ?? const [];
    final r = size.width * 0.082;
    for (final p in pips) {
      final c = Offset(p.dx * size.width, p.dy * size.height);
      canvas.drawCircle(
          c + Offset(0, r * 0.18), r, Paint()..color = Colors.black.withValues(alpha: 0.18));
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [pipColor.withValues(alpha: 0.95), pipColor],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
      canvas.drawCircle(c + Offset(-r * 0.3, -r * 0.3), r * 0.32,
          Paint()..color = Colors.white.withValues(alpha: 0.45));
    }
  }

  @override
  bool shouldRepaint(covariant _PipsPainter old) =>
      old.value != value || old.pipColor != pipColor;
}
