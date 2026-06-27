import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/ads/interstitial_service.dart';
import '../../../../core/haptics/game_haptics.dart';
import '../data/carrom_sfx.dart';
import '../../../game/data/random_question_repo.dart';
import '../data/carrom3_ai.dart';
import '../data/carrom3_prefs.dart';
import '../domain/cosmetics.dart';
import '../engine/carrom_engine.dart';
import '../engine/table_geometry.dart';
import 'carrom3_board.dart';
import 'carrom3_cosmetics_page.dart';

/// Quick-chat preset — emoji + short Arabic phrase.
class ChatLine {
  const ChatLine(this.emoji, this.text);
  final String emoji;
  final String text;
  String get full => '$emoji  $text';
}

List<ChatLine> chatPresets(AppLocalizations l) => [
  ChatLine('👏', l.carromChatNiceGame),
  ChatLine('🔥', l.carromChatFireShot),
  ChatLine('🎯', l.carromChatPreciseAim),
  ChatLine('😎', l.carromChatWatchLearn),
  ChatLine('😅', l.carromChatMyLuck),
  ChatLine('👍', l.carromChatBravo),
  ChatLine('😮', l.carromChatWow),
  ChatLine('🤝', l.carromChatGoodLuck),
  ChatLine('😏', l.carromChatEasy),
  ChatLine('🥵', l.carromChatMadeItHard),
];

/// Carrom (v3) — single-device match vs the heuristic AI, built on the new
/// hand-written engine. You play the white coins from the bottom; the AI plays
/// black from the top. First to clear all nine of their colour wins.
class Carrom3MatchPage extends ConsumerStatefulWidget {
  const Carrom3MatchPage({super.key});

  @override
  ConsumerState<Carrom3MatchPage> createState() => _Carrom3MatchPageState();
}

class _Carrom3MatchPageState extends ConsumerState<Carrom3MatchPage> {
  static const int _toWin = 9;
  static const int _turnSeconds = 20; // your shot clock
  static const int _maxMisses = 3; // consecutive timeouts that lose the game

  late final CarromEngine _engine;
  final Carrom3Ai _ai = Carrom3Ai(skill: 0.82);
  final math.Random _rng = math.Random();

  TableTheme _theme = kTableThemes[0];
  CoinSet _coinSet = kCoinSets[0];
  bool _muted = false;
  Carrom3Prefs? _prefs;

  int _whiteIn = 0;
  int _blackIn = 0;
  Seat? _queenSecuredBy;
  Seat? _queenPendingBy;
  Seat _turn = Seat.you;
  Seat _shooter = Seat.you;
  bool _aiThinking = false;
  bool _gameOver = false;
  bool _youWon = false;
  String? _foul;
  double _placeFrac = 0.5;

  // Your per-turn shot clock + consecutive-timeout streak.
  Timer? _turnTimer;
  int _secondsLeft = _turnSeconds;
  int _missStreak = 0;

  bool _chatOpen = false;
  String? _myChat;
  String? _aiChat;
  Timer? _myChatTimer;
  Timer? _aiChatTimer;

