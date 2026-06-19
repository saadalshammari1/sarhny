import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/painting.dart';

import 'board_dimensions.dart';

/// The shooter's striker — a larger, heavier dynamic body that the player
/// drags into position and slingshots toward the pieces.
///
/// Separate from PieceBody because:
///   * Different size + density (heavier striker = harder break).
///   * Different visual treatment (metallic gradient + ring).
///   * Different lifecycle (re-placed on the baseline before every shot
///     instead of removed on pocket — a pocketed striker counts as a foul
///     and the body is re-spawned, not deleted).
class StrikerBody extends BodyComponent {
  StrikerBody({required this.spawnPosition, required this.shooterSeat})
      : super(renderBody: false);

  Vector2 spawnPosition;
  final Seat shooterSeat;

  bool pocketed = false;
  double sinkScale = 1.0;

  /// Locks the body kinematic during placement (so it doesn't get pushed
  /// by leftover momentum from a previous shot — yes, this can happen).
  bool placementLocked = true;

  @override
  Body createBody() {
    final body = world.createBody(BodyDef(
      type: BodyType.kinematic, // becomes dynamic when shot fires
      position: spawnPosition.clone(),
      linearDamping: BoardDims.linearDamping * 0.75,
      angularDamping: BoardDims.linearDamping,
      bullet: true, // striker IS fast — CCD prevents tunneling pieces
      userData: this,
    ));
    body.createFixture(FixtureDef(
      CircleShape()..radius = BoardDims.strikerRadius,
      density: BoardDims.strikerDensity,
      friction: BoardDims.bodyFriction,
      restitution: BoardDims.pieceRestitution * 0.85, // slightly less bouncy
    ));
    return body;
  }

  /// Place the striker at a world-space X along the player's baseline.
  /// Caller is responsible for clamping x within [BoardDims.strikerXRange].
  void placeAt(double x) {
    final y = shooterSeat == Seat.a
        ? BoardDims.playerABaselineY
        : BoardDims.playerBBaselineY;
    spawnPosition = Vector2(x, y);
    body.setTransform(spawnPosition, 0);
    body.linearVelocity = Vector2.zero();
    body.angularVelocity = 0;
  }

  /// Switch from placement (kinematic, frozen) to live (dynamic, accepts
  /// impulses) and apply the shot impulse.
  void fireShot({required Vector2 impulseDirection, required double power}) {
    placementLocked = false;
    body.setType(BodyType.dynamic);
    final magnitude = power.clamp(0.0, 1.0) * BoardDims.maxImpulse;
    final impulse = impulseDirection.normalized() * magnitude;
    body.applyLinearImpulse(impulse, point: body.worldCenter);
  }

  /// Reset for the next shot — used after the previous shot has settled.
  void reArm({required double x}) {
    placementLocked = true;
    body.setType(BodyType.kinematic);
    pocketed = false;
    sinkScale = 1.0;
    placeAt(x);
  }

  @override
  void render(Canvas canvas) {
    if (pocketed && sinkScale <= 0) return;
    final radius = BoardDims.strikerRadius * sinkScale;
    // Metallic radial gradient — light highlight top-left, dark rim bottom-right.
    final grad = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 0.9,
      colors: const [
        Color(0xFFFAF7F0),
        Color(0xFFCDCAC0),
        Color(0xFF7B7468),
      ],
      stops: const [0.0, 0.55, 1.0],
    );
    final rect = Rect.fromCircle(center: Offset.zero, radius: radius);
    canvas.drawCircle(Offset.zero, radius, Paint()..shader = grad.createShader(rect));
    // Outer rim.
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.014
        ..color = const Color(0xAA2A2521),
    );
    // Centre dot — visual cue for where the player is aiming.
    canvas.drawCircle(
      Offset.zero,
      radius * 0.12,
      Paint()..color = const Color(0xAA2A2521),
    );
  }
}
