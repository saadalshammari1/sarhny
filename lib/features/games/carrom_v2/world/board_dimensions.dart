/// Carrom v2 — canonical board dimensions in Box2D world units (meters).
///
/// We work in a 6.0 m × 6.0 m world so Box2D physics behave well (Forge2D
/// is tuned for sizes in the 0.1–10 m range). The visual layer maps this
/// virtual space to the on-screen canvas via Flame's CameraComponent at
/// build time, so the same constants drive both physics and rendering.
///
/// Coordinate convention (Forge2D + Flame):
///   * Origin (0,0) is the centre of the playfield.
///   * +X = right, +Y = down (matches Flutter's canvas, opposite of stock Box2D
///     mathematical Y-up). We accept this because Flame conventions win when
///     the camera maps world → screen.
///   * Player A's baseline sits at -Y (top half), Player B at +Y (bottom).
library;

class BoardDims {
  /// Square playfield side length, in metres.
  static const double size = 6.0;

  /// Half-side (used so much it earns its own constant).
  static const double half = size / 2.0; // 3.0

  /// Frame border drawn around the playfield. Pure cosmetic — no Box2D body.
  static const double frameThickness = 0.35;

  /// Radius of a regular piece (white/black/queen) in metres.
  static const double pieceRadius = 0.18;

  /// Striker is heavier and slightly larger than a piece.
  static const double strikerRadius = 0.22;

  /// Pocket detection radius — anything whose centre is within this radius
  /// of a pocket centre is captured at the next physics step.
  static const double pocketRadius = 0.28;

  /// Pocket visual radius (slightly larger than detection so the visual
  /// feedback covers the rim properly).
  static const double pocketVisualRadius = 0.34;

  /// Cushion (rail) inset — the wall bodies live this far inside the visual
  /// edge so pieces never tunnel out due to high-speed collisions.
  static const double cushionInset = 0.20;

  /// Half-width of the cushion wall body. Thick walls behave better than
  /// edges under fast impacts in Forge2D.
  static const double cushionHalfThickness = 0.12;

  /// Striker's allowed range along the baseline (X), excluding the corners.
  /// The shooter can place the striker anywhere in [-strikerXRange, +strikerXRange].
  static const double strikerXRange = 1.95;

  /// Player A baseline Y (top of board, negative because Flame Y-down).
  static const double playerABaselineY = -half + cushionInset + 0.45;

  /// Player B baseline Y (bottom).
  static const double playerBBaselineY = half - cushionInset - 0.45;

  /// Y tolerance for snapping the striker to its baseline during drag.
  static const double baselineSnapTolerance = 0.25;

  // ── Physics tuning ──────────────────────────────────────────────────

  /// Linear damping applied to every dynamic body each step. Higher = pieces
  /// stop faster. Real carrom on a polished board uses ~3.0; we use 2.8 so
  /// long combos still play out instead of dying immediately.
  static const double linearDamping = 2.8;

  /// Coefficient of restitution between two pieces (bouncy chain reactions).
  static const double pieceRestitution = 0.55;

  /// Restitution between piece/striker and cushion. Carrom cushions are
  /// fairly elastic — pieces should bounce back at ~70% of incoming speed.
  static const double wallRestitution = 0.72;

  /// Friction between bodies (small — pieces should slide).
  static const double bodyFriction = 0.05;

  /// Density (kg/m²) for pieces and striker. Striker is denser so the
  /// 11 g / 5 g real-world ratio carries into the simulation.
  static const double pieceDensity = 1.6;
  static const double strikerDensity = 3.4;

  /// Maximum impulse magnitude (kg·m/s) at power = 1.0. Tuned so a full-
  /// power shot can clear the board in one combo on a clean break.
  static const double maxImpulse = 2.5;

  /// Speed below which a body is considered "at rest" — used to detect
  /// end-of-shot (when all bodies are sleeping or below this).
  static const double restSpeedThreshold = 0.05;

  /// Maximum time (seconds) the world simulates after a shot before
  /// force-settling. Prevents infinite micro-bounces.
  static const double shotMaxDuration = 8.0;
}

/// Logical pieces in a standard carrom break.
enum PieceColor { white, black, queen, striker }

/// Player seat — A is top, B is bottom. The same player remains "white"
/// throughout the match per traditional rules; assignment is decided at
/// match start by the server (we just render whichever side this device
/// is sitting on).
enum Seat { a, b }
