import 'dart:math' as math;

import 'package:flutter/material.dart';

/// One-shot burst (انفجار ضوئي) — يُضاف للـ Stack ثم يحذف نفسه عند انتهاء
/// الـ animation. يُستخدم عند الـ capture.
class LudoCaptureBurst extends StatefulWidget {
  const LudoCaptureBurst({
    super.key,
    required this.normalizedCenter,
    required this.boardSize,
    required this.color,
    this.onDone,
  });

  /// مركز الانفجار (0..1 normalized).
  final Offset normalizedCenter;
  final double boardSize;
  final Color color;
  final VoidCallback? onDone;

  @override
  State<LudoCaptureBurst> createState() => _LudoCaptureBurstState();
}

class _LudoCaptureBurstState extends State<LudoCaptureBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _ctrl.forward().then((_) {
      if (mounted) {
        widget.onDone?.call();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.boardSize * 0.08;
    return Positioned(
      left: widget.normalizedCenter.dx * widget.boardSize - r,
      top: widget.normalizedCenter.dy * widget.boardSize - r,
      width: r * 2,
      height: r * 2,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            return CustomPaint(
              painter: _BurstPainter(
                progress: _ctrl.value,
                color: widget.color,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final fade = (1 - progress).clamp(0.0, 1.0);

    // outer flash ring
    canvas.drawCircle(
      c,
      size.width * 0.45 * progress,
      Paint()
        ..color = color.withValues(alpha: 0.7 * fade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // 8 particles
    final rng = math.Random(42);
    for (int i = 0; i < 10; i++) {
      final angle = (i / 10) * 2 * math.pi + rng.nextDouble();
      final dist = size.width * 0.45 * progress;
      final pos = Offset(
        c.dx + dist * math.cos(angle),
        c.dy + dist * math.sin(angle),
      );
      canvas.drawCircle(
        pos,
        2.5 * fade,
        Paint()
          ..color = color.withValues(alpha: fade)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter old) =>
      old.progress != progress || old.color != color;
}
