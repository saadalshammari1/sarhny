import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/painting.dart';

import 'board_dimensions.dart';
import 'board_walls.dart';
import 'initial_layout.dart';
import 'piece_body.dart';
import 'pocket_sensor.dart';
import 'striker_body.dart';

/// Outcome of a single shot, produced when the world settles. The match
/// controller forwards this to the backend for authoritative validation
/// and score update.
class ShotOutcome {
  ShotOutcome({
    required this.pocketedIds,
    required this.strikerPocketed,
    required this.queenPocketed,
    required this.firstPieceHitId,
    required this.durationSeconds,
  });

  /// Piece ids that fell into a pocket during this shot, in pocket order.
  final List<int> pocketedIds;

  /// Whether the striker itself fell in (foul).
  final bool strikerPocketed;

  /// Whether the queen (id 0) was pocketed.
  final bool queenPocketed;

  /// Id of the first non-striker piece the striker touched. -1 if none
  /// (which is itself a foul: "no piece hit").
  final int firstPieceHitId;

  /// How long the simulation ran for this shot.
  final double durationSeconds;
}

/// Phase machine for the world. The page UI keys off this to enable/disable
/// the aim overlay and the action buttons.
enum WorldPhase {
  loading,    // initial bodies still being created
  aiming,     // shooter's turn, striker placement + drag is allowed
  shooting,   // shot fired, physics is running
  settling,   // motion has stopped, computing outcome
  remoteTurn, // opponent's turn — no input, replay-only
}

/// The Box2D world hosting the carrom match. Subclasses Forge2DGame so
/// Flame handles camera + tick + render automatically.
///
/// World units: metres. The board is 6.0 × 6.0. CameraComponent maps this
/// to the visible canvas with a viewfinder centred at (0, 0). Pixel size
/// is determined by the parent widget's BoxConstraints.
class CarromWorld extends Forge2DGame {
  CarromWorld({required this.mySeat})
      : super(
          gravity: Vector2.zero(), // top-down board — no gravity
          camera: CameraComponent.withFixedResolution(
            width: BoardDims.size,
            height: BoardDims.size,
          ),
          zoom: 1.0,
        );

  final Seat mySeat;

  WorldPhase phase = WorldPhase.loading;
  StrikerBody? striker;
  final Map<int, PieceBody> pieces = {};
  final List<PocketSensor> pockets = [];

  /// Ids in pocket order during the current shot.
  final List<int> _pocketedThisShot = [];
  bool _strikerPocketedThisShot = false;
  int _firstPieceHitThisShot = -1;
  double _shotElapsed = 0;
  Completer<ShotOutcome>? _shotCompleter;

  /// Lift this completer so callers can `await` shot settlement.
  Future<ShotOutcome>? get currentShotFuture => _shotCompleter?.future;

  /// Broadcast stream of locally-fired shot outcomes. Online match pages
  /// subscribe to forward outcomes to the server. Local pages can ignore.
  final _outcomeController = StreamController<ShotOutcome>.broadcast();
  Stream<ShotOutcome> get outcomes => _outcomeController.stream;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Background board surface — drawn directly in render() of a custom
    // component, not via a Sprite, to avoid asset bundling for v1.
    world.add(_BoardSurface());

    // Walls.
    world.add(BoardWalls());

    // Pockets (4 corners).
    final pocketCenters = InitialLayout.pocketCenters();
    for (var i = 0; i < pocketCenters.length; i++) {
      final p = PocketSensor(index: i, pocketCenter: pocketCenters[i]);
      pockets.add(p);
      world.add(p);
    }

    // Pieces.
    for (final spec in InitialLayout.standardBreak()) {
      final p = PieceBody(
        id: spec.id,
        color: spec.color,
        spawnPosition: spec.position,
      );
      pieces[spec.id] = p;
      world.add(p);
    }

    // Striker — placed at centre of my baseline until I move it.
    striker = StrikerBody(
      spawnPosition: Vector2(
        0,
        mySeat == Seat.a
            ? BoardDims.playerABaselineY
            : BoardDims.playerBBaselineY,
      ),
      shooterSeat: mySeat,
    );
    world.add(striker!);

    // Pocket / collision listener wires sensor + first-hit detection.
    world.physicsWorld.setContactListener(_CarromContactListener(this));

