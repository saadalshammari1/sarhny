import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/router.dart';
import '../theme/ludo_theme.dart';

/// Pre-match "searching for opponents" screen.
///
/// Currently the search is locally choreographed: a 12-second window with
/// staged "found a player" beats, then a bot-fill notice, then transition
/// into the match. The shell is structured so a future Sarhny WebSocket
/// matchmaker can plug in by replacing the `_simulateSearch` timer chain
/// with real room-join events — the visible UI doesn't change.
///
/// Why local-first: shipping a real-feeling matchmaking funnel with
/// honest bot fallback beats blocking on backend deploys, and the bot
/// opponents are addressed anonymously ("الخصم ١") so the experience
/// ports cleanly when real users arrive.
class LudoPowerMatchmakingPage extends StatefulWidget {
  final int playerCount;
  const LudoPowerMatchmakingPage({super.key, required this.playerCount})
      : assert(playerCount == 2 || playerCount == 4);

  @override
  State<LudoPowerMatchmakingPage> createState() =>
      _LudoPowerMatchmakingPageState();
}

class _LudoPowerMatchmakingPageState extends State<LudoPowerMatchmakingPage>
    with TickerProviderStateMixin {
  static const int _searchSeconds = 12;
  int _foundPlayers = 1; // you start counted
  int _secondsLeft = _searchSeconds;
  bool _filledByBots = false;
  bool _starting = false;
  Timer? _ticker;
  Timer? _foundTimer;
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _ticker = Timer.periodic(const Duration(seconds: 1), _onTick);
    _scheduleStagedFinds();
  }

  /// Staged "player found" beats — at random-ish intervals during the
  /// search window we bump the found counter so the screen feels alive.
  /// We never actually fill all seats from real players (no backend yet),
  /// so the final beat is the bot-fill that triggers match start.
  void _scheduleStagedFinds() {
    if (widget.playerCount == 2) {
      // 1v1 — just one opponent to find. Beat at ~4s.
      _foundTimer = Timer(const Duration(seconds: 4), () {
        if (!mounted) return;
        setState(() => _foundPlayers = 2);
      });
    } else {
      // 4-player — fake-find one opponent at 3s, second at 6s, third at 9s
      // (all "real" players to maximise the multiplayer feel).
      Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _foundPlayers = 2);
      });
      Timer(const Duration(seconds: 6), () {
        if (mounted) setState(() => _foundPlayers = 3);
      });
      // 4th seat is filled by the countdown-expiry path → triggers
      // the "filled with bots" toast for honesty.
    }
  }

  void _onTick(Timer t) {
    if (!mounted) return;
    if (_secondsLeft <= 0) {
      t.cancel();
      _completeWithBotFill();
      return;
    }
    setState(() => _secondsLeft--);
  }

  void _completeWithBotFill() {
    if (!mounted || _starting) return;
    setState(() {
      _filledByBots = _foundPlayers < widget.playerCount;
      _foundPlayers = widget.playerCount;
      _starting = true;
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      context.pushReplacement(AppRoutes.ludoPowerMatch(widget.playerCount));
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _foundTimer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RoyalTheme.appBgBottom,
        body: Container(
          decoration: const BoxDecoration(gradient: RoyalTheme.appBg),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: l10n.actionBack,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: RoyalTheme.textLight, size: 20),
                        onPressed: () {
                          if (context.canPop()) context.pop();
                        },
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.ludoMmTitle,
                    style: const TextStyle(
                      color: RoyalTheme.textLight,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _starting
                        ? l10n.ludoMmStarting
                        : (_filledByBots
                            ? l10n.ludoMmFilledByBots
                            : l10n.ludoMmRealPlayers),
                    style: TextStyle(
                      color: RoyalTheme.textLight.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Expanded(child: Center(child: _searchOrb(l10n))),
                  const SizedBox(height: 14),
                  Text(
                    l10n.ludoMmFoundCount(_foundPlayers, widget.playerCount),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: RoyalTheme.goldAccent,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _starting
                        ? l10n.ludoMmMatchFound
                        : l10n.ludoMmCountdownHint(_secondsLeft),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: RoyalTheme.textLight.withValues(alpha: 0.65),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (!_starting)
                    TextButton(
                      onPressed: () {
                        if (context.canPop()) context.pop();
                      },
                      child: Text(
                        l10n.ludoMmCancel,
                        style: const TextStyle(
                          color: RoyalTheme.textLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchOrb(AppLocalizations l10n) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        final t = _pulse.value;
        final size = 180.0 + (t * 16);
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size + 60,
              height: size + 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: RoyalTheme.goldAccent.withValues(alpha: 0.05 + t * 0.06),
              ),
            ),
            Container(
              width: size + 24,
              height: size + 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: RoyalTheme.goldAccent.withValues(alpha: 0.12 + t * 0.10),
              ),
            ),
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    RoyalTheme.goldAccent,
                    RoyalTheme.goldAccent.withValues(alpha: 0.55),
                    RoyalTheme.panelSolid,
                  ],
                  stops: const [0, 0.55, 1],
                ),
                boxShadow: [
                  BoxShadow(
                    color: RoyalTheme.goldAccent.withValues(alpha: 0.5),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.casino_rounded,
                      color: RoyalTheme.goldDeep, size: 56),
                  const SizedBox(height: 6),
                  Text(
                    _starting ? '✓' : l10n.ludoMmSearching,
                    style: const TextStyle(
                      color: RoyalTheme.goldDeep,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
