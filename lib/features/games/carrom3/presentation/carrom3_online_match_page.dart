import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/ads/interstitial_service.dart';
import '../../../../core/haptics/game_haptics.dart';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/providers/storage_providers.dart';
import '../data/carrom_sfx.dart';
import '../data/carrom3_api.dart';
import '../data/carrom3_prefs.dart';
import '../data/carrom3_ws_client.dart';
import '../domain/cosmetics.dart';
import '../engine/carrom_engine.dart';
import '../engine/table_geometry.dart';
import '../engine/vec2.dart';
import 'carrom3_board.dart';
import 'carrom3_match_page.dart' show ChatLine, chatPresets;

/// Online Carrom v3 — real player vs real player over the deterministic
/// lockstep relay. The server is a dumb relay: it forwards each shot's PARAMS
/// (placement + direction + power, in absolute engine coords). Both clients run
/// the SAME deterministic engine and replay the shot, so their boards stay
/// byte-identical without the server simulating anything.
///
/// Seat 'a' is the bottom (engine [Seat.you]); seat 'b' is the top
/// (engine [Seat.opponent]). Seat 'b' renders the board flipped so the local
/// player always sits at the bottom. Seat 'a' plays white, seat 'b' plays black;
/// first to clear all nine of their colour wins. Seat 'a' breaks.
class Carrom3OnlineMatchPage extends ConsumerStatefulWidget {
  const Carrom3OnlineMatchPage({
    super.key,
    required this.roomId,
    required this.mySeat,
  });

  final String roomId;
  final String mySeat; // 'a' | 'b'

  @override
  ConsumerState<Carrom3OnlineMatchPage> createState() =>
      _Carrom3OnlineMatchPageState();
}