  // Winner-asks flow.
  bool _qaDone = false;
  String? _aiQuestion;
  final TextEditingController _qCtrl = TextEditingController();
  final TextEditingController _aCtrl = TextEditingController();

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
    _engine.prepareStriker(Seat.you);
    CarromSfx.instance.init();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(interstitialAdServiceProvider).preload();
    });
    _load();
    _startTurnClock();
  }

  Future<void> _load() async {
    final p = await Carrom3Prefs.instance();
    if (!mounted) return;
    setState(() {
      _prefs = p;
      _theme = tableByKey(p.boardKey);
      _coinSet = coinSetByKey(p.coinKey);
      _muted = p.muted;
    });
    _applyMute();
  }

  void _applyMute() {
    CarromSfx.instance.enabled = !_muted;
    GameHaptics.enabled = !_muted;
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    _myChatTimer?.cancel();
    _aiChatTimer?.cancel();
    _qCtrl.dispose();
    _aCtrl.dispose();
    super.dispose();
  }

  Seat _other(Seat s) => s == Seat.you ? Seat.opponent : Seat.you;

  // ── Your shot clock ───────────────────────────────────────────────────────

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
    // Only your deliberation time counts — pause during motion / the AI's turn.
    if (_turn != Seat.you ||
        _aiThinking ||
        _engine.phase != EnginePhase.idle) {
      return;
    }
    setState(() => _secondsLeft = (_secondsLeft - 1).clamp(0, _turnSeconds));
    if (_secondsLeft <= 0) _onTimeout();
  }

  void _onTimeout() {
    _stopTurnClock();
    _missStreak += 1;
    GameHaptics.tap();
    if (_missStreak >= _maxMisses) return _finish(youWon: false);
    setState(() => _foul = 'timeout');
    Future<void>.delayed(const Duration(milliseconds: 400), () {
      if (!mounted || _gameOver) return;
      _engine.prepareStriker(Seat.opponent);
      setState(() {
        _turn = Seat.opponent;
        _placeFrac = 0.5;
      });
      _runAiTurn();
    });
  }

  // ── Firing ──────────────────────────────────────────────────────────────

  void _fireFromBoard(dir, power) {
    _stopTurnClock();
    _shooter = Seat.you;
    _engine.fireStriker(dir, power);
    setState(() {});
  }

  Future<void> _runAiTurn() async {
    _stopTurnClock();
    setState(() => _aiThinking = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted || _gameOver) return;
    final plan = _ai.plan(_engine, aiSeat: Seat.opponent, aiColor: DiscKind.black);
    _shooter = Seat.opponent;
    _engine.prepareStriker(Seat.opponent, atX: plan.placeX);
    _engine.fireStriker(plan.direction, plan.power);
    GameHaptics.strikerHit();
    setState(() => _aiThinking = false);
  }

  // ── Outcome ─────────────────────────────────────────────────────────────

  void _onSettled(ShotOutcome out) {
    if (_gameOver || !mounted) return;
    final shooter = _shooter;
    final youShot = shooter == Seat.you;

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

    final ownGained = youShot ? whiteGained : blackGained;
    final foul = out.strikerPocketed || out.firstHitId == -1;

    // Queen cover rule (ICF): resolve a pending cover, then a fresh pocket.
    if (_queenPendingBy == shooter) {
      if (!foul && ownGained > 0) {
        _queenSecuredBy = shooter;
        GameHaptics.win();
        CarromSfx.instance.win();
        if (youShot) {
          _aiSay(ChatLine('😮', AppLocalizations.of(context).carromChatCovered));
        }
      } else {
        _engine.returnQueen();
      }
      _queenPendingBy = null;
    }
    if (queenGained && _queenSecuredBy == null && _queenPendingBy == null) {
      if (foul) {
        _engine.returnQueen();
      } else if (ownGained > 0) {
        _queenSecuredBy = shooter;
        GameHaptics.win();
        CarromSfx.instance.win();
      } else {
        _queenPendingBy = shooter;
      }
    }

    if (youShot) _missStreak = 0; // you played → clear your timeout streak

    GameHaptics.pocket();
    setState(() {
      _whiteIn += whiteGained;
      _blackIn += blackGained;
      _foul = foul ? (out.strikerPocketed ? 'striker' : 'no_hit') : null;
    });

    if (!youShot) {
      _aiReact(pocketed: blackGained > 0, foul: foul);
    } else if (whiteGained >= 2 && _rng.nextDouble() < 0.5) {
      _aiSay(ChatLine('😮', AppLocalizations.of(context).carromChatWow));
    }

    if (_whiteIn >= _toWin) return _finish(youWon: true);
    if (_blackIn >= _toWin) return _finish(youWon: false);

    final continues = !foul && (ownGained > 0 || queenGained);
    final next = continues ? shooter : _other(shooter);
    Future<void>.delayed(const Duration(milliseconds: 450), () {
      if (!mounted || _gameOver) return;
      _engine.prepareStriker(next);
      setState(() {
        _turn = next;
        _placeFrac = 0.5;
      });
      if (next == Seat.opponent) {
        _runAiTurn();
      } else {
        _startTurnClock();
      }
    });
  }

  void _finish({required bool youWon}) {
    _stopTurnClock();
    GameHaptics.win();
    if (youWon) {
      CarromSfx.instance.win();
    } else {
      _aiSay(ChatLine('🏆', AppLocalizations.of(context).carromChatBeautifulGame));
    }
    setState(() {
      _gameOver = true;
      _youWon = youWon;
    });
    // Winner asks / loser answers: when the AI wins, pull a real question from
    // the shared bank for you to answer (local + private, like RPS vs-AI).
    if (!youWon) {
      final fallback = AppLocalizations.of(context).gameAiQLight;
      ref.read(randomQuestionRepoProvider).fetch(fallback: fallback).then((q) {
        if (mounted) setState(() => _aiQuestion = q);
      });
    }
    ref.read(interstitialAdServiceProvider).onMatchCompleted();
  }

  void _restart() {
    setState(() {
      _whiteIn = 0;
      _blackIn = 0;
      _queenSecuredBy = null;
      _queenPendingBy = null;
      _turn = Seat.you;
      _shooter = Seat.you;
      _aiThinking = false;
      _gameOver = false;
      _youWon = false;
      _foul = null;
      _placeFrac = 0.5;
      _qaDone = false;
      _aiQuestion = null;
      _missStreak = 0;
    });
    _qCtrl.clear();
    _aCtrl.clear();
    _engine.resetBreak();
    _startTurnClock();
  }

  // ── Chat ────────────────────────────────────────────────────────────────

  void _sendMyChat(ChatLine line) {
    GameHaptics.tap();
    setState(() {
      _myChat = line.full;
      _chatOpen = false;
    });
    _myChatTimer?.cancel();
    _myChatTimer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) setState(() => _myChat = null);
    });
  }

  void _aiSay(ChatLine line) {
    setState(() => _aiChat = line.full);
    _aiChatTimer?.cancel();
    _aiChatTimer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) setState(() => _aiChat = null);
    });
  }

  void _aiReact({required bool pocketed, required bool foul}) {
    final l = AppLocalizations.of(context);
    ChatLine? line;
    if (pocketed && _rng.nextDouble() < 0.7) {
      line = [
        ChatLine('😎', l.carromChatWatchLearn),
        ChatLine('😏', l.carromChatEasy),
        ChatLine('🎯', l.carromChatPreciseAim),
      ][_rng.nextInt(3)];
    } else if (foul && _rng.nextDouble() < 0.55) {
      line = [ChatLine('😅', l.carromChatMyLuck), ChatLine('🥵', l.carromChatMadeItHard)]
          [_rng.nextInt(2)];
    } else if (_rng.nextDouble() < 0.28) {
      final presets = chatPresets(l);
      line = presets[_rng.nextInt(presets.length)];
    }
    if (line != null) _aiSay(line);
  }

  // ── Build ───────────────────────────────────────────────────────────────

  String _statusText() {
    final l = AppLocalizations.of(context);
    if (_gameOver) return _youWon ? l.carromMatchWonMatch : l.carromMatchOppWon;
    if (_aiThinking) return l.carromMatchOppAiming;
    if (_engine.phase == EnginePhase.simulating) return l.carromMatchPiecesMoving;
    if (_turn == Seat.opponent) {
      return _queenPendingBy == Seat.opponent
          ? l.carromMatchOppCoversQueen
          : l.carromMatchOppTurn;
    }
    if (_queenPendingBy == Seat.you) return l.carromMatchCoverQueen;
    return l.carromMatchYourTurnHint;
  }

  Future<void> _toggleMute() async {
    setState(() => _muted = !_muted);
    _applyMute();
    GameHaptics.tap();
    await _prefs?.setMuted(_muted);
  }

  Future<void> _openCosmetics() async {
    GameHaptics.tap();
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const Carrom3CosmeticsPage()),
    );
    // Re-apply choices on return.
    final p = _prefs;
    if (p != null && mounted) {
      setState(() {
        _theme = tableByKey(p.boardKey);
        _coinSet = coinSetByKey(p.coinKey);
        _muted = p.muted;
      });
      _applyMute();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final l = AppLocalizations.of(context);
    final aimEnabled = !_gameOver &&
        !_aiThinking &&
        _turn == Seat.you &&
        _engine.phase == EnginePhase.idle;

    // Force LTR for the whole game so left/right controls (the placement
    // track, scoreboard, aim) are consistent regardless of the app language
    // (Arabic RTL was mirroring the placement slider).
    return Directionality(
      textDirection: TextDirection.ltr,
      child: PopScope(
      canPop: _gameOver,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _gameOver) context.go(AppRoutes.gamesHub);
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
              context.go(AppRoutes.gamesHub);
            },
          ),
          title: Text(l.carromMatchTitle,
              style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 18)),
          centerTitle: false,
          actions: [
            IconButton(
              tooltip: _muted ? l.carromUnmute : l.carromMute,
              icon: Icon(
                  _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: colors.textSecondary),
              onPressed: _toggleMute,
            ),
            IconButton(
              tooltip: l.carromSkins,
              icon: Icon(Icons.palette_outlined, color: colors.mind),
              onPressed: _openCosmetics,
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
                            coinColor: _coinSet.white.base,
                            progress: _whiteIn,
                            total: _toWin,
                            active: _turn == Seat.you && !_gameOver,
                            accent: colors.moment,
                          ),
                        ),
                        const Gap(10),
                        _QueenBadge(
                          secured: _queenSecuredBy != null,
                          securedByYou: _queenSecuredBy == Seat.you,
                          pending: _queenPendingBy != null,
                        ),
                        const Gap(10),
                        Expanded(
                          child: _PlayerChip(
                            name: l.carromOpponent,
                            coinColor: _coinSet.black.base,
                            progress: _blackIn,
                            total: _toWin,
                            active: _turn == Seat.opponent && !_gameOver,
                            accent: colors.face,
                            thinking: _aiThinking,
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
                                    color: Colors.black.withValues(alpha: 0.35),
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
                                  onSettled: _onSettled,
                                  onFire: _fireFromBoard,
                                ),
                              ),
                            ),
                            IgnorePointer(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (_aiChat != null)
                                    Align(
                                      alignment: const Alignment(0, -0.78),
                                      child: _ChatBubble(
                                          key: ValueKey('ai_$_aiChat'),
                                          text: _aiChat!),
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
                              _QaOverlay(
                                youWon: _youWon,
                                aiQuestion: _aiQuestion,
                                qCtrl: _qCtrl,
                                aCtrl: _aCtrl,
                                onDone: () => setState(() => _qaDone = true),
                              ),
                            if (_gameOver && _qaDone)
                              _MatchOverOverlay(
                                youWon: _youWon,
                                you: _whiteIn,
                                opp: _blackIn,
                                onRestart: _restart,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Gap(8),
                  // Placement track (precise striker positioning).
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: _PlacementBar(
                      value: _placeFrac,
                      enabled: aimEnabled,
                      accent: colors.moment,
                      onChanged: (f) {
                        setState(() => _placeFrac = f);
                        final x = TableGeometry.strikerMinX +
                            (TableGeometry.strikerMaxX -
                                    TableGeometry.strikerMinX) *
                                f;
                        _engine.moveStriker(x);
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
                              !_aiThinking &&
                              _turn == Seat.you &&
                              _engine.phase == EnginePhase.idle)
                          ? _secondsLeft.clamp(0, _turnSeconds)
                          : null,
                    ),
                  ),
                ],
              ),
              // Chat button — bottom-left for easy thumb reach.
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
    ));
  }
}

