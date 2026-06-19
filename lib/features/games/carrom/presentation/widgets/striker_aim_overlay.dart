import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../app/theme/app_theme.dart';
import '../../domain/carrom_state.dart';
import '../../domain/piece.dart';
import '../../domain/shot_input.dart';
import 'carrom_board.dart';

/// Overlay شفاف فوق الـ FlameGame — يدير drag-to-place + slingshot aim.
///
/// تجربة مستوحاة من Carrom Pool (Miniclip):
/// 1. **Stage A — Placement**: تسحب الستراكر يميناً/يساراً على الـ baseline.
/// 2. **Stage B — Aim**: تسحب بعيداً عن الستراكر فيظهر شريط مطّاطي
///    (slingshot)، ومسار منقّط، وعدّاد قوة عمودي على يمين اللوحة.
/// 3. **Release**: لو القوة > 5% نطلق التصويبة، وإلا نلغي بهدوء.
///
/// كل القياسات الـ "virtual" بالـ board units (0..600). الـ painter يأخذ
/// قيم pixel جاهزة.
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

/// مرحلة التفاعل الحالية.
enum _AimStage { placement, aim }

/// قواعد المنطقة الشرعية لتمركز الستراكر — مطابقة للسيرفر
/// (`is_legal_striker_position` في app/core/carrom_physics.py:460-489).
class _StrikerBounds {
  static const double minX = 92;
  static const double maxX = 508;
  static const double playerABaselineY = 90;   // أعلى — اللاعب الأبيض
  static const double playerBBaselineY = 510;  // أسفل
  static const double baselineSnapTolY = 20;   // ±20 وحدة من الـ baseline
}

