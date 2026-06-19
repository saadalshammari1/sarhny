import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/api_providers.dart';
import '../../../../core/providers/storage_providers.dart';
import '../data/carrom_v2_api.dart';
import '../data/carrom_v2_ws_client.dart';
import '../world/board_dimensions.dart';

/// Snapshot of an online Carrom v2 match — drives the match page UI.
class CarromV2MatchSnapshot {
  CarromV2MatchSnapshot({
    this.aScore = 0,
    this.bScore = 0,
    this.mySeat = Seat.a,
    this.turnSeat = 'a',
    this.status = 'playing',
    this.winnerSeat,
    this.connectionUp = true,
    this.opponentLeft = false,
    this.lastError,
    this.lastFoulReason,
  });

  final int aScore;
  final int bScore;
  final Seat mySeat;
  final String turnSeat; // "a" | "b"
  final String status; // "playing" | "finished"
  final String? winnerSeat;
  final bool connectionUp;
  final bool opponentLeft;
  final String? lastError;
  final String? lastFoulReason;

  bool get isMyTurn =>
      (mySeat == Seat.a && turnSeat == 'a') ||
      (mySeat == Seat.b && turnSeat == 'b');

  bool get isFinished => status == 'finished';
  bool get iWon =>
      isFinished &&
      ((mySeat == Seat.a && winnerSeat == 'a') ||
          (mySeat == Seat.b && winnerSeat == 'b'));

  int get myScore => mySeat == Seat.a ? aScore : bScore;
  int get oppScore => mySeat == Seat.a ? bScore : aScore;

  CarromV2MatchSnapshot copyWith({
    int? aScore,
    int? bScore,
    Seat? mySeat,
    String? turnSeat,
    String? status,
    String? winnerSeat,
    bool? connectionUp,
    bool? opponentLeft,
    String? lastError,
    String? lastFoulReason,
    bool clearError = false,
    bool clearFoul = false,
  }) =>
      CarromV2MatchSnapshot(
        aScore: aScore ?? this.aScore,
        bScore: bScore ?? this.bScore,
        mySeat: mySeat ?? this.mySeat,
        turnSeat: turnSeat ?? this.turnSeat,
        status: status ?? this.status,
        winnerSeat: winnerSeat ?? this.winnerSeat,
        connectionUp: connectionUp ?? this.connectionUp,
        opponentLeft: opponentLeft ?? this.opponentLeft,
        lastError: clearError ? null : (lastError ?? this.lastError),
        lastFoulReason: clearFoul ? null : (lastFoulReason ?? this.lastFoulReason),
      );
}

/// Online Carrom v2 controller — owns the WS lifecycle + score sync.
class CarromV2Controller extends StateNotifier<CarromV2MatchSnapshot> {
  CarromV2Controller({
    required this.roomId,
    required this.mySeat,
    required CarromV2WsClient ws,
  })  : _ws = ws,
        super(CarromV2MatchSnapshot(mySeat: mySeat)) {
    _sub = ws.events.listen(_onEvent);
    ws.connect();
  }

  final String roomId;
  final Seat mySeat;
  final CarromV2WsClient _ws;
  StreamSubscription<CarromV2WsEvent>? _sub;

  /// Stream of remote shot results — the match page listens and forwards
  /// to CarromWorld.applyRemoteOutcome to play the sink animation.
  final _remoteShotController = StreamController<CarromV2RemoteShot>.broadcast();
  Stream<CarromV2RemoteShot> get remoteShots => _remoteShotController.stream;

  void _onEvent(CarromV2WsEvent e) {
    if (!mounted) return;
    if (e is CarromV2StateEvent) {
      state = state.copyWith(
        aScore: e.aScore,
        bScore: e.bScore,
        turnSeat: e.turnSeat,
        status: e.status,
        winnerSeat: e.winnerSeat,
      );
    } else if (e is CarromV2ShotResultEvent) {
      // If this shot is from the opponent, surface as a remote shot to
      // replay on the local world. Either way, update scores + turn.
      final fromSeat = e.fromSeat == 'a' ? Seat.a : Seat.b;
      final isRemote = fromSeat != mySeat;
      state = state.copyWith(
        aScore: e.aScoreAfter,
        bScore: e.bScoreAfter,
        turnSeat: e.turnAfterSeat,
        status: e.status,
        lastFoulReason: e.foul ? e.foulReason : null,
        clearFoul: !e.foul,
      );
      if (isRemote) {
        _remoteShotController.add(CarromV2RemoteShot(
          pocketedIds: e.pocketedIds,
          strikerPocketed: e.strikerPocketed,
          nextTurnIsMine:
              (mySeat == Seat.a && e.turnAfterSeat == 'a') ||
                  (mySeat == Seat.b && e.turnAfterSeat == 'b'),
        ));
      }
    } else if (e is CarromV2OpponentLeftEvent) {
      state = state.copyWith(opponentLeft: true);
    } else if (e is CarromV2ConnectionDown) {
      state = state.copyWith(connectionUp: false);
    } else if (e is CarromV2ConnectionUp) {
      state = state.copyWith(connectionUp: true);
    } else if (e is CarromV2ErrorEvent) {
      state = state.copyWith(lastError: e.code);
    }
  }

  /// Called by the match page once the local Box2D shot settles.
  void submitLocalShot({
    required List<int> pocketedIds,
    required bool strikerPocketed,
    required bool queenPocketed,
    required int firstPieceHitId,
  }) {
    _ws.sendShot(
      pocketedIds: pocketedIds,
      strikerPocketed: strikerPocketed,
      queenPocketed: queenPocketed,
      firstPieceHitId: firstPieceHitId,
    );
  }

  void clearError() {
    if (state.lastError != null) state = state.copyWith(clearError: true);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _ws.dispose();
    _remoteShotController.close();
    super.dispose();
  }
}

class CarromV2RemoteShot {
  CarromV2RemoteShot({
    required this.pocketedIds,
    required this.strikerPocketed,
    required this.nextTurnIsMine,
  });
  final List<int> pocketedIds;
  final bool strikerPocketed;
  final bool nextTurnIsMine;
}

// ─────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────

final carromV2ApiProvider = Provider<CarromV2Api>((ref) {
  return CarromV2Api(ref.read(dioClientProvider));
});

class CarromV2WsParams {
  CarromV2WsParams({required this.roomId, required this.mySeat});
  final String roomId;
  final Seat mySeat;

  @override
  bool operator ==(Object other) =>
      other is CarromV2WsParams && other.roomId == roomId && other.mySeat == mySeat;
  @override
  int get hashCode => Object.hash(roomId, mySeat);
}

final carromV2ControllerProvider = StateNotifierProvider.autoDispose
    .family<CarromV2Controller, CarromV2MatchSnapshot, CarromV2WsParams>(
        (ref, params) {
  final dio = ref.read(dioClientProvider);
  final secure = ref.read(secureStorageProvider);
  final ws = CarromV2WsClient(
    httpBaseUrl: dio.raw.options.baseUrl,
    roomId: params.roomId,
    secureStorage: secure,
  );
  final ctrl = CarromV2Controller(
    roomId: params.roomId,
    mySeat: params.mySeat,
    ws: ws,
  );
  if (kDebugMode) {
    debugPrint('CarromV2Controller created for ${params.roomId} as ${params.mySeat}');
  }
  return ctrl;
});