// ─────────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────────

class _PlayerChip extends StatelessWidget {
  const _PlayerChip({
    required this.name,
    required this.coinColor,
    required this.progress,
    required this.total,
    required this.active,
    required this.accent,
    this.thinking = false,
  });
  final String name;
  final Color coinColor;
  final int progress;
  final int total;
  final bool active;
  final Color accent;
  final bool thinking;

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
                Row(
                  children: [
                    Text(name,
                        style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w800)),
                    if (thinking) ...[
                      const Gap(6),
                      const SizedBox(
                          width: 11,
                          height: 11,
                          child: CircularProgressIndicator(strokeWidth: 1.8)),
                    ],
                  ],
                ),
                const Gap(4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress / total,
                    minHeight: 5,
                    backgroundColor: colors.textSecondary.withValues(alpha: 0.18),
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
      {required this.secured, required this.securedByYou, required this.pending});
  final bool secured;
  final bool securedByYou;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final accent = pending
        ? const Color(0xFFE6A23C)
        : secured
            ? (securedByYou ? const Color(0xFFD4A85F) : const Color(0xFF6DB4D8))
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
                inactiveTrackColor: colors.textSecondary.withValues(alpha: 0.2),
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
        return l.carromFoulTimeout;
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

/// Winner-asks / loser-answers. When you win you compose a question for your
/// opponent; when you lose you answer the question they ask (pulled from the
/// shared bank for the AI). Local + private here; the online layer will route
/// it to the real opponent.
class _QaOverlay extends StatelessWidget {
  const _QaOverlay({
    required this.youWon,
    required this.aiQuestion,
    required this.qCtrl,
    required this.aCtrl,
    required this.onDone,
  });