class _Carrom3OnlineMatchPageState
    extends ConsumerState<Carrom3OnlineMatchPage> {
  static const int _toWin = 9;
  static const int _turnSeconds = 20; // per-turn shot clock
  static const int _passiveGrace = 5; // extra seconds before claiming a stall
  static const int _maxMisses = 3; // consecutive timeouts that lose the game

  late final CarromEngine _engine;
  Carrom3WsClient? _ws;
  StreamSubscription<C3Event>? _sub;

  bool get _flip => widget.mySeat == 'b';
  Seat _engineSeat(String s) => s == 'a' ? Seat.you : Seat.opponent;
  String _otherSeat(String s) => s == 'a' ? 'b' : 'a';
  bool get _isMyTurn => _turnSeat == widget.mySeat;

  TableTheme _theme = kTableThemes[0];
  CoinSet _coinSet = kCoinSets[0];
  bool _muted = false;

  int _whiteIn = 0;
  int _blackIn = 0;
  String? _queenSecuredSeat;
  String? _queenPendingSeat;
  String _turnSeat = 'a'; // seat 'a' breaks
  String _shooterSeat = 'a';
  bool _gameOver = false;
  String? _winnerSeat;
  String? _foul;
  double _placeFrac = 0.5;

  bool _connectionUp = true;
  bool _opponentLeft = false;
  bool _opponentPresent = true; // assume present once matched

  // Per-turn shot clock + consecutive-timeout streaks (per seat).
  Timer? _turnTimer;
  int _secondsLeft = _turnSeconds;
  int _missA = 0;
  int _missB = 0;

  bool _chatOpen = false;
  String? _myChat;
  String? _oppChat;
  Timer? _myChatTimer;
  Timer? _oppChatTimer;

  // Winner-asks / loser-answers, routed over the relay.
  bool _qaDone = false;
  bool _questionSent = false;
  bool _answerSent = false;
  String? _incomingQuestion; // shown to the loser
  String? _incomingAnswer; // shown to the winner
  final TextEditingController _qCtrl = TextEditingController();
  final TextEditingController _aCtrl = TextEditingController();

  bool get _iWon => _gameOver && _winnerSeat == widget.mySeat;

  @override
  void initState() {
    super.initState();
    _engine = CarromEngine()
      ..onStrike = () {
        CarromSfx.instance.strike();
      }
      ..onCollide = (i) {
        CarromSfx.instance.hit(i);
      }
      ..onPocket = (_) {
        CarromSfx.instance.pocket();
      };
    _engine.prepareStriker(Seat.you); // seat 'a' baseline (the breaker)
    CarromSfx.instance.init();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(interstitialAdServiceProvider).preload();
    });
    _load();
    _openSocket();
    _startTurnClock(); // seat 'a' is on the clock from the break
  }

  Future<void> _load() async {
    final p = await Carrom3Prefs.instance();
    if (!mounted) return;
    setState(() {
      _theme = tableByKey(p.boardKey);
      _coinSet = coinSetByKey(p.coinKey);
      _muted = p.muted;
    });
    CarromSfx.instance.enabled = !_muted;
    GameHaptics.enabled = !_muted;
  }

  void _openSocket() {
    final dio = ref.read(dioClientProvider);
    final ws = Carrom3WsClient(
      httpBaseUrl: dio.raw.options.baseUrl,
      roomId: widget.roomId,
      mySeat: widget.mySeat,
      secureStorage: ref.read(secureStorageProvider),
    );
    _ws = ws;
    _sub = ws.events.listen(_onWsEvent);
    ws.connect();
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    _myChatTimer?.cancel();
    _oppChatTimer?.cancel();
    _qCtrl.dispose();
    _aCtrl.dispose();
    _sub?.cancel();
    _ws?.dispose();
    super.dispose();
  }

  // ── Networking ────────────────────────────────────────────────────────────

  void _onWsEvent(C3Event e) {
    if (!mounted) return;
    switch (e) {
      case C3ConnectionUp():
        setState(() => _connectionUp = true);
      case C3ConnectionDown():
        setState(() => _connectionUp = false);
      case C3OpponentReadyEvent():
        setState(() => _opponentPresent = true);
      case C3OpponentLeftEvent():
        setState(() {
          _opponentPresent = false;
          _opponentLeft = true;
        });
        if (!_gameOver) _finish(winnerSeat: widget.mySeat);
      case C3ShotEvent():
        _opponentPresent = true;
        _applyRemoteShot(e);
      case C3ChatEvent():
        _showOppChat('${e.emoji}  ${e.text}'.trim());
      case C3QuestionEvent():
        setState(() => _incomingQuestion = e.text);
      case C3AnswerEvent():
        setState(() => _incomingAnswer = e.text);
      case C3SkipEvent():
        // The opponent's shot clock ran out → record it and pass the turn.
        _applyTimeout(e.fromSeat);
      case C3ConcedeEvent():
        // The opponent forfeited → we win.
        if (!_gameOver) _finish(winnerSeat: widget.mySeat);
      case C3StateEvent():
        if (e.status == 'finished' && !_gameOver) {
          _finish(winnerSeat: e.winnerSeat ?? widget.mySeat);
        }
      case C3ErrorEvent():
        break;
    }
  }

  /// Remote shots that arrived while our engine was still simulating the
  /// previous one. The old code DROPPED them, which permanently desynced the
  /// two boards; instead we replay them in order once we return to idle.
  final List<C3ShotEvent> _pendingRemoteShots = [];

  void _drainPendingRemoteShots() {
    if (_gameOver || _pendingRemoteShots.isEmpty) return;
    if (_engine.phase != EnginePhase.idle) return;
    _applyRemoteShot(_pendingRemoteShots.removeAt(0));
  }

  void _applyRemoteShot(C3ShotEvent e) {
    if (_gameOver) return;
    if (_engine.phase != EnginePhase.idle) {
      // Don't drop — queue and replay when the engine settles (see _onSettled
      // / _applyTimeout draining). Dropping caused permanent board divergence.
      _pendingRemoteShots.add(e);
      return;
    }
    _stopTurnClock();
    _shooterSeat = e.fromSeat;
    _engine.prepareStriker(_engineSeat(e.fromSeat), atX: e.placeX);
    _engine.fireStriker(Vec2(e.dirX, e.dirY), e.power);
    GameHaptics.strikerHit();
    setState(() {});
  }

  // ── Firing (local) ────────────────────────────────────────────────────────

  void _fireFromBoard(Vec2 dir, double power) {
    if (!_isMyTurn || _gameOver) return;
    _stopTurnClock();
    _shooterSeat = widget.mySeat;
    final placeX = _engine.striker.pos.x;
    _engine.fireStriker(dir, power);
    _ws?.sendShot(
      placeX: placeX,
      dirX: dir.x,
      dirY: dir.y,
      power: power,
    );
    setState(() {});
  }

  // ── Per-turn shot clock ───────────────────────────────────────────────────

  void _startTurnClock() {
    _stopTurnClock();
    if (_gameOver) return;
    setState(() => _secondsLeft = _turnSeconds);
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  void _stopTurnClock() {
    _turnTimer?.cancel();
    _turnTimer = null;
  }

  void _onTick() {
    if (!mounted || _gameOver) {
      _stopTurnClock();
      return;
    }
    // Pause while disconnected, while the opponent is gone, or while the
    // pieces are still moving — the clock only counts deliberation time.
    if (!_connectionUp ||
        _opponentLeft ||
        !_opponentPresent ||
        _engine.phase != EnginePhase.idle) {
      return;
    }
    final active = _turnSeat;
    final iAmActive = active == widget.mySeat;
    setState(() {
      _secondsLeft = (_secondsLeft - 1).clamp(-_passiveGrace, _turnSeconds);
    });
    if (iAmActive) {
      // I own my clock: when it hits zero, relay the skip and pass the turn.
      if (_secondsLeft <= 0) {
        _ws?.sendSkip();
        _applyTimeout(active);
      }
    } else {
      // Passive fallback — if the active player never relays a skip (frozen
      // client), claim the timeout a few seconds late so we can't deadlock.
      if (_secondsLeft <= -_passiveGrace) {
        _applyTimeout(active);
      }
    }
  }

  /// Pass the turn because [seat]'s clock expired. The [_turnSeat] guard makes
  /// this idempotent, so a duplicated skip (relayed + passive fallback) is
  /// applied at most once. Both clients run identical book-keeping.
  void _applyTimeout(String seat) {
    if (_gameOver ||
        _turnSeat != seat ||
        _engine.phase != EnginePhase.idle) {
      return;
    }
    _stopTurnClock();
    if (seat == 'a') {
      _missA += 1;
    } else {
      _missB += 1;
    }
    final streak = seat == 'a' ? _missA : _missB;
    GameHaptics.tap();
    if (streak >= _maxMisses) {
      _finish(winnerSeat: _otherSeat(seat));
      return;
    }
    final next = _otherSeat(seat);
    _engine.prepareStriker(_engineSeat(next));
    setState(() {
      _turnSeat = next;
      _placeFrac = 0.5;
      _foul = 'timeout';
    });
    _startTurnClock();
    _drainPendingRemoteShots();
  }

  // ── Outcome (identical on both clients — engine is deterministic) ──────────

  void _onSettled(ShotOutcome out) {
    if (_gameOver || !mounted) return;
    final shooter = _shooterSeat;
    final shooterIsA = shooter == 'a';

    var whiteGained = 0;
    var blackGained = 0;
    var queenGained = false;
    for (final id in out.pocketedIds) {
      if (id < 0 || id >= _engine.pieces.length) continue;
      switch (_engine.pieces[id].kind) {
        case DiscKind.white:
          whiteGained++;
        case DiscKind.black:
          blackGained++;
        case DiscKind.queen:
          queenGained = true;
        case DiscKind.striker:
          break;
      }
    }

    final ownGained = shooterIsA ? whiteGained : blackGained;
    final foul = out.strikerPocketed || out.firstHitId == -1;

    // Queen cover rule (ICF): resolve a pending cover, then a fresh pocket.
    if (_queenPendingSeat == shooter) {
      if (!foul && ownGained > 0) {
        _queenSecuredSeat = shooter;
        GameHaptics.win();
        CarromSfx.instance.win();
      } else {
        _engine.returnQueen();
      }
      _queenPendingSeat = null;
    }
    if (queenGained && _queenSecuredSeat == null && _queenPendingSeat == null) {
      if (foul) {
        _engine.returnQueen();
      } else if (ownGained > 0) {
        _queenSecuredSeat = shooter;
        GameHaptics.win();
        CarromSfx.instance.win();
      } else {
        _queenPendingSeat = shooter;
      }
    }

    // A played shot clears that player's timeout streak.
    if (shooterIsA) {
      _missA = 0;
    } else {
      _missB = 0;
    }

    GameHaptics.pocket();
    setState(() {
      _whiteIn += whiteGained;
      _blackIn += blackGained;
      _foul = foul ? (out.strikerPocketed ? 'striker' : 'no_hit') : null;
    });

    if (_whiteIn >= _toWin) return _finish(winnerSeat: 'a');
    if (_blackIn >= _toWin) return _finish(winnerSeat: 'b');

    final continues = !foul && (ownGained > 0 || queenGained);
    final next = continues ? shooter : _otherSeat(shooter);
    Future<void>.delayed(const Duration(milliseconds: 450), () {
      if (!mounted || _gameOver) return;
      _engine.prepareStriker(_engineSeat(next));
      setState(() {
        _turnSeat = next;
        _placeFrac = 0.5;
      });
      _startTurnClock();
      _drainPendingRemoteShots();
    });
  }

  void _finish({required String winnerSeat}) {
    if (_gameOver) return;
    _stopTurnClock();
    GameHaptics.win();
    if (winnerSeat == widget.mySeat) CarromSfx.instance.win();
    setState(() {
      _gameOver = true;
      _winnerSeat = winnerSeat;
    });
    ref.read(interstitialAdServiceProvider).onMatchCompleted();
  }

  // ── Chat ──────────────────────────────────────────────────────────────────

  void _sendMyChat(ChatLine line) {
    GameHaptics.tap();
    _ws?.sendChat(line.emoji, line.text);
    setState(() {
      _myChat = line.full;
      _chatOpen = false;
    });
    _myChatTimer?.cancel();
    _myChatTimer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) setState(() => _myChat = null);
    });
  }

  void _showOppChat(String text) {
    setState(() => _oppChat = text);
    _oppChatTimer?.cancel();
    _oppChatTimer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) setState(() => _oppChat = null);
    });
  }

  // ── Q&A (winner asks / loser answers, over the relay) ─────────────────────

  void _sendQuestion() {
    final t = _qCtrl.text.trim();
    if (t.isEmpty) return;
    GameHaptics.uiPop();
    _ws?.sendQuestion(t);
    setState(() => _questionSent = true);
  }

  void _sendAnswer() {
    final t = _aCtrl.text.trim();
    if (t.isEmpty) return;
    GameHaptics.uiPop();
    _ws?.sendAnswer(t);
    setState(() => _answerSent = true);
  }

  // ── Leaving ────────────────────────────────────────────────────────────────

  Future<void> _leave() async {
    if (!_gameOver) {
      _ws?.sendConcede();
      await ref.read(carrom3ApiProvider).concede(widget.roomId);
    }
    if (mounted) context.go(AppRoutes.gamesHub);
  }

  // ── Status text ───────────────────────────────────────────────────────────

  String _statusText() {
    final l = AppLocalizations.of(context);
    if (!_connectionUp) return l.carromMatchReconnect;
    if (_opponentLeft) return l.carromOppLeft;
    if (_gameOver) return _iWon ? l.carromMatchWonMatch : l.carromMatchOppWon;
    if (_engine.phase == EnginePhase.simulating) return l.carromMatchPiecesMoving;
    if (!_isMyTurn) {
      return _queenPendingSeat == _otherSeat(widget.mySeat)
          ? l.carromMatchOppCoversQueen
          : l.carromMatchOppTurn;
    }
    if (_queenPendingSeat == widget.mySeat) {
      return l.carromMatchCoverQueen;
    }
    return l.carromMatchYourTurnHint;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final l = AppLocalizations.of(context);
    final myColor = widget.mySeat == 'a' ? _coinSet.white : _coinSet.black;
    final oppColor = widget.mySeat == 'a' ? _coinSet.black : _coinSet.white;
    final myScore = widget.mySeat == 'a' ? _whiteIn : _blackIn;
    final oppScore = widget.mySeat == 'a' ? _blackIn : _whiteIn;

    final aimEnabled = !_gameOver &&
        _isMyTurn &&
        _connectionUp &&
        _opponentPresent &&
        !_opponentLeft &&
        _engine.phase == EnginePhase.idle;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _leave();
        },
        child: Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: colors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.close_rounded, color: colors.textPrimary),
              onPressed: () {
                GameHaptics.tap();
                _leave();
              },
            ),
            title: Text(l.carromOnlineTitle,
                style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 18)),
            centerTitle: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _ConnDot(up: _connectionUp),
              ),
            ],
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    const Gap(4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: _PlayerChip(
                              name: l.carromYou,
                              coinColor: myColor.base,
                              progress: myScore,
                              total: _toWin,
                              active: _isMyTurn && !_gameOver,
                              accent: colors.moment,
                            ),
                          ),
                          const Gap(10),
                          _QueenBadge(
                            secured: _queenSecuredSeat != null,
                            securedByMe: _queenSecuredSeat == widget.mySeat,
                            pending: _queenPendingSeat != null,
                          ),
                          const Gap(10),
                          Expanded(
                            child: _PlayerChip(
                              name: l.carromOpponent,
                              coinColor: oppColor.base,
                              progress: oppScore,
                              total: _toWin,
                              active: !_isMyTurn && !_gameOver,
                              accent: colors.face,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(6),
                    if (_foul != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _FoulBanner(reason: _foul!),
                      ),
                    const Gap(4),
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.35),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Carrom3BoardView(
                                    engine: _engine,
                                    theme: _theme,
                                    coinSet: _coinSet,
                                    aimEnabled: aimEnabled,
                                    flip: _flip,
                                    onSettled: _onSettled,
                                    onFire: _fireFromBoard,
                                  ),
                                ),
                              ),
                              IgnorePointer(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    if (_oppChat != null)
                                      Align(
                                        alignment: const Alignment(0, -0.78),
                                        child: _ChatBubble(
                                            key: ValueKey('opp_$_oppChat'),
                                            text: _oppChat!),
                                      ),
                                    if (_myChat != null)
                                      Align(
                                        alignment: const Alignment(0, 0.82),
                                        child: _ChatBubble(
                                            key: ValueKey('me_$_myChat'),
                                            text: _myChat!),
                                      ),
                                  ],
                                ),
                              ),
                              if (_gameOver && !_qaDone)
                                _OnlineQaOverlay(
                                  iWon: _iWon,
                                  qCtrl: _qCtrl,
                                  aCtrl: _aCtrl,
                                  questionSent: _questionSent,
                                  answerSent: _answerSent,
                                  incomingQuestion: _incomingQuestion,
                                  incomingAnswer: _incomingAnswer,
                                  onSendQuestion: _sendQuestion,
                                  onSendAnswer: _sendAnswer,
                                  onDone: () => setState(() => _qaDone = true),
                                ),
                              if (_gameOver && _qaDone)
                                _MatchOverOverlay(
                                  iWon: _iWon,
                                  me: myScore,
                                  opp: oppScore,
                                  onLobby: () =>
                                      context.go(AppRoutes.gamesHub),
                                  onRematch: () => context.pushReplacement(
                                      AppRoutes.carrom3Online),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Gap(8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: _PlacementBar(
                        value: _placeFrac,
                        enabled: aimEnabled,
                        accent: colors.moment,
                        onChanged: (f) {
                          setState(() => _placeFrac = f);
                          final range = TableGeometry.strikerMaxX -
                              TableGeometry.strikerMinX;
                          final ex = _flip
                              ? TableGeometry.strikerMaxX - range * f
                              : TableGeometry.strikerMinX + range * f;
                          _engine.moveStriker(ex);
                        },
                      ),
                    ),
                    const Gap(8),
                    if (_chatOpen && !_gameOver)
                      _ChatPresetRow(onPick: _sendMyChat, accent: colors.mind),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _StatusPill(
                        text: _statusText(),
                        accent: colors.crystal,
                        seconds: (!_gameOver &&
                                _connectionUp &&
                                !_opponentLeft &&
                                _opponentPresent &&
                                _engine.phase == EnginePhase.idle)
                            ? _secondsLeft.clamp(0, _turnSeconds)
                            : null,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: _ChatFab(
                    open: _chatOpen,
                    accent: colors.mind,
                    surface: colors.surface,
                    onTap: _gameOver
                        ? null
                        : () {
                            GameHaptics.tap();
                            setState(() => _chatOpen = !_chatOpen);
                          },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Widgets (mirrors the vs-AI page; kept local so the two stay independent)
// ─────────────────────────────────────────────────────────────────────

class _ConnDot extends StatelessWidget {
  const _ConnDot({required this.up});
  final bool up;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = up ? const Color(0xFF3DBE6B) : const Color(0xFFE0A33C);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(shape: BoxShape.circle, color: c),
        ),
        const Gap(6),
        Text(up ? l.carromConnected : l.carromConnecting,
            style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _PlayerChip extends StatelessWidget {
  const _PlayerChip({
    required this.name,
    required this.coinColor,
    required this.progress,
    required this.total,
    required this.active,
    required this.accent,
  });
  final String name;
  final Color coinColor;
  final int progress;
  final int total;
  final bool active;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: active
            ? accent.withValues(alpha: 0.16)
            : colors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active
              ? accent.withValues(alpha: 0.7)
              : colors.textSecondary.withValues(alpha: 0.18),
          width: active ? 1.4 : 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.3),
                colors: [Color.lerp(coinColor, Colors.white, 0.5)!, coinColor],
              ),
              border: Border.all(color: const Color(0x55000000)),
            ),
          ),
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name,
                    style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
                const Gap(4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress / total,
                    minHeight: 5,
                    backgroundColor:
                        colors.textSecondary.withValues(alpha: 0.18),
                    valueColor: AlwaysStoppedAnimation(accent),
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),
          Text('$progress/$total',
              style: TextStyle(
                  color: accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  fontFeatures: const [FontFeature.tabularFigures()])),
        ],
      ),
    );
  }
}

