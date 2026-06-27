import 'package:flutter/material.dart';

const Map<int, List<List<int>>> kPips = {
  1: [[1, 1]],
  2: [[0, 0], [2, 2]],
  3: [[0, 0], [1, 1], [2, 2]],
  4: [[0, 0], [0, 2], [2, 0], [2, 2]],
  5: [[0, 0], [0, 2], [1, 1], [2, 0], [2, 2]],
  6: [[0, 0], [0, 2], [1, 0], [1, 2], [2, 0], [2, 2]],
};

class DiceWidget extends StatelessWidget {
  final int value;
  final double size;
  final VoidCallback? onTap;
  final bool enabled;
  const DiceWidget({super.key, required this.value, this.size = 72, this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.26),
          gradient: const RadialGradient(
            center: Alignment(0, -0.3),
            colors: [Color(0xFFFFFDF6), Color(0xFFF6E3B8)],
          ),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFF7C544).withValues(alpha: enabled ? 0.7 : 0.2),
                blurRadius: 18, spreadRadius: 3),
            const BoxShadow(color: Color(0x66442200), blurRadius: 10, offset: Offset(0, 5)),
          ],
          border: Border.all(color: const Color(0xFFF7C544), width: 3),
        ),
        child: CustomPaint(painter: _PipsPainter(value)),
      ),
    );
  }
}

class _PipsPainter extends CustomPainter {
  final int value;
  _PipsPainter(this.value);
  @override
  void paint(Canvas canvas, Size size) {
    if (value < 1) return;
    final pad = size.width * 0.28;
    final span = size.width - pad * 2;
    final pr = size.width * 0.09;
    for (final p in kPips[value]!) {
      final px = pad + p[1] * (span / 2);
      final py = pad + p[0] * (span / 2);
      final rect = Rect.fromCircle(center: Offset(px, py), radius: pr);
      canvas.drawCircle(Offset(px, py), pr,
          Paint()..shader = RadialGradient(colors: const [Color(0xFFB08A3A), Color(0xFF6E521D)]).createShader(rect));
    }
  }

  @override
  bool shouldRepaint(covariant _PipsPainter old) => old.value != value;
}
