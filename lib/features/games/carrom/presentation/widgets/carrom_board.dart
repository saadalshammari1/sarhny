import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../domain/carrom_state.dart';
import '../../domain/cosmetics.dart';
import '../../domain/piece.dart';
import '../../domain/shot_input.dart';
import '../../domain/shot_result.dart';

/// FlameGame يعرض رقعة كيرم 600×600 (virtual units) وقطعها.
///
/// تصميم Server-authoritative:
/// - الرقعة + القطع تُرسم من state يأتي من السيرفر.
/// - عند shot_result: نأخذ الـ 60 frame ونرسمها عبر دالة time-mapped (1s)
///   مع interpolation بين الـ frames لو frame rate الجهاز < 60 fps.
/// - الـ aiming overlay يستخدم نفس الـ camera transform — ندير الزاوية
///   ونمرر القيمة للـ widget الأب عبر callback، الذي يرسل WS shoot.
class CarromBoardGame extends FlameGame with TapCallbacks {
  CarromBoardGame({
    required this.initialState,
    required this.myUserId,
    required this.onShoot,
  }) : _cosmetics = initialState.cosmetics;

  /// Virtual board size — match السيرفر (600×600).
  static const double boardUnits = 600;

  /// Margin wood frame داخل الـ virtual coordinates.
  static const double frameMargin = 40;

  /// نصف قطر القطع (virtual units).
  static const double pieceRadius = 14;
  static const double strikerRadius = 18;
  static const double pocketRadius = 24;

  CarromState initialState;
  final int? myUserId;
  final void Function(CarromShotInput input) onShoot;

  /// Resolved per-match cosmetics — السيرفر يحسبها قبل بدء المباراة
  /// ويرسلها داخل state.cosmetics. كل component يقرأ من هنا.
  MatchCosmetics _cosmetics;

  late BoardBackground _bg;
  final Map<int, PieceComponent> _piecesById = {};
  StrikerComponent? _striker;

  /// playback queue — كل element = [time_ms, frame].
  CarromShotResult? _playingResult;
  int _playbackStartMs = 0;

  @override
  Future<void> onLoad() async {
    // الـ camera viewport يطابق الـ board (600×600). يتم scale عبر
    // GameWidget في الـ widget الأب.
    camera.viewfinder.visibleGameSize = Vector2.all(boardUnits);
    camera.viewfinder.position = Vector2.all(boardUnits / 2);
    camera.viewfinder.anchor = Anchor.center;

    _bg = BoardBackground(cosmetics: _cosmetics);
    world.add(_bg);

    _rebuildPieces(initialState.pieces);
  }

  /// يستدعى من الـ widget الأب عندما يصل state جديد من WS.
  void applyState(CarromState s) {
    initialState = s;
    // Cosmetics theoretically شبه ثابتة طوال المباراة، لكن نُحدّث في
    // كل snapshot دفاعاً عن reconnect/late-bind scenarios.
    if (s.cosmetics.boardSkin != _cosmetics.boardSkin ||
        s.cosmetics.aPieceColor != _cosmetics.aPieceColor ||
        s.cosmetics.bPieceColor != _cosmetics.bPieceColor) {
      _cosmetics = s.cosmetics;
      _bg.updateCosmetics(_cosmetics);
    } else {
      _cosmetics = s.cosmetics;
    }
    if (_playingResult != null) {
      // أثناء الـ playback نتجاهل state mid-flight — سنطبق الـ final
      // عند انتهاء الـ playback.
      return;
    }
    _rebuildPieces(s.pieces);
  }

  /// يبدأ playback لنتيجة shot. الـ duration ثابت 1 ثانية (60 frames @60fps).
  void playShotResult(CarromShotResult result) {
    _playingResult = result;
    _playbackStartMs = DateTime.now().millisecondsSinceEpoch;
  }

