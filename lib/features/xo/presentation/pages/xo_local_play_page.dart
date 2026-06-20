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
import '../../application/xo_local_engine.dart';
import '../widgets/xo_board_v3.dart';

/// Local XO — Player vs AI on a single device. Pure-Dart engine, zero
/// network. Used both as a "quick play" entry from the lobby AND as a
/// reliable verification surface so the user can confirm the rules
/// engine works without needing a real opponent online.
///
/// The player is ALWAYS X (so they open) and the AI is O.
class XoLocalPlayPage extends ConsumerStatefulWidget {
  const XoLocalPlayPage({super.key});
  @override
  ConsumerState<XoLocalPlayPage> createState() => _XoLocalPlayPageState();
}

class _XoLocalPlayPageState extends ConsumerState<XoLocalPlayPage> {
  final XoLocalEngine _engine = XoLocalEngine();
  bool _aiThinking = false;
  /// One-shot guard so the interstitial trigger fires only once per
  /// completed game (the service itself decides if THIS one shows an
  /// ad — every 3rd match across sessions).
  bool _firedThisRound = false;

  static const String me = 'X';
  static const String ai = 'O';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(interstitialAdServiceProvider).preload().catchError((_) {});
    });
  }

  Future<void> _onCellTap(int row, int col) async {
    if (_aiThinking || _engine.isOver) return;
    GameHaptics.tap();
    final result = _engine.play(row, col, me);
    if (result != XoMoveOutcome.ok) return;
    setState(() {});
    if (_engine.isOver) {
      _onGameEnded();
      return;
    }
    // AI move after a short pause for natural pacing.
    setState(() => _aiThinking = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    final pick = _engine.aiPick(ai);
    if (pick != null) {
      _engine.play(pick.row, pick.col, ai);
    }
    setState(() => _aiThinking = false);
    if (_engine.isOver) {
      _onGameEnded();
    }
  }

  void _onRejectedTap(int row, int col, String reason) {
    if (reason == 'filled') {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.xoCellFilled),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _onGameEnded() {
    if (_firedThisRound) return;
    _firedThisRound = true;
    if (_engine.winner == me) {
      GameHaptics.win();
    } else if (_engine.winner == ai) {
      GameHaptics.uiPop();
    }
    // Interstitial bookkeeping — service decides if THIS round triggers
    // an ad (every 3rd). Delay so the win-line animation lands first.
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      ref.read(interstitialAdServiceProvider).onMatchCompleted();
    });
  }

  void _restart() {
    GameHaptics.uiPop();
    setState(() {
      _engine.reset();
      _firedThisRound = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final l10n = AppLocalizations.of(context);
    final myTurn = _engine.turn == me && !_engine.isOver && !_aiThinking;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            GameHaptics.tap();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.gamesHub);
            }
          },
        ),
        title: Text(
          l10n.xoPracticeTitle,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        ),
        actions: [
          IconButton(
            tooltip: l10n.actionPlayAgain,
            onPressed: _engine.movesMade == 0 ? null : _restart,
            icon: const Icon(Icons.replay_rounded),
          ),
          const Gap(4),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 20),
          child: Column(
            children: [
              _TurnHeader(
                myTurn: myTurn,
                aiThinking: _aiThinking,
                winner: _engine.winner,
                colors: colors,
                l10n: l10n,
              ),
              const Gap(18),
              XoBoardV3(
                cells: _engine.cells,
                winningLine: _engine.winningLine,
                interactive: myTurn,
                onTap: _onCellTap,
                onRejectedTap: _onRejectedTap,
                xColor: colors.moment,
                oColor: colors.face,
                surfaceColor: colors.surface,
                borderColor: colors.border,
                winColor: colors.crystal,
              ),
              const Spacer(),
              if (_engine.isOver) ...[
                _OutcomeBanner(
                  winner: _engine.winner!,
                  mySymbol: me,
                  colors: colors,
                  l10n: l10n,
                ),
                const Gap(14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _restart,
                        icon: const Icon(Icons.replay_rounded, size: 18),
                        label: Text(l10n.actionPlayAgain),
                      ),
                    ),
                    const Gap(10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          GameHaptics.tap();
                          context.go(AppRoutes.gamesHub);
                        },
                        icon: const Icon(Icons.home_rounded, size: 18),
                        label: Text(l10n.labelGamesHome),
                      ),
                    ),
                  ],
                ),
              ] else
                _MarksLegend(
                  myTurn: myTurn,
                  aiThinking: _aiThinking,
                  colors: colors,
                  l10n: l10n,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Turn header
// ─────────────────────────────────────────────────────────────────────

class _TurnHeader extends StatelessWidget {
  const _TurnHeader({
    required this.myTurn,
    required this.aiThinking,
    required this.winner,
    required this.colors,
    required this.l10n,
  });
  final bool myTurn;
  final bool aiThinking;
  final String? winner;
  final SarhnyColors colors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    String text;
    Color accent;
    IconData icon;
    if (winner != null) {
      text = l10n.gameOverTitle;
      accent = colors.crystal;
      icon = Icons.emoji_events_rounded;
    } else if (myTurn) {
      text = l10n.labelTurnYours;
      accent = colors.moment;
      icon = Icons.touch_app_rounded;
    } else if (aiThinking) {
      text = l10n.labelTurnAi;
      accent = colors.face;
      icon = Icons.psychology_rounded;
    } else {
      text = l10n.labelWaiting;
      accent = colors.textSecondary;
      icon = Icons.adjust_rounded;
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: accent.withValues(alpha: 0.10),
        border: Border.all(color: accent.withValues(alpha: 0.40), width: 0.8),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 18),
          const Gap(8),
          Text(
            text,
            style: TextStyle(
              color: accent,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          if (aiThinking)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(accent),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Bottom legend / outcome
// ─────────────────────────────────────────────────────────────────────

class _MarksLegend extends StatelessWidget {
  const _MarksLegend({
    required this.myTurn,
    required this.aiThinking,
    required this.colors,
    required this.l10n,
  });
  final bool myTurn;
  final bool aiThinking;
  final SarhnyColors colors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Mark(
            label: l10n.labelYou,
            mark: 'X',
            color: colors.moment,
            active: myTurn,
          ),
        ),
        const Gap(8),
        Text(
          l10n.labelVs,
          style: TextStyle(
            color: colors.textSecondary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Gap(8),
        Expanded(
          child: _Mark(
            label: l10n.labelAi,
            mark: 'O',
            color: colors.face,
            active: aiThinking,
          ),
        ),
      ],
    );
  }
}

class _Mark extends StatelessWidget {
  const _Mark({
    required this.label,
    required this.mark,
    required this.color,
    required this.active,
  });
  final String label;
  final String mark;
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: active ? 0.22 : 0.10),
        border: Border.all(
          color: color.withValues(alpha: active ? 0.80 : 0.30),
          width: active ? 1.4 : 0.6,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              mark,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Gap(10),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutcomeBanner extends StatelessWidget {
  const _OutcomeBanner({
    required this.winner,
    required this.mySymbol,
    required this.colors,
    required this.l10n,
  });
  final String winner;
  final String mySymbol;
  final SarhnyColors colors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isDraw = winner == 'draw';
    final iWon = !isDraw && winner == mySymbol;
    final text = isDraw
        ? l10n.outcomeDraw
        : (iWon ? l10n.outcomeYouWon : l10n.outcomeAiWins);
    final sub = isDraw
        ? l10n.xoLocalDrawSub
        : (iWon
            ? l10n.xoLocalWinSub
            : l10n.xoLocalLoseSub);
    final accent = isDraw
        ? colors.crystal
        : (iWon ? colors.moment : colors.face);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.24),
            accent.withValues(alpha: 0.10),
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Text(
            isDraw ? '🤝' : (iWon ? '🏆' : '🤖'),
            style: const TextStyle(fontSize: 30),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: accent,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(2),
                Text(
                  sub,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