    phase = WorldPhase.aiming;
  }

  /// Move the striker along the baseline while the player drags it.
  /// Caller (the aim overlay) provides world-space X.
  void placeStriker(double worldX) {
    if (phase != WorldPhase.aiming) return;
    final s = striker;
    if (s == null) return;
    final clamped = worldX.clamp(-BoardDims.strikerXRange, BoardDims.strikerXRange);
    s.placeAt(clamped);
  }

  /// Apply the shot. The overlay computes direction + power; we apply the
  /// impulse, switch phase to shooting, and return a future that resolves
  /// when the world settles into an outcome.
  Future<ShotOutcome> fireShot({
    required Vector2 direction,
    required double power,
  }) {
    if (phase != WorldPhase.aiming) {
      return Future.value(ShotOutcome(
        pocketedIds: const [],
        strikerPocketed: false,
        queenPocketed: false,
        firstPieceHitId: -1,
        durationSeconds: 0,
      ));
    }
    _pocketedThisShot.clear();
    _strikerPocketedThisShot = false;
    _firstPieceHitThisShot = -1;
    _shotElapsed = 0;
    _shotCompleter = Completer<ShotOutcome>();
    striker?.fireShot(impulseDirection: direction, power: power);
    phase = WorldPhase.shooting;
    return _shotCompleter!.future;
  }

  /// Reset the striker after a shot settles, in preparation for the next
  /// shooter (could be me again on a continuation, or the opponent).
  void rearmFor({required Seat nextShooter, double atX = 0}) {
    final s = striker;
    if (s == null) return;
    // If the striker pocketed, rebuild it; otherwise re-arm in place.
    if (s.pocketed) {
      s.placementLocked = true;
      s.body.setType(BodyType.kinematic);
      s.pocketed = false;
      s.sinkScale = 1.0;
    }
    s.placeAt(atX);
    phase = nextShooter == mySeat ? WorldPhase.aiming : WorldPhase.remoteTurn;
  }

  /// Apply an opponent's shot outcome to our local world. Called when the
  /// server broadcasts a shot_result for the remote player. No simulation
  /// happens locally — we just remove the pieces they pocketed (with the
  /// existing sink animation) and re-arm the striker for whoever shoots
  /// next. The scoreboard is owned by the calling controller; this method
  /// updates only the visual + body state.
  void applyRemoteOutcome({
    required List<int> pocketedIds,
    required bool strikerPocketed,
    required Seat nextShooter,
  }) {
    for (final id in pocketedIds) {
      final p = pieces[id];
      if (p != null && !p.pocketed) {
        p.pocketed = true; // triggers the sink animation in update()
      }
    }
    if (strikerPocketed) {
      final s = striker;
      if (s != null) s.pocketed = true;
    }
    // Re-arm a frame later so the sink animation gets to play.
    Future<void>.delayed(const Duration(milliseconds: 280), () {
      rearmFor(nextShooter: nextShooter);
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Drive the per-piece pocket-sink animation toward 0 over ~240ms.
    for (final p in pieces.values) {
      if (p.pocketed && p.sinkScale > 0) {
        p.sinkScale = (p.sinkScale - dt / 0.24).clamp(0.0, 1.0);
      }
    }
    final s = striker;
    if (s != null && s.pocketed && s.sinkScale > 0) {
      s.sinkScale = (s.sinkScale - dt / 0.24).clamp(0.0, 1.0);
    }

    // Settle detection — only while a shot is in flight.
    if (phase == WorldPhase.shooting) {
      _shotElapsed += dt;
      final maxSpeed = _maxBodySpeed();
      final settled = maxSpeed < BoardDims.restSpeedThreshold;
      if (settled || _shotElapsed > BoardDims.shotMaxDuration) {
        phase = WorldPhase.settling;
        _emitOutcome();
      }
    }
  }

  double _maxBodySpeed() {
    var m = 0.0;
    final s = striker;
    if (s != null && !s.pocketed) {
      final v = s.body.linearVelocity.length;
      if (v > m) m = v;
    }
    for (final p in pieces.values) {
      if (p.pocketed) continue;
      final v = p.body.linearVelocity.length;
      if (v > m) m = v;
    }
    return m;
  }

  void _emitOutcome() {
    final completer = _shotCompleter;
    if (completer == null || completer.isCompleted) return;
    final outcome = ShotOutcome(
      pocketedIds: List.unmodifiable(_pocketedThisShot),
      strikerPocketed: _strikerPocketedThisShot,
      queenPocketed: _pocketedThisShot.contains(0),
      firstPieceHitId: _firstPieceHitThisShot,
      durationSeconds: _shotElapsed,
    );
    completer.complete(outcome);
    if (!_outcomeController.isClosed) _outcomeController.add(outcome);
  }

  @override
  void onRemove() {
    _outcomeController.close();
    super.onRemove();
  }

  // Called by the contact listener when a piece sensor-overlaps a pocket.
  void _onPocketEntered(int pieceId) {
    final p = pieces[pieceId];
    if (p != null && !p.pocketed) {
      p.pocketed = true;
      _pocketedThisShot.add(pieceId);
    }
  }

  void _onStrikerPocketed() {
    final s = striker;
    if (s == null || s.pocketed) return;
    s.pocketed = true;
    _strikerPocketedThisShot = true;
  }

  void _onFirstPieceHit(int pieceId) {
    if (_firstPieceHitThisShot == -1) {
      _firstPieceHitThisShot = pieceId;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────
// Custom contact listener — fires for sensor overlap (pockets) AND for
// the first non-sensor strike of a piece by the striker.
// ─────────────────────────────────────────────────────────────────────

class _CarromContactListener extends ContactListener {
  _CarromContactListener(this.gameWorld);
  final CarromWorld gameWorld;

  @override
  void beginContact(Contact contact) {
    final a = contact.bodyA.userData;
    final b = contact.bodyB.userData;

    // Pocket sensor + piece/striker.
    final pocket = a is PocketSensor ? a : (b is PocketSensor ? b : null);
    if (pocket != null) {
      final other = a is PocketSensor ? b : a;
      if (other is PieceBody) {
        gameWorld._onPocketEntered(other.id);
        return;
      }
      if (other is StrikerBody) {
        gameWorld._onStrikerPocketed();
        return;
      }
    }

    // Striker hitting a piece — record first hit only.
    final striker = a is StrikerBody ? a : (b is StrikerBody ? b : null);
    if (striker != null) {
      final piece = a is PieceBody ? a : (b is PieceBody ? b : null);
      if (piece != null) {
        gameWorld._onFirstPieceHit(piece.id);
      }
    }
  }

  @override
  void endContact(Contact contact) {}

  // preSolve + postSolve intentionally not overridden — we only need
  // beginContact for pocket detection and first-piece-hit tagging.
}

// ─────────────────────────────────────────────────────────────────────
// Board surface (drawn underneath the bodies). Wood-stained playfield +
// arrow markers + pocket rims + the two baseline guide lines.
// ─────────────────────────────────────────────────────────────────────

class _BoardSurface extends PositionComponent {
  _BoardSurface() : super(priority: -10);

  @override
  void render(Canvas canvas) {
    // Playfield base — warm honey wood gradient.
    final playRect = Rect.fromCenter(
      center: Offset.zero,
      width: BoardDims.size,
      height: BoardDims.size,
    );
    final basePaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFEFD9A8), Color(0xFFC79752)],
        stops: [0.0, 1.0],
      ).createShader(playRect);
    canvas.drawRect(playRect, basePaint);

    // Subtle inner frame.
    canvas.drawRect(
      playRect.deflate(BoardDims.cushionInset),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.03
        ..color = const Color(0xAA5A3A1B),
    );

    // Centre circle (queen ring).
    canvas.drawCircle(
      Offset.zero,
      BoardDims.pieceRadius * 1.6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.015
        ..color = const Color(0x88B8001F),
    );
    // Centre dot.
    canvas.drawCircle(
      Offset.zero,
      0.02,
      Paint()..color = const Color(0xCC5A3A1B),
    );

    // Pockets — visual rim (sensor itself is invisible).
    for (final c in InitialLayout.pocketCenters()) {
      // Outer hole.
      canvas.drawCircle(
        Offset(c.x, c.y),
        BoardDims.pocketVisualRadius,
        Paint()..color = const Color(0xFF1B0F05),
      );
      // Brass rim.
      canvas.drawCircle(
        Offset(c.x, c.y),
        BoardDims.pocketVisualRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.025
          ..color = const Color(0xFFD4AF37),
      );
    }

    // Baselines for both players (faint guides).
    _drawBaseline(canvas, BoardDims.playerABaselineY);
    _drawBaseline(canvas, BoardDims.playerBBaselineY);
  }

  void _drawBaseline(Canvas canvas, double y) {
    canvas.drawLine(
      Offset(-BoardDims.strikerXRange, y),
      Offset(BoardDims.strikerXRange, y),
      Paint()
        ..color = const Color(0x885A3A1B)
        ..strokeWidth = 0.012
        ..strokeCap = StrokeCap.round,
    );
  }
}