class _StrikerAimOverlayState extends State<StrikerAimOverlay>
    with SingleTickerProviderStateMixin {
  // الستراكر بالـ virtual units (0..600).
  late double _strikerX;
  late double _strikerY;

  // المرحلة الحالية + تفاصيل الـ aim.
  _AimStage _stage = _AimStage.placement;
  Offset? _aimPullPx; // اتجاه السحب (بالـ px) من الستراكر إلى نقطة الإصبع
  bool _wasSnappedLastFrame = false;

  // Halo pulse + cross-fade controllers.
  late final AnimationController _pulse;

  // الزوايا الموجبة (cardinal/diagonal) للـ snap بالراديان.
  static const List<double> _snapAngles = [
    0,
    math.pi / 4,
    math.pi / 2,
    3 * math.pi / 4,
    math.pi,
    -3 * math.pi / 4,
    -math.pi / 2,
    -math.pi / 4,
  ];
  static const double _snapToleranceRad = 4 * math.pi / 180; // ±4°

  // أحجام عرض ثابتة.
  static const double _powerBarWidthPx = 24;
  static const double _powerBarHeightFrac = 0.60;
  static const double _trajectoryMaxLenPx = 250;
  static const double _snapGuideRadiusPx = 60;
  static const double _slingMaxThicknessPx = 6;
  static const double _slingMinThicknessPx = 2;

  // طول السحب (بالـ px) الذي يساوي قوة 100%.
  static const double _fullPowerPullPx = 180;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _initStrikerFromState();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StrikerAimOverlay old) {
    super.didUpdateWidget(old);
    if (widget.state.seq != old.state.seq ||
        widget.myUserId != old.myUserId) {
      _initStrikerFromState();
      _stage = _AimStage.placement;
      _aimPullPx = null;
    }
  }

  /// يحدد baseline اللاعب الحالي بالـ virtual units.
  /// player A = أعلى (Y=90)، player B = أسفل (Y=510).
  double get _myBaselineY {
    if (widget.myUserId == widget.state.playerBId) {
      return _StrikerBounds.playerBBaselineY;
    }
    return _StrikerBounds.playerABaselineY;
  }

  /// قراءة موضع الستراكر من state، أو وضعه افتراضياً على منتصف baseline اللاعب.
  void _initStrikerFromState() {
    final striker = widget.state.pieces
        .where((p) => p.color == CarromPieceColor.striker && !p.pocketed)
        .cast<CarromPiece?>()
        .firstWhere((_) => true, orElse: () => null);

    final baselineY = _myBaselineY;
    if (striker != null) {
      // لو السيرفر يضع الستراكر على baseline الـ "أنا" — اقبله. وإلا اضبطه.
      final onMyBaseline =
          (striker.y - baselineY).abs() <= _StrikerBounds.baselineSnapTolY;
      _strikerX = striker.x.clamp(_StrikerBounds.minX, _StrikerBounds.maxX);
      _strikerY = onMyBaseline ? baselineY : baselineY;
    } else {
      _strikerX = CarromBoardGame.boardUnits / 2;
      _strikerY = baselineY;
    }
  }

  // ─── حساب القوة + الزاوية ──────────────────────────────────────────

  /// قوة 0..1 من طول السحب الحالي.
  double get _power {
    final pull = _aimPullPx;
    if (pull == null) return 0;
    final mag = pull.distance;
    return (mag / _fullPowerPullPx).clamp(0.0, 1.0);
  }

  /// زاوية اتجاه الإطلاق (عكس اتجاه السحب) — atan2(dy, dx).
  /// إذا كانت قريبة من زاوية cardinal/diagonal ضمن ±4° نقفلها عليها.
  double get _shotAngleRad {
    final pull = _aimPullPx;
    if (pull == null) return 0;
    // عكس السحب = اتجاه الإطلاق.
    final raw = math.atan2(-pull.dy, -pull.dx);
    return _snappedAngle(raw) ?? raw;
  }

  /// لو الزاوية ضمن tolerance لأي زاوية snap، نُرجع الـ snap. وإلا null.
  double? _snappedAngle(double raw) {
    for (final s in _snapAngles) {
      final diff = _angleDiff(raw, s);
      if (diff.abs() <= _snapToleranceRad) return s;
    }
    return null;
  }

  static double _angleDiff(double a, double b) {
    var d = a - b;
    while (d > math.pi) {
      d -= 2 * math.pi;
    }
    while (d < -math.pi) {
      d += 2 * math.pi;
    }
    return d;
  }

  /// هل الـ aim حالياً مقفول على snap؟
  bool get _isSnapped {
    final pull = _aimPullPx;
    if (pull == null) return false;
    final raw = math.atan2(-pull.dy, -pull.dx);
    return _snappedAngle(raw) != null;
  }

  // ─── بناء الواجهة ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final animMs = reduceMotion ? 0 : 200;
    final brand = context.sarhnyColors.moment;

    return LayoutBuilder(builder: (ctx, c) {
      final scale = c.maxWidth / CarromBoardGame.boardUnits;
      final boardHeightPx = c.maxHeight;
      final pxStrikerX = _strikerX * scale;
      final pxStrikerY = _strikerY * scale;
      final pxStrikerR = CarromBoardGame.strikerRadius * scale;
      final pxBaselineY = _myBaselineY * scale;
      final pxBaselineLeft = _StrikerBounds.minX * scale;
      final pxBaselineRight = _StrikerBounds.maxX * scale;

      final powerColor = _tensionColor(_power);
      final aimPull = _aimPullPx;
      final snapped = _stage == _AimStage.aim && _isSnapped;

      final overlay = Stack(
        clipBehavior: Clip.none,
        children: [
          // طبقة gestures — تمتد على كل اللوحة.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (d) => _onPanStart(d, scale),
              onPanUpdate: (d) => _onPanUpdate(d, scale),
              onPanEnd: (_) => _onPanEnd(),
              onPanCancel: _onPanCancel,
              child: const SizedBox.expand(),
            ),
          ),

          // الـ baseline stripe — line + soft glow.
          CustomPaint(
            size: Size(c.maxWidth, boardHeightPx),
            painter: _BaselinePainter(
              y: pxBaselineY,
              x1: pxBaselineLeft,
              x2: pxBaselineRight,
              color: brand,
            ),
          ),

          // الـ slingshot + trajectory + snap guide — لما نكون في aim.
          if (_stage == _AimStage.aim && aimPull != null)
            CustomPaint(
              size: Size(c.maxWidth, boardHeightPx),
              painter: _AimPainter(
                strikerPx: Offset(pxStrikerX, pxStrikerY),
                pullPx: aimPull,
                strikerRadiusPx: pxStrikerR,
                power: _power,
                color: powerColor,
                snapped: snapped,
                shotAngleRad: _shotAngleRad,
                trajectoryMaxLen: _trajectoryMaxLenPx,
                snapGuideRadius: _snapGuideRadiusPx,
                slingMinThickness: _slingMinThicknessPx,
                slingMaxThickness: _slingMaxThicknessPx,
                pulse: reduceMotion ? 0 : _pulse.value,
              ),
            ),

          // الستراكر + halo نابض.
          Positioned(
            left: pxStrikerX - pxStrikerR - 8,
            top: pxStrikerY - pxStrikerR - 8,
            width: (pxStrikerR + 8) * 2,
            height: (pxStrikerR + 8) * 2,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => CustomPaint(
                  painter: _StrikerDiscPainter(
                    radiusPx: pxStrikerR,
                    haloOn: widget.enabled,
                    pulsePhase: reduceMotion ? 0 : _pulse.value,
                    interactable: widget.enabled,
                  ),
                ),
              ),
            ),
          ),

          // عدّاد القوة العمودي على يمين اللوحة.
          Positioned(
            right: 6,
            top: boardHeightPx * (1 - _powerBarHeightFrac) / 2,
            width: _powerBarWidthPx,
            height: boardHeightPx * _powerBarHeightFrac,
            child: IgnorePointer(
              child: _PowerBar(
                power: _power,
                color: powerColor,
                animMs: animMs,
              ),
            ),
          ),

          // hint نصي علوي مع cross-fade.
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: IgnorePointer(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: animMs),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _HintBubble(
                  key: ValueKey(_hintKey()),
                  text: _hintText(),
                ),
              ),
            ),
          ),
        ],
      );

      return AnimatedOpacity(
        opacity: widget.enabled ? 1.0 : 0.4,
        duration: Duration(milliseconds: animMs),
        child: IgnorePointer(
          ignoring: !widget.enabled,
          child: overlay,
        ),
      );
    });
  }

  // ─── Hint text helpers ─────────────────────────────────────────────

  String _hintKey() {
    if (!widget.enabled) return 'disabled';
    if (_stage == _AimStage.aim) return 'aim';
    return 'placement';
  }

  String _hintText() {
    if (!widget.enabled) return 'دور الخصم';
    if (_stage == _AimStage.aim) {
      final deg = (_shotAngleRad * 180 / math.pi).round();
      final pct = (_power * 100).round();
      // نحوّل الزاوية لـ 0..360 لقراءة أسهل.
      final normalised = deg < 0 ? deg + 360 : deg;
      return 'زاوية $normalised° · قوة $pct%';
    }
    return 'اسحب الستراكر يساراً أو يميناً';
  }

  // ─── Gesture handlers ──────────────────────────────────────────────

  void _onPanStart(DragStartDetails d, double scale) {
    if (!widget.enabled) return;
    final localPx = d.localPosition;
    if (_isOnStriker(localPx, scale)) {
      // ندخل مرحلة aim — لكن لن نظهر slingshot حتى يحصل drag حقيقي.
      _setStage(_AimStage.aim);
      setState(() {
        _aimPullPx = Offset.zero;
      });
    } else {
      // محاولة سحب الـ baseline — نقبل فقط إذا كانت قريبة من baseline اللاعب.
      _setStage(_AimStage.placement);
      _maybeMoveStrikerOnBaseline(localPx, scale);
    }
  }

  void _onPanUpdate(DragUpdateDetails d, double scale) {
    if (!widget.enabled) return;
    if (_stage == _AimStage.aim) {
      final pull = d.localPosition - Offset(_strikerX * scale, _strikerY * scale);
      setState(() {
        _aimPullPx = pull;
      });
      // haptic snap entry (ليس exit).
      final snappedNow = _isSnapped;
      if (snappedNow && !_wasSnappedLastFrame) {
        HapticFeedback.lightImpact();
      }
      _wasSnappedLastFrame = snappedNow;
    } else {
      _maybeMoveStrikerOnBaseline(d.localPosition, scale);
    }
  }

  void _onPanEnd() {
    if (!widget.enabled) {
      _resetAim();
      return;
    }
    if (_stage != _AimStage.aim || _aimPullPx == null) {
      _resetAim();
      return;
    }
    final power = _power;
    if (power <= 0.05) {
      HapticFeedback.selectionClick();
      _resetAim();
      return;
    }
    final angle = _shotAngleRad;
    HapticFeedback.heavyImpact();
    widget.onShoot(CarromShotInput(
      strikerX: _strikerX,
      strikerY: _strikerY,
      angleRad: angle,
      power: power,
    ));
    _resetAim();
  }

  void _onPanCancel() {
    _resetAim();
  }

  void _resetAim() {
    if (!mounted) return;
    setState(() {
      _aimPullPx = null;
      _stage = _AimStage.placement;
      _wasSnappedLastFrame = false;
    });
  }

  /// تنقل بين stage مع haptic + cross-fade تلقائي (الـ AnimatedSwitcher يدير الـ fade).
  void _setStage(_AimStage next) {
    if (_stage == next) return;
    setState(() {
      _stage = next;
    });
    HapticFeedback.selectionClick();
  }

  bool _isOnStriker(Offset pxPos, double scale) {
    final dx = pxPos.dx - _strikerX * scale;
    final dy = pxPos.dy - _strikerY * scale;
    final dist = math.sqrt(dx * dx + dy * dy);
    return dist <= CarromBoardGame.strikerRadius * scale * 2.6;
  }

  /// يقبل السحب لو كانت النقطة قريبة من baseline اللاعب (±60px على الشاشة).
  /// X يُقيّد بالـ [92, 508].
  void _maybeMoveStrikerOnBaseline(Offset px, double scale) {
    final vy = px.dy / scale;
    final baselineY = _myBaselineY;
    if ((vy - baselineY).abs() > 70) return;
    final newX = (px.dx / scale).clamp(
      _StrikerBounds.minX,
      _StrikerBounds.maxX,
    );
    setState(() {
      _strikerX = newX;
      _strikerY = baselineY;
    });
  }

  // ─── Tension color (HSL interpolation green→yellow→red) ────────────

  static Color _tensionColor(double power) {
    // HSL: hue 120 (green) → 60 (yellow) → 0 (red).
    final hue = (120 * (1 - power)).clamp(0.0, 120.0);
    return HSLColor.fromAHSL(1.0, hue, 0.85, 0.50).toColor();
  }
}