  final bool youWon;
  final String? aiQuestion;
  final TextEditingController qCtrl;
  final TextEditingController aCtrl;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      color: Colors.black.withValues(alpha: 0.62),
      alignment: Alignment.center,
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
            Text(youWon ? '🏆' : '🎯', style: const TextStyle(fontSize: 40)),
            const Gap(6),
            Text(
              youWon ? l.carromQaWinAsk : l.carromQaLoseAnswer,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFFD4A85F),
                  fontSize: 18,
                  fontWeight: FontWeight.w900),
            ),
            const Gap(14),
            if (youWon)
              TextField(
                controller: qCtrl,
                maxLines: 2,
                minLines: 1,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.white),
                decoration: _dec(l.carromQaQuestionHint),
              )
            else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x22D4A85F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  aiQuestion ?? l.carromQaFetchingQuestion,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const Gap(10),
              TextField(
                controller: aCtrl,
                maxLines: 2,
                minLines: 1,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.white),
                decoration: _dec(l.carromQaAnswerHint),
              ),
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
                    child: Text(l.carromSkip),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFD4A85F),
                        foregroundColor: const Color(0xFF2A1A0D)),
                    onPressed: () {
                      GameHaptics.uiPop();
                      onDone();
                    },
                    child: Text(youWon ? l.carromSendQuestion : l.carromSendAnswer),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

