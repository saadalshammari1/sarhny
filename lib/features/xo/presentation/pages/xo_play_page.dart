import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/haptics/game_haptics.dart';
import '../../../../core/ads/interstitial_service.dart';
import '../../../games/carrom/application/carrom_controllers.dart';
import '../../../games/carrom/data/admob_service.dart';
import '../../application/xo_controller.dart';
import '../../data/xo_repository.dart';
import '../../domain/xo_state.dart';
import '../widgets/xo_board_v3.dart';

/// XO match page — owns the board + the post-game question/answer flow.
///
/// Phase machine (mirrors the snapshot's `phase` field):
///   loading                  → still fetching first snapshot
///   waiting (waiting_for_opponent) → solo, show invite code or queue spinner
///   playing                  → board interactive on my turn
///   writing_question (winner) → text composer + countdown to fallback
///   waiting_winner_question (loser) → spinner with synced countdown
///   answer (loser)           → answer composer + skip + abstain-via-ad
///   answer-wait (winner)     → reveal banner + opponent typing message
///   answered                 → full reveal + rematch + back-to-lobby
class XoPlayPage extends ConsumerStatefulWidget {
  const XoPlayPage({super.key, required this.gameId});
  final String gameId;

  @override
  ConsumerState<XoPlayPage> createState() => _XoPlayPageState();
}

class _XoPlayPageState extends ConsumerState<XoPlayPage> {
  AdMobRewardService? _adService;
  /// Once the match enters a terminal state we trigger the mandatory
  /// interstitial bookkeeping exactly once.
  bool _interstitialFiredForThisMatch = false;

