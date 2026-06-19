import 'package:flame_forge2d/flame_forge2d.dart';

import 'board_dimensions.dart';

/// Four static cushion walls forming the playfield perimeter.
///
/// Each cushion is a thick rectangular static body inset from the visual
/// edge by [BoardDims.cushionInset]. Thick walls beat thin edges for two
/// reasons:
///   1. Fast strikers can tunnel through edge fixtures at high speed.
///   2. Box2D resolves stacking contacts more cleanly against thick bodies.
///
/// The four bodies are independent so future variants (e.g. a cushion that
/// dampens shots differently) can swap them out individually.
class BoardWalls extends BodyComponent {
  BoardWalls() : super(renderBody: false);

  @override
  Body createBody() {
    final body = world.createBody(BodyDef(
      type: BodyType.static,
      position: Vector2.zero(),
    ));

    final inner = BoardDims.half - BoardDims.cushionInset;
    final t = BoardDims.cushionHalfThickness;

    // Top cushion (above the playfield, extending into the frame area).
    body.createFixture(FixtureDef(
      PolygonShape()
        ..setAsBox(BoardDims.half, t, Vector2(0, -inner - t), 0),
      friction: BoardDims.bodyFriction,
      restitution: BoardDims.wallRestitution,
      density: 0, // static — density irrelevant
    ));

    // Bottom cushion.
    body.createFixture(FixtureDef(
      PolygonShape()
        ..setAsBox(BoardDims.half, t, Vector2(0, inner + t), 0),
      friction: BoardDims.bodyFriction,
      restitution: BoardDims.wallRestitution,
    ));

    // Left cushion.
    body.createFixture(FixtureDef(
      PolygonShape()
        ..setAsBox(t, BoardDims.half, Vector2(-inner - t, 0), 0),
      friction: BoardDims.bodyFriction,
      restitution: BoardDims.wallRestitution,
    ));

    // Right cushion.
    body.createFixture(FixtureDef(
      PolygonShape()
        ..setAsBox(t, BoardDims.half, Vector2(inner + t, 0), 0),
      friction: BoardDims.bodyFriction,
      restitution: BoardDims.wallRestitution,
    ));

    return body;
  }
}
