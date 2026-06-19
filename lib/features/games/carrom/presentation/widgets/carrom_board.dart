import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

import '../../domain/carrom_state.dart';
import '../../domain/cosmetics.dart';
import '../../domain/piece.dart';
import '../../domain/shot_input.dart';
import '../../domain/shot_result.dart';

// TODO: parent should listen to CarromShotResultEvent.foulReason and
// queenPending and show CarromAlertBanner above the board. The board
// itself stays pure-rendering; the screen scaffold around it is the
// right place to surface server-side rule events because the banner is
// a Flutter widget (not a Flame component) and should overlap the
// GameWidget via a Stack/Positioned in the parent.

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

  /// Frame-to-frame tracker — last frame index we processed for
  /// transient effects (pocket glow, hit sparks). Prevents firing the
  /// same effect 60 times when interpolating between two keyframes.
  int _lastProcessedFrameIdx = -1;

  /// Set of piece ids we've already triggered the pocket-sink animation
  /// for during the current playback. Cleared at the start of each
  /// playback. Without this, drifting interpolation around the pocket
  /// could re-trigger the effect on the same id.
  final Set<int> _animatedPocketIds = {};

  /// True once we've spawned hit-spark particles for this playback. We
  /// only spawn on the FIRST collision frame — repeated collisions
  /// throughout the trajectory would spam the screen.
  bool _hitSparksSpawned = false;

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
    _lastProcessedFrameIdx = -1;
    _animatedPocketIds.clear();
    _hitSparksSpawned = false;
  }

  /// Geometric helpers for transient pocket effects. Mirrors
  /// `_pocketCenters` in [BoardBackground] — both must stay in sync
  /// with the server's POCKET_RADIUS = 18 / pocket placement (see
  /// `app/core/carrom_state.py`).
  List<Vector2> _pocketCentersV2() {
    const inset = frameMargin + pocketRadius;
    final far = boardUnits - inset;
    return [
      Vector2(inset, inset),
      Vector2(far, inset),
      Vector2(inset, far),
      Vector2(far, far),
    ];
  }

  /// One-shot pocket glow — white radial gradient that scales 1→1.3
  /// and fades over 220ms, then auto-removes. Used when a piece centre
  /// crosses within POCKET_RADIUS of a pocket centre (the "swallowed"
  /// moment, before the sink animation completes).
  void _spawnPocketGlow(Vector2 pocketCentre) {
    final glow = _PocketGlowComponent(radius: pocketRadius);
    glow.position = pocketCentre;
    world.add(glow);
  }

  /// Quick expanding gold ring at the pocket as a piece enters — single
  /// CircleParticle wrapped in a ParticleSystemComponent so Flame
  /// handles its lifespan + auto-removal.
  void _spawnPocketRing(Vector2 pocketCentre) {
    final ring = ParticleSystemComponent(
      position: pocketCentre,
      particle: ComputedParticle(
        lifespan: 0.2,
        renderer: (canvas, particle) {
          final t = particle.progress.clamp(0.0, 1.0);
          final r = pocketRadius * (0.0 + t * 1.4);
          final alpha = (0.8 * (1.0 - t)).clamp(0.0, 1.0);
          final paint = Paint()
            ..color = const Color(0xFFFFD86A)
                .withValues(alpha: alpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0
            ..maskFilter =
                const MaskFilter.blur(BlurStyle.normal, 1.5);
          canvas.drawCircle(Offset.zero, r, paint);
        },
      ),
    );
    world.add(ring);
  }

  /// Six tiny gold sparks radiating outward from [centre], each
  /// travelling 30px in its own direction and fading out over 280ms.
  /// Wrapped into a single ParticleSystemComponent → Flame cleans them
  /// up once their lifespan ends (no manual remove needed).
  void _spawnHitSparks(Vector2 centre) {
    final particle = Particle.generate(
      count: 6,
      lifespan: 0.28,
      generator: (i) {
        final angle = (i / 6) * 2 * math.pi;
        final dir = Vector2(math.cos(angle), math.sin(angle));
        return AcceleratedParticle(
          speed: dir * (30 / 0.28), // travel exactly ~30px over lifespan
          child: ComputedParticle(
            renderer: (canvas, p) {
              final t = p.progress.clamp(0.0, 1.0);
              final alpha = (1.0 - t).clamp(0.0, 1.0);
              canvas.drawCircle(
                Offset.zero,
                1.6,
                Paint()
                  ..color = const Color(0xFFFFE07A)
                      .withValues(alpha: alpha)
                  ..maskFilter = const MaskFilter.blur(
                    BlurStyle.normal,
                    1.0,
                  ),
              );
            },
          ),
        );
      },
    );
    world.add(
      ParticleSystemComponent(position: centre, particle: particle),
    );
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

    // ── Frame-crossing detection ──────────────────────────────────────
    // Some transient effects (pocket glow, hit sparks) should fire
    // exactly ONCE per simulated frame, not per Flame tick (we tick at
    // device fps but the simulation is 60 keyframes / 1s). Track when
    // the integer frame index advances and fire once per advance.
    final crossedNewFrame = idxLo != _lastProcessedFrameIdx;
    if (crossedNewFrame) {
      _lastProcessedFrameIdx = idxLo;

      // ── Hit sparks on first real collision ──────────────────────
      // Detection: on the very first frame transition where any
      // non-striker piece has a velocity that jumped from ~0 to >0.
      // We compare consecutive raw frames (lo → hi) — this avoids the
      // false positives that comparing across the whole result would
      // create.
      if (!_hitSparksSpawned && idxLo > 0) {
        final prevPieces = frames[idxLo - 1].pieces;
        final prevMap = {for (final p in prevPieces) p.id: p};
        for (final cur in lo) {
          if (cur.color == CarromPieceColor.striker) continue;
          final prev = prevMap[cur.id];
          if (prev == null) continue;
          final prevSpeed = math.sqrt(prev.vx * prev.vx + prev.vy * prev.vy);
          final curSpeed = math.sqrt(cur.vx * cur.vx + cur.vy * cur.vy);
          // ~0 → >0 means the piece just got struck.
          if (prevSpeed < 0.5 && curSpeed > 0.5) {
            _spawnHitSparks(Vector2(cur.x, cur.y));
            _hitSparksSpawned = true;
            break;
          }
        }
      }
    }

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

    // ── Pocket entry detection + sink animation ──────────────────────
    // For each scored id, the moment its interpolated centre crosses
    // within POCKET_RADIUS of any pocket centre we (a) spawn a glow
    // on that pocket, (b) spawn the expanding gold ring, and (c) play
    // the two-phase sink animation on the piece. The piece component
    // is then auto-removed via RemoveEffect at the tail of the
    // sequence — no leak.
    final pockets = _pocketCentersV2();
    for (final id in scoredSet) {
      if (_animatedPocketIds.contains(id)) continue;
      final comp = _piecesById[id];
      if (comp == null || !comp.isMounted || comp.isRemoving) continue;
      // Find the closest pocket and check distance against the radius.
      Vector2? nearest;
      double bestD2 = double.infinity;
      for (final pc in pockets) {
        final d2 = (comp.position - pc).length2;
        if (d2 < bestD2) {
          bestD2 = d2;
          nearest = pc;
        }
      }
      if (nearest == null) continue;
      // POCKET_RADIUS = 18 (server). We match using the client-side
      // pocketRadius constant (24) because the rendered hole is a
      // little bigger than the physics radius — the visual cue should
      // trigger when the piece visibly enters the hole.
      if (bestD2 <= pocketRadius * pocketRadius) {
        _animatedPocketIds.add(id);
        _piecesById.remove(id);
        _spawnPocketGlow(nearest);
        _spawnPocketRing(nearest);
        // Phase 1: sink (scale 1→0.4 + translate Y +6) over 160ms.
        // Phase 2: vanish (opacity 1→0 + scale 0.4→0.2) over 80ms.
        // Then RemoveEffect cleans up.
        comp.add(
          SequenceEffect(
            [
              ScaleEffect.to(
                Vector2.all(0.4),
                EffectController(duration: 0.16, curve: Curves.easeIn),
              ),
              ScaleEffect.to(
                Vector2.all(0.2),
                EffectController(duration: 0.08, curve: Curves.easeIn),
              ),
              RemoveEffect(),
            ],
          ),
        );
        comp.add(
          MoveEffect.by(
            Vector2(0, 6),
            EffectController(duration: 0.16, curve: Curves.easeIn),
          ),
        );
        comp.add(
          OpacityEffect.to(
            0.0,
            EffectController(
              startDelay: 0.16,
              duration: 0.08,
              curve: Curves.easeIn,
            ),
          ),
        );
      }
    }

    if (progress >= 1.0) {
      // طبّق الـ final state ثم انهِ playback
      _playingResult = null;
      _rebuildPieces(result.finalPieces);
    }
  }
}

