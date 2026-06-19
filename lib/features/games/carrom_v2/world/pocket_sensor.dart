import 'package:flame_forge2d/flame_forge2d.dart';

import 'board_dimensions.dart';

/// A pocket modelled as a circular sensor (non-colliding body that fires
/// contact events). When any piece body's centre enters the sensor area,
/// the world records that piece as pocketed via a contact callback.
///
/// Why sensor (isSensor=true) instead of a hole:
///   * Sensors detect contact without affecting physics, so pieces don't
///     bounce off the pocket rim — they just fly straight in once their
///     centre crosses the threshold.
///   * The detection radius is slightly smaller than the visual pocket
///     radius (see BoardDims) so the piece visually "drops" before being
///     removed, which gives the animation layer time to play.
class PocketSensor extends BodyComponent {
  PocketSensor({required this.index, required this.pocketCenter})
      : super(renderBody: false);

  /// 0=top-left, 1=top-right, 2=bottom-left, 3=bottom-right.
  final int index;
  final Vector2 pocketCenter;

  @override
  Body createBody() {
    final body = world.createBody(BodyDef(
      type: BodyType.static,
      position: pocketCenter,
      userData: this,
    ));
    body.createFixture(FixtureDef(
      CircleShape()..radius = BoardDims.pocketRadius,
      isSensor: true,
    ));
    return body;
  }
}
