import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/ludo_token.dart';
import 'ludo_board_geometry.dart';

/// رمز واحد على اللوحة — يدير حركته الذاتية عبر path stepwise.
///
/// API:
/// - يبدأ من [initialPosition].
/// - استخدم `controller.moveTo(...)` لتشغيل animation.
/// - يدعم selected + pulse glow + capture flying-back-to-base.
class LudoTokenWidget extends StatefulWidget {
  const LudoTokenWidget({
    super.key,
    required this.color,
    required this.tokenIndex,
    required this.initialPosition,
    required this.boardSize,
    required this.controller,
    this.selectable = false,
    this.selected = false,
    this.canMove = false,
    this.onTap,
  });

  final LudoColor color;
  final int tokenIndex;
  final LudoTokenPosition initialPosition;

  /// طول ضلع اللوحة (للضرب في normalized coords).
  final double boardSize;

  /// مرجع للتحكم الخارجي بالحركة.
  final LudoTokenAnimController controller;

  /// true لو يمكن النقر عليه.
  final bool selectable;
  final bool selected;
  final bool canMove;
  final VoidCallback? onTap;

  @override
  State<LudoTokenWidget> createState() => _LudoTokenWidgetState();
}

/// External handle for triggering token animations from the board controller.
class LudoTokenAnimController {
  _LudoTokenWidgetState? _state;

  /// يحرك القطعة عبر مجموعة خطوات بـ spring/jump bounce.
  Future<void> moveAlongPath(List<Offset> normalizedPath) async {
    final s = _state;
    if (s == null) return;
    await s._playPath(normalizedPath);
  }

  /// أنيميشن أكل القطعة: يقذفها للسماء + يحرّكها لـ home base ثم يعيد scale.
  Future<void> captureAndReturnHome(Offset homeSlotNormalized) async {
    final s = _state;
    if (s == null) return;
    await s._playCaptureReturn(homeSlotNormalized);
  }

  /// قفزة احتفال خفيفة (للـ finish).
  Future<void> celebrationHop() async {
    final s = _state;
    if (s == null) return;
    await s._playCelebration();
  }
}

