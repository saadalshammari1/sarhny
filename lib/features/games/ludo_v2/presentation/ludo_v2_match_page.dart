// Adapted from fludo (https://github.com/smokelaboratory/fludo) game.dart
// Original copyright (c) 2020 smokelaboratory, Apache License 2.0.
// Port + theming + 2/3/4-player support + Sarhny app integration: 2026.
//
// Differences from fludo:
//   * Hosted inside an AppBar Scaffold (not full-screen) so the app's
//     navigation + status bar remain intact.
//   * PopScope guards system-back during play (concede confirmation).
//   * Configurable player count (2 / 3 / 4) — original was 4-fixed.
//   * GameHaptics integration on dice land, capture, win.
//   * No SystemChrome lockdown — the host app handles orientation.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/haptics/game_haptics.dart';
import '../board/board_painter.dart';
import '../board/overlay_surface.dart';
import '../dice/dice_painter.dart';
import '../players/players_painter.dart';
import '../result/result_painter.dart';
import '../state/collision_details.dart';
import '../util/ludo_v2_colors.dart';

enum LudoV2Variant { normal, magic }

extension LudoV2VariantX on LudoV2Variant {
  static LudoV2Variant parse(String? raw) {
    return raw == 'magic' ? LudoV2Variant.magic : LudoV2Variant.normal;
  }

  String get wire => this == LudoV2Variant.magic ? 'magic' : 'normal';
  String get arabicLabel =>
      this == LudoV2Variant.magic ? 'لودو سحرية' : 'لودو عادية';
}

enum _MagicTileKind { rocket, freeze, door, tornado }

class _MagicTile {
  const _MagicTile(this.kind, this.step);
  final _MagicTileKind kind;
  final int step;

  String get glyph {
    switch (kind) {
      case _MagicTileKind.rocket:
        return 'ص';
      case _MagicTileKind.freeze:
        return 'ج';
      case _MagicTileKind.door:
        return 'ب';
      case _MagicTileKind.tornado:
        return 'ع';
    }
  }

  Color get color {
    switch (kind) {
      case _MagicTileKind.rocket:
        return const Color(0xFFFF7A1A);
      case _MagicTileKind.freeze:
        return const Color(0xFF38BDF8);
      case _MagicTileKind.door:
        return const Color(0xFF9B5CF6);
      case _MagicTileKind.tornado:
        return const Color(0xFF14B8A6);
    }
  }
}

const Map<int, _MagicTile> _magicTiles = {
  7: _MagicTile(_MagicTileKind.door, 7),
  10: _MagicTile(_MagicTileKind.rocket, 10),
  16: _MagicTile(_MagicTileKind.freeze, 16),
  23: _MagicTile(_MagicTileKind.tornado, 23),
  31: _MagicTile(_MagicTileKind.door, 31),
  36: _MagicTile(_MagicTileKind.freeze, 36),
  44: _MagicTile(_MagicTileKind.rocket, 44),
  49: _MagicTile(_MagicTileKind.tornado, 49),
};

/// Local pass-and-play Ludo, ported from fludo with our scaffold + theming.
///
/// `playerCount` valid values: 2, 3, 4. For 2 players the active seats
/// are 0 + 2 (diagonal), for 3 it's 0 + 1 + 2, for 4 it's all seats.
class LudoV2MatchPage extends StatefulWidget {
  const LudoV2MatchPage({
    super.key,
    this.playerCount = 4,
    this.variant = LudoV2Variant.normal,
  });
  final int playerCount;
  final LudoV2Variant variant;

  @override
  State<LudoV2MatchPage> createState() => _LudoV2MatchPageState();
}