  void _rebuildPieces(List<CarromPiece> pieces) {
    // أزل القطع التي اختفت
    final activeIds = pieces.map((p) => p.id).toSet();
    final toRemove =
        _piecesById.keys.where((id) => !activeIds.contains(id)).toList();
    for (final id in toRemove) {
      final c = _piecesById.remove(id);
      if (c != null) world.remove(c);
    }
    // أضِف الجديد + حدّث الموجود
    for (final p in pieces) {
      final existing = _piecesById[p.id];
      if (p.pocketed) {
        if (existing != null) {
          world.remove(existing);
          _piecesById.remove(p.id);
        }
        continue;
      }
      if (p.color == CarromPieceColor.striker) {
        // الـ striker الذي يراه اللاعب الحالي = مضربه هو. الخصم يرى
        // مضربه الخاص في WS-driven trajectory replay — لكن في الـ
        // initial board لا striker ظاهر إلا لما يدور دور أحدهم.
        final strikerKey = _viewerStrikerKey();
        if (_striker == null || _striker!.skinKey != strikerKey) {
          if (_striker?.isMounted ?? false) world.remove(_striker!);
          _striker = StrikerComponent(skinKey: strikerKey)
            ..size = Vector2.all(strikerRadius * 2);
        }
        _striker!.position = Vector2(p.x, p.y);
        if (!_striker!.isMounted) world.add(_striker!);
        continue;
      }
      final pieceColor = _pieceFillFor(p.color);
      if (existing == null) {
        final c = PieceComponent(
          color: p.color,
          fillColor: pieceColor,
          finish: _finishFor(p.color),
        )
          ..size = Vector2.all(pieceRadius * 2)
          ..position = Vector2(p.x, p.y);
        _piecesById[p.id] = c;
        world.add(c);
      } else {
        existing.fillColor = pieceColor;
        existing.finish = _finishFor(p.color);
        existing.position = Vector2(p.x, p.y);
      }
    }
  }

  /// لاعب A = white side (server convention). نُرجع لون قطعة بناءً على
  /// owner — الملكة دائماً حمراء (لا تُخصَّص).
  Color _pieceFillFor(CarromPieceColor c) {
    switch (c) {
      case CarromPieceColor.white:
        return _cosmetics.aPieceColor;
      case CarromPieceColor.black:
        return _cosmetics.bPieceColor;
      case CarromPieceColor.queen:
        return const Color(0xFFC0392B); // crimson, never customised
      case CarromPieceColor.striker:
        return _cosmetics.aPieceColor;
    }
  }

  /// نوع الـ finish — يختلف بحسب الـ piece skin. الـ queen دائماً jewel.
  String _finishFor(CarromPieceColor c) {
    if (c == CarromPieceColor.queen) return 'jewel';
    // كلا اللاعبين على نفس الـ piece pair في الغالب — نأخذ من A.
    return _cosmetics.aPieceSkin;
  }

  /// لو me == playerA → A's striker، وإلا B's. هذا ضمان أن الستراكر
  /// الذي أراه هو الذي اخترته.
  String _viewerStrikerKey() {
    if (myUserId != null && myUserId == initialState.playerBId) {
      return _cosmetics.bStriker;
    }
    return _cosmetics.aStriker;
  }

  @override
  void update(double dt) {
    super.update(dt);

    final result = _playingResult;
    if (result == null || result.frames.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - _playbackStartMs;
    const totalMs = 1000;
    final progress = (elapsed / totalMs).clamp(0.0, 1.0);

    // Interpolate بين الـ frames — keyframe رقم n عند progress = n/(N-1).
    final frames = result.frames;
    final n = frames.length;
    final exact = progress * (n - 1);
    final idxLo = exact.floor().clamp(0, n - 1);
    final idxHi = (idxLo + 1).clamp(0, n - 1);
    final t = (exact - idxLo).clamp(0.0, 1.0);

    final lo = frames[idxLo].pieces;
    final hi = frames[idxHi].pieces;
    final hiMap = {for (final p in hi) p.id: p};
    final scoredSet = result.scoredIds.toSet();

    for (final p in lo) {
      final h = hiMap[p.id] ?? p;
      final ix = p.x + (h.x - p.x) * t;
      final iy = p.y + (h.y - p.y) * t;
      if (p.color == CarromPieceColor.striker) {
        _striker?.position = Vector2(ix, iy);
        continue;
      }
      final comp = _piecesById[p.id];
      if (comp != null) comp.position = Vector2(ix, iy);
    }
    // pocketed جديد في الـ frame الحالي
    for (final id in scoredSet) {
      final hi = hiMap[id];
      if (hi != null && hi.pocketed) {
        final comp = _piecesById.remove(id);
        if (comp != null && comp.isMounted && !comp.isRemoving) {
          // pocket animation: scale + fade ثم remove
          comp.add(SequenceEffect([
            ScaleEffect.to(
              Vector2.all(0.1),
              EffectController(duration: 0.18),
            ),
            RemoveEffect(),
          ], onComplete: () {}));
        }
      }
    }

    if (progress >= 1.0) {
      // طبّق الـ final state ثم انهِ playback
      _playingResult = null;
      _rebuildPieces(result.finalPieces);
    }
  }
}

/// خلفية الرقعة — frame + 4 جيوب + center decoration + baselines.
///
/// تستخدم الـ [MatchCosmetics] لتختار اللون والـ texture للإطار + سطح
/// اللعب. الجيوب دائماً matte black والـ center ring دائماً قرمزي (هما
/// عناصر دلالية على القواعد، فلا تُخصَّصان).
class BoardBackground extends PositionComponent {
  BoardBackground({required MatchCosmetics cosmetics})
      : _cosmetics = cosmetics,
        super(size: Vector2.all(CarromBoardGame.boardUnits));

