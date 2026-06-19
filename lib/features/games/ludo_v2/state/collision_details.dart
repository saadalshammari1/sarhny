// Adapted from fludo (https://github.com/smokelaboratory/fludo)
// Original copyright (c) 2020 smokelaboratory, Apache License 2.0.
// Port + theming for Sarhny: 2026, Sarhny team.

/// Carries information about a capture-in-progress: which player's pawn is
/// being knocked back to home and which pawn index it is. `isReverse` flips
/// the animation direction so the captured pawn slides backward step by
/// step until it reaches the spawn — gives the visual feedback that the
/// capture is happening, not a teleport.
class CollisionDetails {
  CollisionDetails();

  int pawnIndex = 0;
  int targetPlayerIndex = 0;
  bool isReverse = false;
}
