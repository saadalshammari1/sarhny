import 'package:flutter/material.dart';
import '../theme/cosmetics.dart';
import '../theme/ludo_theme.dart';

/// قطعة الفارس بأسلوب glossy (قاعدة + جسم مخروطي + رأس كروي بلمعة) مع تاج ذهبي
/// حسب النمط المختار.
class PawnWidget extends StatelessWidget {
  final String colorKey;
  final double size;
  final bool glow;
  final KnightStyle style;
  const PawnWidget({super.key, required this.colorKey, this.size = 40, this.glow = false, this.style = KnightStyle.classic});

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
          // ظل أرضي
          Positioned(
            bottom: 0,
            child: Container(
              width: size * 0.9,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.all(Radius.elliptical(size * 0.9, size * 0.3)),
              ),
            ),
          ),
          // القاعدة
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
                borderRadius: BorderRadius.all(Radius.elliptical(size * 0.92, size * 0.4)),
              ),
            ),
          ),
          // الجسم (مخروط مبسّط)
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
          // الرأس الكروي
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
                    ? [BoxShadow(color: Colors.white.withValues(alpha: 0.9), blurRadius: 12, spreadRadius: 1)]
                    : null,
              ),
              child: Align(
                alignment: const Alignment(-0.4, -0.5),
                child: Container(
                  width: size * 0.22,
                  height: size * 0.16,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.all(Radius.elliptical(size * 0.22, size * 0.16)),
                  ),
                ),
              ),
            ),
          ),
          // التاج/الزخرفة الذهبية حسب النمط
          if (style != KnightStyle.classic)
            Positioned(
              top: 0,
              child: CustomPaint(size: Size(size * 0.6, size * 0.4), painter: _Topper(style)),
            ),
        ],
      ),
    );
  }
}

const List<Color> _goldRamp = [Color(0xFFFFF6D6), Color(0xFFF0D488), Color(0xFFE3BD5E), Color(0xFFB8893A)];

class _Topper extends CustomPainter {
  final KnightStyle style;
  _Topper(this.style);

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height, cx = w / 2;
    Paint gold(Rect r) => Paint()..shader = const LinearGradient(colors: _goldRamp).createShader(r);
    final full = Rect.fromLTWH(0, 0, w, h);
    switch (style) {
      case KnightStyle.classic:
        break;
      case KnightStyle.knight:
        // عُرف/ريشة الفارس
        final p = Path()
          ..moveTo(cx - w * 0.12, h)
          ..quadraticBezierTo(cx - w * 0.05, h * 0.1, cx + w * 0.18, 0)
          ..quadraticBezierTo(cx + w * 0.04, h * 0.45, cx + w * 0.12, h)
          ..close();
        canvas.drawPath(p, gold(full));
      case KnightStyle.sorcerer:
        // قبعة مدببة + نجمة
        final p = Path()
          ..moveTo(cx, 0)
          ..lineTo(cx - w * 0.26, h * 0.78)
          ..lineTo(cx + w * 0.26, h * 0.78)
          ..close();
        canvas.drawPath(p, gold(full));
        canvas.drawCircle(Offset(cx, h * 0.42), w * 0.08, Paint()..color = Colors.white);
      case KnightStyle.crown:
        // تاج
        final p = Path()
          ..moveTo(cx - w * 0.3, h)
          ..lineTo(cx - w * 0.3, h * 0.4)
          ..lineTo(cx - w * 0.15, h * 0.7)
          ..lineTo(cx, h * 0.25)
          ..lineTo(cx + w * 0.15, h * 0.7)
          ..lineTo(cx + w * 0.3, h * 0.4)
          ..lineTo(cx + w * 0.3, h)
          ..close();
        canvas.drawPath(p, gold(full));
        canvas.drawCircle(Offset(cx, h * 0.62), w * 0.06, Paint()..color = const Color(0xFFE23B32));
    }
    // لمعة بسيطة
    if (style != KnightStyle.classic) {
      canvas.drawCircle(Offset(cx - w * 0.12, h * 0.3), w * 0.05,
          Paint()..color = Colors.white.withValues(alpha: 0.6));
    }
  }

  @override
  bool shouldRepaint(covariant _Topper old) => old.style != style;
}

class _BodyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final p = Path();
    p.moveTo(s.width * 0.02, s.height);
    p.quadraticBezierTo(s.width * 0.2, s.height * 0.3, s.width * 0.33, s.height * 0.08);
    p.lineTo(s.width * 0.67, s.height * 0.08);
    p.quadraticBezierTo(s.width * 0.8, s.height * 0.3, s.width * 0.98, s.height);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(_) => false;
}