/// رسالة hint عائمة فوق اللوحة.
class _HintBubble extends StatelessWidget {
  const _HintBubble({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// عدّاد القوة العمودي على يمين اللوحة. يملأ من الأسفل للأعلى.
class _PowerBar extends StatelessWidget {
  const _PowerBar({
    required this.power,
    required this.color,
    required this.animMs,
  });

  final double power;
  final Color color;
  final int animMs;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      padding: const EdgeInsets.all(2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // طبقة tick marks (25/50/75).
            const Positioned.fill(child: _PowerBarTicks()),
            // الـ fill animated من الأسفل.
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedFractionallySizedBox(
                duration: Duration(milliseconds: animMs),
                curve: Curves.easeOut,
                widthFactor: 1.0,
                heightFactor: power.clamp(0.0, 1.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        color.withValues(alpha: 0.95),
                        color.withValues(alpha: 0.65),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.55),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PowerBarTicks extends StatelessWidget {
  const _PowerBarTicks();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PowerTicksPainter());
  }
}

class _PowerTicksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (final frac in const [0.25, 0.50, 0.75]) {
      final y = size.height * (1 - frac);
      canvas.drawLine(
        Offset(2, y),
        Offset(size.width - 2, y),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_PowerTicksPainter old) => false;
}

/// يرسم baseline اللاعب — line + soft glow shadow.
class _BaselinePainter extends CustomPainter {
  _BaselinePainter({
    required this.y,
    required this.x1,
    required this.x2,
    required this.color,
  });

  final double y;
  final double x1;
  final double x2;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawLine(Offset(x1, y), Offset(x2, y), glow);

    final line = Paint()
      ..color = color.withValues(alpha: 0.60)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x1, y), Offset(x2, y), line);
  }

  @override
  bool shouldRepaint(_BaselinePainter old) =>
      old.y != y || old.x1 != x1 || old.x2 != x2 || old.color != color;
}

/// يرسم الستراكر + halo نابض (4px gold). نطلق pulse فقط لما interactable.
class _StrikerDiscPainter extends CustomPainter {
  _StrikerDiscPainter({
    required this.radiusPx,
    required this.haloOn,
    required this.pulsePhase,
    required this.interactable,
  });

