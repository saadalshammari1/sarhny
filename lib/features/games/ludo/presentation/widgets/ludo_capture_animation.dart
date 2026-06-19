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

  /// Total animation duration (ms).
  static const int _totalMs = 700;

  /// Phase-1 particle burst lifetime (ms) — matches the token shrink+lift
  /// phase per the capture animation audit.
  static const int _particleLifeMs = 320;

  /// Radiating particles spawned at t = 0 (start of Phase 1).
  /// Direction is uniform in [0, 2π); speed is uniform in [0.5, 1.5]
  /// normalized units of the burst extent.
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(DateTime.now().microsecondsSinceEpoch & 0xFFFF);
    _particles = List<_Particle>.generate(10, (_) {
      return _Particle(
        angle: rng.nextDouble() * 2 * math.pi,
        speed: 0.5 + rng.nextDouble() * 1.0, // 0.5..1.5
      );
    });
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalMs),
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
    // Particle life as fraction of total controller progress.
    final particleLifeFrac = _particleLifeMs / _totalMs;
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
                particles: _particles,
                particleLifeFrac: particleLifeFrac,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Single radiating particle spawned at the start of Phase 1.
class _Particle {
  const _Particle({required this.angle, required this.speed});
  final double angle;
  final double speed;
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({
    required this.progress,
    required this.color,
    required this.particles,
    required this.particleLifeFrac,
  });
  final double progress;
  final Color color;
  final List<_Particle> particles;
  final double particleLifeFrac;

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

    // Phase-1 radiating particle burst (10 particles, life 320ms, linear
    // fade-out, scale 1.0 → 0.4). Spawns at t = 0 so they radiate while
    // the captured token is shrinking. radius = 3px, color = seat color.
    _paintPhase1Particles(canvas, size, c);

    // 10 secondary post-flash particles (kept from original burst look).
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

  void _paintPhase1Particles(Canvas canvas, Size size, Offset c) {
    // Normalised lifetime progress for Phase 1 particles (0..1 over 320ms).
    final pt = (progress / particleLifeFrac).clamp(0.0, 1.0);
    if (pt >= 1.0) return; // life ended → skip
    // Linear fade-out + scale 1.0 → 0.4 across the particle life.
    final alpha = 1.0 - pt;
    final scale = 1.0 - 0.6 * pt;
    // Radiate up to ~85% of half-extent at full speed (1.5 units).
    final maxReach = size.width * 0.45;
    for (final p in particles) {
      final dist = maxReach * p.speed * pt;
      final pos = Offset(
        c.dx + dist * math.cos(p.angle),
        c.dy + dist * math.sin(p.angle),
      );
      canvas.drawCircle(
        pos,
        3.0 * scale,
        Paint()..color = color.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.particles != particles ||
      old.particleLifeFrac != particleLifeFrac;
}