  @override
  void initState() {
    super.initState();
    // Pre-load a rewarded ad (for the abstain button) AND the shared
    // interstitial (for the every-3-matches rule) so both surfaces are
    // ready when the user taps.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _adService = AdMobRewardService(ref.read(carromApiProvider));
      _adService?.loadRewardedAd().catchError((_) {});
      ref.read(interstitialAdServiceProvider).preload().catchError((_) {});
    });
  }

  @override
  void dispose() {
    _adService?.dispose();
    super.dispose();
  }

  /// Drives the every-3-matches interstitial. The service owns the
  /// counter + the show-or-skip logic — we just notify it once per
  /// completed match.
  void _maybeFireInterstitial() {
    if (_interstitialFiredForThisMatch) return;
    _interstitialFiredForThisMatch = true;
    // Brief delay so the result banner has a beat to land before the
    // ad takes over the screen.
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      ref.read(interstitialAdServiceProvider).onMatchCompleted();
    });
  }

  Future<bool> _confirmLeave(BuildContext context, SarhnyColors colors) async {
    final l10n = AppLocalizations.of(context);
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0x33D22F2F),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.flag_outlined,
                    color: Color(0xFFD22F2F), size: 28),
              ),
              const Gap(12),
              Text(
                l10n.leaveTitle,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const Gap(4),
              Text(
                l10n.leaveBody,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(l10n.continueMatch),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFD22F2F),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(l10n.actionLeave),
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

  Future<void> _handleAbstain(BuildContext context, SarhnyColors colors) async {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(xoMatchControllerProvider(widget.gameId).notifier);
    final svc = _adService ??= AdMobRewardService(ref.read(carromApiProvider));
    Fluttertoast.showToast(msg: l10n.adLoading);
    try {
      final grant = await svc.showRewardedAd();
      if (grant == null) {
        if (!context.mounted) return;
        Fluttertoast.showToast(msg: l10n.adIncomplete);
        return;
      }
      final token = grant.adToken;
      if (token == null || token.isEmpty) {
        if (!context.mounted) return;
        Fluttertoast.showToast(msg: l10n.errorGeneric);
        return;
      }
      await controller.abstain(token);
      if (!context.mounted) return;
      Fluttertoast.showToast(
        msg: l10n.adRewardEarned,
      );
    } on AdRewardException catch (e) {
      Fluttertoast.showToast(msg: _adErrorMessage(e.code, l10n));
    } catch (_) {
      Fluttertoast.showToast(msg: l10n.errorAdLaunch);
    }
  }

  String _adErrorMessage(String code, AppLocalizations l10n) {
    switch (code) {
      case 'ads_unsupported_platform':
        return l10n.errorAdLaunch;
      case 'ad_unavailable':
        return l10n.adUnavailable;
      case 'daily_cap_reached':
        return l10n.adDailyCap;
      case 'already_granted':
        return l10n.adRewardEarned;
      case 'invalid_signature':
        return l10n.errorGeneric;
      default:
        return l10n.errorGeneric;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final mState = ref.watch(xoMatchControllerProvider(widget.gameId));

    // Toast any new errors + drive the every-3-matches interstitial.
    ref.listen(xoMatchControllerProvider(widget.gameId),
        (prev, next) {
      if (next.error != null && prev?.error != next.error) {
        Fluttertoast.showToast(
            msg: xoErrorMessage(next.error!, AppLocalizations.of(context)));
        ref.read(xoMatchControllerProvider(widget.gameId).notifier).clearError();
      }
      final isDone = next.snapshot?.status == 'answered' ||
          next.snapshot?.status == 'abandoned';
      final wasDone = prev?.snapshot?.status == 'answered' ||
          prev?.snapshot?.status == 'abandoned';
      if (isDone && !wasDone) {
        _maybeFireInterstitial();
      }
    });

    return PopScope(
      canPop: mState.snapshot?.status == 'answered' ||
          mState.snapshot?.status == 'abandoned',
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (mState.snapshot?.status == 'answered') {
          if (!context.mounted) return;
          context.go(AppRoutes.gamesHub);
          return;
        }
        final ok = await _confirmLeave(context, colors);
        if (!ok) return;
        await ref
            .read(xoMatchControllerProvider(widget.gameId).notifier)
            .leave();
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
            icon: const Icon(Icons.close_rounded),
            onPressed: () async {
              GameHaptics.tap();
              if (mState.snapshot?.status == 'answered') {
                context.go(AppRoutes.gamesHub);
                return;
              }
              final ok = await _confirmLeave(context, colors);
              if (!ok) return;
              await ref
                  .read(xoMatchControllerProvider(widget.gameId).notifier)
                  .leave();
              if (!context.mounted) return;
              context.go(AppRoutes.gamesHub);
            },
          ),
          title: Text(
            AppLocalizations.of(context).xoPageTitle,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: _buildBody(context, colors, mState),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SarhnyColors colors, XoMatchState mState) {
    if (mState.loading && mState.snapshot == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final snap = mState.snapshot;
    if (snap == null) {
      return Center(child: Text(AppLocalizations.of(context).errorMatchLoad));
    }

    // Waiting for opponent.
    if (snap.waitingForOpponent || snap.noOpponentYet) {
      return _WaitingForOpponent(snapshot: snap, colors: colors);
    }

    if (snap.status == 'playing') {
      return _PlayingView(snapshot: snap, colors: colors, busy: mState.busy);
    }

    // Post-game flow.
    return _PostGameView(
      snapshot: snap,
      colors: colors,
      busy: mState.busy,
      onAbstain: () => _handleAbstain(context, colors),
    );
  }
}

// Tiny convenience extension — XoSnapshot already exposes
// waitingForOpponent but we add a defensive secondary check for the case
// where the server didn't set the flag.
extension on XoSnapshot {
  bool get noOpponentYet => status == 'waiting';
}

// ─────────────────────────────────────────────────────────────────────
// Waiting for opponent
// ─────────────────────────────────────────────────────────────────────

class _WaitingForOpponent extends StatefulWidget {
  const _WaitingForOpponent({required this.snapshot, required this.colors});
  final XoSnapshot snapshot;
  final SarhnyColors colors;

  @override
  State<_WaitingForOpponent> createState() => _WaitingForOpponentState();
}

class _WaitingForOpponentState extends State<_WaitingForOpponent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final l10n = AppLocalizations.of(context);
    final isInvite = widget.snapshot.isInvite && widget.snapshot.inviteCode != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        children: [
          const Spacer(),
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) => Stack(
              alignment: Alignment.center,
              children: [
                for (var i = 0; i < 3; i++)
                  Opacity(
                    opacity: 1 - ((_pulse.value + i / 3) % 1),
                    child: Container(
                      width: 120 + ((_pulse.value + i / 3) % 1) * 140,
                      height: 120 + ((_pulse.value + i / 3) % 1) * 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.moment.withValues(alpha: 0.55),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.moment.withValues(alpha: 0.15),
                    border: Border.all(color: colors.moment, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isInvite ? '🤝' : '🔎',
                    style: const TextStyle(fontSize: 44),
                  ),
                ),
              ],
            ),
          ),
          const Gap(28),
          Text(
            isInvite ? l10n.labelWaitingOpponent : l10n.labelSearching,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          if (isInvite) ...[
            const Gap(14),
            _InviteCodeChip(
              code: widget.snapshot.inviteCode!,
              colors: colors,
            ),
          ],
          const Spacer(),
        ],
      ),
    );
  }
}

