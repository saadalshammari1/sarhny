import 'dart:math' as math;

import 'disc.dart';
import 'table_geometry.dart';
import 'vec2.dart';

/// The settled result of one shot — handed to the match controller for scoring.
class ShotOutcome {
  ShotOutcome({
    required this.pocketedIds,
    required this.strikerPocketed,
    required this.queenPocketed,
    required this.firstHitId,
    required this.seconds,
  });

  final List<int> pocketedIds;
  final bool strikerPocketed;
  final bool queenPocketed;

  /// First piece the striker touched (queen = 0, coins 1..18). -1 = none.
  final int firstHitId;
  final double seconds;
}

enum EnginePhase { idle, simulating }

/// Predicted aim path: a poly-line (board units) plus, if the striker would
/// strike a piece, the piece centre and the striker centre at contact.
class AimPrediction {
  AimPrediction(this.points, this.hitPieceCentre, this.strikerAtHit);
  final List<Vec2> points;
  final Vec2? hitPieceCentre;
  final Vec2? strikerAtHit;
}

/// Hand-written top-down carrom physics — no Box2D, no flame.
///
/// Semi-implicit Euler with fixed sub-steps for stable collisions: integrate →
/// damp → cushions → disc/disc impulses → pocket capture → settle test.
class CarromEngine {
  CarromEngine() {
    _buildBreak();
    striker = Disc.makeStriker(
      Vec2(TableGeometry.playCenter, TableGeometry.baselineY(Seat.you)),
    );
  }

  final List<Disc> pieces = []; // 9 white + 9 black + queen(id 0)
  late Disc striker;
  final List<Vec2> _pockets = TableGeometry.pockets();

  EnginePhase phase = EnginePhase.idle;

  // ── Sound / event hooks (wired by the page; all optional) ──────────────
  void Function()? onStrike;
  void Function(double intensity)? onCollide; // 0..1-ish
  void Function(DiscKind kind)? onPocket;

  // ── Per-shot accumulators ──────────────────────────────────────────────
  final List<int> _pocketedThisShot = [];
  bool _strikerPocketed = false;
  bool _queenPocketed = false;
  bool _firstHitSet = false;
  int _firstHitId = -1;
  double _elapsed = 0;

  /// FIXED simulation timestep. Stepping a fixed h (rather than the variable
  /// frame dt) makes the simulation DETERMINISTIC across machines — essential
  /// for the online lockstep, where both clients replay the same shot and must
  /// land on byte-identical board states regardless of their frame rates. 1/240
  /// keeps the original fine resolution (the fast striker moves ~10u/step, well
  /// under the ~37u collision radius, so no tunneling).
  static const double _fixedH = 1 / 240.0;
  double _accum = 0;

  // ── Setup ───────────────────────────────────────────────────────────────

  void _buildBreak() {
    pieces.clear();
    final c = Vec2(TableGeometry.playCenter, TableGeometry.playCenter);
    final r = TableGeometry.coinRadius;
    // Queen at the centre.
    pieces.add(Disc.coin(0, DiscKind.queen, c.clone()));

    var id = 1;
    // Inner ring of 6, alternating black/white.
    final r1 = 2 * r + 0.6;
    for (var i = 0; i < 6; i++) {
      final a = (math.pi / 3) * i - math.pi / 2;
      final p = Vec2(c.x + r1 * math.cos(a), c.y + r1 * math.sin(a));
      pieces.add(Disc.coin(id, i.isEven ? DiscKind.black : DiscKind.white, p));
      id++;
    }
    // Outer ring of 12, alternating.
    final r2 = 4 * r + 1.2;
    for (var i = 0; i < 12; i++) {
      final a = (math.pi / 6) * i - math.pi / 2;
      final p = Vec2(c.x + r2 * math.cos(a), c.y + r2 * math.sin(a));
      pieces.add(Disc.coin(id, i.isEven ? DiscKind.black : DiscKind.white, p));
      id++;
    }
  }

  /// Fresh break + striker on the [seat] baseline (defaults to bottom/you).
  void resetBreak({Seat seat = Seat.you}) {
    for (final p in pieces) {
      p.resetToSpawn();
    }
    prepareStriker(seat);
    _clearAccumulators();
    phase = EnginePhase.idle;
  }

  /// Un-pocket the queen back to the centre (failed cover).
  void returnQueen() {
    final q = pieces[0];
    q
      ..potted = false
      ..sink = 1.0;
    q.pos.setFrom(q.spawn);
    q.stop();
  }

  /// Position the striker on a seat's baseline, ready to aim.
  void prepareStriker(Seat seat, {double atX = TableGeometry.playCenter}) {
    final x = atX.clamp(TableGeometry.strikerMinX, TableGeometry.strikerMaxX);
    striker.placeAt(x, TableGeometry.baselineY(seat));
  }

