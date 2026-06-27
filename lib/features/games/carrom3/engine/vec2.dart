import 'dart:math' as math;

/// Minimal 2D vector for the hand-written carrom physics engine.
///
/// Deliberately tiny and dependency-free — this module owns its own maths so
/// the engine is "from scratch" (no Box2D / flame_forge2d). Values are doubles
/// in board units (see [TableGeometry]).
class Vec2 {
  Vec2(this.x, this.y);
  factory Vec2.zero() => Vec2(0, 0);

  double x;
  double y;

  Vec2 clone() => Vec2(x, y);

  Vec2 operator +(Vec2 o) => Vec2(x + o.x, y + o.y);
  Vec2 operator -(Vec2 o) => Vec2(x - o.x, y - o.y);
  Vec2 operator *(double s) => Vec2(x * s, y * s);

  double dot(Vec2 o) => x * o.x + y * o.y;

  double get length => math.sqrt(x * x + y * y);
  double get length2 => x * x + y * y;

  Vec2 get normalized {
    final l = length;
    if (l < 1e-9) return Vec2(0, 0);
    return Vec2(x / l, y / l);
  }

  /// In-place accumulate (avoids allocations in the hot loop).
  void addScaled(Vec2 o, double s) {
    x += o.x * s;
    y += o.y * s;
  }

  void scaleInPlace(double s) {
    x *= s;
    y *= s;
  }

  void setFrom(Vec2 o) {
    x = o.x;
    y = o.y;
  }

  static double dist(Vec2 a, Vec2 b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return math.sqrt(dx * dx + dy * dy);
  }
}