  final double radiusPx;
  final bool haloOn;
  final double pulsePhase; // 0..1
  final bool interactable;

  static const Color _gold = Color(0xFFE5C77A);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);

    // halo نابض — alpha يتنفس بين 0.45 → 0.85.
    if (haloOn) {
      final pulse = interactable
          ? 0.45 + 0.40 * pulsePhase
          : 0.30;
      canvas.drawCircle(
        c,
        radiusPx + 6,
        Paint()
          ..color = _gold.withValues(alpha: pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }

    // ظل خفيف ثم disc — disc يُرسم بـ Flame تحته، لكن نضع طبقة شفافة
    // بسيطة تُبرز شكله ضمن الـ overlay (الـ Flame striker قد لا يكون mounted
    // قبل أول state تحديث).
    canvas.drawCircle(
      c,
      radiusPx,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      c,
      radiusPx,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  @override
  bool shouldRepaint(_StrikerDiscPainter old) =>
      old.radiusPx != radiusPx ||
      old.haloOn != haloOn ||
      old.pulsePhase != pulsePhase ||
      old.interactable != interactable;
}

/// يرسم الـ slingshot + trajectory ray + snap guide.
class _AimPainter extends CustomPainter {
  _AimPainter({
    required this.strikerPx,
    required this.pullPx,
    required this.strikerRadiusPx,
    required this.power,
    required this.color,
    required this.snapped,
    required this.shotAngleRad,
    required this.trajectoryMaxLen,
    required this.snapGuideRadius,
    required this.slingMinThickness,
    required this.slingMaxThickness,
    required this.pulse,
  });

  final Offset strikerPx;
  final Offset pullPx;
  final double strikerRadiusPx;
  final double power;
  final Color color;
  final bool snapped;
  final double shotAngleRad;
  final double trajectoryMaxLen;
  final double snapGuideRadius;
  final double slingMinThickness;
  final double slingMaxThickness;
  final double pulse; // 0..1 — للنبض على snap

  static const Color _gold = Color(0xFFE5C77A);

  @override
  void paint(Canvas canvas, Size size) {
    final pullEnd = strikerPx + pullPx;

    // ── Snap guide ring + pulse glow on aim line ─────────────────────
    if (snapped) {
      // ring ذهبي حول الستراكر.
      canvas.drawCircle(
        strikerPx,
        snapGuideRadius,
        Paint()
          ..color = _gold.withValues(alpha: 0.55 + 0.30 * pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
      // glow على خط الإطلاق.
      final shotDir = Offset(math.cos(shotAngleRad), math.sin(shotAngleRad));
      canvas.drawLine(
        strikerPx,
        strikerPx + shotDir * trajectoryMaxLen * power,
        Paint()
          ..color = _gold.withValues(alpha: 0.30 + 0.40 * pulse)
          ..strokeWidth = 6
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    // ── Slingshot — مطّاطة من جانبَي الستراكر إلى نقطة السحب ─────────
    // العرض = lerp(min..max) حسب power.
    final tension = slingMinThickness +
        (slingMaxThickness - slingMinThickness) * power;
    final perp = _perpendicular(pullPx);
    // نقطتا تثبيت المطّاطة على جانبَي الستراكر.
    final anchorA = strikerPx + perp * strikerRadiusPx;
    final anchorB = strikerPx - perp * strikerRadiusPx;
    // نقطة تحكم Bezier — قريبة من المنتصف، منزاحة قليلاً للخارج لشعور "شد".
    final mid = strikerPx + pullPx * 0.50;
    final ctrlA = mid + perp * (strikerRadiusPx * 0.6);
    final ctrlB = mid - perp * (strikerRadiusPx * 0.6);

    final bandPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = tension
      ..strokeCap = StrokeCap.round;

    final pathA = Path()
      ..moveTo(anchorA.dx, anchorA.dy)
      ..quadraticBezierTo(ctrlA.dx, ctrlA.dy, pullEnd.dx, pullEnd.dy);
    final pathB = Path()
      ..moveTo(anchorB.dx, anchorB.dy)
      ..quadraticBezierTo(ctrlB.dx, ctrlB.dy, pullEnd.dx, pullEnd.dy);
    canvas.drawPath(pathA, bandPaint);
    canvas.drawPath(pathB, bandPaint);

    // نقطة سحب (لمسة الإصبع) — disc صغير ملوّن.
    canvas.drawCircle(
      pullEnd,
      5,
      Paint()..color = color,
    );
    canvas.drawCircle(
      pullEnd,
      5,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // ── Trajectory dotted ray (في اتجاه الإطلاق = عكس السحب) ─────────
    _drawDottedRay(canvas);
  }

  void _drawDottedRay(Canvas canvas) {
    final length = trajectoryMaxLen * power;
    if (length < 4) return;
    final shotDir = Offset(math.cos(shotAngleRad), math.sin(shotAngleRad));
    const dash = 8.0;
    const gap = 6.0;
    var travelled = 0.0;
    // نبدأ من حافة الستراكر، ليس من مركزه.
    final start = strikerPx + shotDir * strikerRadiusPx;
    while (travelled < length) {
      final a = start + shotDir * travelled;
      final segEnd = math.min(travelled + dash, length);
      final b = start + shotDir * segEnd;
      // alpha يتلاشى مع المسافة (1.0 → 0.0).
      final t = (travelled / length).clamp(0.0, 1.0);
      final alpha = (1.0 - t).clamp(0.0, 1.0);
      final p = Paint()
        ..color = color.withValues(alpha: alpha)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(a, b, p);
      travelled += dash + gap;
    }
  }

  Offset _perpendicular(Offset v) {
    final mag = v.distance;
    if (mag < 0.001) {
      // pull صفر — نختار unit perpendicular أفقي افتراضاً.
      return const Offset(0, 1);
    }
    return Offset(-v.dy / mag, v.dx / mag);
  }

  @override
  bool shouldRepaint(_AimPainter old) =>
      old.strikerPx != strikerPx ||
      old.pullPx != pullPx ||
      old.power != power ||
      old.color != color ||
      old.snapped != snapped ||
      old.shotAngleRad != shotAngleRad ||
      old.pulse != pulse;
}
