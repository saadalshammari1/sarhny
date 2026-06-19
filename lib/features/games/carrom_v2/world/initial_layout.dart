import 'dart:math' as math;

import 'package:flame_forge2d/flame_forge2d.dart';

import 'board_dimensions.dart';

/// Canonical carrom opening: queen at centre, 9 white + 9 black arranged
/// in two rings. Coordinates are world-space metres, origin = board centre.
///
/// Layout matches the established convention used by the existing Python
/// backend in `app/core/carrom_state.py:initial_pieces` (white starts at
/// 0°, alternating around the rings). Keeping client-side and server-side
/// pieces in the same starting order makes server-driven reconciliation
/// trivial — we just match by index.
class InitialLayout {
  /// Returns 19 piece specs (id, color, position) for a fresh break.
  /// id 0 = queen, ids 1..6 = inner ring, ids 7..18 = outer ring.
  static List<PieceSpec> standardBreak() {
    final pieces = <PieceSpec>[
      PieceSpec(id: 0, color: PieceColor.queen, position: Vector2.zero()),
    ];

    // Inner ring: 6 pieces at radius 2.05 × pieceRadius, alternating colors.
    final innerR = 2.05 * BoardDims.pieceRadius;
    for (var i = 0; i < 6; i++) {
      final angle = (math.pi / 3.0) * i + (math.pi / 6.0);
      pieces.add(PieceSpec(
        id: 1 + i,
        color: i.isEven ? PieceColor.white : PieceColor.black,
        position: Vector2(innerR * math.cos(angle), innerR * math.sin(angle)),
      ));
    }

    // Outer ring: 12 pieces at radius 4.10 × pieceRadius, alternating.
    final outerR = 4.10 * BoardDims.pieceRadius;
    for (var i = 0; i < 12; i++) {
      final angle = (math.pi / 6.0) * i;
      pieces.add(PieceSpec(
        id: 7 + i,
        color: i.isEven ? PieceColor.white : PieceColor.black,
        position: Vector2(outerR * math.cos(angle), outerR * math.sin(angle)),
      ));
    }

    return pieces;
  }

  /// Four pocket centres at the four playfield corners, inset by the
  /// cushion + a small margin so a piece needs to actually round the
  /// corner to fall in (matches real carrom geometry).
  static List<Vector2> pocketCenters() {
    const inset = BoardDims.cushionInset + 0.10;
    final c = BoardDims.half - inset;
    return [
      Vector2(-c, -c), // top-left
      Vector2(c, -c),  // top-right
      Vector2(-c, c),  // bottom-left
      Vector2(c, c),   // bottom-right
    ];
  }
}

class PieceSpec {
  const PieceSpec({
    required this.id,
    required this.color,
    required this.position,
  });
  final int id;
  final PieceColor color;
  final Vector2 position;
}
