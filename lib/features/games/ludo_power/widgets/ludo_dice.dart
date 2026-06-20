import 'dart:math' as math;
import 'package:flutter/material.dart';

const Map<int, List<List<int>>> kPips = {
  1: [[1, 1]],
  2: [[0, 0], [2, 2]],
  3: [[0, 0], [1, 1], [2, 2]],
  4: [[0, 0], [0, 2], [2, 0], [2, 2]],
  5: [[0, 0], [0, 2], [1, 1], [2, 0], [2, 2]],
  6: [[0, 0], [0, 2], [1, 0], [1, 2], [2, 0], [2, 2]],
};

/// Big tappable dice — used as the human player's primary roll button.
/// `rolling` triggers a satisfying 1.2s tumble animation: rapid spin that
/// decelerates and snaps to the final face. The dice is rendered as a
/// faux-3D cube (top face tilted + side shadow) rather than a flat square.
class LudoDice extends StatefulWidget {
  final int value;
  final double size;
  final VoidCallback? onTap;
  final bool enabled;
  final bool rolling;
  const LudoDice({
    super.key,
    required this.value,
    this.size = 80,
    this.onTap,
    this.enabled = true,
    this.rolling = false,
  });

  @override
  State<LudoDice> createState() => _LudoDiceState();
}

class _LudoDiceState extends State<LudoDice>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _spin;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _spin = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void didUpdateWidget(covariant LudoDice old) {
    super.didUpdateWidget(old);
    if (widget.rolling && !old.rolling) {
      _ctrl.forward(from: 0);
    } else if (!widget.rolling && old.rolling) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _spin,
        builder: (_, __) {
          // Rotate hard during the spin, easing into rest at value.
          final t = widget.rolling ? _spin.value : 1.0;
          final spinTurns = widget.rolling ? (1 - t) * 4 : 0;
          final tiltX = math.sin(spinTurns * math.pi * 2) * 0.4;
          final tiltY = math.cos(spinTurns * math.pi * 2) * 0.3;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateX(tiltX)
              ..rotateY(tiltY),
            child: _DiceFace(
                value: widget.value, size: widget.size, enabled: widget.enabled),
          );
        },
      ),
    );
  }
}

/// Small static dice — shown next to each player's name in the HUD.
/// Glows when it's that player's turn.
class LudoMiniDice extends StatelessWidget {
  final int value;
  final double size;
  final Color glowColor;
  final bool active;
  const LudoMiniDice({
    super.key,
    required this.value,
    this.size = 38,
    required this.glowColor,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        gradient: const RadialGradient(
          center: Alignment(0, -0.3),
          colors: [Color(0xFFFFFDF6), Color(0xFFF2DCA6)],
        ),
        boxShadow: [
          BoxShadow(
              color: glowColor.withValues(alpha: active ? 0.85 : 0.18),
              blurRadius: active ? 14 : 4,
              spreadRadius: active ? 2 : 0),
          const BoxShadow(
              color: Color(0x66000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
        border: Border.all(
            color: active ? glowColor : const Color(0xFFB89A52), width: 1.6),
      ),
      child: CustomPaint(painter: _PipsPainter(value)),
    );
  }
}

class _DiceFace extends StatelessWidget {
  const _DiceFace({
    required this.value,
    required this.size,
    required this.enabled,
  });
  final int value;
  final double size;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        gradient: const RadialGradient(
          center: Alignment(0, -0.3),
          colors: [Color(0xFFFFFDF6), Color(0xFFF2DCA6)],
        ),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFF7C544)
                  .withValues(alpha: enabled ? 0.7 : 0.15),
              blurRadius: 20,
              spreadRadius: 3),
          const BoxShadow(
              color: Color(0x88442200), blurRadius: 10, offset: Offset(0, 5)),
        ],
        border: Border.all(color: const Color(0xFFE3BD5E), width: 3),
      ),
      child: CustomPaint(painter: _PipsPainter(value)),
    );
  }
}

class _PipsPainter extends CustomPainter {
  final int value;
  _PipsPainter(this.value);
  @override
  void paint(Canvas canvas, Size size) {
    if (value < 1) return;
    final pad = size.width * 0.26;
    final span = size.width - pad * 2;
    final pr = size.width * 0.095;
    for (final p in kPips[value]!) {
      final px = pad + p[1] * (span / 2);
      final py = pad + p[0] * (span / 2);
      final rect = Rect.fromCircle(center: Offset(px, py), radius: pr);
      canvas.drawCircle(
          Offset(px, py),
          pr,
          Paint()
            ..shader = RadialGradient(
              colors: const [Color(0xFFB08A3A), Color(0xFF4A3210)],
            ).createShader(rect));
    }
  }

  @override
  bool shouldRepaint(covariant _PipsPainter old) => old.value != value;
}