  /// Slide the striker along its current baseline while aiming (idle only).
  void moveStriker(double x) {
    if (phase != EnginePhase.idle) return;
    striker.pos.x =
        x.clamp(TableGeometry.strikerMinX, TableGeometry.strikerMaxX);
    striker.stop();
  }

  void _clearAccumulators() {
    _pocketedThisShot.clear();
    _strikerPocketed = false;
    _queenPocketed = false;
    _firstHitSet = false;
    _firstHitId = -1;
    _elapsed = 0;
    _accum = 0;
  }

  // ── Firing ──────────────────────────────────────────────────────────────

  void fireStriker(Vec2 direction, double power) {
    if (phase != EnginePhase.idle) return;
    _clearAccumulators();
    final dir = direction.normalized;
    final speed = power.clamp(0.0, 1.0) * TableGeometry.maxStrikerSpeed;
    striker
      ..potted = false
      ..sink = 1.0;
    striker.vel
      ..x = dir.x * speed
      ..y = dir.y * speed;
    phase = EnginePhase.simulating;
    onStrike?.call();
  }

  // ── Simulation tick — returns an outcome on the frame the shot settles ───

  ShotOutcome? update(double dt) {
    _animateSinks(dt);
    if (phase != EnginePhase.simulating) return null;

    // Advance in FIXED-size steps via an accumulator. The number of physics
    // steps to settle then depends ONLY on the shot (not on frame timing), so
    // two clients replaying the same shot land on identical boards. The step
    // cap spreads a slow frame's backlog over the next frames without changing
    // the eventual outcome.
    _accum += dt;
    var steps = 0;
    while (_accum >= _fixedH && steps < 16) {
      _substep(_fixedH);
      _elapsed += _fixedH;
      steps++;
      if (_maxSpeed() < TableGeometry.restSpeed ||
          _elapsed > TableGeometry.maxShotSeconds) {
        phase = EnginePhase.idle;
        _accum = 0;
        return _finish();
      }
    }
    return null;
  }

  Iterable<Disc> get _active sync* {
    if (!striker.potted) yield striker;
    for (final p in pieces) {
      if (!p.potted) yield p;
    }
  }

  void _substep(double h) {
    final bodies = _active.toList(growable: false);

    // 1. Integrate + exponential damping.
    for (final d in bodies) {
      d.pos.addScaled(d.vel, h);
      d.vel.scaleInPlace(math.exp(-d.damping * h));
    }

    // 2. Cushions.
    for (final d in bodies) {
      final lo = TableGeometry.playMin + d.radius;
      final hi = TableGeometry.playMax - d.radius;
      if (d.pos.x < lo) {
        d.pos.x = lo;
        if (d.vel.x < 0) {
          d.vel.x = -d.vel.x * TableGeometry.wallRestitution;
          _wallSound(d);
        }
      } else if (d.pos.x > hi) {
        d.pos.x = hi;
        if (d.vel.x > 0) {
          d.vel.x = -d.vel.x * TableGeometry.wallRestitution;
          _wallSound(d);
        }
      }
      if (d.pos.y < lo) {
        d.pos.y = lo;
        if (d.vel.y < 0) {
          d.vel.y = -d.vel.y * TableGeometry.wallRestitution;
          _wallSound(d);
        }
      } else if (d.pos.y > hi) {
        d.pos.y = hi;
        if (d.vel.y > 0) {
          d.vel.y = -d.vel.y * TableGeometry.wallRestitution;
          _wallSound(d);
        }
      }
    }

    // 3. Disc–disc impulses.
    for (var i = 0; i < bodies.length; i++) {
      for (var j = i + 1; j < bodies.length; j++) {
        _resolvePair(bodies[i], bodies[j]);
      }
    }

    // 4. Pocket capture.
    for (final d in bodies) {
      if (d.potted) continue;
      for (final pk in _pockets) {
        if (Vec2.dist(d.pos, pk) < TableGeometry.pocketRadius) {
          _capture(d);
          break;
        }
      }
    }
  }

  void _resolvePair(Disc a, Disc b) {
    final nx = b.pos.x - a.pos.x;
    final ny = b.pos.y - a.pos.y;
    final d2 = nx * nx + ny * ny;
    final minD = a.radius + b.radius;
    if (d2 >= minD * minD || d2 < 1e-9) return;

    final d = math.sqrt(d2);
    final ux = nx / d;
    final uy = ny / d;
    final invA = 1 / a.mass;
    final invB = 1 / b.mass;
    final invSum = invA + invB;

    // Positional correction (separate the overlap by inverse mass).
    final overlap = minD - d;
    a.pos.x -= ux * overlap * (invA / invSum);
    a.pos.y -= uy * overlap * (invA / invSum);
    b.pos.x += ux * overlap * (invB / invSum);
    b.pos.y += uy * overlap * (invB / invSum);

    // Relative velocity along the contact normal.
    final rvx = b.vel.x - a.vel.x;
    final rvy = b.vel.y - a.vel.y;
    final rel = rvx * ux + rvy * uy;
    if (rel >= 0) return; // separating

    final e = TableGeometry.coinRestitution;
    final jImp = -(1 + e) * rel / invSum;
    a.vel.x -= ux * jImp * invA;
    a.vel.y -= uy * jImp * invA;
    b.vel.x += ux * jImp * invB;
    b.vel.y += uy * jImp * invB;

    // First striker→piece contact + collision sound.
    if (!_firstHitSet) {
      if (a.isStriker && !b.isStriker) {
        _firstHitId = b.id;
        _firstHitSet = true;
      } else if (b.isStriker && !a.isStriker) {
        _firstHitId = a.id;
        _firstHitSet = true;
      }
    }
    onCollide?.call((-rel) / 1400.0);
  }

