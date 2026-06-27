import 'table_geometry.dart';
import 'vec2.dart';

/// A single moving body on the board — a coin, the queen, or the striker.
class Disc {
  Disc({
    required this.id,
    required this.kind,
    required this.spawn,
    required this.radius,
    required this.mass,
    required this.damping,
  })  : pos = spawn.clone(),
        vel = Vec2.zero();

  /// Stable id. Queen is always id 0; the striker uses id -1.
  final int id;
  final DiscKind kind;

  /// Original break position (used to reset / return the queen to centre).
  final Vec2 spawn;

  final double radius;
  final double mass;
  final double damping;

  final Vec2 pos;
  final Vec2 vel;

  /// True once the disc has fallen into a pocket.
  bool potted = false;

  /// Visual sink animation factor, 1 → 0 after pocketing.
  double sink = 1.0;

  bool get isStriker => kind == DiscKind.striker;
  bool get isQueen => kind == DiscKind.queen;
  double get speed => vel.length;

  void stop() {
    vel.x = 0;
    vel.y = 0;
  }

  /// Reset to the break position, fully visible and at rest.
  void resetToSpawn() {
    pos.setFrom(spawn);
    stop();
    potted = false;
    sink = 1.0;
  }

  /// Place at an explicit point (e.g. striker on its baseline) and freeze.
  void placeAt(double x, double y) {
    pos.x = x;
    pos.y = y;
    stop();
    potted = false;
    sink = 1.0;
  }

  static Disc coin(int id, DiscKind kind, Vec2 spawn) => Disc(
        id: id,
        kind: kind,
        spawn: spawn,
        radius: TableGeometry.coinRadius,
        mass: TableGeometry.coinMass,
        damping: TableGeometry.coinDamping,
      );

  static Disc makeStriker(Vec2 spawn) => Disc(
        id: -1,
        kind: DiscKind.striker,
        spawn: spawn,
        radius: TableGeometry.strikerRadius,
        mass: TableGeometry.strikerMass,
        damping: TableGeometry.strikerDamping,
      );
}