class _MatchOverOverlay extends StatelessWidget {
  const _MatchOverOverlay({
    required this.youWon,
    required this.you,
    required this.opp,
    required this.onRestart,
  });
  final bool youWon;
  final int you;
  final int opp;
  final VoidCallback onRestart;
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
              color: youWon ? const Color(0xFFD4A85F) : const Color(0xFF8A6520),
              width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(youWon ? '🏆' : '🤖', style: const TextStyle(fontSize: 52)),
            const Gap(8),
            Text(youWon ? l.carromYouWon : l.carromMatchOppWon,
                style: TextStyle(
                    color: youWon
                        ? const Color(0xFFD4A85F)
                        : const Color(0xFFE0D6C4),
                    fontWeight: FontWeight.w900,
                    fontSize: 26)),
            const Gap(6),
            Text('$you × $opp',
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
                  onPressed: () => GoRouter.of(context).go(AppRoutes.gamesHub),
                  icon: const Icon(Icons.home_rounded, size: 16),
                  label: Text(l.carromGameOverLobby),
                ),
                const Gap(10),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFD4A85F),
                      foregroundColor: const Color(0xFF2A1A0D)),
                  onPressed: onRestart,
                  icon: const Icon(Icons.restart_alt_rounded, size: 16),
                  label: Text(l.carromNewMatch),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
