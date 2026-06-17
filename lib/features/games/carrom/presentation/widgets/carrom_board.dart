import 'dart:async';

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

    // ── 4 pockets (always matte black) ────────────────────────────
    final pocketPaint = Paint()..color = const Color(0xFF0A0A0A);
    final pocketRim = Paint()
      ..color = theme.accent.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final c in _pocketCenters()) {
      canvas.drawCircle(c, CarromBoardGame.pocketRadius, pocketPaint);
      canvas.drawCircle(c, CarromBoardGame.pocketRadius - 1.5, pocketRim);
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

    // shadow under
    canvas.drawCircle(
      Offset(r + 1, r + 2),
      r,
      Paint()..color = const Color(0x66000000),
    );

    if (color == CarromPieceColor.queen) {
      _paintQueen(canvas, center, r);
      return;
    }

    // Base body — finish-aware shader.
    final paint = Paint();
    switch (finish) {
      case 'metallic':
        paint.shader = RadialGradient(
          colors: [
            Color.lerp(fillColor, Colors.white, 0.35)!,
            fillColor,
            Color.lerp(fillColor, Colors.black, 0.30)!,
          ],
          stops: const [0.0, 0.55, 1.0],
          center: const Alignment(-0.3, -0.4),
        ).createShader(Rect.fromCircle(center: center, radius: r));
        break;
      case 'jewel':
      case 'gem':
        paint.shader = RadialGradient(
          colors: [
            Color.lerp(fillColor, Colors.white, 0.5)!,
            fillColor,
            Color.lerp(fillColor, Colors.black, 0.18)!,
          ],
          stops: const [0.0, 0.5, 1.0],
          center: const Alignment(-0.4, -0.4),
        ).createShader(Rect.fromCircle(center: center, radius: r));
        break;
      default: // 'matte' or unknown
        paint.shader = RadialGradient(
          colors: [
            Color.lerp(fillColor, Colors.white, 0.20)!,
            fillColor,
          ],
          center: const Alignment(-0.3, -0.4),
        ).createShader(Rect.fromCircle(center: center, radius: r));
    }
    canvas.drawCircle(center, r, paint);

    // Rim.
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = Color.lerp(fillColor, Colors.black, 0.55)!.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Highlight.
    canvas.drawCircle(
      Offset(r - r * 0.35, r - r * 0.35),
      r * 0.20,
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
  }

  void _paintQueen(Canvas canvas, Offset center, double r) {
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: const [Color(0xFFE74C3C), Color(0xFF8E2B22)],
          center: const Alignment(-0.3, -0.4),
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: '✦',
        style: TextStyle(
          color: Color(0xFFFFE7B0),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
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

    // Outer glow for special skins.
    if (theme.special == _StrikerSpecial.shine ||
        theme.special == _StrikerSpecial.crystal) {
      canvas.drawCircle(
        center,
        r * 1.18,
        Paint()
          ..color = theme.base.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    // Shadow.
    canvas.drawCircle(
      Offset(r + 1, r + 2),
      r,
      Paint()..color = const Color(0x77000000),
    );

    // Base body — finish per special.
    final paint = Paint();
    switch (theme.special) {
      case _StrikerSpecial.shine:
        paint.shader = RadialGradient(
          colors: [
            Color.lerp(theme.base, Colors.white, 0.55)!,
            theme.base,
            Color.lerp(theme.base, const Color(0xFF6E4B12), 0.45)!,
          ],
          stops: const [0.0, 0.55, 1.0],
          center: const Alignment(-0.35, -0.4),
        ).createShader(Rect.fromCircle(center: center, radius: r));
        break;
      case _StrikerSpecial.matteBlack:
        paint.shader = RadialGradient(
          colors: const [
            Color(0xFF3A3A3A),
            Color(0xFF1A1A1A),
            Color(0xFF050505),
          ],
          stops: const [0.0, 0.7, 1.0],
          center: const Alignment(-0.3, -0.4),
        ).createShader(Rect.fromCircle(center: center, radius: r));
        break;
      case _StrikerSpecial.crystal:
        paint.shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.95),
            theme.base.withValues(alpha: 0.85),
            theme.base.withValues(alpha: 0.65),
          ],
          stops: const [0.0, 0.5, 1.0],
          center: const Alignment(-0.3, -0.3),
        ).createShader(Rect.fromCircle(center: center, radius: r));
        break;
      case _StrikerSpecial.standard:
        paint.shader = RadialGradient(
          colors: const [
            Color(0xFFEAF0F5),
            Color(0xFF8AA0B5),
            Color(0xFF4A6075),
          ],
          stops: const [0.0, 0.6, 1.0],
          center: const Alignment(-0.3, -0.4),
        ).createShader(Rect.fromCircle(center: center, radius: r));
        break;
    }
    canvas.drawCircle(center, r, paint);

    // Rim.
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = Color.lerp(theme.base, Colors.black, 0.6)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Highlights.
    if (theme.special == _StrikerSpecial.crystal) {
      final sparkle = Paint()..color = Colors.white.withValues(alpha: 0.85);
      canvas.drawCircle(
        Offset(r - r * 0.30, r - r * 0.30),
        r * 0.18,
        sparkle,
      );
      canvas.drawCircle(
        Offset(r + r * 0.25, r + r * 0.20),
        r * 0.10,
        Paint()..color = Colors.white.withValues(alpha: 0.6),
      );
      // a tiny twinkle line
      final twinkle = Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..strokeWidth = 1.4;
      canvas.drawLine(
        Offset(r + r * 0.05, r - r * 0.6),
        Offset(r + r * 0.05, r - r * 0.35),
        twinkle,
      );
    } else {
      canvas.drawCircle(
        Offset(r - r * 0.35, r - r * 0.35),
        r * 0.25,
        Paint()..color = Colors.white.withValues(alpha: 0.7),
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