/// Transient pocket glow — a white→transparent radial gradient that
/// scales 1.0 → 1.3 while fading from 0.85 → 0 over 220ms, then auto-
/// removes itself. Spawned by [CarromBoardGame] when a piece centre
/// crosses into a pocket.
///
/// Implemented as a PositionComponent (not a Particle) so the
/// rendering pass can read the elapsed-time progress directly without
/// going through the Particle lifespan plumbing — keeps the math
/// transparent for tuning.
class _PocketGlowComponent extends PositionComponent {
  _PocketGlowComponent({required this.radius})
      : super(anchor: Anchor.center, priority: 5);

  final double radius;
  static const double _durationMs = 220;
  double _elapsedMs = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsedMs += dt * 1000;
    if (_elapsedMs >= _durationMs) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final t = (_elapsedMs / _durationMs).clamp(0.0, 1.0);
    final scale = 1.0 + 0.3 * t;
    final alpha = (0.85 * (1.0 - t)).clamp(0.0, 1.0);
    final r = radius * scale;
    final rect = Rect.fromCircle(center: Offset.zero, radius: r);
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        Offset.zero,
        r,
        [
          Colors.white.withValues(alpha: alpha),
          Colors.white.withValues(alpha: 0.0),
        ],
      );
    canvas.drawRect(rect, paint);
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

  // Modeled after real tournament boards (rosewood frame + birch playfield
  // + brass inlays) and modern arena-game UI references. Each theme owns
  // its full palette here so the render switch can pick exact colours
  // for frame edges, inlay rings, baseline strips, center rosette.
  static const Map<String, _BoardTheme> _themes = {
    // Honey-toned tournament wood. Rosewood frame + polished birch face.
    'classic_wood': _BoardTheme(
      base: Color(0xFFE0B179),           // polished honey birch (warmer)
      accent: Color(0xFF5C3416),         // deep walnut frame
      accentAlt: Color(0xFFD4AF37),      // brass inlay rings
      texture: _BoardTexture.wood,
      borderStyle: _BorderStyle.wood,
      lineColor: Color(0xFF6E3F18),
    ),
    // Italian carrara marble + champagne gold. Suite-grade.
    'marble_white': _BoardTheme(
      base: Color(0xFFF8F4ED),
      accent: Color(0xFF8B6A35),         // antique gold frame
      accentAlt: Color(0xFFE8C16A),      // bright gold inlay
      texture: _BoardTexture.marble,
      borderStyle: _BorderStyle.thinGold,
      lineColor: Color(0xFFA3865B),
    ),
    // Royal tournament — deep felt + heavy gold.
    'royal_navy': _BoardTheme(
      base: Color(0xFF152744),           // deeper navy felt
      accent: Color(0xFFE5C77A),         // brushed gold frame
      accentAlt: Color(0xFFFFE3A0),      // bright gold trim
      texture: _BoardTexture.felt,
      borderStyle: _BorderStyle.goldCrown,
      lineColor: Color(0xFFE5C77A),
    ),
    // Cyber arena — pitch black + dual neon.
    'neon_dark': _BoardTheme(
      base: Color(0xFF050817),           // deeper black
      accent: Color(0xFF00F0FF),         // cyan
      accentAlt: Color(0xFFFF2EA0),      // magenta
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

    // ── Outer ambient shadow under the whole board ────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.translate(0, 6),
        const Radius.circular(22),
      ),
      Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // ── Frame: heavy, multi-band, theme-specific ──────────────────
    _paintFrame(canvas, rect, inner, theme);

    // ── Play surface ──────────────────────────────────────────────
    _paintSurface(canvas, inner, theme);

    // ── Inlay strip — bright thin ring around the play area ──────
    // Real boards have a brass/black wood line just inside the frame.
    canvas.drawRRect(
      RRect.fromRectAndRadius(inner.deflate(2), const Radius.circular(6)),
      Paint()
        ..color = (theme.accentAlt ?? theme.accent).withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(inner.deflate(6), const Radius.circular(4)),
      Paint()
        ..color = theme.lineColor.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // ── Striker baseline arcs (theme-specific brass/gold/cyan) ────
    _paintStrikerBaselines(canvas, inner, theme);

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

    // ── Centre rosette — themed, multi-layer ──────────────────────
    _paintCenterRosette(canvas, Offset(size.x / 2, size.y / 2), theme);

    // ── Crown emblems for royal_navy ──────────────────────────────
    if (theme.borderStyle == _BorderStyle.goldCrown) {
      final tp = TextPainter(
        text: TextSpan(
          text: '♛',
          style: TextStyle(
            color: theme.accentAlt ?? theme.accent,
            fontSize: 56,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: theme.accent.withValues(alpha: 0.55),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(size.x / 2 - tp.width / 2, inner.top + 12),
      );
      tp.paint(
        canvas,
        Offset(size.x / 2 - tp.width / 2, inner.bottom - tp.height - 12),
      );
    }

    // ── Straight baselines (a hair away from the arcs) ────────────
    final baselinePaint = Paint()
      ..color = theme.lineColor.withValues(alpha: 0.50)
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(inner.left + 60, inner.top + 72),
      Offset(inner.right - 60, inner.top + 72),
      baselinePaint,
    );
    canvas.drawLine(
      Offset(inner.left + 60, inner.bottom - 72),
      Offset(inner.right - 60, inner.bottom - 72),
      baselinePaint,
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  Theme-specific painters
  // ─────────────────────────────────────────────────────────────────

  /// Frame: heavy multi-band band, per-theme.
  /// Wood gets a 3-band rosewood look. Marble gets a champagne gold
  /// frame with bright inlay. Royal gets brushed gold + filigree
  /// corner studs. Neon gets dual cyan/magenta glow rings.
  void _paintFrame(
    Canvas canvas,
    Rect rect,
    Rect inner,
    _BoardTheme theme,
  ) {
    // 1) Base frame (theme-specific gradient).
    final framePaint = Paint();
    switch (theme.borderStyle) {
      case _BorderStyle.wood:
        // Rosewood — deep walnut with grain hint.
        framePaint.shader = LinearGradient(
          colors: [
            const Color(0xFF7A4A22),
            theme.accent,                 // deep walnut
            const Color(0xFF3A1F0C),
            theme.accent,
            const Color(0xFF5A2F12),
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect);
        break;
      case _BorderStyle.thinGold:
        // Antique champagne gold — 3 stops with proper shine.
        framePaint.shader = LinearGradient(
          colors: [
            const Color(0xFFE8C16A),
            theme.accent,
            const Color(0xFFC9A04F),
            theme.accent,
            const Color(0xFFB8924A),
          ],
          stops: const [0.0, 0.3, 0.55, 0.8, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect);
        break;
      case _BorderStyle.goldCrown:
        // Brushed royal gold — bright on top, darker on bottom.
        framePaint.shader = LinearGradient(
          colors: [
            const Color(0xFFFFE3A0),
            theme.accent,
            const Color(0xFFB3933A),
            theme.accent,
            const Color(0xFF8B6E2C),
          ],
          stops: const [0.0, 0.25, 0.55, 0.78, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect);
        break;
      case _BorderStyle.neonGlow:
        // Outer halo (cyan).
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(4), const Radius.circular(22)),
          Paint()
            ..color = theme.accent.withValues(alpha: 0.55)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
        );
        // Outer halo (magenta).
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(2), const Radius.circular(20)),
          Paint()
            ..color = (theme.accentAlt ?? theme.accent).withValues(alpha: 0.40)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
        framePaint.color = const Color(0xFF0A0A18);
        break;
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(18)),
      framePaint,
    );

    // 2) Frame inner darkening — fakes a recessed playfield well.
    canvas.drawRRect(
      RRect.fromRectAndRadius(inner.inflate(2), const Radius.circular(8)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // 3) Per-theme frame ornaments.
    switch (theme.borderStyle) {
      case _BorderStyle.wood:
        // Subtle grain stripes on the frame band.
        for (int i = 0; i < 6; i++) {
          final dy = rect.top + 4 + i * 2.5;
          canvas.drawLine(
            Offset(rect.left + 10, dy),
            Offset(rect.right - 10, dy),
            Paint()
              ..color = Colors.black.withValues(alpha: 0.10)
              ..strokeWidth = 0.6,
          );
          final dyB = rect.bottom - 4 - i * 2.5;
          canvas.drawLine(
            Offset(rect.left + 10, dyB),
            Offset(rect.right - 10, dyB),
            Paint()
              ..color = Colors.black.withValues(alpha: 0.10)
              ..strokeWidth = 0.6,
          );
        }
        break;
      case _BorderStyle.goldCrown:
        // Corner filigree studs (gold dots in each corner).
        const studPositions = [
          Offset(0.04, 0.04),
          Offset(0.96, 0.04),
          Offset(0.04, 0.96),
          Offset(0.96, 0.96),
        ];
        for (final p in studPositions) {
          final c = Offset(
            rect.left + rect.width * p.dx,
            rect.top + rect.height * p.dy,
          );
          canvas.drawCircle(
            c,
            4.5,
            Paint()..color = (theme.accentAlt ?? theme.accent),
          );
          canvas.drawCircle(
            c,
            4.5,
            Paint()
              ..color = Colors.black.withValues(alpha: 0.55)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.8,
          );
          canvas.drawCircle(
            c.translate(-1.2, -1.4),
            1.4,
            Paint()..color = Colors.white.withValues(alpha: 0.85),
          );
        }
        break;
      case _BorderStyle.neonGlow:
        // Hex-vertex accents (4 tiny cyan diamonds on the inner frame).
        final diamondPositions = [
          Offset(rect.center.dx, rect.top + 8),
          Offset(rect.center.dx, rect.bottom - 8),
          Offset(rect.left + 8, rect.center.dy),
          Offset(rect.right - 8, rect.center.dy),
        ];
        for (final c in diamondPositions) {
          final path = Path()
            ..moveTo(c.dx, c.dy - 4)
            ..lineTo(c.dx + 4, c.dy)
            ..lineTo(c.dx, c.dy + 4)
            ..lineTo(c.dx - 4, c.dy)
            ..close();
          canvas.drawPath(
            path,
            Paint()
              ..color = theme.accent
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
          );
        }
        break;
      case _BorderStyle.thinGold:
        // Slim brass rivets on each frame side (3 per side).
        for (int i = 0; i < 3; i++) {
          final f = (i + 1) / 4;
          final positions = [
            Offset(rect.left + rect.width * f, rect.top + 6),
            Offset(rect.left + rect.width * f, rect.bottom - 6),
            Offset(rect.left + 6, rect.top + rect.height * f),
            Offset(rect.right - 6, rect.top + rect.height * f),
          ];
          for (final c in positions) {
            canvas.drawCircle(
              c,
              2.4,
              Paint()..color = (theme.accentAlt ?? theme.accent),
            );
            canvas.drawCircle(
              c.translate(-0.6, -0.7),
              0.8,
              Paint()..color = Colors.white.withValues(alpha: 0.85),
            );
          }
        }
        break;
    }
  }

  /// Play surface — wood/marble/felt/neon — with real materiality.
  void _paintSurface(Canvas canvas, Rect inner, _BoardTheme theme) {
    final playPaint = Paint();
    switch (theme.texture) {
      case _BoardTexture.wood:
        // Honey birch with sun glow + vignette.
        playPaint.shader = RadialGradient(
          colors: [
            Color.lerp(theme.base, Colors.white, 0.18)!,
            theme.base,
            Color.lerp(theme.base, const Color(0xFF7A4A22), 0.30)!,
          ],
          stops: const [0.0, 0.55, 1.0],
          center: const Alignment(-0.20, -0.25),
          radius: 1.05,
        ).createShader(inner);
        break;
      case _BoardTexture.marble:
        playPaint.shader = RadialGradient(
          colors: [
            const Color(0xFFFFFFFF),
            theme.base,
            const Color(0xFFEDE6D8),
            const Color(0xFFD8CFB8),
          ],
          stops: const [0.0, 0.45, 0.85, 1.0],
          center: const Alignment(-0.2, -0.3),
          radius: 1.1,
        ).createShader(inner);
        break;
      case _BoardTexture.felt:
        playPaint.shader = RadialGradient(
          colors: [
            Color.lerp(theme.base, Colors.white, 0.08)!,
            theme.base,
            Color.lerp(theme.base, Colors.black, 0.40)!,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(inner);
        break;
      case _BoardTexture.neon:
        // Black with very subtle cyan radial bleed.
        playPaint.shader = RadialGradient(
          colors: [
            const Color(0xFF0F1430),
            theme.base,
            const Color(0xFF000000),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(inner);
        break;
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(inner, const Radius.circular(8)),
      playPaint,
    );

    // ── Texture overlays (theme-specific) ─────────────────────────
    switch (theme.texture) {
      case _BoardTexture.wood:
        _paintWoodGrain(canvas, inner);
        break;
      case _BoardTexture.marble:
        _paintMarbleVeining(canvas, inner);
        break;
      case _BoardTexture.felt:
        _paintFeltPattern(canvas, inner);
        break;
      case _BoardTexture.neon:
        _paintHexGrid(canvas, inner, theme);
        break;
    }
  }

  /// Long, denser, multi-pass wood grain with knots.
  void _paintWoodGrain(Canvas canvas, Rect inner) {
    final grain = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    // Layer 1: thin dark grain.
    for (int i = 0; i < 22; i++) {
      final y = inner.top + (inner.height / 22) * i + 3;
      final path = Path()..moveTo(inner.left + 4, y);
      for (double x = inner.left + 4; x <= inner.right - 4; x += 4) {
        final yWave = y + math.sin((x + i * 31) * 0.035) * 1.8;
        path.lineTo(x, yWave);
      }
      grain.color = (i % 3 == 0
              ? const Color(0xFF5A3315)
              : const Color(0xFF8B5A2B))
          .withValues(alpha: i.isEven ? 0.10 : 0.05);
      canvas.drawPath(path, grain);
    }
    // Layer 2: 6 deterministic knots.
    const knots = [
      Offset(0.18, 0.32),
      Offset(0.72, 0.22),
      Offset(0.35, 0.68),
      Offset(0.82, 0.78),
      Offset(0.55, 0.45),
      Offset(0.12, 0.85),
    ];
    for (final k in knots) {
      final kp = Offset(
        inner.left + inner.width * k.dx,
        inner.top + inner.height * k.dy,
      );
      // Dark knot core.
      canvas.drawCircle(
        kp,
        2.5,
        Paint()..color = const Color(0xFF3A1F0C).withValues(alpha: 0.30),
      );
      // Soft halo around knot.
      canvas.drawCircle(
        kp,
        5.0,
        Paint()
          ..color = const Color(0xFF5A3315).withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
      );
    }
  }

  /// Carrara-style marble veining (3 organic Bezier paths + faint dots).
  void _paintMarbleVeining(Canvas canvas, Rect inner) {
    // Path 1: thick gray vein.
    final v1 = Paint()
      ..color = const Color(0xFFAFAAA0).withValues(alpha: 0.50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final p1 = Path()
      ..moveTo(inner.left + inner.width * 0.05, inner.top + 16)
      ..cubicTo(
        inner.center.dx - 60, inner.top + 80,
        inner.center.dx + 30, inner.center.dy - 20,
        inner.right - 30, inner.bottom - 110,
      );
    canvas.drawPath(p1, v1);

    // Path 2: thin gold vein.
    final v2 = Paint()
      ..color = const Color(0xFFC2A06A).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    final p2 = Path()
      ..moveTo(inner.right - 22, inner.top + 40)
      ..cubicTo(
        inner.center.dx + 40, inner.center.dy - 80,
        inner.center.dx - 60, inner.center.dy + 30,
        inner.left + 50, inner.bottom - 40,
      );
    canvas.drawPath(p2, v2);

    // Path 3: secondary dark vein.
    final v3 = Paint()
      ..color = const Color(0xFF8A8478).withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    final p3 = Path()
      ..moveTo(inner.left + inner.width * 0.55, inner.top + 20)
      ..quadraticBezierTo(
        inner.center.dx + 20, inner.center.dy,
        inner.center.dx - 80, inner.bottom - 20,
      );
    canvas.drawPath(p3, v3);

    // Subtle dot speckle.
    const speckles = [
      Offset(0.22, 0.28), Offset(0.78, 0.16), Offset(0.42, 0.55),
      Offset(0.66, 0.72), Offset(0.15, 0.78), Offset(0.85, 0.62),
      Offset(0.30, 0.40), Offset(0.58, 0.32), Offset(0.48, 0.85),
    ];
    final dot = Paint()
      ..color = const Color(0xFF8A8478).withValues(alpha: 0.35);
    for (final s in speckles) {
      canvas.drawCircle(
        Offset(
          inner.left + inner.width * s.dx,
          inner.top + inner.height * s.dy,
        ),
        0.8,
        dot,
      );
    }
  }

  /// Felt: dense subtle weave + radial vignette.
  void _paintFeltPattern(Canvas canvas, Rect inner) {
    final dot = Paint()
      ..color = Colors.white.withValues(alpha: 0.045);
    for (int gy = 0; gy < 38; gy++) {
      for (int gx = 0; gx < 38; gx++) {
        final dx = inner.left + (inner.width / 38) * gx + (gy.isOdd ? 3 : 0);
        final dy = inner.top + (inner.height / 38) * gy + 3;
        if (dx > inner.right - 4 || dy > inner.bottom - 4) continue;
        canvas.drawCircle(Offset(dx, dy), 0.55, dot);
      }
    }
    // Strong vignette for premium felt feel.
    canvas.drawRect(
      inner,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.35),
          ],
          stops: const [0.0, 0.60, 1.0],
        ).createShader(inner),
    );
  }

  /// Neon: hex-style grid pattern.
  void _paintHexGrid(Canvas canvas, Rect inner, _BoardTheme theme) {
    final grid = Paint()
      ..color = theme.accent.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    const cell = 28.0;
    for (double y = inner.top; y < inner.bottom; y += cell * 0.866) {
      final row = ((y - inner.top) / (cell * 0.866)).floor();
      for (double x = inner.left + (row.isOdd ? cell * 0.5 : 0);
          x < inner.right;
          x += cell) {
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final angle = i * math.pi / 3 + math.pi / 6;
          final px = x + cell * 0.30 * math.cos(angle);
          final py = y + cell * 0.30 * math.sin(angle);
          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, grid);
      }
    }
    // Subtle scan-line at center.
    canvas.drawLine(
      Offset(inner.left + 20, inner.center.dy),
      Offset(inner.right - 20, inner.center.dy),
      Paint()
        ..color = (theme.accentAlt ?? theme.accent).withValues(alpha: 0.10)
        ..strokeWidth = 0.5,
    );
  }

  /// Striker arc on each player's baseline — 2 short arcs per side.
  void _paintStrikerBaselines(Canvas canvas, Rect inner, _BoardTheme theme) {
    final paint = Paint()
      ..color = (theme.accentAlt ?? theme.accent).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    // Top baseline (small dot in middle + 2 lateral marks)
    void drawSideMark(double y, bool top) {
      final cx = inner.center.dx;
      final yLine = top ? y : y;
      // Mid dot.
      canvas.drawCircle(Offset(cx, yLine), 2.2, Paint()..color = paint.color);
      // Two flanking marks ~ 80 units from center.
      for (final dx in [-78.0, 78.0]) {
        canvas.drawLine(
          Offset(cx + dx, yLine - 4),
          Offset(cx + dx, yLine + 4),
          paint,
        );
      }
    }

    drawSideMark(inner.top + 72, true);
    drawSideMark(inner.bottom - 72, false);
  }

  /// Center rosette — themed, layered.
  void _paintCenterRosette(Canvas canvas, Offset center, _BoardTheme theme) {
    // 1) Outer ring.
    canvas.drawCircle(
      center,
      28,
      Paint()
        ..color = (theme.accentAlt ?? theme.accent).withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // 2) Mid ring — themed.
    canvas.drawCircle(
      center,
      22,
      Paint()
        ..color = centerRing.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // 3) 8 small dots around the ring — a "star" effect.
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi;
      final p = Offset(
        center.dx + 22 * math.cos(angle),
        center.dy + 22 * math.sin(angle),
      );
      canvas.drawCircle(
        p,
        1.5,
        Paint()
          ..color = (theme.accentAlt ?? theme.accent).withValues(alpha: 0.85),
      );
    }
    // 4) Inner red dot — where the queen will sit.
    canvas.drawCircle(
      center,
      8,
      Paint()..color = centerRing.withValues(alpha: 0.55),
    );
    canvas.drawCircle(
      center,
      3.5,
      Paint()..color = centerRing,
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
class PieceComponent extends PositionComponent implements OpacityProvider {
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

  /// Component-level opacity (0..1). Driven by Flame's [OpacityEffect]
  /// during the pocket sink animation. Implemented manually because
  /// [PieceComponent] does its own rendering and doesn't use the
  /// [HasPaint] mixin.
  double _opacity = 1.0;

  @override
  double get opacity => _opacity;

  @override
  set opacity(double value) {
    _opacity = value.clamp(0.0, 1.0);
  }

  @override
  void render(Canvas canvas) {
    if (_opacity <= 0.0) return;
    // Apply opacity via a saveLayer wrapper so every paint call in the
    // hand-rolled body below is uniformly faded. This is necessary
    // because each paint constructs its own Paint() — there's no
    // single component-wide paint to set alpha on.
    final r = size.x / 2;
    final useLayer = _opacity < 1.0;
    if (useLayer) {
      final bounds = Rect.fromLTWH(0, 0, size.x, size.y).inflate(r * 0.5);
      final layerPaint = Paint()
        ..color = Color.fromRGBO(0, 0, 0, _opacity);
      canvas.saveLayer(bounds, layerPaint);
    }
    _renderBody(canvas, r);
    if (useLayer) {
      canvas.restore();
    }
  }

  void _renderBody(Canvas canvas, double r) {
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

    // ── Embossed central seal — gives every piece a maker's-mark ──
    // Real tournament pieces have a faint impressed mark in the
    // middle. We draw a tiny dot ring (3 rings) with a subtle highlight.
    canvas.drawCircle(
      center,
      r * 0.32,
      Paint()
        ..color = Color.lerp(fillColor, Colors.black, isLight ? 0.18 : 0.55)!
            .withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );
    canvas.drawCircle(
      center,
      r * 0.18,
      Paint()
        ..color = Color.lerp(fillColor, Colors.black, isLight ? 0.10 : 0.40)!
            .withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
    canvas.drawCircle(
      center,
      r * 0.06,
      Paint()
        ..color = Color.lerp(fillColor, Colors.white, 0.40)!
            .withValues(alpha: 0.55),
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