class _QueenBadge extends StatelessWidget {
  const _QueenBadge(
      {required this.secured, required this.securedByMe, required this.pending});
  final bool secured;
  final bool securedByMe;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final accent = pending
        ? const Color(0xFFE6A23C)
        : secured
            ? (securedByMe ? const Color(0xFFD4A85F) : const Color(0xFF6DB4D8))
            : const Color(0xFFC8102E);
    final label = secured ? '✓' : (pending ? '…' : '👑');
    return Container(
      width: 46,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.55)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.3, -0.3),
                colors: [Color(0xFFFF7C8C), Color(0xFFC8102E)],
              ),
              border: pending
                  ? Border.all(color: const Color(0xFFE6A23C), width: 1.4)
                  : null,
            ),
          ),
          const Gap(3),
          Text(label,
              style: TextStyle(
                  color: accent, fontSize: 11, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _PlacementBar extends StatelessWidget {
  const _PlacementBar({
    required this.value,
    required this.enabled,
    required this.accent,
    required this.onChanged,
  });
  final double value;
  final bool enabled;
  final Color accent;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Row(
        children: [
          Icon(Icons.swap_horiz_rounded, size: 18, color: colors.textSecondary),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                activeTrackColor: accent.withValues(alpha: 0.6),
                inactiveTrackColor:
                    colors.textSecondary.withValues(alpha: 0.2),
                thumbColor: accent,
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                value: value.clamp(0.0, 1.0),
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoulBanner extends StatelessWidget {
  const _FoulBanner({required this.reason});
  final String reason;
  String _label(AppLocalizations l) {
    switch (reason) {
      case 'striker':
        return l.carromFoulStriker;
      case 'no_hit':
        return l.carromFoulNoHit;
      case 'timeout':
        return l.carromFoulTimeoutOnline;
      default:
        return l.carromFoul;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: const Color(0xCCD22F2F),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 14),
          const Gap(6),
          Text(_label(l),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.accent, this.seconds});
  final String text;
  final Color accent;
  final int? seconds;
  @override
  Widget build(BuildContext context) {
    final low = seconds != null && seconds! <= 5;
    final timerColor = low ? const Color(0xFFE0533C) : accent;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.30), width: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (seconds != null) ...[
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: timerColor.withValues(alpha: 0.18),
                border: Border.all(color: timerColor.withValues(alpha: 0.8)),
              ),
              child: Text('$seconds',
                  style: TextStyle(
                      color: timerColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      fontFeatures: const [FontFeature.tabularFigures()])),
            ),
            const Gap(10),
          ],
          Flexible(
            child: Text(text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: accent, fontSize: 13.5, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _ChatFab extends StatelessWidget {
  const _ChatFab({
    required this.open,
    required this.accent,
    required this.surface,
    required this.onTap,
  });
  final bool open;
  final Color accent;
  final Color surface;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: open ? accent.withValues(alpha: 0.22) : surface,
            shape: BoxShape.circle,
            border: Border.all(color: accent.withValues(alpha: 0.55), width: 1.2),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Icon(
            open
                ? Icons.chat_bubble_rounded
                : Icons.chat_bubble_outline_rounded,
            color: accent,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _ChatPresetRow extends StatelessWidget {
  const _ChatPresetRow({required this.onPick, required this.accent});
  final void Function(ChatLine) onPick;
  final Color accent;
  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final l = AppLocalizations.of(context);
    final presets = chatPresets(l);
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(70, 0, 14, 8),
        itemCount: presets.length,
        separatorBuilder: (_, __) => const Gap(8),
        itemBuilder: (context, i) {
          final line = presets[i];
          return GestureDetector(
            onTap: () => onPick(line),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: accent.withValues(alpha: 0.4), width: 0.8),
              ),
              alignment: Alignment.center,
              child: Text(line.full,
                  style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ),
          );
        },
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.7 + 0.3 * t, child: child),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 230),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xF21D1A16),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xBFD4A85F), width: 1.2),
        ),
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

/// Winner asks → loser answers, routed live between the two real players.
class _OnlineQaOverlay extends StatelessWidget {
  const _OnlineQaOverlay({
    required this.iWon,
    required this.qCtrl,
    required this.aCtrl,
    required this.questionSent,
    required this.answerSent,
    required this.incomingQuestion,
    required this.incomingAnswer,
    required this.onSendQuestion,
    required this.onSendAnswer,
    required this.onDone,
  });

  final bool iWon;
  final TextEditingController qCtrl;
  final TextEditingController aCtrl;
  final bool questionSent;
  final bool answerSent;
  final String? incomingQuestion;
  final String? incomingAnswer;
  final VoidCallback onSendQuestion;
  final VoidCallback onSendAnswer;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      color: Colors.black.withValues(alpha: 0.62),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2421),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFD4A85F), width: 1.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(iWon ? '🏆' : '🎯', style: const TextStyle(fontSize: 40)),
              const Gap(6),
              Text(
                iWon ? l.carromQaWinAsk : l.carromQaLoseAnswer,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFFD4A85F),
                    fontSize: 18,
                    fontWeight: FontWeight.w900),
              ),
              const Gap(14),
              if (iWon) ...[
                if (!questionSent)
                  TextField(
                    controller: qCtrl,
                    maxLines: 2,
                    minLines: 1,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white),
                    decoration: _dec(l.carromQaQuestionHint),
                  )
                else if (incomingAnswer == null)
                  _WaitRow(text: l.carromQaWaitingAnswer)
                else
                  _Bubble(label: l.carromBubbleOppAnswer, text: incomingAnswer!),
              ] else ...[
                if (incomingQuestion == null)
                  _WaitRow(text: l.carromQaWaitingQuestion)
                else ...[
                  _Bubble(label: l.carromBubbleOppQuestion, text: incomingQuestion!),
                  const Gap(10),
                  if (!answerSent)
                    TextField(
                      controller: aCtrl,
                      maxLines: 2,
                      minLines: 1,
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: Colors.white),
                      decoration: _dec(l.carromQaAnswerHint),
                    )
                  else
                    _WaitRow(text: l.carromQaAnswerSent, spin: false),
                ],
              ],
              const Gap(8),
              Text(l.carromQaPrivate,
                  style: const TextStyle(color: Color(0x88FFFFFF), fontSize: 11)),
              const Gap(14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE0D6C4),
                        side: const BorderSide(color: Color(0x55FFFFFF)),
                      ),
                      onPressed: onDone,
                      child: Text(_skipLabel(l)),
                    ),
                  ),
                  if (_showSend()) ...[
                    const Gap(10),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFD4A85F),
                            foregroundColor: const Color(0xFF2A1A0D)),
                        onPressed: iWon ? onSendQuestion : onSendAnswer,
                        child: Text(iWon ? l.carromSendQuestion : l.carromSendAnswer),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _showSend() {
    if (iWon) return !questionSent;
    return incomingQuestion != null && !answerSent;
  }

  String _skipLabel(AppLocalizations l) {
    if (iWon) return questionSent ? l.carromFinish : l.carromSkip;
    return answerSent ? l.carromFinish : l.carromSkip;
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0x66FFFFFF)),
        filled: true,
        fillColor: const Color(0x22FFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.label, required this.text});
  final String label;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x22D4A85F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  color: Color(0xAAD4A85F),
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
          const Gap(4),
          Text(text,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _WaitRow extends StatelessWidget {
  const _WaitRow({required this.text, this.spin = true});
  final String text;
  final bool spin;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (spin)
          const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Color(0xFFD4A85F))),
        if (spin) const Gap(8),
        Flexible(
          child: Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFFE0D6C4),
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