class _LudoTokenWidgetState extends State<LudoTokenWidget>
    with TickerProviderStateMixin {
  late Offset _currentNorm;
  double _scale = 1.0;
  double _yLift = 0; // visual lift during step (jump arc)
  bool _ghost = false;

  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
    _currentNorm = LudoBoardGeometry.tokenPosition(
      color: widget.color,
      tokenIndex: widget.tokenIndex,
      pos: widget.initialPosition,
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant LudoTokenWidget old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller._state = null;
      widget.controller._state = this;
    }
  }

  @override
  void dispose() {
    widget.controller._state = null;
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _playPath(List<Offset> path) async {
    if (path.isEmpty) return;
    // كل خطوة 220ms — مع jump arc + bounce.
    for (int i = 1; i < path.length; i++) {
      await _animateStep(path[i - 1], path[i]);
    }
    _currentNorm = path.last;
    if (mounted) setState(() {});
  }

  Future<void> _animateStep(Offset from, Offset to) async {
    const stepMs = 200;
    final c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: stepMs),
    );
    final curve = CurvedAnimation(parent: c, curve: Curves.easeOutBack);
    final completer = Completer<void>();
    void tick() {
      final t = curve.value.clamp(0.0, 1.5); // overshoot allowed
      // arc: peak in the middle.
      final arc = math.sin((t.clamp(0.0, 1.0)) * math.pi);
      if (!mounted) return;
      setState(() {
        _currentNorm = Offset.lerp(from, to, t.clamp(0.0, 1.0))!;
        _yLift = arc * 0.025;
        _scale = 1.0 + arc * 0.08;
      });
    }

    c.addListener(tick);
    c.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _yLift = 0;
            _scale = 1.0;
          });
        }
        c.dispose();
        if (!completer.isCompleted) completer.complete();
      }
    });
    c.forward();
    await completer.future;
  }

  Future<void> _playCaptureReturn(Offset homeNorm) async {
    // 1) shrink + lift
    final c1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    final completer1 = Completer<void>();
    void tick1() {
      final t = c1.value;
      if (!mounted) return;
      setState(() {
        _scale = 1.0 + 0.3 * math.sin(t * math.pi);
        _yLift = 0.04 * math.sin(t * math.pi);
        _ghost = t > 0.6;
      });
    }

    c1.addListener(tick1);
    c1.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        c1.dispose();
        completer1.complete();
      }
    });
    c1.forward();
    await completer1.future;

    // 2) teleport to home (instant) then bounce in
    if (!mounted) return;
    setState(() {
      _currentNorm = homeNorm;
    });
    await Future<void>.delayed(const Duration(milliseconds: 80));

    final c2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    final curve = CurvedAnimation(parent: c2, curve: Curves.elasticOut);
    final completer2 = Completer<void>();
    c2.addListener(() {
      final t = curve.value;
      if (!mounted) return;
      setState(() {
        _scale = 0.6 + 0.4 * t;
        _ghost = false;
      });
    });
    c2.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _scale = 1.0;
          });
        }
        c2.dispose();
        completer2.complete();
      }
    });
    c2.forward();
    await completer2.future;
    // ensure final position recorded
    _currentNorm = homeNorm;
  }

  Future<void> _playCelebration() async {
    final c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    final curve = CurvedAnimation(parent: c, curve: Curves.elasticOut);
    final completer = Completer<void>();
    c.addListener(() {
      if (!mounted) return;
      setState(() {
        _scale = 1.0 + 0.30 * math.sin(curve.value * math.pi);
        _yLift = 0.03 * math.sin(curve.value * math.pi);
      });
    });
    c.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _scale = 1.0;
            _yLift = 0;
          });
        }
        c.dispose();
        completer.complete();
      }
    });
    c.forward();
    await completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.boardSize;
    final radius = size * LudoBoardGeometry.tokenRadius;
    final left = _currentNorm.dx * size - radius;
    final top = (_currentNorm.dy - _yLift) * size - radius;

    return Positioned(
      left: left,
      top: top,
      width: radius * 2,
      height: radius * 2,
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (context, _) {
          final pulse = (math.sin(_pulseCtrl.value * 2 * math.pi) + 1) / 2;
          return GestureDetector(
            onTap: widget.selectable && widget.canMove ? widget.onTap : null,
            child: Opacity(
              opacity: _ghost ? 0.55 : 1.0,
              child: Transform.scale(
                scale: _scale,
                child: _TokenPainted(
                  color: widget.color,
                  selected: widget.selected,
                  canMove: widget.canMove,
                  pulse: pulse,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TokenPainted extends StatelessWidget {
  const _TokenPainted({
    required this.color,
    required this.selected,
    required this.canMove,
    required this.pulse,
  });
  final LudoColor color;
  final bool selected;
  final bool canMove;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TokenPainter(
        color: color,
        selected: selected,
        canMove: canMove,
        pulse: pulse,
      ),
    );
  }
}

class _TokenPainter extends CustomPainter {
  _TokenPainter({
    required this.color,
    required this.selected,
    required this.canMove,
    required this.pulse,
  });
  final LudoColor color;
  final bool selected;
  final bool canMove;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // moveable green halo (only if canMove and not selected)
    if (canMove && !selected) {
      canvas.drawCircle(
        c,
        r + 4 + pulse * 3,
        Paint()
          ..color = const Color(0xFF22D3A0).withValues(alpha: 0.45 + pulse * 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    // selection glow
    if (selected) {
      canvas.drawCircle(
        c,
        r + 5 + pulse * 4,
        Paint()
          ..color = color.primary.withValues(alpha: 0.65)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    // drop shadow
    canvas.drawCircle(
      c.translate(0.6, 1.5),
      r * 0.95,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );

    // body — 3D gradient
    final body = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        colors: [
          Color.lerp(color.primary, Colors.white, 0.55)!,
          color.primary,
          color.dark,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r * 0.92, body);

    // outer rim
    canvas.drawCircle(
      c,
      r * 0.92,
      Paint()
        ..color = const Color(0xFFD4AF37).withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );

    // inner ring with seal
    canvas.drawCircle(
      c,
      r * 0.55,
      Paint()..color = color.dark.withValues(alpha: 0.6),
    );
    canvas.drawCircle(
      c,
      r * 0.55,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );

    // ✦ glyph at center
    final tp = TextPainter(
      text: TextSpan(
        text: '✦',
        style: TextStyle(
          fontSize: r * 0.95,
          color: Colors.white.withValues(alpha: 0.95),
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));

    // top highlight
    canvas.drawCircle(
      Offset(c.dx - r * 0.30, c.dy - r * 0.35),
      r * 0.20,
      Paint()..color = Colors.white.withValues(alpha: 0.32),
    );
  }

  @override
  bool shouldRepaint(covariant _TokenPainter old) =>
      old.color != color ||
      old.selected != selected ||
      old.canMove != canMove ||
      old.pulse != pulse;
}