  MatchCosmetics _cosmetics;

  static const Color centerRing = Color(0xFFC0392B);

  void updateCosmetics(MatchCosmetics next) {
    _cosmetics = next;
    // لا حاجة لـ trigger explicit — Flame يعيد الرسم في الـ frame التالي.
  }

  /// تعرض الـ skin النشط — مفيد للـ debug + accessibility hooks.
  String get activeBoardSkin => _cosmetics.boardSkin;

  // ── Catalogue mirror (subset, just for rendering). ─────────────────
  // مكرر مع الـ Python catalog لكن narrow + render-focused. أي تغيير
  // هنا يجب أن يطابق `app/core/cosmetics.py:BOARD_SKINS`.

  static const Map<String, _BoardTheme> _themes = {
    'classic_wood': _BoardTheme(
      base: Color(0xFFE8C49A),
      accent: Color(0xFF8B5A2B),
      texture: _BoardTexture.wood,
      borderStyle: _BorderStyle.wood,
      lineColor: Color(0xFF7A4A20),
    ),
    'marble_white': _BoardTheme(
      base: Color(0xFFF5F1EA),
      accent: Color(0xFFD4A574),
      texture: _BoardTexture.marble,
      borderStyle: _BorderStyle.thinGold,
      lineColor: Color(0xFFB58E5A),
    ),
    'royal_navy': _BoardTheme(
      base: Color(0xFF1E3A5F),
      accent: Color(0xFFD4AF37),
      texture: _BoardTexture.felt,
      borderStyle: _BorderStyle.goldCrown,
      lineColor: Color(0xFFD4AF37),
    ),
    'neon_dark': _BoardTheme(
      base: Color(0xFF0A0E27),
      accent: Color(0xFF00F0FF),
      accentAlt: Color(0xFFFF00AA),
      texture: _BoardTexture.neon,
      borderStyle: _BorderStyle.neonGlow,
      lineColor: Color(0xFF00F0FF),
    ),
  };

  _BoardTheme get _theme =>
      _themes[_cosmetics.boardSkin] ?? _themes['classic_wood']!;

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    final inner = Rect.fromLTWH(
      CarromBoardGame.frameMargin,
      CarromBoardGame.frameMargin,
      size.x - CarromBoardGame.frameMargin * 2,
      size.y - CarromBoardGame.frameMargin * 2,
    );

    final theme = _theme;

