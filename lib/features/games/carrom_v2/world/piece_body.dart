import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/painting.dart';

import 'board_dimensions.dart';

/// A carrom piece (white / black / queen) modelled as a circular dynamic body.
///
/// Render strategy: we draw the visual disc directly in render() instead of
/// adding a child SpriteComponent — this keeps the body and visual locked
/// frame-perfect and avoids the latency of Flame's child positioning.
class PieceBody extends BodyComponent {
  PieceBody({
    required this.id,
    required this.color,
    required this.spawnPosition,
  }) : super(renderBody: false);

  /// Stable id matching the server's piece id (used for reconciliation).
  final int id;
  final PieceColor color;
  final Vector2 spawnPosition;

  /// Set true by the world after the piece's centre crosses a pocket sensor.
  /// The world then animates the visual drop and removes the body next step.
  bool pocketed = false;

  /// Visual scale factor for the pocket "sink" animation (1.0 → 0.0).
  double sinkScale = 1.0;

  @override
  Body createBody() {
    final body = world.createBody(BodyDef(
      type: BodyType.dynamic,
      position: spawnPosition.clone(),
      linearDamping: BoardDims.linearDamping,
      angularDamping: BoardDims.linearDamping,
      bullet: false, // pieces aren't fast enough to need CCD
      userData: this,
    ));
    body.createFixture(FixtureDef(
      CircleShape()..radius = BoardDims.pieceRadius,
      density: BoardDims.pieceDensity,
      friction: BoardDims.bodyFriction,
      restitution: BoardDims.pieceRestitution,
    ));
    return body;
  }

  @override
  void render(Canvas canvas) {
    if (pocketed && sinkScale <= 0) return;
    final radius = BoardDims.pieceRadius * sinkScale;
    final paint = _fillPaint();
    canvas.drawCircle(Offset.zero, radius, paint);
    // Thin rim — makes the white piece readable on the light board.
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.012
        ..color = const Color(0x55000000),
    );
  }

  Paint _fillPaint() {
    switch (color) {
      case PieceColor.white:
        return Paint()..color = const Color(0xFFF6F1E4);
      case PieceColor.black:
        return Paint()..color = const Color(0xFF1B1814);
      case PieceColor.queen:
        return Paint()..color = const Color(0xFFB8001F);
      case PieceColor.striker:
        // Striker uses its own component class; defensive default.
        return Paint()..color = const Color(0xFFC9C9D1);
    }
  }
}
