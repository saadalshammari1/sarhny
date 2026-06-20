import 'package:flutter/material.dart';
import '../theme/ludo_theme.dart';

/// Glossy 3-D-style pawn rendered entirely with gradients + clippers.
/// `glow` adds a white halo when the piece is movable on the current turn.
class LudoPawn extends StatelessWidget {
  final String colorKey;
  final double size;
  final bool glow;
  const LudoPawn({
    super.key,
    required this.colorKey,
    this.size = 40,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = ludoColors[colorKey]!;
    final h = size * 1.5;
    return SizedBox(
      width: size,
      height: h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: size * 0.9,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.all(
                    Radius.elliptical(size * 0.9, size * 0.3)),
              ),
            ),
          ),
          Positioned(
            bottom: size * 0.12,
            child: Container(
              width: size * 0.92,
              height: size * 0.4,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.2, -1),
                  radius: 1.2,
                  colors: [c.base, c.dark, c.deep],
                  stops: const [0, 0.7, 1],
                ),
                borderRadius: BorderRadius.all(
                    Radius.elliptical(size * 0.92, size * 0.4)),
              ),
            ),
          ),
          Positioned(
            bottom: size * 0.28,
            child: ClipPath(
              clipper: _BodyClipper(),
              child: Container(
                width: size * 0.7,
                height: size * 0.7,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.4, -0.8),
                    radius: 1.2,
                    colors: [c.light, c.base, c.mid, c.dark],
                    stops: const [0, 0.38, 0.64, 1],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: glow ? size * 0.05 : size * 0.02,
            child: Container(
              width: size * 0.72,
              height: size * 0.72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.32, -0.48),
                  radius: 0.95,
                  colors: [c.light, c.base, c.dark, c.deep],
                  stops: const [0, 0.42, 0.86, 1],
                ),
                boxShadow: glow
                    ? [
                        BoxShadow(
                            color: Colors.white.withValues(alpha: 0.9),
                            blurRadius: 12,
                            spreadRadius: 1)
                      ]
                    : null,
              ),
              child: Align(
                alignment: const Alignment(-0.4, -0.5),
                child: Container(
                  width: size * 0.22,
                  height: size * 0.16,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.all(
                        Radius.elliptical(size * 0.22, size * 0.16)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final p = Path();
    p.moveTo(s.width * 0.02, s.height);
    p.quadraticBezierTo(
        s.width * 0.2, s.height * 0.3, s.width * 0.33, s.height * 0.08);
    p.lineTo(s.width * 0.67, s.height * 0.08);
    p.quadraticBezierTo(
        s.width * 0.8, s.height * 0.3, s.width * 0.98, s.height);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> _) => false;
}