class _MatchOverOverlay extends StatelessWidget {
  const _MatchOverOverlay({
    required this.iWon,
    required this.me,
    required this.opp,
    required this.onLobby,
    required this.onRematch,
  });
  final bool iWon;
  final int me;
  final int opp;
  final VoidCallback onLobby;
  final VoidCallback onRematch;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      color: Colors.black.withValues(alpha: 0.58),
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2421),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: iWon ? const Color(0xFFD4A85F) : const Color(0xFF8A6520),
              width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(iWon ? '🏆' : '🎯', style: const TextStyle(fontSize: 52)),
            const Gap(8),
            Text(iWon ? l.carromYouWon : l.carromMatchOppWon,
                style: TextStyle(
                    color: iWon
                        ? const Color(0xFFD4A85F)
                        : const Color(0xFFE0D6C4),
                    fontWeight: FontWeight.w900,
                    fontSize: 26)),
            const Gap(6),
            Text('$me × $opp',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    fontFeatures: [FontFeature.tabularFigures()])),
            const Gap(18),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE0D6C4),
                      side: const BorderSide(color: Color(0x55FFFFFF))),
                  onPressed: onLobby,
                  icon: const Icon(Icons.home_rounded, size: 16),
                  label: Text(l.carromGameOverLobby),
                ),
                const Gap(10),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFD4A85F),
                      foregroundColor: const Color(0xFF2A1A0D)),
                  onPressed: onRematch,
                  icon: const Icon(Icons.search_rounded, size: 16),
                  label: Text(l.carromNewOpponent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
