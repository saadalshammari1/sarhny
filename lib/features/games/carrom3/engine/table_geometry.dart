import 'vec2.dart';

/// Logical disc colours (independent of the chosen cosmetic skin).
enum DiscKind { white, black, queen, striker }

/// Which baseline a seat shoots from. `you` is always rendered at the bottom.
enum Seat { you, opponent }

/// All board dimensions + physics tuning for carrom3, in board units.
///
/// The board is a [size]×[size] square in logical units; the painter scales it
/// to the on-screen pixel size. Working in fixed logical units keeps the
/// physics tuning resolution-independent.
class TableGeometry {
  TableGeometry._();

  /// Full board side (frame included), in logical units.
  static const double size = 600.0;
  static const double half = size / 2.0;

  /// Visual wooden frame thickness; the play surface is inset by this.
  static const double frame = 40.0;

  /// Play-area bounds (disc centres bounce inside [playMin+r, playMax-r]).
  static const double playMin = frame;
  static const double playMax = size - frame;
  static const double playSize = playMax - playMin;
  static const double playCenter = size / 2.0;

  /// Disc radii — a touch larger for a more substantial, premium presence.
  static const double coinRadius = 16.5;
  static const double strikerRadius = 20.5;

  /// Pocket capture radius (centre within this of a pocket → potted) and the
  /// slightly larger visual radius.
  static const double pocketRadius = 24.0;
  static const double pocketVisualRadius = 30.0;

  /// Pocket centres tucked into the four play-area corners.
  static const double _pInset = 4.0;
  static List<Vec2> pockets() => [
        Vec2(playMin + _pInset, playMin + _pInset), // top-left
        Vec2(playMax - _pInset, playMin + _pInset), // top-right
        Vec2(playMin + _pInset, playMax - _pInset), // bottom-left
        Vec2(playMax - _pInset, playMax - _pInset), // bottom-right
      ];

  /// Baselines (where each seat's striker sits). `you` = bottom.
  static const double baselineInset = 78.0;
  static double baselineY(Seat seat) =>
      seat == Seat.you ? playMax - baselineInset : playMin + baselineInset;

  /// Striker travel range along the baseline (X), centred on the board.
  static const double strikerXRange = 165.0;
  static double strikerMinX = playCenter - strikerXRange;
  static double strikerMaxX = playCenter + strikerXRange;

  // ── Physics tuning (units & seconds) ────────────────────────────────
  /// Coins glide on the waxed surface; a touch more damping than a pure slide
  /// so the spread settles a little sooner (calmer, prettier than full speed).
  static const double coinDamping = 0.85;

  /// The heavier striker bleeds speed faster so it settles after the hit
  /// instead of pinballing into a pocket.
  static const double strikerDamping = 1.35;

  /// Restitution (bounciness).
  static const double coinRestitution = 0.62;
  static const double wallRestitution = 0.74;

  /// Masses (striker is the heavy "cue").
  static const double coinMass = 1.0;
  static const double strikerMass = 2.2;

  /// Full-power striker launch speed (units/second). Tuned so a full flick
  /// reaches a far-corner coin with energy to spare, then settles.
  static const double maxStrikerSpeed = 2450.0;

  /// Below this speed every disc is considered at rest → the shot has settled.
  static const double restSpeed = 7.0;

  /// Hard cap on a single shot's simulated time (seconds) — prevents a stuck
  /// micro-bounce from hanging the turn.
  static const double maxShotSeconds = 7.0;

  /// Pocket sink animation duration (seconds).
  static const double sinkSeconds = 0.22;
}