class _LudoV2MatchPageState extends State<LudoV2MatchPage>
    with TickerProviderStateMixin {
  late final Animation<Color?> _playerHighlightAnim;
  late final Animation<double> _diceHighlightAnim;
  late final AnimationController _playerHighlightAnimCont;
  late final AnimationController _diceHighlightAnimCont;
  final List<List<AnimationController>> _playerAnimContList = [];
  final List<List<Animation<Offset>>> _playerAnimList = [];
  final List<List<int>> _winnerPawnList = [];

  bool _provideFreeTurn = false;
  final CollisionDetails _collisionDetails = CollisionDetails();

  int _stepCounter = 0;
  int _diceOutput = 0;
  int _currentTurn = 0;
  int _selectedPawnIndex = 0;
  final int _maxTrackIndex = 57;
  int _straightSixesCounter = 0;
  final int _forwardStepAnimTimeInMillis = 250;
  final int _reverseStepAnimTimeInMillis = 60;

  late List<List<List<Rect>>> _playerTracks;
  late List<Rect> _safeSpots;
  final List<List<MapEntry<int, Rect>>> _pawnCurrentStepInfo = [];

  bool _tracksReady = false;
  bool _gameOver = false;
  bool _suppressPawnCompletion = false;
  final List<int> _ranks = List.filled(4, 0); // 1 = 1st, 2 = 2nd, etc.
  int _finishedCount = 0;
  int _nextRank = 1;
  final List<int> _frozenTurns = List.filled(4, 0);
  String? _magicMessage;

  /// Seat indices that are actually played (others get auto-ranked at start).
  late final List<int> _activeSeats;

  bool get _magicEnabled => widget.variant == LudoV2Variant.magic;

  @override
  void initState() {
    super.initState();
    _activeSeats = _seatsForCount(widget.playerCount);

    _playerHighlightAnimCont = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _diceHighlightAnimCont = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _playerHighlightAnim =
        ColorTween(begin: Colors.black12, end: Colors.black45)
            .animate(_playerHighlightAnimCont);
    _diceHighlightAnim =
        Tween(begin: 0.0, end: 2 * pi).animate(_diceHighlightAnimCont);

    _currentTurn = _activeSeats.first;
  }

  static List<int> _seatsForCount(int count) {
    switch (count) {
      case 2:
        return const [0, 2]; // diagonal
      case 3:
        return const [0, 1, 2];
      case 4:
      default:
        return const [0, 1, 2, 3];
    }
  }

  @override
  void dispose() {
    for (final list in _playerAnimContList) {
      for (final c in list) {
        c.dispose();
      }
    }
    _playerHighlightAnimCont.dispose();
    _diceHighlightAnimCont.dispose();
    super.dispose();
  }

  // ── Track / pawn init (called once when BoardPainter paints) ────────

  void _onTracksReady(List<List<List<Rect>>> tracks) {
    if (_tracksReady) return;
    _playerTracks = tracks;

    for (var playerIndex = 0;
        playerIndex < _playerTracks.length;
        playerIndex++) {
      final pawnAnimList = <Animation<Offset>>[];
      final pawnContList = <AnimationController>[];
      final stepInfoList = <MapEntry<int, Rect>>[];

      for (var pawnIndex = 0;
          pawnIndex < _playerTracks[playerIndex].length;
          pawnIndex++) {
        final cont = AnimationController(
          duration: Duration(milliseconds: _forwardStepAnimTimeInMillis),
          vsync: this,
        )..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              if (_suppressPawnCompletion) return;
              if (!_collisionDetails.isReverse) _stepCounter++;
              _movePawn();
            }
          });

        pawnContList.add(cont);
        pawnAnimList.add(
          Tween(
            begin: _playerTracks[playerIndex][pawnIndex][0].center,
            end: _playerTracks[playerIndex][pawnIndex][1].center,
          ).animate(cont),
        );
        stepInfoList.add(MapEntry(0, _playerTracks[playerIndex][pawnIndex][0]));
      }

      _playerAnimContList.add(pawnContList);
      _playerAnimList.add(pawnAnimList);
      _pawnCurrentStepInfo.add(stepInfoList);
      _winnerPawnList.add([]);
    }

    // Safe spots are the same on every player's track — read from player 0.
    final track = _playerTracks[0][0];
    _safeSpots = [
      track[1],
      track[9],
      track[14],
      track[22],
      track[27],
      track[35],
      track[40],
      track[48],
    ];

    setState(() => _tracksReady = true);
    _highlightCurrentPlayer();
    _highlightDice();
  }

  // ── Click handling ──────────────────────────────────────────────────

  void _handleClick(Offset clickOffset) {
    if (_gameOver) return;
    if (_diceHighlightAnimCont.isAnimating) return;
    if (_stepCounter != 0) return;

    for (var pawnIndex = 0;
        pawnIndex < _pawnCurrentStepInfo[_currentTurn].length;
        pawnIndex++) {
      if (_pawnCurrentStepInfo[_currentTurn][pawnIndex]
          .value
          .contains(clickOffset)) {
        final pawnStepIndex = _pawnCurrentStepInfo[_currentTurn][pawnIndex].key;
        if (pawnStepIndex == 0) {
          if (_diceOutput == 6) {
            _diceOutput = 1; // move from house with effective step of 1
          } else {
            break;
          }
        } else if (pawnStepIndex + _diceOutput > _maxTrackIndex) {
          break;
        }
        _playerHighlightAnimCont.reset();
        _selectedPawnIndex = pawnIndex;
        GameHaptics.tap();
        _movePawn(considerCurrentStep: true);
        break;
      }
    }
  }

  // ── Dice ────────────────────────────────────────────────────────────

  void _rollDice() {
    if (!_diceHighlightAnimCont.isAnimating) return;
    if (_magicEnabled && _frozenTurns[_currentTurn] > 0) {
      _consumeFrozenTurn();
      return;
    }
    _playerHighlightAnimCont.reset();
    _diceHighlightAnimCont.reset();
    setState(() {
      _diceOutput = 1 + Random().nextInt(6);
      _magicMessage = null;
    });
    if (_diceOutput == 6) _straightSixesCounter += 1;
    GameHaptics.diceRoll();
    _highlightCurrentPlayer();
    _checkDiceResultValidity();
  }

  void _checkDiceResultValidity() {
    var isValid = false;
    for (final stepInfo in _pawnCurrentStepInfo[_currentTurn]) {
      if (_diceOutput == 6) {
        if (_straightSixesCounter == 3) break; // 3-six void
        if (stepInfo.key + _diceOutput > _maxTrackIndex) continue;
        _provideFreeTurn = true;
        isValid = true;
        break;
      } else if (stepInfo.key != 0) {
        if (stepInfo.key + _diceOutput <= _maxTrackIndex) {
          isValid = true;
          break;
        }
      }
    }
    if (!isValid) _changeTurn();
  }

  // ── Pawn movement engine (recursive — animates step-by-step) ────────

  void _movePawn({bool considerCurrentStep = false}) {
    if (_gameOver) return;
    int playerIndex, pawnIndex, currentStepIndex;

    if (_collisionDetails.isReverse) {
      playerIndex = _collisionDetails.targetPlayerIndex;
      pawnIndex = _collisionDetails.pawnIndex;
      currentStepIndex = max(
        _pawnCurrentStepInfo[playerIndex][pawnIndex].key -
            (considerCurrentStep ? 0 : 1),
        0,
      );
    } else {
      playerIndex = _currentTurn;
      pawnIndex = _selectedPawnIndex;
      currentStepIndex = min(
        _pawnCurrentStepInfo[playerIndex][pawnIndex].key +
            (considerCurrentStep ? 0 : 1),
        _maxTrackIndex,
      );
    }

    final currentStepInfo = MapEntry(
      currentStepIndex,
      _playerTracks[playerIndex][pawnIndex][currentStepIndex],
    );
    _pawnCurrentStepInfo[playerIndex][pawnIndex] = currentStepInfo;
    final cont = _playerAnimContList[playerIndex][pawnIndex];

    if (_collisionDetails.isReverse) {
      if (currentStepIndex > 0) {
        _playerAnimList[_collisionDetails.targetPlayerIndex]
            [_collisionDetails.pawnIndex] = Tween(
          begin: currentStepInfo.value.center,
          end: _playerTracks[_collisionDetails.targetPlayerIndex]
                  [_collisionDetails.pawnIndex][currentStepIndex - 1]
              .center,
        ).animate(cont);
        cont.forward(from: 0.0);
      } else {
        _playerAnimContList[playerIndex][pawnIndex].duration =
            Duration(milliseconds: _forwardStepAnimTimeInMillis);
        _collisionDetails.isReverse = false;
        _provideFreeTurn = true;
        GameHaptics.capture();
        _changeTurn();
      }
    } else if (_stepCounter != _diceOutput) {
      _playerAnimList[playerIndex][pawnIndex] = Tween(
        begin: currentStepInfo.value.center,
        end: _playerTracks[playerIndex][pawnIndex]
                [min(currentStepIndex + 1, _maxTrackIndex)]
            .center,
      ).animate(
        CurvedAnimation(
          parent: cont,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
        ),
      );
      cont.forward(from: 0.0);
    } else {
      if (_checkCollision(currentStepInfo)) {
        _movePawn(considerCurrentStep: true);
      } else {
        if (_magicEnabled && currentStepIndex != _maxTrackIndex) {
          _applyMagicTile(currentStepIndex);
        }
        final landedStep =
            _pawnCurrentStepInfo[_currentTurn][_selectedPawnIndex].key;
        if (landedStep == _maxTrackIndex) {
          _finishPawnIfNeeded(_currentTurn, _selectedPawnIndex);
        }
        _changeTurn();
      }
    }
  }

  void _consumeFrozenTurn() {
    final remaining = _frozenTurns[_currentTurn] - 1;
    setState(() {
      _frozenTurns[_currentTurn] = remaining;
      _magicMessage = remaining == 0
          ? 'انتهى تجميد ${_seatName(_currentTurn)}'
          : '${_seatName(_currentTurn)} مجمّد — بقي $remaining';
    });
    GameHaptics.capture();
    _provideFreeTurn = false;
    _changeTurn();
  }

  void _applyMagicTile(int step) {
    final tile = _magicTiles[step];
    if (tile == null) return;

    switch (tile.kind) {
      case _MagicTileKind.rocket:
        final boost = 1 + Random().nextInt(6);
        final target = min(_maxTrackIndex, step + boost);
        _teleportPawn(_currentTurn, _selectedPawnIndex, target);
        setState(() {
          _magicMessage = target == _maxTrackIndex
              ? 'صاروخ +$boost أوصلك للبيت'
              : 'صاروخ دفعك $boost خطوات';
        });
        GameHaptics.uiPop();
        break;
      case _MagicTileKind.freeze:
        final targetSeat = _nextEnemySeat();
        if (targetSeat != null) {
          _frozenTurns[targetSeat] = 3;
          setState(() {
            _magicMessage = 'تجميد ${_seatName(targetSeat)} لمدة 3 رميات';
          });
          GameHaptics.capture();
        }
        break;
      case _MagicTileKind.door:
        final target = step == 7 ? 31 : 7;
        _teleportPawn(_currentTurn, _selectedPawnIndex, target);
        setState(() {
          _magicMessage =
              step == 7 ? 'دخلت الباب وخرجت للأمام' : 'الباب أعادك للخلف';
        });
        GameHaptics.uiPop();
        break;
      case _MagicTileKind.tornado:
        final occupied = <int>{
          for (final info in _pawnCurrentStepInfo.expand((x) => x))
            if (info.key > 0 && info.key < _maxTrackIndex) info.key,
        };
        var target = 1 + Random().nextInt(_maxTrackIndex - 2);
        for (var attempts = 0;
            attempts < 18 && occupied.contains(target);
            attempts++) {
          target = 1 + Random().nextInt(_maxTrackIndex - 2);
        }
        _teleportPawn(_currentTurn, _selectedPawnIndex, target);
        setState(() {
          _magicMessage = 'الإعصار نقل الحجر إلى موقع غير متوقع';
        });
        GameHaptics.capture();
        break;
    }
  }

  void _teleportPawn(int playerIndex, int pawnIndex, int targetStep) {
    final clamped = targetStep.clamp(0, _maxTrackIndex);
    final targetRect = _playerTracks[playerIndex][pawnIndex][clamped];
    _pawnCurrentStepInfo[playerIndex][pawnIndex] =
        MapEntry(clamped, targetRect);
    final current = _playerAnimList[playerIndex][pawnIndex].value;
    _playerAnimList[playerIndex][pawnIndex] = Tween(
      begin: current,
      end: targetRect.center,
    ).animate(
      CurvedAnimation(
        parent: _playerAnimContList[playerIndex][pawnIndex],
        curve: Curves.easeOutBack,
      ),
    );
    _suppressPawnCompletion = true;
    _playerAnimContList[playerIndex][pawnIndex]
        .forward(from: 0)
        .whenComplete(() {
      _suppressPawnCompletion = false;
    });
  }

  int? _nextEnemySeat() {
    if (_activeSeats.length <= 1) return null;
    final currentIdx = _activeSeats.indexOf(_currentTurn);
    for (var i = 1; i <= _activeSeats.length; i++) {
      final seat = _activeSeats[(currentIdx + i) % _activeSeats.length];
      if (seat != _currentTurn && _ranks[seat] == 0) return seat;
    }
    return null;
  }

  void _finishPawnIfNeeded(int playerIndex, int pawnIndex) {
    if (_winnerPawnList[playerIndex].contains(pawnIndex)) return;
    _winnerPawnList[playerIndex].add(pawnIndex);
    if (_winnerPawnList[playerIndex].length < 4) {
      _provideFreeTurn = true;
      return;
    }
    _finishedCount += 1;
    _ranks[playerIndex] = _nextRank;
    _nextRank += 1;
    _provideFreeTurn = false;
    _checkGameOver();
  }

  bool _checkCollision(MapEntry<int, Rect> currentStepInfo) {
    final centre = currentStepInfo.value.center;

    if (currentStepInfo.key < 52) {
      // skip if landed on a safe spot
      if (!_safeSpots.any((s) => s.contains(centre))) {
        final collisions = <CollisionDetails>[];
        for (var p = 0; p < _pawnCurrentStepInfo.length; p++) {
          for (var w = 0; w < _pawnCurrentStepInfo[p].length; w++) {
            if (p == _currentTurn && w == _selectedPawnIndex) continue;
            if (_pawnCurrentStepInfo[p][w].value.contains(centre)) {
              collisions.add(
                CollisionDetails()
                  ..pawnIndex = w
                  ..targetPlayerIndex = p,
              );
            }
          }
        }

        // No capture if: empty, hit own pawn, or stack > 1 (group protection).
        if (collisions.isEmpty ||
            collisions.any((c) => c.targetPlayerIndex == _currentTurn) ||
            collisions.length > 1) {
          _collisionDetails.isReverse = false;
        } else {
          final first = collisions.first;
          _collisionDetails
            ..pawnIndex = first.pawnIndex
            ..targetPlayerIndex = first.targetPlayerIndex
            ..isReverse = true;
          _playerAnimContList[first.targetPlayerIndex][first.pawnIndex]
              .duration = Duration(milliseconds: _reverseStepAnimTimeInMillis);
        }
      } else {
        _collisionDetails.isReverse = false;
      }
    } else {
      _collisionDetails.isReverse = false;
    }
    return _collisionDetails.isReverse;
  }

  void _changeTurn() {
    if (_gameOver) return;
    if (_finishedCount >= _activeSeats.length - 1) {
      // Last player standing gets auto-ranked.
      for (final seat in _activeSeats) {
        if (_ranks[seat] == 0) {
          _ranks[seat] = _nextRank;
          _nextRank += 1;
        }
      }
      _checkGameOver();
      return;
    }

    _highlightDice();
    _stepCounter = 0;
    if (!_provideFreeTurn) {
      // Advance to next active seat, skipping finished players.
      var attempts = 0;
      do {
        final idx = _activeSeats.indexOf(_currentTurn);
        _currentTurn = _activeSeats[(idx + 1) % _activeSeats.length];
        attempts += 1;
        if (attempts > _activeSeats.length * 2) break;
      } while (_ranks[_currentTurn] != 0);
      _straightSixesCounter = 0;
    } else if (_diceOutput != 6) {
      _straightSixesCounter = 0;
    }
    if (!_playerHighlightAnimCont.isAnimating) _highlightCurrentPlayer();
    _provideFreeTurn = false;
    setState(() {});
  }

  String _seatName(int seat) {
    switch (seat) {
      case 0:
        return 'اللاعب 1';
      case 1:
        return 'اللاعب 2';
      case 2:
        return 'اللاعب 3';
      default:
        return 'اللاعب 4';
    }
  }

  void _checkGameOver() {
    if (_gameOver) return;
    final remaining = _activeSeats.where((s) => _ranks[s] == 0).length;
    if (remaining == 0) {
      setState(() => _gameOver = true);
      GameHaptics.win();
    }
  }

  void _highlightCurrentPlayer() {
    _playerHighlightAnimCont.repeat(reverse: true);
  }

  void _highlightDice() {
    _diceHighlightAnimCont.repeat();
  }

  // ── Concede ─────────────────────────────────────────────────────────

  Future<bool> _confirmConcede() async {
    if (_gameOver) return true;
    final colors = context.sarhnyColors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0x33D22F2F),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.flag_outlined,
                  color: Color(0xFFD22F2F),
                  size: 32,
                ),
              ),
              const Gap(12),
              Text(
                'الخروج من المباراة؟',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('متابعة'),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFD22F2F),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('خروج'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return ok == true;
  }

  // ── Render ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return PopScope(
      canPop: _gameOver,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_gameOver) {
          if (!context.mounted) return;
          context.go(AppRoutes.gamesHub);
          return;
        }
        final confirmed = await _confirmConcede();
        if (!confirmed) return;
        if (!context.mounted) return;
        context.go(AppRoutes.gamesHub);
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close_rounded, color: colors.textPrimary),
            onPressed: () async {
              GameHaptics.tap();
              if (_gameOver) {
                context.go(AppRoutes.gamesHub);
                return;
              }
              final confirmed = await _confirmConcede();
              if (!confirmed) return;
              if (!context.mounted) return;
              context.go(AppRoutes.gamesHub);
            },
          ),
          title: Text(
            '${widget.variant.arabicLabel} — ${widget.playerCount} لاعبين',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              const Gap(8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _TurnBanner(
                  currentTurn: _currentTurn,
                  activeSeats: _activeSeats,
                  ranks: _ranks,
                  frozenTurns: _frozenTurns,
                  gameOver: _gameOver,
                ),
              ),
              if (_magicEnabled) ...[
                const Gap(8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _MagicPowerRail(colors: colors),
                ),
              ],
              if (_magicMessage != null) ...[
                const Gap(8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _MagicEventBanner(message: _magicMessage!),
                ),
              ],
              const Gap(8),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: <Widget>[
                            SizedBox.expand(
                              child: CustomPaint(
                                painter: BoardPainter(
                                  trackCalculationListener: _onTracksReady,
                                ),
                              ),
                            ),
                            if (_magicEnabled && _tracksReady)
                              SizedBox.expand(
                                child: CustomPaint(
                                  painter: _MagicTilesPainter(
                                    tracks: _playerTracks,
                                    activeSeats: _activeSeats,
                                  ),
                                ),
                              ),
                            if (_tracksReady)
                              SizedBox.expand(
                                child: AnimatedBuilder(
                                  animation: _playerHighlightAnim,
                                  builder: (_, __) => CustomPaint(
                                    painter: OverlaySurface(
                                      highlightColor:
                                          _playerHighlightAnim.value!,
                                      selectedHomeIndex: _currentTurn,
                                      clickOffset: _handleClick,
                                    ),
                                  ),
                                ),
                              ),
                            if (_tracksReady) ..._buildPawnWidgets(),
                            if (_tracksReady)
                              SizedBox.expand(
                                child: CustomPaint(
                                  painter: ResultPainter(_ranks),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (_magicEnabled)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _MagicLegend(),
                ),
              const Gap(8),
              GestureDetector(
                onTap: _rollDice,
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    children: [
                      SizedBox.expand(
                        child: AnimatedBuilder(
                          animation: _diceHighlightAnim,
                          builder: (_, __) => CustomPaint(
                            painter: DiceBasePainter(_diceHighlightAnim.value),
                          ),
                        ),
                      ),
                      SizedBox.expand(
                        child: CustomPaint(
                          painter: DicePaint(_diceOutput),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _gameOver
                      ? 'انتهت المباراة'
                      : (_magicEnabled && _frozenTurns[_currentTurn] > 0
                          ? '${_seatName(_currentTurn)} مجمّد — اضغط النرد لاستهلاك رمية'
                          : (_diceHighlightAnimCont.isAnimating
                              ? 'اضغط على النرد للرمي'
                              : 'اختر القطعة لتحريكها')),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Gap(8),
              if (_gameOver)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: FilledButton.icon(
                    onPressed: () => context.go(AppRoutes.gamesHub),
                    icon: const Icon(Icons.home_rounded, size: 16),
                    label: const Text('العودة للوبي'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPawnWidgets() {
    final widgets = <Widget>[];
    for (var playerIndex = 0; playerIndex < 4; playerIndex++) {
      Color color;
      switch (playerIndex) {
        case 0:
          color = LudoV2Colors.player1;
          break;
        case 1:
          color = LudoV2Colors.player2;
          break;
        case 2:
          color = LudoV2Colors.player3;
          break;
        default:
          color = LudoV2Colors.player4;
      }
      for (var pawnIndex = 0; pawnIndex < 4; pawnIndex++) {
        widgets.add(
          SizedBox.expand(
            child: AnimatedBuilder(
              animation: _playerAnimList[playerIndex][pawnIndex],
              builder: (_, __) => CustomPaint(
                painter: PlayersPainter(
                  playerCurrentSpot:
                      _playerAnimList[playerIndex][pawnIndex].value,
                  playerColor: color,
                ),
              ),
            ),
          ),
        );
      }
    }
    return widgets;
  }
}

// ─────────────────────────────────────────────────────────────────────
// Turn banner — shows whose turn it is + finished ranks
// ─────────────────────────────────────────────────────────────────────

class _TurnBanner extends StatelessWidget {
  const _TurnBanner({
    required this.currentTurn,
    required this.activeSeats,
    required this.ranks,
    required this.frozenTurns,
    required this.gameOver,
  });
  final int currentTurn;
  final List<int> activeSeats;
  final List<int> ranks;
  final List<int> frozenTurns;
  final bool gameOver;

  Color _seatColor(int seat) {
    switch (seat) {
      case 0:
        return LudoV2Colors.player1;
      case 1:
        return LudoV2Colors.player2;
      case 2:
        return LudoV2Colors.player3;
      default:
        return LudoV2Colors.player4;
    }
  }

  String _seatName(int seat) {
    switch (seat) {
      case 0:
        return 'اللاعب 1';
      case 1:
        return 'اللاعب 2';
      case 2:
        return 'اللاعب 3';
      default:
        return 'اللاعب 4';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: activeSeats.map((seat) {
        final isCurrent = !gameOver && seat == currentTurn;
        final rank = ranks[seat];
        final color = _seatColor(seat);
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isCurrent ? 0.30 : 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withValues(alpha: isCurrent ? 0.85 : 0.30),
                width: isCurrent ? 1.6 : 0.8,
              ),
            ),
            child: Column(
              children: [
                Text(
                  _seatName(seat),
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  rank == 0
                      ? (frozenTurns[seat] > 0
                          ? 'مجمّد ${frozenTurns[seat]}'
                          : (isCurrent ? 'دوره' : '—'))
                      : '#$rank',
                  style: TextStyle(
                    color: color,
                    fontSize: frozenTurns[seat] > 0 ? 10.5 : 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MagicEventBanner extends StatelessWidget {
  const _MagicEventBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.mind.withValues(alpha: 0.18),
            colors.crystal.withValues(alpha: 0.14),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.mind.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: colors.mind, size: 18),
          const Gap(8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MagicLegend extends StatelessWidget {
  const _MagicLegend();

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    const items = [
      (_MagicTileKind.rocket, 'صاروخ'),
      (_MagicTileKind.freeze, 'تجميد'),
      (_MagicTileKind.door, 'باب'),
      (_MagicTileKind.tornado, 'إعصار'),
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 7,
      runSpacing: 6,
      children: items.map((item) {
        final tile = _MagicTile(item.$1, 0);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: tile.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: tile.color.withValues(alpha: 0.35),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tile.glyph,
                style: TextStyle(
                  color: tile.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Gap(4),
              Text(
                item.$2,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _MagicTilesPainter extends CustomPainter {
  const _MagicTilesPainter({
    required this.tracks,
    required this.activeSeats,
  });

  final List<List<List<Rect>>> tracks;
  final List<int> activeSeats;

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    final seen = <String>{};
    for (final seat in activeSeats) {
      if (seat >= tracks.length || tracks[seat].isEmpty) continue;
      final track = tracks[seat][0];
      for (final entry in _magicTiles.entries) {
        if (entry.key >= track.length) continue;
        final rect = track[entry.key].deflate(2);
        final key =
            '${rect.center.dx.toStringAsFixed(1)}:${rect.center.dy.toStringAsFixed(1)}';
        if (!seen.add(key)) continue;
        final tile = entry.value;
        final paint = Paint()
          ..shader = RadialGradient(
            colors: [
              tile.color.withValues(alpha: 0.85),
              tile.color.withValues(alpha: 0.25),
            ],
          ).createShader(rect);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(5)),
          paint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(5)),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.82)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.1,
        );
        textPainter.text = TextSpan(
          text: tile.glyph,
          style: TextStyle(
            color: Colors.white,
            fontSize: rect.height * 0.52,
            fontWeight: FontWeight.w900,
          ),
        );
        textPainter.layout(maxWidth: rect.width);
        textPainter.paint(
          canvas,
          rect.center - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MagicTilesPainter oldDelegate) {
    return oldDelegate.tracks != tracks ||
        oldDelegate.activeSeats != activeSeats;
  }
}

class _MagicPowerRail extends StatelessWidget {
  const _MagicPowerRail({required this.colors});
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: const [
          Expanded(
            child: _MagicPowerChip(
              label: 'صاروخ',
              detail: '+1 إلى +6',
              icon: Icons.rocket_launch_rounded,
              color: Color(0xFFFF7A1A),
            ),
          ),
          Gap(7),
          Expanded(
            child: _MagicPowerChip(
              label: 'تجميد',
              detail: '3 رميات',
              icon: Icons.ac_unit_rounded,
              color: Color(0xFF38BDF8),
            ),
          ),
          Gap(7),
          Expanded(
            child: _MagicPowerChip(
              label: 'أبواب',
              detail: 'انتقال',
              icon: Icons.door_front_door_rounded,
              color: Color(0xFF9B5CF6),
            ),
          ),
          Gap(7),
          Expanded(
            child: _MagicPowerChip(
              label: 'إعصار',
              detail: 'عشوائي',
              icon: Icons.cyclone_rounded,
              color: Color(0xFF14B8A6),
            ),
          ),
        ],
      ),
    );
  }
}

class _MagicPowerChip extends StatelessWidget {
  const _MagicPowerChip({
    required this.label,
    required this.detail,
    required this.icon,
    required this.color,
  });

  final String label;
  final String detail;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const Gap(3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 11.5,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              detail,
              maxLines: 1,
              style: TextStyle(
                color: color.withValues(alpha: 0.82),
                fontWeight: FontWeight.w700,
                fontSize: 9.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