  void _capture(Disc d) {
    d.potted = true;
    if (d.isStriker) {
      _strikerPocketed = true;
    } else {
      _pocketedThisShot.add(d.id);
      if (d.isQueen) _queenPocketed = true;
    }
    onPocket?.call(d.kind);
  }

  void _wallSound(Disc d) {
    final v = d.speed;
    if (v > 120) onCollide?.call(v / 1400.0);
  }

  void _animateSinks(double dt) {
    for (final p in pieces) {
      if (p.potted && p.sink > 0) {
        p.sink = (p.sink - dt / TableGeometry.sinkSeconds).clamp(0.0, 1.0);
      }
    }
    if (striker.potted && striker.sink > 0) {
      striker.sink =
          (striker.sink - dt / TableGeometry.sinkSeconds).clamp(0.0, 1.0);
    }
  }

  double _maxSpeed() {
    var m = 0.0;
    for (final d in _active) {
      final s = d.speed;
      if (s > m) m = s;
    }
    return m;
  }

  ShotOutcome _finish() => ShotOutcome(
        pocketedIds: List.unmodifiable(_pocketedThisShot),
        strikerPocketed: _strikerPocketed,
        queenPocketed: _queenPocketed,
        firstHitId: _firstHitSet ? _firstHitId : -1,
        seconds: _elapsed,
      );

  // ── Aim prediction (reflecting raycast → first piece) ───────────────────

  AimPrediction predict(Vec2 start, Vec2 dir, {double maxLen = 520}) {
    const eps = 1e-4;
    final lo = TableGeometry.playMin + striker.radius;
    final hi = TableGeometry.playMax - striker.radius;
    final hitDist = striker.radius + TableGeometry.coinRadius;

    final centres = <Vec2>[
      for (final p in pieces)
        if (!p.potted) p.pos,
    ];

    var pos = start.clone();
    var dx = dir.x;
    var dy = dir.y;
    final dl = math.sqrt(dx * dx + dy * dy);
    if (dl < eps) return AimPrediction([start.clone()], null, null);
    dx /= dl;
    dy /= dl;

    var remaining = maxLen;
    final pts = <Vec2>[start.clone()];
    Vec2? hitCentre;
    Vec2? strikerAt;
    var bounces = 0;

    while (remaining > eps && bounces <= 3) {
      // Nearest cushion.
      var tWall = double.infinity;
      int? axis;
      if (dx > eps) {
        final t = (hi - pos.x) / dx;
        if (t > eps && t < tWall) {
          tWall = t;
          axis = 0;
        }
      } else if (dx < -eps) {
        final t = (lo - pos.x) / dx;
        if (t > eps && t < tWall) {
          tWall = t;
          axis = 0;
        }
      }
      if (dy > eps) {
        final t = (hi - pos.y) / dy;
        if (t > eps && t < tWall) {
          tWall = t;
          axis = 1;
        }
      } else if (dy < -eps) {
        final t = (lo - pos.y) / dy;
        if (t > eps && t < tWall) {
          tWall = t;
          axis = 1;
        }
      }

      // Nearest piece.
      var tPiece = double.infinity;
      Vec2? piece;
      for (final c in centres) {
        final fx = pos.x - c.x;
        final fy = pos.y - c.y;
        final b = 2 * (fx * dx + fy * dy);
        final cc = fx * fx + fy * fy - hitDist * hitDist;
        final disc = b * b - 4 * cc;
        if (disc < 0) continue;
        final t = (-b - math.sqrt(disc)) / 2;
        if (t > eps && t < tPiece) {
          tPiece = t;
          piece = c;
        }
      }

      final tSeg = math.min(math.min(tWall, tPiece), remaining);
      final next = Vec2(pos.x + dx * tSeg, pos.y + dy * tSeg);
      pts.add(next);

      if (tPiece <= tWall && tPiece <= remaining && piece != null) {
        hitCentre = piece;
        strikerAt = next;
        break;
      }
      if (tWall <= remaining && axis != null) {
        if (axis == 0) {
          dx = -dx;
        } else {
          dy = -dy;
        }
        pos = next;
        remaining -= tSeg;
        bounces++;
        continue;
      }
      break;
    }
    return AimPrediction(pts, hitCentre, strikerAt);
  }
}