class _InviteCodeChip extends StatelessWidget {
  const _InviteCodeChip({required this.code, required this.colors});
  final String code;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.moment.withValues(alpha: 0.12),
        border: Border.all(color: colors.moment.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            code,
            style: TextStyle(
              color: colors.moment,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 6,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Playing view — board + turn header + turn indicator
// ─────────────────────────────────────────────────────────────────────

class _PlayingView extends ConsumerWidget {
  const _PlayingView({
    required this.snapshot,
    required this.colors,
    required this.busy,
  });
  final XoSnapshot snapshot;
  final SarhnyColors colors;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        const Gap(8),
        _TurnHeader(snapshot: snapshot, colors: colors),
        const Gap(16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: XoBoardV3(
            cells: snapshot.cells,
            winningLine: snapshot.winningLine,
            interactive:
                snapshot.isPlaying && snapshot.myTurn && !busy,
            xColor: snapshot.myMark == 'X' ? colors.moment : colors.face,
            oColor: snapshot.myMark == 'O' ? colors.moment : colors.face,
            surfaceColor: colors.surface,
            borderColor: colors.border,
            winColor: colors.crystal,
            onTap: (r, c) {
              GameHaptics.tap();
              ref
                  .read(xoMatchControllerProvider(snapshot.gameId).notifier)
                  .move(r, c);
            },
            onRejectedTap: (r, c, reason) {
              // The cell rejected the tap locally. Most common cause:
              // "opponent's move arrived between polls and the cell
              // we tapped is now filled". Surface the exact reason and
              // force a snapshot refresh so the next tap sees current
              // state.
              final msg = switch (reason) {
                'filled' => l10n.xoCellFilled,
                'inert' => l10n.xoNotYourTurn,
                _ => '',
              };
              if (msg.isEmpty) return;
              Fluttertoast.showToast(msg: msg);
              ref
                  .read(xoMatchControllerProvider(snapshot.gameId).notifier)
                  .refresh();
            },
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          child: Row(
            children: [
              Expanded(
                child: _MarkChip(
                  label: l10n.labelYou,
                  mark: snapshot.myMark,
                  accent: colors.moment,
                  active: snapshot.myTurn,
                ),
              ),
              const Gap(8),
              Text(
                l10n.labelVs,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Gap(8),
              Expanded(
                child: _MarkChip(
                  label: l10n.labelOpponent,
                  mark: snapshot.oppMark,
                  accent: colors.face,
                  active: !snapshot.myTurn,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TurnHeader extends StatelessWidget {
  const _TurnHeader({required this.snapshot, required this.colors});
  final XoSnapshot snapshot;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = snapshot.myTurn ? l10n.labelTurnYours : l10n.labelTurnTheirs;
    final accent = snapshot.myTurn ? colors.moment : colors.face;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: accent.withValues(alpha: 0.10),
        border: Border.all(color: accent.withValues(alpha: 0.45), width: 0.8),
      ),
      child: Row(
        children: [
          Icon(Icons.adjust_rounded, color: accent, size: 16),
          const Gap(8),
          Text(
            text,
            style: TextStyle(
              color: accent,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Text(
            l10n.xoMovesProgress(snapshot.movesMade, 9),
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkChip extends StatelessWidget {
  const _MarkChip({
    required this.label,
    required this.mark,
    required this.accent,
    required this.active,
  });
  final String label;
  final String mark;
  final Color accent;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: active ? 0.20 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent.withValues(alpha: active ? 0.7 : 0.30),
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
              color: accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              mark,
              style: TextStyle(
                color: accent,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Gap(10),
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Post-game view — winner question / loser answer / answered reveal
// ─────────────────────────────────────────────────────────────────────

class _PostGameView extends ConsumerWidget {
  const _PostGameView({
    required this.snapshot,
    required this.colors,
    required this.busy,
    required this.onAbstain,
  });
  final XoSnapshot snapshot;
  final SarhnyColors colors;
  final bool busy;
  final Future<void> Function() onAbstain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        children: [
          _ResultBanner(snapshot: snapshot, colors: colors),
          const Gap(16),
          // Mini final board (read-only) — shows the winning line glow.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: XoBoardV3(
              cells: snapshot.cells,
              winningLine: snapshot.winningLine,
              interactive: false,
              xColor: snapshot.myMark == 'X' ? colors.moment : colors.face,
              oColor: snapshot.myMark == 'O' ? colors.moment : colors.face,
              surfaceColor: colors.surface,
              borderColor: colors.border,
              winColor: colors.crystal,
              highlightHints: false,
              onTap: (_, __) {},
              onRejectedTap: (_, __, ___) {},
            ),
          ),
          const Gap(20),
          _PhaseBlock(
            snapshot: snapshot,
            colors: colors,
            busy: busy,
            onAbstain: onAbstain,
          ),
          const Gap(16),
          if (snapshot.status == 'answered')
            _RematchAndExit(snapshot: snapshot, colors: colors),
        ],
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.snapshot, required this.colors});
  final XoSnapshot snapshot;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (snapshot.isDraw) {
      return _Banner(
        text: l10n.outcomeDraw,
        sub: l10n.roundDraw,
        accent: colors.crystal,
        emoji: '🤝',
      );
    }
    if (snapshot.isWinner == true) {
      return _Banner(
        text: l10n.outcomeYouWon,
        sub: l10n.questionAsk,
        accent: colors.moment,
        emoji: '🏆',
      );
    }
    return _Banner(
      text: l10n.outcomeYouLost,
      sub: l10n.questionAbstainNote,
      accent: colors.face,
      emoji: '🎯',
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.text,
    required this.sub,
    required this.accent,
    required this.emoji,
  });
  final String text;
  final String sub;
  final Color accent;
  final String emoji;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.22),
            accent.withValues(alpha: 0.10),
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: accent,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(2),
                Text(
                  sub,
                  style: const TextStyle(
                    color: Colors.white70,
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

class _PhaseBlock extends ConsumerStatefulWidget {
  const _PhaseBlock({
    required this.snapshot,
    required this.colors,
    required this.busy,
    required this.onAbstain,
  });
  final XoSnapshot snapshot;
  final SarhnyColors colors;
  final bool busy;
  final Future<void> Function() onAbstain;
  @override
  ConsumerState<_PhaseBlock> createState() => _PhaseBlockState();
}

class _PhaseBlockState extends ConsumerState<_PhaseBlock> {
  final _winnerQuestionCtrl = TextEditingController();
  final _answerCtrl = TextEditingController();

  @override
  void dispose() {
    _winnerQuestionCtrl.dispose();
    _answerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.snapshot;
    final colors = widget.colors;

    if (s.isDraw) {
      return const SizedBox.shrink();
    }

    // Winner composing the question.
    if (s.phase == 'writing_question') {
      return _WinnerComposer(
        controller: _winnerQuestionCtrl,
        deadline: s.finalQuestionDeadline,
        colors: colors,
        busy: widget.busy,
        onSubmit: (text) => ref
            .read(xoMatchControllerProvider(s.gameId).notifier)
            .submitWinnerQuestion(text),
      );
    }

    // Loser waiting for the winner to compose.
    if (s.phase == 'waiting_winner_question') {
      return _LoserWaiting(
        deadline: s.finalQuestionDeadline,
        colors: colors,
      );
    }

    // Loser answering (with skip + abstain via ad).
    if (s.phase == 'answer' && s.isWinner == false) {
      return _LoserAnswerer(
        question: s.finalQuestionText ?? '',
        controller: _answerCtrl,
        deadline: s.finalAnswerDeadline,
        skipUsed: s.finalSkipUsed,
        colors: colors,
        busy: widget.busy,
        onAnswer: (text) => ref
            .read(xoMatchControllerProvider(s.gameId).notifier)
            .submitAnswer(text),
        onSkip: () =>
            ref.read(xoMatchControllerProvider(s.gameId).notifier).skipQuestion(),
        onAbstain: widget.onAbstain,
      );
    }

    // Winner waiting for the loser to answer.
    if (s.phase == 'answer' && s.isWinner == true) {
      return _WinnerAwaitingAnswer(
        question: s.finalQuestionText ?? '',
        deadline: s.finalAnswerDeadline,
        colors: colors,
      );
    }

    // Answered — show the reveal.
    if (s.phase == 'answered') {
      return _Reveal(
        question: s.finalQuestionText ?? '',
        answer: s.finalAnswer ?? '',
        colors: colors,
      );
    }

    return const SizedBox.shrink();
  }
}

class _WinnerComposer extends StatelessWidget {
  const _WinnerComposer({
    required this.controller,
    required this.deadline,
    required this.colors,
    required this.busy,
    required this.onSubmit,
  });
  final TextEditingController controller;
  final double? deadline;
  final SarhnyColors colors;
  final bool busy;
  final Future<void> Function(String? text) onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colors.surface,
        border: Border.all(color: colors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.edit_rounded, color: colors.moment, size: 18),
              const Gap(8),
              Text(
                l10n.questionAsk,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              _Countdown(deadline: deadline, colors: colors),
            ],
          ),
          const Gap(10),
          TextField(
            controller: controller,
            maxLength: 200,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: l10n.questionWriteHint,
              filled: true,
              fillColor: colors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.border.withValues(alpha: 0.6)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.border.withValues(alpha: 0.6)),
              ),
            ),
          ),
          const Gap(10),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: busy
                  ? null
                  : () => onSubmit(controller.text.trim().isEmpty
                      ? null
                      : controller.text.trim()),
              icon: const Icon(Icons.send_rounded, size: 16),
              label: Text(l10n.actionSend),
            ),
          ),
          const Gap(6),
          TextButton(
            onPressed: busy ? null : () => onSubmit(null),
            child: Text(l10n.questionUsePresetCta),
          ),
        ],
      ),
    );
  }
}

class _LoserWaiting extends StatelessWidget {
  const _LoserWaiting({required this.deadline, required this.colors});
  final double? deadline;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colors.surface,
        border: Border.all(color: colors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const Gap(10),
              Text(
                AppLocalizations.of(context).questionWaitingQ,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Gap(10),
          _Countdown(deadline: deadline, colors: colors),
        ],
      ),
    );
  }
}

class _LoserAnswerer extends StatelessWidget {
  const _LoserAnswerer({
    required this.question,
    required this.controller,
    required this.deadline,
    required this.skipUsed,
    required this.colors,
    required this.busy,
    required this.onAnswer,
    required this.onSkip,
    required this.onAbstain,
  });
  final String question;
  final TextEditingController controller;
  final double? deadline;
  final bool skipUsed;
  final SarhnyColors colors;
  final bool busy;
  final Future<void> Function(String text) onAnswer;
  final Future<void> Function() onSkip;
  final Future<void> Function() onAbstain;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colors.surface,
        border: Border.all(color: colors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question card.
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: colors.moment.withValues(alpha: 0.10),
              border: Border.all(color: colors.moment.withValues(alpha: 0.40)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.help_outline_rounded,
                    color: colors.moment, size: 18),
                const Gap(8),
                Expanded(
                  child: Text(
                    question,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          Row(
            children: [
              Text(
                l10n.questionAnswer,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              _Countdown(deadline: deadline, colors: colors),
            ],
          ),
          const Gap(8),
          TextField(
            controller: controller,
            maxLength: 500,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: l10n.answerWriteHint,
              filled: true,
              fillColor: colors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.border.withValues(alpha: 0.6)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.border.withValues(alpha: 0.6)),
              ),
            ),
          ),
          const Gap(8),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: busy
                  ? null
                  : () {
                      final t = controller.text.trim();
                      if (t.isEmpty) {
                        Fluttertoast.showToast(msg: l10n.answerWriteHint);
                        return;
                      }
                      onAnswer(t);
                    },
              icon: const Icon(Icons.send_rounded, size: 16),
              label: Text(l10n.actionSend),
            ),
          ),
          const Gap(10),
          // Skip + Abstain row (the two "ways out" for the loser).
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: busy || skipUsed ? null : onSkip,
                  icon: const Icon(Icons.shuffle_rounded, size: 14),
                  label: Text(skipUsed
                      ? l10n.questionSkipUsed
                      : l10n.questionSkipNew),
                ),
              ),
              const Gap(10),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: busy ? null : onAbstain,
                  icon: const Icon(Icons.play_circle_outline_rounded, size: 16),
                  label: Text(l10n.questionAbstainAd),
                ),
              ),
            ],
          ),
          const Gap(4),
          Text(
            l10n.questionAbstainNote,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _WinnerAwaitingAnswer extends StatelessWidget {
  const _WinnerAwaitingAnswer({
    required this.question,
    required this.deadline,
    required this.colors,
  });
  final String question;
  final double? deadline;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colors.surface,
        border: Border.all(color: colors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const Gap(10),
              Expanded(
                child: Text(
                  l10n.questionWaitingA,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              _Countdown(deadline: deadline, colors: colors),
            ],
          ),
          const Gap(12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: colors.moment.withValues(alpha: 0.08),
            ),
            child: Text(
              l10n.questionYoursPrefix(question),
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Reveal extends StatelessWidget {
  const _Reveal({
    required this.question,
    required this.answer,
    required this.colors,
  });
  final String question;
  final String answer;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: colors.moment.withValues(alpha: 0.10),
            border: Border.all(color: colors.moment.withValues(alpha: 0.40)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.help_outline_rounded, color: colors.moment, size: 18),
              const Gap(8),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: colors.face.withValues(alpha: 0.10),
            border: Border.all(color: colors.face.withValues(alpha: 0.40)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.chat_bubble_outline_rounded,
                  color: colors.face, size: 18),
              const Gap(8),
              Expanded(
                child: Text(
                  answer,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Rematch + exit (visible at end of match)
// ─────────────────────────────────────────────────────────────────────

class _RematchAndExit extends ConsumerStatefulWidget {
  const _RematchAndExit({required this.snapshot, required this.colors});
  final XoSnapshot snapshot;
  final SarhnyColors colors;
  @override
  ConsumerState<_RematchAndExit> createState() => _RematchAndExitState();
}

class _RematchAndExitState extends ConsumerState<_RematchAndExit> {
  String _phase = 'none';
  bool _busy = false;
  Timer? _poller;

  @override
  void initState() {
    super.initState();
    _poller = Timer.periodic(const Duration(seconds: 2), (_) => _checkStatus());
    _checkStatus();
  }

  @override
  void dispose() {
    _poller?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    if (!mounted) return;
    try {
      final r = await ref
          .read(xoRepositoryProvider)
          .rematchStatus(widget.snapshot.gameId);
      if (!mounted) return;
      setState(() => _phase = r.phase);
      if (r.phase == 'ready' && r.newGameId != null) {
        _poller?.cancel();
        GameHaptics.uiPop();
        if (mounted) context.go('/xo/play/${r.newGameId}');
      }
    } catch (_) {}
  }

  Future<void> _request(bool accept) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    GameHaptics.uiPop();
    try {
      final r = await ref
          .read(xoRepositoryProvider)
          .rematch(widget.snapshot.gameId, accept: accept);
      if (!mounted) return;
      setState(() => _phase = r.phase);
      if (r.phase == 'ready' && r.newGameId != null) {
        _poller?.cancel();
        if (mounted) context.go('/xo/play/${r.newGameId}');
      }
    } on XoApiException catch (e) {
      Fluttertoast.showToast(msg: xoErrorMessage(e.message, l10n));
    } catch (_) {
      Fluttertoast.showToast(msg: l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final l10n = AppLocalizations.of(context);
    String status;
    switch (_phase) {
      case 'waiting':
        status = l10n.rematchWaiting;
        break;
      case 'declined':
        status = l10n.rematchDeclined;
        break;
      case 'timeout':
        status = l10n.rematchTimeout;
        break;
      default:
        status = l10n.rematchTitle;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: colors.surface,
            border: Border.all(color: colors.border.withValues(alpha: 0.6)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.replay_rounded, color: colors.moment, size: 20),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      status,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (_phase == 'waiting')
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const Gap(12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _busy || _phase == 'declined' || _phase == 'timeout'
                          ? null
                          : () => _request(true),
                      icon: const Icon(Icons.replay_rounded, size: 16),
                      label: Text(l10n.rematchAccept),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : () => _request(false),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: Text(l10n.rematchDecline),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Gap(10),
        SizedBox(
          height: 52,
          child: FilledButton.tonalIcon(
            onPressed: () {
              GameHaptics.tap();
              context.go(AppRoutes.gamesHub);
            },
            icon: const Icon(Icons.home_rounded, size: 18),
            label: Text(l10n.actionLeaveLobby),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Countdown widget (mm:ss) — shared by writer/answerer
// ─────────────────────────────────────────────────────────────────────

class _Countdown extends StatefulWidget {
  const _Countdown({required this.deadline, required this.colors});
  final double? deadline;
  final SarhnyColors colors;

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.deadline;
    if (d == null) return const SizedBox.shrink();
    final remaining =
        (d - (DateTime.now().millisecondsSinceEpoch / 1000)).round();
    final clamped = remaining.clamp(0, 9999);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.colors.crystal.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        AppLocalizations.of(context).secondsShort(clamped),
        style: TextStyle(
          color: widget.colors.crystal,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
