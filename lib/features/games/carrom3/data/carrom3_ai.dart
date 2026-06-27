import 'dart:math' as math;

import '../engine/carrom_engine.dart';
import '../engine/disc.dart';
import '../engine/table_geometry.dart';
import '../engine/vec2.dart';

/// A planned AI shot for the carrom3 engine.
class Carrom3Plan {
  Carrom3Plan({
    required this.placeX,
    required this.direction,
    required this.power,
  });
  final double placeX;
  final Vec2 direction;
  final double power;
}

/// Heuristic opponent. For every own-colour (or queen) target and every pocket
/// it finds the "ghost" contact point, samples striker placements along its
/// baseline, and scores each by how straight the pot is and how clear the lane
/// is. The winner is degraded by a [skill]-driven jitter so it misses
/// believably rather than playing perfectly.
class Carrom3Ai {
  Carrom3Ai({this.skill = 0.8, math.Random? rng})
      : _rng = rng ?? math.Random();

  final double skill;
  final math.Random _rng;

  Carrom3Plan plan(
    CarromEngine engine, {
    required Seat aiSeat,
    required DiscKind aiColor,
  }) {
    final baselineY = TableGeometry.baselineY(aiSeat);
    final pockets = TableGeometry.pockets();
    final targets = engine.pieces
        .where((p) =>
            !p.potted && (p.kind == aiColor || p.kind == DiscKind.queen))
        .toList();

    _Cand? best;
    const hitDist = TableGeometry.strikerRadius + TableGeometry.coinRadius;

    for (final p in targets) {
      final pc = p.pos;
      for (final k in pockets) {
        final toX = k.x - pc.x;
        final toY = k.y - pc.y;
        final toLen = math.sqrt(toX * toX + toY * toY);
        if (toLen < 1e-3) continue;
        final tux = toX / toLen;
        final tuy = toY / toLen;
        final ghostX = pc.x - tux * hitDist;
        final ghostY = pc.y - tuy * hitDist;

        for (var s = 0; s <= 8; s++) {
          final x = TableGeometry.strikerMinX +
              (TableGeometry.strikerMaxX - TableGeometry.strikerMinX) * (s / 8);
          final spx = ghostX - x;
          final spy = ghostY - baselineY;
          final spLen = math.sqrt(spx * spx + spy * spy);
          if (spLen < 20) continue;
          final sux = spx / spLen;
          final suy = spy / spLen;
          final alignment = sux * tux + suy * tuy; // 1 = straight pot
          if (alignment <= 0.2) continue;
          final block = _blockPenalty(engine, x, baselineY, ghostX, ghostY, p.id);
          final pocketBonus = p.isQueen ? 0.35 : 0.0;
          final score = alignment -
              block * 0.6 -
              (toLen / TableGeometry.size) * 0.45 -
              (spLen / TableGeometry.size) * 0.30 +
              pocketBonus;
          if (best == null || score > best.score) {
            best = _Cand(score, x, Vec2(sux, suy), spLen + toLen);
          }
        }
      }
    }

    if (best == null) return _fallback(baselineY, targets);

    var power = (0.45 + (best.distance / TableGeometry.size) * 0.55)
        .clamp(0.42, 1.0)
        .toDouble();
    final miss = 1 - skill;
    final ang = (_rng.nextDouble() - 0.5) * miss * 0.22;
    final dir = _rotate(best.direction, ang);
    power = (power + (_rng.nextDouble() - 0.5) * miss * 0.25)
        .clamp(0.4, 1.0)
        .toDouble();
    return Carrom3Plan(placeX: best.placeX, direction: dir, power: power);
  }

  Carrom3Plan _fallback(double baselineY, List<Disc> targets) {
    if (targets.isEmpty) {
      return Carrom3Plan(
        placeX: TableGeometry.playCenter,
        direction: Vec2(0, baselineY < TableGeometry.half ? 1 : -1),
        power: 0.6,
      );
    }
    targets.sort((a, b) {
      final da = (a.pos.x - TableGeometry.playCenter).abs();
      final db = (b.pos.x - TableGeometry.playCenter).abs();
      return da.compareTo(db);
    });
    final t = targets.first.pos;
    final dir = Vec2(t.x - TableGeometry.playCenter, t.y - baselineY).normalized;
    return Carrom3Plan(
      placeX: TableGeometry.playCenter,
      direction: dir,
      power: 0.62,
    );
  }

  double _blockPenalty(CarromEngine e, double fx, double fy, double tx,
      double ty, int ignoreId) {
    final segx = tx - fx;
    final segy = ty - fy;
    final segLen = math.sqrt(segx * segx + segy * segy);
    if (segLen < 1e-3) return 0;
    final ux = segx / segLen;
    final uy = segy / segLen;
    var penalty = 0.0;
    for (final p in e.pieces) {
      if (p.potted || p.id == ignoreId) continue;
      final dx = p.pos.x - fx;
      final dy = p.pos.y - fy;
      final proj = dx * ux + dy * uy;
      if (proj < 0 || proj > segLen) continue;
      final ex = dx - ux * proj;
      final ey = dy - uy * proj;
      final perp = math.sqrt(ex * ex + ey * ey);
      if (perp < TableGeometry.strikerRadius + TableGeometry.coinRadius) {
        penalty += 1.0;
      }
    }
    return penalty;
  }

  Vec2 _rotate(Vec2 v, double a) {
    final ca = math.cos(a);
    final sa = math.sin(a);
    return Vec2(v.x * ca - v.y * sa, v.x * sa + v.y * ca);
  }
}

class _Cand {
  _Cand(this.score, this.placeX, this.direction, this.distance);
  final double score;
  final double placeX;
  final Vec2 direction;
  final double distance;
}