    // ── Frame ─────────────────────────────────────────────────────
    final framePaint = Paint();
    switch (theme.borderStyle) {
      case _BorderStyle.wood:
        framePaint.shader = LinearGradient(
          colors: [
            theme.accent,
            Color.lerp(theme.accent, Colors.white, 0.2)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect);
        break;
      case _BorderStyle.thinGold:
        framePaint.color = theme.accent.withValues(alpha: 0.95);
        break;
      case _BorderStyle.goldCrown:
        framePaint.shader = LinearGradient(
          colors: [
            Color.lerp(theme.accent, Colors.white, 0.1)!,
            theme.accent,
            Color.lerp(theme.accent, Colors.black, 0.25)!,
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect);
        break;
      case _BorderStyle.neonGlow:
        framePaint.shader = LinearGradient(
          colors: [
            theme.accent,
            theme.accentAlt ?? theme.accent,
            theme.accent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect);
        break;
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(18)),
      framePaint,
    );

    // ── Surface (texture-aware) ───────────────────────────────────
    final playPaint = Paint();
    switch (theme.texture) {
      case _BoardTexture.wood:
        playPaint.shader = LinearGradient(
          colors: [
            theme.base,
            Color.lerp(theme.base, Colors.brown, 0.08)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(inner);
        break;
      case _BoardTexture.marble:
        playPaint.shader = LinearGradient(
          colors: [
            theme.base,
            Color.lerp(theme.base, Colors.grey.shade300, 0.20)!,
            theme.base,
            Color.lerp(theme.base, Colors.grey.shade400, 0.10)!,
          ],
          stops: const [0.0, 0.3, 0.6, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(inner);
        break;
      case _BoardTexture.felt:
        playPaint.shader = RadialGradient(
          colors: [
            Color.lerp(theme.base, Colors.white, 0.06)!,
            theme.base,
            Color.lerp(theme.base, Colors.black, 0.18)!,
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(inner);
        break;
      case _BoardTexture.neon:
        playPaint.shader = RadialGradient(
          colors: [
            Color.lerp(theme.base, Colors.white, 0.04)!,
            theme.base,
          ],
        ).createShader(inner);
        break;
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(inner, const Radius.circular(8)),
      playPaint,
    );

    // Marble veining — thin pale strokes.
    if (theme.texture == _BoardTexture.marble) {
      final vein = Paint()
        ..color = const Color(0x33A8A8A8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      final path = Path()
        ..moveTo(inner.left + inner.width * 0.10, inner.top + 12)
        ..quadraticBezierTo(
          inner.center.dx - 30,
          inner.top + 60,
          inner.center.dx + 80,
          inner.bottom - 90,
        )
        ..moveTo(inner.right - 40, inner.top + 50)
        ..quadraticBezierTo(
          inner.center.dx + 10,
          inner.center.dy,
          inner.left + 80,
          inner.bottom - 30,
        );
      canvas.drawPath(path, vein);
    }

    // Neon outer glow rings.
    if (theme.borderStyle == _BorderStyle.neonGlow) {
      final glow = Paint()
        ..color = theme.accent.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(inner.deflate(3), const Radius.circular(6)),
        glow,
      );
      if (theme.accentAlt != null) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(inner.deflate(8), const Radius.circular(4)),
          Paint()
            ..color = theme.accentAlt!.withValues(alpha: 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
    }

    // Inner line.
    final linePaint = Paint()
      ..color = theme.lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(inner.deflate(6), linePaint);

    // ── Wood-grain procedural lines (classic_wood only) ───────────
    if (theme.texture == _BoardTexture.wood) {
      final grain = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6;
      // 14 evenly spaced sine-curves give a directional wood-grain feel.
      for (int i = 0; i < 14; i++) {
        final y = inner.top + (inner.height / 14) * i + 4;
        final path = Path()..moveTo(inner.left + 4, y);
        for (double x = inner.left + 4; x <= inner.right - 4; x += 6) {
          final yWave = y + math.sin((x + i * 23) * 0.04) * 2.5;
          path.lineTo(x, yWave);
        }
        grain.color = (i % 3 == 0
                ? const Color(0xFF6B3F1F)
                : const Color(0xFF8B5A2B))
            .withValues(alpha: 0.12);
        canvas.drawPath(path, grain);
      }
      // A few "knots" scattered randomly but deterministically.
      const knots = [
        Offset(0.18, 0.32),
        Offset(0.72, 0.22),
        Offset(0.35, 0.68),
        Offset(0.82, 0.78),
      ];
      for (final k in knots) {
        final kp = Offset(
          inner.left + inner.width * k.dx,
          inner.top + inner.height * k.dy,
        );
        canvas.drawCircle(
          kp,
          3.0,
          Paint()..color = const Color(0xFF4A2D14).withValues(alpha: 0.22),
        );
        canvas.drawCircle(
          kp,
          5.0,
          Paint()
            ..color = const Color(0xFF6B3F1F).withValues(alpha: 0.12)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }
    }

    // ── Felt board: tiny dot texture pattern ───────────────────────
    if (theme.texture == _BoardTexture.felt) {
      final dot = Paint()
        ..color = Colors.white.withValues(alpha: 0.04);
      for (int gy = 0; gy < 30; gy++) {
        for (int gx = 0; gx < 30; gx++) {
          final dx = inner.left + (inner.width / 30) * gx + (gy.isOdd ? 4 : 0);
          final dy = inner.top + (inner.height / 30) * gy + 4;
          if (dx > inner.right - 4 || dy > inner.bottom - 4) continue;
          canvas.drawCircle(Offset(dx, dy), 0.7, dot);
        }
      }
      // Subtle vignette for depth.
      canvas.drawRect(
        inner,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.transparent,
              Colors.transparent,
              Colors.black.withValues(alpha: 0.25),
            ],
            stops: const [0.0, 0.65, 1.0],
          ).createShader(inner),
      );
    }

    // ── 4 pockets — beveled hole with depth ───────────────────────
    final pocketRim = Paint()
      ..color = theme.accent.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final pocketInnerRim = Paint()
      ..color = Color.lerp(theme.accent, Colors.black, 0.5)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (final c in _pocketCenters()) {
      // Soft outer shadow that hints the pocket sits below surface.
      canvas.drawCircle(
        c.translate(0, 1),
        CarromBoardGame.pocketRadius + 2,
        Paint()
          ..color = const Color(0x66000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      // Outer themed rim ring (gold/silver/neon).
      canvas.drawCircle(c, CarromBoardGame.pocketRadius + 1, pocketRim);
      // Dark depth gradient — pure black at center, slightly grey at rim.
      canvas.drawCircle(
        c,
        CarromBoardGame.pocketRadius,
        Paint()
          ..shader = RadialGradient(
            colors: const [
              Color(0xFF000000),
              Color(0xFF050505),
              Color(0xFF1A1A1A),
            ],
            stops: [0.0, 0.7, 1.0],
            center: const Alignment(0.15, 0.15),
          ).createShader(
            Rect.fromCircle(center: c, radius: CarromBoardGame.pocketRadius),
          ),
      );
      // Inner dark rim — closes the hole feel.
      canvas.drawCircle(
        c,
        CarromBoardGame.pocketRadius - 0.8,
        pocketInnerRim,
      );
    }

    // ── Centre red ring (queen spot — never themed) ───────────────
    final center = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(
      center,
      26,
      Paint()
        ..color = centerRing
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      center,
      8,
      Paint()..color = centerRing.withValues(alpha: 0.7),
    );

    // Royal crown emblem above the centre.
    if (theme.borderStyle == _BorderStyle.goldCrown) {
      final tp = TextPainter(
        text: TextSpan(
          text: '♛',
          style: TextStyle(
            color: theme.accent.withValues(alpha: 0.85),
            fontSize: 64,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(center.dx - tp.width / 2, inner.top + 16),
      );
      tp.paint(
        canvas,
        Offset(center.dx - tp.width / 2, inner.bottom - tp.height - 16),
      );
    }

    // ── Baselines (front of each player) ───────────────────────────
    final baselinePaint = Paint()
      ..color = theme.lineColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(inner.left + 60, inner.top + 70),
      Offset(inner.right - 60, inner.top + 70),
      baselinePaint,
    );
    canvas.drawLine(
      Offset(inner.left + 60, inner.bottom - 70),
      Offset(inner.right - 60, inner.bottom - 70),
      baselinePaint,
    );
  }

  List<Offset> _pocketCenters() {
    const inset = CarromBoardGame.frameMargin + CarromBoardGame.pocketRadius;
    final far = CarromBoardGame.boardUnits - inset;
    return [
      Offset(inset, inset),
      Offset(far, inset),
      Offset(inset, far),
      Offset(far, far),
    ];
  }
}

enum _BoardTexture { wood, marble, felt, neon }

enum _BorderStyle { wood, thinGold, goldCrown, neonGlow }

class _BoardTheme {
  const _BoardTheme({
    required this.base,
    required this.accent,
    this.accentAlt,
    required this.texture,
    required this.borderStyle,
    required this.lineColor,
  });
  final Color base;
  final Color accent;
  final Color? accentAlt;
  final _BoardTexture texture;
  final _BorderStyle borderStyle;
  final Color lineColor;
}

/// قطعة عادية (white-side أو black-side أو ملكة).
///
/// لون التعبئة [fillColor] يأتي من الـ MatchCosmetics الذي حسبه السيرفر
/// (color_a لـ A، color_b لـ B). الـ [finish] يحدد الـ shader: matte /
/// metallic / jewel / gem. الـ queen دائماً تستخدم اللون القرمزي
/// المعروف (هذا مفروض من server-side هنا أيضاً للحماية).
class PieceComponent extends PositionComponent {
  PieceComponent({
    required this.color,
    required this.fillColor,
    required this.finish,
  }) : anchor = Anchor.center;
  final CarromPieceColor color;
  Color fillColor;
  String finish;

  @override
  Anchor anchor;

  @override
  void render(Canvas canvas) {
    final r = size.x / 2;
    final center = Offset(r, r);

    // ── Multi-layer shadow ─────────────────────────────────────────
    // Soft ambient occlusion + sharper contact shadow gives the
    // illusion of a 3D disk sitting on the table.
    canvas.drawCircle(
      Offset(r + 0.5, r + 3.5),
      r * 1.05,
      Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5),
    );
    canvas.drawCircle(
      Offset(r + 0.3, r + 1.6),
      r * 0.98,
      Paint()
        ..color = const Color(0x44000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );

    if (color == CarromPieceColor.queen) {
      _paintQueen(canvas, center, r);
      return;
    }

    final isLight = _isLight(fillColor);

    // ── Base body — sculpted gradient with proper depth ────────────
    final paint = Paint();
    switch (finish) {
      case 'metallic':
        // Two-stop specular + dim rim to mimic brushed metal.
        paint.shader = RadialGradient(
          colors: [
            Color.lerp(fillColor, Colors.white, 0.55)!,
            Color.lerp(fillColor, Colors.white, 0.20)!,
            fillColor,
            Color.lerp(fillColor, Colors.black, 0.45)!,
          ],
          stops: const [0.0, 0.25, 0.65, 1.0],
          center: const Alignment(-0.40, -0.45),
          radius: 1.05,
        ).createShader(Rect.fromCircle(center: center, radius: r));
        break;
      case 'jewel':
      case 'gem':
        // Sub-surface scattering vibe: bright core, saturated mid, dark edge.
        paint.shader = RadialGradient(
          colors: [
            Color.lerp(fillColor, Colors.white, 0.62)!,
            Color.lerp(fillColor, Colors.white, 0.18)!,
            fillColor,
            Color.lerp(fillColor, Colors.black, 0.28)!,
          ],
          stops: const [0.0, 0.30, 0.70, 1.0],
          center: const Alignment(-0.45, -0.45),
          radius: 1.0,
        ).createShader(Rect.fromCircle(center: center, radius: r));
        break;
      default: // 'matte' or unknown — ivory/wood feel
        paint.shader = RadialGradient(
          colors: [
            Color.lerp(fillColor, Colors.white, 0.30)!,
            Color.lerp(fillColor, Colors.white, 0.05)!,
            fillColor,
            Color.lerp(fillColor, Colors.black, 0.22)!,
          ],
          stops: const [0.0, 0.40, 0.78, 1.0],
          center: const Alignment(-0.35, -0.40),
          radius: 1.05,
        ).createShader(Rect.fromCircle(center: center, radius: r));
    }
    canvas.drawCircle(center, r, paint);

    // ── Beveled inner ring (depth illusion) ────────────────────────
    // A faint dark band inside the rim suggests an embossed edge.
    canvas.drawCircle(
      center,
      r * 0.95,
      Paint()
        ..color = Color.lerp(fillColor, Colors.black, isLight ? 0.18 : 0.50)!
            .withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // ── Outer rim (sharper) ────────────────────────────────────────
    canvas.drawCircle(
      center,
      r - 0.3,
      Paint()
        ..color = Color.lerp(fillColor, Colors.black, isLight ? 0.45 : 0.75)!
            .withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );

    // ── Specular highlights — two oval gleams ──────────────────────
    // Elongated soft glow (sub-surface).
    final softHighlight = Paint()
      ..color = Colors.white.withValues(alpha: isLight ? 0.55 : 0.42)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.save();
    canvas.translate(center.dx - r * 0.35, center.dy - r * 0.40);
    canvas.scale(1.0, 0.55);
    canvas.drawCircle(Offset.zero, r * 0.32, softHighlight);
    canvas.restore();

    // Sharp specular dot (top-left).
    canvas.drawCircle(
      Offset(center.dx - r * 0.42, center.dy - r * 0.48),
      r * 0.10,
      Paint()
        ..color = Colors.white.withValues(alpha: isLight ? 0.95 : 0.80),
    );

    // ── Bottom rim-light (back-scatter for jewel/gem only) ─────────
    if (finish == 'jewel' || finish == 'gem') {
      canvas.drawCircle(
        Offset(center.dx + r * 0.20, center.dy + r * 0.45),
        r * 0.20,
        Paint()
          ..color =
              Color.lerp(fillColor, Colors.white, 0.40)!.withValues(alpha: 0.30)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
    }
  }

  static bool _isLight(Color c) {
    // Standard luma — used to flip rim/highlight strength so white
    // pieces don't get blown out and dark pieces don't lose their edge.
    final luma =
        0.299 * (c.r * 255) + 0.587 * (c.g * 255) + 0.114 * (c.b * 255);
    return luma > 140;
  }

  void _paintQueen(Canvas canvas, Offset center, double r) {
    // ── Queen body — ruby-red with deep sub-surface glow ──────────
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: const [
            Color(0xFFFF8088),
            Color(0xFFE63946),
            Color(0xFFB31E2C),
            Color(0xFF5A0E14),
          ],
          stops: [0.0, 0.30, 0.72, 1.0],
          center: const Alignment(-0.40, -0.45),
          radius: 1.05,
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );

    // ── Beveled inner ring ────────────────────────────────────────
    canvas.drawCircle(
      center,
      r * 0.95,
      Paint()
        ..color = const Color(0xFF7A0A12).withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // ── Outer gold rim — the queen wears a gold band ──────────────
    canvas.drawCircle(
      center,
      r - 0.3,
      Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // ── Subtle ruby caustic at the bottom ─────────────────────────
    canvas.drawCircle(
      Offset(center.dx + r * 0.15, center.dy + r * 0.45),
      r * 0.30,
      Paint()
        ..color = const Color(0xFFFFE3DE).withValues(alpha: 0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    // ── Gold crown emblem (♛) — properly sized to the piece ───────
    final emblemSize = r * 1.15;
    final tp = TextPainter(
      text: TextSpan(
        text: '♛',
        style: TextStyle(
          color: const Color(0xFFFFE7A0),
          fontSize: emblemSize,
          fontWeight: FontWeight.w900,
          shadows: const [
            Shadow(
              color: Color(0x88000000),
              blurRadius: 1.5,
              offset: Offset(0, 0.8),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );

    // ── Top specular gleam ─────────────────────────────────────────
    canvas.save();
    canvas.translate(center.dx - r * 0.35, center.dy - r * 0.45);
    canvas.scale(1.0, 0.55);
    canvas.drawCircle(
      Offset.zero,
      r * 0.30,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
    );
    canvas.restore();

    // ── Sharp top-left specular dot ───────────────────────────────
    canvas.drawCircle(
      Offset(center.dx - r * 0.42, center.dy - r * 0.50),
      r * 0.10,
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );
  }
}

/// الستراكر — يحمل [skinKey] (silver/gold/obsidian/crystal). كل skin له
/// shader مختلف. اللاعب يرى الـ skin الذي اختاره — الخصم يرى مضربه.
class StrikerComponent extends PositionComponent {
  StrikerComponent({required this.skinKey}) : anchor = Anchor.center;
  final String skinKey;

  @override
  Anchor anchor;

  // catalogue mirror (subset, render-only).
  static const Map<String, _StrikerTheme> _themes = {
    'silver': _StrikerTheme(
      base: Color(0xFFC0C0C0),
      special: _StrikerSpecial.standard,
    ),
    'gold': _StrikerTheme(
      base: Color(0xFFFFD700),
      special: _StrikerSpecial.shine,
    ),
    'obsidian': _StrikerTheme(
      base: Color(0xFF1C1C1C),
      special: _StrikerSpecial.matteBlack,
    ),
    'crystal': _StrikerTheme(
      base: Color(0xFFB4E7FF),
      special: _StrikerSpecial.crystal,
    ),
  };

  _StrikerTheme get _theme => _themes[skinKey] ?? _themes['silver']!;

  @override
  void render(Canvas canvas) {
    final r = size.x / 2;
    final center = Offset(r, r);
    final theme = _theme;

    // ── Outer glow halo for premium skins ─────────────────────────
    if (theme.special == _StrikerSpecial.shine) {
      canvas.drawCircle(
        center,
        r * 1.28,
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: 0.40)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    } else if (theme.special == _StrikerSpecial.crystal) {
      canvas.drawCircle(
        center,
        r * 1.30,
        Paint()
          ..color = const Color(0xFFB4E7FF).withValues(alpha: 0.55)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    // ── Multi-layer shadow (proper 3D contact) ────────────────────
    canvas.drawCircle(
      Offset(r + 0.8, r + 4),
      r * 1.08,
      Paint()
        ..color = const Color(0x66000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.5),
    );
    canvas.drawCircle(
      Offset(r + 0.4, r + 2),
      r,
      Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );

    // ── Base body — finish-specific deep shaders ──────────────────
    final paint = Paint();
    switch (theme.special) {
      case _StrikerSpecial.shine:
        // Polished gold — 4-stop gradient mimicking real reflection.
        paint.shader = RadialGradient(
          colors: const [
            Color(0xFFFFF7C2),
            Color(0xFFFFE066),
            Color(0xFFFFD700),
            Color(0xFFA67800),
            Color(0xFF5C4200),
          ],
          stops: [0.0, 0.20, 0.45, 0.82, 1.0],
          center: const Alignment(-0.42, -0.50),
          radius: 1.05,
        ).createShader(Rect.fromCircle(center: center, radius: r));
        break;
      case _StrikerSpecial.matteBlack:
        // Obsidian — deep, low-key, subtle dark transition.
        paint.shader = RadialGradient(
          colors: const [
            Color(0xFF4E4E4E),
            Color(0xFF2A2A2A),
            Color(0xFF111111),
            Color(0xFF000000),
          ],
          stops: [0.0, 0.40, 0.80, 1.0],
          center: const Alignment(-0.35, -0.45),
          radius: 1.05,
        ).createShader(Rect.fromCircle(center: center, radius: r));
        break;
      case _StrikerSpecial.crystal:
        // Crystal — internal refraction look, lots of light.
        paint.shader = RadialGradient(
          colors: const [
            Color(0xFFFFFFFF),
            Color(0xFFEAF8FF),
            Color(0xFFA8E0FF),
            Color(0xFF6CB8E8),
            Color(0xFF3A7CB0),
          ],
          stops: [0.0, 0.25, 0.55, 0.85, 1.0],
          center: const Alignment(-0.35, -0.40),
          radius: 1.0,
        ).createShader(Rect.fromCircle(center: center, radius: r));
        break;
      case _StrikerSpecial.standard:
        // Brushed silver — cool steel with proper depth.
        paint.shader = RadialGradient(
          colors: const [
            Color(0xFFFFFFFF),
            Color(0xFFE0E8F0),
            Color(0xFFA8B5C2),
            Color(0xFF5A6878),
            Color(0xFF2C3A48),
          ],
          stops: [0.0, 0.22, 0.55, 0.85, 1.0],
          center: const Alignment(-0.40, -0.45),
          radius: 1.05,
        ).createShader(Rect.fromCircle(center: center, radius: r));
        break;
    }
    canvas.drawCircle(center, r, paint);

    // ── Beveled inner ring (depth) ────────────────────────────────
    canvas.drawCircle(
      center,
      r * 0.93,
      Paint()
        ..color = Color.lerp(theme.base, Colors.black, 0.50)!
            .withValues(alpha: 0.40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // ── Outer sharp rim ───────────────────────────────────────────
    canvas.drawCircle(
      center,
      r - 0.3,
      Paint()
        ..color = Color.lerp(theme.base, Colors.black, 0.70)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );

    // ── Top specular sweep (elongated highlight) ──────────────────
    canvas.save();
    canvas.translate(center.dx - r * 0.30, center.dy - r * 0.45);
    canvas.rotate(-0.45);
    canvas.scale(1.0, 0.40);
    canvas.drawCircle(
      Offset.zero,
      r * 0.55,
      Paint()
        ..color = Colors.white.withValues(
          alpha: theme.special == _StrikerSpecial.matteBlack ? 0.18 : 0.65,
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );
    canvas.restore();

    // ── Sharp catchlight (top-left dot) ───────────────────────────
    canvas.drawCircle(
      Offset(center.dx - r * 0.44, center.dy - r * 0.52),
      r * 0.12,
      Paint()
        ..color = Colors.white.withValues(
          alpha: theme.special == _StrikerSpecial.matteBlack ? 0.45 : 0.95,
        ),
    );

    // ── Crystal-only: extra sparkle stars ─────────────────────────
    if (theme.special == _StrikerSpecial.crystal) {
      // Bottom-right small twinkle.
      canvas.drawCircle(
        Offset(center.dx + r * 0.30, center.dy + r * 0.25),
        r * 0.08,
        Paint()..color = Colors.white.withValues(alpha: 0.70),
      );
      // Tiny ✦ marker — micro-sparkle vibe.
      final tp = TextPainter(
        text: TextSpan(
          text: '✦',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.80),
            fontSize: r * 0.55,
            fontWeight: FontWeight.w900,
            shadows: const [
              Shadow(color: Color(0x66FFFFFF), blurRadius: 4),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(center.dx + r * 0.12 - tp.width / 2,
            center.dy - r * 0.20 - tp.height / 2),
      );
    }

    // ── Gold-only: subtle inner gold ring inscription ─────────────
    if (theme.special == _StrikerSpecial.shine) {
      canvas.drawCircle(
        center,
        r * 0.78,
        Paint()
          ..color = const Color(0xFFFFE066).withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }

    // ── Bottom rim-light (back-scatter) for non-matte ─────────────
    if (theme.special != _StrikerSpecial.matteBlack) {
      canvas.drawCircle(
        Offset(center.dx + r * 0.15, center.dy + r * 0.50),
        r * 0.22,
        Paint()
          ..color = Color.lerp(theme.base, Colors.white, 0.50)!
              .withValues(alpha: 0.30)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
      );
    }
  }
}

enum _StrikerSpecial { standard, shine, matteBlack, crystal }

class _StrikerTheme {
  const _StrikerTheme({required this.base, required this.special});
  final Color base;
  final _StrikerSpecial special;
}
