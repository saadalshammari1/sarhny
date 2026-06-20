import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/ads/interstitial_service.dart';
import '../../../games/carrom/application/carrom_controllers.dart';
import '../../../games/carrom/data/admob_service.dart';
import '../../data/game_repository.dart';
import '../providers/game_providers.dart';

/// The live game screen. Polls /state every 2 seconds; renders the right
/// sub-screen for the current game phase (waiting / playing / final /
/// answered / abandoned).
class GamePlayPage extends ConsumerStatefulWidget {
  const GamePlayPage({super.key, required this.gameId});
  final String gameId;
  @override
  ConsumerState<GamePlayPage> createState() => _GamePlayPageState();
}

class _GamePlayPageState extends ConsumerState<GamePlayPage> {
  Timer? _poll;
  GameSnapshot? _snap;
  bool _busy = false;
  AdMobRewardService? _adService;
  /// Once the match enters a terminal status we fire the every-3-matches
  /// interstitial bookkeeping exactly once.
  bool _interstitialFiredForThisMatch = false;

  @override
  void initState() {
    super.initState();
    _refresh();
    _poll = Timer.periodic(const Duration(seconds: 2), (_) => _refresh());
    // Pre-load both ad types so the "امتنع" rewarded ad AND the every-
    // 3-matches interstitial fire instantly when the conditions hit.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _adService = AdMobRewardService(ref.read(carromApiProvider));
      _adService?.loadRewardedAd().catchError((_) {});
      ref.read(interstitialAdServiceProvider).preload().catchError((_) {});
    });
  }

  void _maybeFireInterstitial(GameSnapshot? newSnap) {
    if (_interstitialFiredForThisMatch) return;
    final terminal =
        newSnap?.status == 'answered' || newSnap?.status == 'abandoned';
    if (!terminal) return;
    _interstitialFiredForThisMatch = true;
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      ref.read(interstitialAdServiceProvider).onMatchCompleted();
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    _adService?.dispose();
    super.dispose();
  }

  Future<void> _handleAbstain() async {
    final svc = _adService ??= AdMobRewardService(ref.read(carromApiProvider));
    final gameId = widget.gameId;
    Fluttertoast.showToast(msg: 'جاري تحميل الإعلان...');
    try {
      final grant = await svc.showRewardedAd();
      if (!mounted) return;
      if (grant == null) {
        Fluttertoast.showToast(msg: 'الإعلان لم يكتمل');
        return;
      }
      final token = grant.adToken;
      if (token == null || token.isEmpty) {
        Fluttertoast.showToast(msg: 'لم نتحقق من الإعلان');
        return;
      }
      await _wrap(
        () => ref.read(gameRepositoryProvider).abstain(gameId, token),
      );
      if (!mounted) return;
      Fluttertoast.showToast(msg: 'حصلت على نقطة. تم الامتناع.');
    } on AdRewardException catch (e) {
      Fluttertoast.showToast(msg: _adErr(e.code));
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر تشغيل الإعلان');
    }
  }

  String _adErr(String code) {
    switch (code) {
      case 'ads_unsupported_platform':
        return 'الإعلانات غير متاحة هنا';
      case 'ad_unavailable':
        return 'لا يوجد إعلان متاح حالياً';
      case 'daily_cap_reached':
        return 'وصلت الحد اليومي للإعلانات';
      case 'already_granted':
        return 'تم احتساب الإعلان مسبقاً';
      default:
        return 'تعذّر الحصول على المكافأة';
    }
  }

  Future<void> _refresh() async {
    try {
      final next = await ref.read(gameRepositoryProvider).state(widget.gameId);
      if (!mounted) return;
      setState(() => _snap = next);
      _maybeFireInterstitial(next);
    } catch (_) {
      // ignore — next tick will try again
    }
  }

  Future<void> _wrap(Future<GameSnapshot> Function() op) async {
    setState(() => _busy = true);
    try {
      final next = await op();
      if (!mounted) return;
      setState(() => _snap = next);
    } on GameApiException catch (e) {
      Fluttertoast.showToast(msg: e.message);
      if (e.cancelled && mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 800));
        if (mounted) context.go('/game');
      }
    } catch (_) {
      Fluttertoast.showToast(msg: 'حدث خطأ');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirmLeave() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('مغادرة اللعبة؟'),
        content: const Text('المغادرة وسط اللعبة تُحتسب خسارة لك.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('بقاء')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('مغادرة'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _handleLeave() async {
    final snap = _snap;
    if (snap == null ||
        snap.status == 'answered' ||
        snap.status == 'abandoned') {
      if (mounted) context.go('/game');
      return;
    }
    if (await _confirmLeave()) {
      await ref.read(gameRepositoryProvider).leave(widget.gameId);
      if (mounted) context.go('/game');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final snap = _snap;
    // Allow iOS swipe-back / Android back gesture, but intercept it
    // to confirm leave (and call /leave so the server marks the loss).
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleLeave();
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: const Text('تحدّى 🎮'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'رجوع',
            onPressed: _handleLeave,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'الخروج',
              onPressed: _handleLeave,
            ),
          ],
        ),
        body: snap == null
            ? const Center(child: CircularProgressIndicator())
            : _buildPhase(snap, colors),
      ),
    );
  }

  Widget _buildPhase(GameSnapshot s, SarhnyColors colors) {
    if (s.status == 'abandoned') {
      return _EndedView(
        title: 'انتهت اللعبة',
        subtitle: 'الجولة انتهت بشكل غير اعتيادي.',
        colors: colors,
      );
    }
    if (s.status == 'answered') {
      return _AnsweredView(snap: s, colors: colors);
    }
    // ── Post-game phases — driven by the server-supplied `phase` field
    // (with a `status` fallback for older builds).
    final phase = s.phase ?? (s.status == 'answering' ? 'answer' : s.status);
    if (s.status == 'final' || s.status == 'answering') {
      final iAmWinner = s.isWinner == true;

      if (iAmWinner && phase == 'writing_question') {
        return _WinnerFinalView(
          snap: s,
          busy: _busy,
          colors: colors,
          onSubmit: (text) => _wrap(
            () => ref.read(gameRepositoryProvider).winnerQuestion(s.gameId, text),
          ),
        );
      }
      if (!iAmWinner && phase == 'waiting_winner_question') {
        // CRITICAL — the loser must NOT see the question yet. We render a
        // dedicated waiting screen with a synced countdown matching the
        // winner's compose timer.
        return _LoserWaitingForQuestionView(snap: s, colors: colors);
      }
      // phase == 'answer' (or older server with status=='final' and a
      // visible question text — backwards compat).
      if (!iAmWinner) {
        return _LoserFinalView(
          snap: s,
          busy: _busy,
          colors: colors,
          onAnswer: (text) => _wrap(
            () => ref.read(gameRepositoryProvider).answer(s.gameId, text),
          ),
          onSkip: s.finalSkipUsed
              ? null
              : () => _wrap(
                    () => ref.read(gameRepositoryProvider).skip(s.gameId),
                  ),
          onAbstain: _handleAbstain,
        );
      }
      // Winner waiting on the loser's answer — show a calm waiting state
      // instead of letting them stare at the question composer they already
      // submitted.
      return _WinnerWaitingForAnswerView(snap: s, colors: colors);
    }
    if (s.status == 'waiting') {
      return _WaitingView(snap: s, colors: colors);
    }
    // playing
    return _PlayingView(
      snap: s,
      busy: _busy,
      colors: colors,
      onLock: (choice, guess) => _wrap(
        () => ref.read(gameRepositoryProvider).move(s.gameId, choice, guess),
      ),
    );
  }
}

// ── Waiting room (random matchmaking or invite created) ────────────────────

class _WaitingView extends StatelessWidget {
  const _WaitingView({required this.snap, required this.colors});
  final GameSnapshot snap;
  final SarhnyColors colors;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 18),
            Text(
              snap.isInvite ? 'بانتظار صديقك...' : 'نبحث عن خصم مناسب...',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'لا تكشف هويتك. لا تكشف هوية خصمك.',
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
            if (snap.isInvite && snap.inviteCode != null) ...[
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.elevated,
                  border: Border.all(color: colors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  snap.inviteCode!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: snap.inviteCode!),
                  );
                  Fluttertoast.showToast(msg: 'نُسخ الرمز');
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('انسخ الرمز'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Playing view — full redesign 2026-06-20. Built around three pillars:
//   1. A premium HEADER: animated win-progress dots + my-vs-opponent
//      hand previews + clear "round X" label.
//   2. A LARGE CENTRAL stage: huge animated hand glyphs that lift +
//      pulse when picked. The choice + guess flow lives below it.
//   3. A bold LOCK-IN button that pulses gold once both picks are in.
//
// After both players lock the round resolves and a reveal banner shows
// what the opponent picked alongside my picks, with a points delta
// animation. This view is the entry point for new RPS players, so the
// design leans confident + readable over clever.
// ─────────────────────────────────────────────────────────────────────

const Map<String, String> _kRpsGlyph = {
  'rock': '✊',
  'paper': '✋',
  'scissors': '✌️',
};

const Map<String, String> _kRpsLabel = {
  'rock': 'حجر',
  'paper': 'ورقة',
  'scissors': 'مقص',
};

class _PlayingView extends StatefulWidget {
  const _PlayingView({
    required this.snap,
    required this.busy,
    required this.colors,
    required this.onLock,
  });
  final GameSnapshot snap;
  final bool busy;
  final SarhnyColors colors;
  final Future<void> Function(String choice, String guess) onLock;
  @override
  State<_PlayingView> createState() => _PlayingViewState();
}

class _PlayingViewState extends State<_PlayingView>
    with TickerProviderStateMixin {
  String? _choice;
  String? _guess;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _PlayingView old) {
    super.didUpdateWidget(old);
    // New round → reset local picks.
    if (old.snap.roundIndex != widget.snap.roundIndex) {
      _choice = null;
      _guess = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    final s = widget.snap;
    final canLock =
        !widget.busy && _choice != null && _guess != null && !s.meLocked;
    final liveChoice = _choice ?? s.currentMyChoice;
    final liveGuess = _guess ?? s.currentMyGuess;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _RpsHeaderBar(snap: s, colors: c),
            const SizedBox(height: 14),
            _RpsStage(
              snap: s,
              colors: c,
              myChoice: liveChoice,
              pulse: _pulse,
            ),
            const SizedBox(height: 12),
            if (s.lastRoundRevealed) _RpsRevealStrip(snap: s, colors: c),
            const SizedBox(height: 10),
            // Section: my choice
            _SectionLabel(text: 'اختر يدك', colors: c),
            const SizedBox(height: 8),
            _RpsPickRow(
              selected: liveChoice,
              disabled: widget.busy || s.meLocked,
              accent: c.moment,
              colors: c,
              onTap: (v) => setState(() => _choice = v),
            ),
            const SizedBox(height: 14),
            // Section: my guess of opponent
            _SectionLabel(text: 'خمّن يد الخصم', colors: c),
            const SizedBox(height: 8),
            _RpsPickRow(
              selected: liveGuess,
              disabled: widget.busy || s.meLocked,
              accent: c.face,
              colors: c,
              onTap: (v) => setState(() => _guess = v),
            ),
            const SizedBox(height: 14),
            _RpsLockButton(
              canLock: canLock,
              meLocked: s.meLocked,
              oppLocked: s.oppLocked,
              waitingNextRound: s.lastRoundRevealed && !s.meLocked,
              pulse: _pulse,
              colors: c,
              onLock: () => widget.onLock(_choice!, _guess!),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tiny shared section label.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.colors});
  final String text;
  final SarhnyColors colors;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        text,
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ── Header bar — round indicator + per-player score dots.
class _RpsHeaderBar extends StatelessWidget {
  const _RpsHeaderBar({required this.snap, required this.colors});
  final GameSnapshot snap;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colors.surface,
        border: Border.all(color: colors.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RpsScoreSide(
              label: 'أنت',
              score: snap.scoreMe,
              winScore: snap.winScore,
              accent: colors.moment,
              alignEnd: false,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colors.crystal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'جولة ${snap.roundIndex + 1}',
              style: TextStyle(
                color: colors.crystal,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: _RpsScoreSide(
              label: 'الخصم',
              score: snap.scoreOpp,
              winScore: snap.winScore,
              accent: colors.face,
              alignEnd: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _RpsScoreSide extends StatelessWidget {
  const _RpsScoreSide({
    required this.label,
    required this.score,
    required this.winScore,
    required this.accent,
    required this.alignEnd,
  });
  final String label;
  final int score;
  final int winScore;
  final Color accent;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final dots = List.generate(winScore, (i) {
      final filled = i < score;
      return Container(
        width: 9,
        height: 9,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? accent : accent.withValues(alpha: 0.18),
        ),
      );
    });
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: accent,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$score',
              style: TextStyle(
                color: accent,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment:
              alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: dots,
        ),
      ],
    );
  }
}

// ── Central stage — animated glyphs that react to picks + reveal.
class _RpsStage extends StatelessWidget {
  const _RpsStage({
    required this.snap,
    required this.colors,
    required this.myChoice,
    required this.pulse,
  });
  final GameSnapshot snap;
  final SarhnyColors colors;
  final String? myChoice;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    // During reveal we show BOTH hands (mine + opponent's actual pick).
    // Otherwise we show mine (or a placeholder) on the left and a hidden
    // silhouette for the opponent on the right.
    final revealed = snap.lastRoundRevealed;
    final oppRevealed = revealed ? snap.currentOppChoice : null;
    return Container(
      height: 132,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.moment.withValues(alpha: 0.15),
            colors.face.withValues(alpha: 0.10),
          ],
        ),
        border: Border.all(color: colors.border.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RpsHandSlot(
              glyph: myChoice != null ? _kRpsGlyph[myChoice] : null,
              accent: colors.moment,
              label: 'أنا',
              filled: myChoice != null,
              pulse: pulse,
              flipped: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'VS',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: _RpsHandSlot(
              glyph: oppRevealed != null ? _kRpsGlyph[oppRevealed] : null,
              accent: colors.face,
              label: 'الخصم',
              filled: oppRevealed != null,
              pulse: pulse,
              // Visually mirror the opponent's hand toward the player.
              flipped: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _RpsHandSlot extends StatelessWidget {
  const _RpsHandSlot({
    required this.glyph,
    required this.accent,
    required this.label,
    required this.filled,
    required this.pulse,
    required this.flipped,
  });
  final String? glyph;
  final Color accent;
  final String label;
  final bool filled;
  final Animation<double> pulse;
  final bool flipped;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, _) {
        final lift = filled ? -3 - 3 * pulse.value : 0.0;
        final scale = filled ? 1.0 + 0.04 * pulse.value : 0.92;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, lift),
              child: Transform.scale(
                scale: scale,
                child: Transform.scale(
                  scaleX: flipped ? -1 : 1,
                  child: Text(
                    glyph ?? '✋',
                    style: TextStyle(
                      fontSize: 56,
                      color: filled ? null : accent.withValues(alpha: 0.30),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: accent,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Reveal strip — appears on round resolve, fades within ~3s as the
// next round's UI takes over.
class _RpsRevealStrip extends StatelessWidget {
  const _RpsRevealStrip({required this.snap, required this.colors});
  final GameSnapshot snap;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    final myPts = snap.role == 'a' ? snap.lastRoundAPoints : snap.lastRoundBPoints;
    final oppPts = snap.role == 'a' ? snap.lastRoundBPoints : snap.lastRoundAPoints;
    final myDelta = myPts > 0 ? '+$myPts' : '$myPts';
    final oppDelta = oppPts > 0 ? '+$oppPts' : '$oppPts';
    final iWonRound = myPts > oppPts;
    final tied = myPts == oppPts;
    final tag = tied ? 'تعادل' : (iWonRound ? 'ربحت الجولة' : 'الخصم كسب');
    final tagColor = tied
        ? colors.crystal
        : (iWonRound ? colors.moment : colors.face);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: tagColor.withValues(alpha: 0.10),
        border: Border.all(color: tagColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: tagColor.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tag,
              style: TextStyle(
                color: tagColor,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'أنت $myDelta',
            style: TextStyle(
              color: colors.moment,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'الخصم $oppDelta',
            style: TextStyle(
              color: colors.face,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Choice / guess row — three large pick tiles.
class _RpsPickRow extends StatelessWidget {
  const _RpsPickRow({
    required this.selected,
    required this.disabled,
    required this.accent,
    required this.colors,
    required this.onTap,
  });
  final String? selected;
  final bool disabled;
  final Color accent;
  final SarhnyColors colors;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RpsPickTile(
            value: 'rock',
            selected: selected,
            disabled: disabled,
            accent: accent,
            colors: colors,
            onTap: onTap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _RpsPickTile(
            value: 'paper',
            selected: selected,
            disabled: disabled,
            accent: accent,
            colors: colors,
            onTap: onTap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _RpsPickTile(
            value: 'scissors',
            selected: selected,
            disabled: disabled,
            accent: accent,
            colors: colors,
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}

class _RpsPickTile extends StatelessWidget {
  const _RpsPickTile({
    required this.value,
    required this.selected,
    required this.disabled,
    required this.accent,
    required this.colors,
    required this.onTap,
  });
  final String value;
  final String? selected;
  final bool disabled;
  final Color accent;
  final SarhnyColors colors;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : () => onTap(value),
        borderRadius: BorderRadius.circular(16),
        splashColor: accent.withValues(alpha: 0.18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? accent.withValues(alpha: 0.20)
                : colors.surface,
            border: Border.all(
              color: isSelected
                  ? accent.withValues(alpha: 0.85)
                  : colors.border.withValues(alpha: 0.6),
              width: isSelected ? 1.6 : 0.8,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.32),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                _kRpsGlyph[value] ?? '✋',
                style: TextStyle(
                  fontSize: 30,
                  color: disabled && !isSelected
                      ? colors.textSecondary.withValues(alpha: 0.6)
                      : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _kRpsLabel[value] ?? value,
                style: TextStyle(
                  color: isSelected ? accent : colors.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Lock button — pulses gold when both picks are made; switches to
// "waiting for opponent" once we've locked.
class _RpsLockButton extends StatelessWidget {
  const _RpsLockButton({
    required this.canLock,
    required this.meLocked,
    required this.oppLocked,
    required this.waitingNextRound,
    required this.pulse,
    required this.colors,
    required this.onLock,
  });
  final bool canLock;
  final bool meLocked;
  final bool oppLocked;
  final bool waitingNextRound;
  final Animation<double> pulse;
  final SarhnyColors colors;
  final VoidCallback onLock;

  @override
  Widget build(BuildContext context) {
    if (waitingNextRound) {
      return _StatusBar(
        text: 'الجولة التالية تبدأ الآن…',
        accent: colors.crystal,
      );
    }
    if (meLocked && !oppLocked) {
      return _StatusBar(
        text: 'بانتظار الخصم…',
        accent: colors.face,
      );
    }
    if (meLocked && oppLocked) {
      return _StatusBar(
        text: 'يكشف الآن…',
        accent: colors.moment,
      );
    }
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, _) => SizedBox(
        height: 56,
        child: FilledButton.icon(
          onPressed: canLock ? onLock : null,
          icon: const Icon(Icons.lock_outline_rounded, size: 18),
          label: const Text(
            'ثبّت اختياري',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: canLock
                ? Color.lerp(colors.moment, colors.crystal, pulse.value * 0.4)
                : null,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.text, required this.accent});
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: accent.withValues(alpha: 0.12),
        border: Border.all(color: accent.withValues(alpha: 0.40), width: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Winner picks the question ──────────────────────────────────────────────

class _WinnerFinalView extends StatefulWidget {
  const _WinnerFinalView({
    required this.snap,
    required this.busy,
    required this.colors,
    required this.onSubmit,
  });
  final GameSnapshot snap;
  final bool busy;
  final SarhnyColors colors;
  final Future<void> Function(String? text) onSubmit;
  @override
  State<_WinnerFinalView> createState() => _WinnerFinalViewState();
}

class _WinnerFinalViewState extends State<_WinnerFinalView> {
  final _ctrl = TextEditingController();
  Timer? _tick;
  int _secondsLeft = 25;

  @override
  void initState() {
    super.initState();
    _resync();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => _resync());
  }

  void _resync() {
    final dl = widget.snap.finalQuestionDeadline;
    if (dl == null) return;
    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    final remaining = (dl - now).round();
    setState(() => _secondsLeft = remaining.clamp(0, 999));
  }

  @override
  void dispose() {
    _tick?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    final fallback = widget.snap.finalQuestionText;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.crystal.withValues(alpha: 0.12),
              border: Border.all(color: c.crystal),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Text('🏆', style: TextStyle(fontSize: 22, color: c.crystal)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('فزت في التحدّي',
                          style: TextStyle(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        'اكتب سؤالاً لخصمك. لو ما كتبت، نرسل السؤال التلقائي.',
                        style: TextStyle(color: c.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Icon(Icons.timer_outlined, color: c.textSecondary, size: 16),
            const SizedBox(width: 6),
            Text(
              '$_secondsLeft ثانية متبقية',
              style: TextStyle(
                  color: _secondsLeft <= 5 ? Theme.of(context).colorScheme.error : c.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
            ),
          ]),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            maxLines: 3,
            minLines: 2,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'اكتب سؤالك بصدق (لا أرقام تواصل، لا روابط، لا إساءة)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),
          if (fallback != null && fallback.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.elevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('السؤال التلقائي إن لم تكتب:',
                      style: TextStyle(color: c.textSecondary, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(fallback,
                      style: TextStyle(color: c.textPrimary, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: widget.busy
                ? null
                : () {
                    final text = _ctrl.text.trim();
                    widget.onSubmit(text.isEmpty ? null : text);
                  },
            icon: const Icon(Icons.send_rounded),
            label: const Text('أرسل السؤال'),
          ),
        ],
      ),
    );
  }
}

// ── Loser answers ──────────────────────────────────────────────────────────

class _LoserFinalView extends StatefulWidget {
  const _LoserFinalView({
    required this.snap,
    required this.busy,
    required this.colors,
    required this.onAnswer,
    required this.onSkip,
    this.onAbstain,
  });
  final GameSnapshot snap;
  final bool busy;
  final SarhnyColors colors;
  final Future<void> Function(String text) onAnswer;
  final VoidCallback? onSkip;
  /// Optional — when wired, shows an "امتنع · إعلان +1" button that
  /// triggers the ad-then-abstain flow.
  final VoidCallback? onAbstain;
  @override
  State<_LoserFinalView> createState() => _LoserFinalViewState();
}

class _LoserFinalViewState extends State<_LoserFinalView> {
  final _ctrl = TextEditingController();
  Timer? _tick;
  int _secondsLeft = 60;

  @override
  void initState() {
    super.initState();
    _resync();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => _resync());
  }

  void _resync() {
    final dl = widget.snap.finalAnswerDeadline;
    if (dl == null) {
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    final remaining = (dl - now).round();
    if (!mounted) return;
    setState(() => _secondsLeft = remaining.clamp(0, 999));
  }

  @override
  void dispose() {
    _tick?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    final s = widget.snap;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (s.finalAnswerDeadline != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Icon(Icons.timer_outlined, color: c.textSecondary, size: 16),
                const SizedBox(width: 6),
                Text(
                  '$_secondsLeft ثانية للإجابة',
                  style: TextStyle(
                    color: _secondsLeft <= 10
                        ? Theme.of(context).colorScheme.error
                        : c.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ]),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.face.withValues(alpha: 0.10),
              border: Border.all(color: c.face),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('سؤال من خصمك',
                    style: TextStyle(
                        color: c.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
                const SizedBox(height: 6),
                Text(
                  s.finalQuestionText ?? '...',
                  style: TextStyle(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _ctrl,
            maxLines: 5,
            minLines: 3,
            maxLength: 400,
            decoration: InputDecoration(
              hintText: 'أجب بصدق. (لا أرقام تواصل، لا روابط)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            if (widget.onSkip != null)
              OutlinedButton.icon(
                onPressed: widget.busy ? null : widget.onSkip,
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: const Text('بدّل السؤال'),
              ),
            const Spacer(),
            FilledButton.icon(
              onPressed: widget.busy || _ctrl.text.trim().isEmpty
                  ? null
                  : () => widget.onAnswer(_ctrl.text.trim()),
              icon: const Icon(Icons.send_rounded),
              label: const Text('أرسل إجابتي'),
            ),
          ]),
          if (widget.onAbstain != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: widget.busy ? null : widget.onAbstain,
                icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
                label: const Text('امتنع · شاهد إعلاناً (+1 نقطة)'),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'الامتناع ينهي المباراة بدون إجابة ويضيف نقطة لرصيدك.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Loser waiting for the winner's question ────────────────────────────────
//
// CRITICAL — this view renders DURING the "final" phase for the loser.
// It MUST NOT receive or display `snap.finalQuestionText`; the server
// already strips it for the loser, but we double-down here for defense
// in depth. A synced countdown gives parity with the winner's compose
// timer so the loser feels the rhythm rather than staring at a blank.
class _LoserWaitingForQuestionView extends StatefulWidget {
  const _LoserWaitingForQuestionView({required this.snap, required this.colors});
  final GameSnapshot snap;
  final SarhnyColors colors;
  @override
  State<_LoserWaitingForQuestionView> createState() =>
      _LoserWaitingForQuestionViewState();
}

class _LoserWaitingForQuestionViewState
    extends State<_LoserWaitingForQuestionView>
    with SingleTickerProviderStateMixin {
  Timer? _tick;
  int _secondsLeft = 25;
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _resync();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => _resync());
  }

  void _resync() {
    final dl = widget.snap.finalQuestionDeadline;
    if (dl == null) return;
    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    final remaining = (dl - now).round();
    if (!mounted) return;
    setState(() => _secondsLeft = remaining.clamp(0, 999));
  }

  @override
  void dispose() {
    _tick?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: Tween(begin: 0.9, end: 1.05).animate(
                CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
              ),
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: c.crystal.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: c.crystal, width: 1.2),
                ),
                child: Icon(Icons.hourglass_top_rounded,
                    size: 44, color: c.crystal),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'ينتظر الفائز يكتب سؤاله…',
              style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'السؤال سيظهر بعد لحظات. ابقَ صبوراً.',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, color: c.textSecondary, size: 16),
                const SizedBox(width: 6),
                Text(
                  '$_secondsLeft ثانية',
                  style: TextStyle(
                    color: _secondsLeft <= 5
                        ? Theme.of(context).colorScheme.error
                        : c.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Winner waiting for the loser's answer ──────────────────────────────────
class _WinnerWaitingForAnswerView extends StatelessWidget {
  const _WinnerWaitingForAnswerView({required this.snap, required this.colors});
  final GameSnapshot snap;
  final SarhnyColors colors;
  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 56, height: 56,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 18),
            Text(
              'بانتظار إجابة خصمك...',
              style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'السؤال انطلق — لحظة وتصلك إجابته.',
              style: TextStyle(color: c.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Answered (final reveal) ────────────────────────────────────────────────

class _AnsweredView extends ConsumerStatefulWidget {
  const _AnsweredView({required this.snap, required this.colors});
  final GameSnapshot snap;
  final SarhnyColors colors;
  @override
  ConsumerState<_AnsweredView> createState() => _AnsweredViewState();
}

class _AnsweredViewState extends ConsumerState<_AnsweredView> {
  // Rematch flow state. Mirrors the Carrom Game Over UX:
  //   none      → both buttons visible
  //   waiting   → I've accepted, waiting for the opponent (polling)
  //   matched   → server returned new_game_id, navigating away
  //   declined  → opponent said no
  //   timeout   → no answer within REMATCH_WINDOW_SECONDS
  String _rematchPhase = 'none';
  Timer? _pollTimer;
  Timer? _windowTimer;
  int _secondsLeft = 20;

  @override
  void dispose() {
    _pollTimer?.cancel();
    _windowTimer?.cancel();
    super.dispose();
  }

  Future<void> _acceptRematch() async {
    setState(() => _rematchPhase = 'waiting');
    try {
      final res = await ref
          .read(gameRepositoryProvider)
          .rematch(widget.snap.gameId, 'accept');
      if (!mounted) return;
      if (res.status == 'matched' && res.newGameId != null) {
        _goToNewGame(res.newGameId!);
        return;
      }
      if (res.status == 'declined') {
        setState(() => _rematchPhase = 'declined');
        return;
      }
      // Pending — start countdown + polling.
      _secondsLeft = res.windowSeconds ?? 20;
      _windowTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() => _secondsLeft -= 1);
        if (_secondsLeft <= 0) {
          t.cancel();
          if (_rematchPhase == 'waiting') {
            setState(() => _rematchPhase = 'timeout');
            _pollTimer?.cancel();
          }
        }
      });
      _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
        try {
          final st = await ref
              .read(gameRepositoryProvider)
              .rematchStatus(widget.snap.gameId);
          if (!mounted) return;
          if (st.status == 'matched' && st.newGameId != null) {
            _pollTimer?.cancel();
            _windowTimer?.cancel();
            _goToNewGame(st.newGameId!);
          } else if (st.status == 'declined') {
            _pollTimer?.cancel();
            _windowTimer?.cancel();
            setState(() => _rematchPhase = 'declined');
          }
        } catch (_) {
          // tick will retry
        }
      });
    } on GameApiException catch (e) {
      Fluttertoast.showToast(msg: e.message);
      if (!mounted) return;
      setState(() => _rematchPhase = 'none');
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر الإرسال');
      if (!mounted) return;
      setState(() => _rematchPhase = 'none');
    }
  }

  Future<void> _declineAndSearch() async {
    // Best-effort decline to free the opponent's wait UI fast.
    unawaited(
      ref
          .read(gameRepositoryProvider)
          .rematch(widget.snap.gameId, 'decline')
          .catchError((_) => const RematchStatus(status: 'declined')),
    );
    if (!mounted) return;
    context.go('/game');
  }

  void _goToNewGame(String newId) {
    if (!mounted) return;
    context.go('/game/play/$newId');
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final snap = widget.snap;
    final iAmWinner = snap.isWinner == true;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: (iAmWinner ? colors.crystal : colors.face).withValues(alpha: 0.10),
              border: Border.all(color: iAmWinner ? colors.crystal : colors.face),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(iAmWinner ? '🏆 الفائز' : '🌹 الخاسر',
                    style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
                const SizedBox(height: 6),
                Text('${snap.scoreMe} — ${snap.scoreOpp}',
                    style: TextStyle(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (snap.finalQuestionText != null)
            _QABubble(
              label: 'السؤال',
              text: snap.finalQuestionText!,
              colors: colors,
              isQuestion: true,
            ),
          const SizedBox(height: 10),
          if (snap.finalAnswer != null)
            _QABubble(
              label: 'الإجابة',
              text: snap.finalAnswer!,
              colors: colors,
              isQuestion: false,
            ),
          const SizedBox(height: 24),
          // ── Rematch UI ────────────────────────────────────────────────
          _RematchPanel(
            phase: _rematchPhase,
            secondsLeft: _secondsLeft,
            colors: colors,
            onAccept: _acceptRematch,
            onSearchOther: _declineAndSearch,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.go('/game'),
            icon: const Icon(Icons.exit_to_app, size: 18),
            label: const Text('الخروج للوبي'),
          ),
        ],
      ),
    );
  }
}

class _RematchPanel extends StatelessWidget {
  const _RematchPanel({
    required this.phase,
    required this.secondsLeft,
    required this.colors,
    required this.onAccept,
    required this.onSearchOther,
  });
  final String phase;
  final int secondsLeft;
  final SarhnyColors colors;
  final VoidCallback onAccept;
  final VoidCallback onSearchOther;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    if (phase == 'waiting') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: c.elevated,
          border: Border.all(color: c.crystal.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            const SizedBox(
              width: 28, height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(height: 10),
            Text('بانتظار قبول الخصم… ($secondsLeft ث)',
                style: TextStyle(
                    color: c.textPrimary, fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }
    if (phase == 'declined' || phase == 'timeout') {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: c.danger.withValues(alpha: 0.08),
              border: Border.all(color: c.danger.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              phase == 'declined'
                  ? 'الخصم لم يقبل الإعادة'
                  : 'انتهى الوقت — الخصم غير متاح',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: c.textPrimary, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: onSearchOther,
            icon: const Icon(Icons.search_rounded),
            label: const Text('البحث عن منافس آخر'),
          ),
        ],
      );
    }
    return Column(
      children: [
        FilledButton.icon(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: c.crystal,
          ),
          onPressed: onAccept,
          icon: const Icon(Icons.replay_rounded),
          label: const Text(
            '🔄 إعادة مع نفس الخصم',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: onSearchOther,
          icon: const Icon(Icons.search_rounded),
          label: const Text('🔍 البحث عن منافس آخر'),
        ),
      ],
    );
  }
}

class _QABubble extends StatelessWidget {
  const _QABubble({
    required this.label,
    required this.text,
    required this.colors,
    required this.isQuestion,
  });
  final String label;
  final String text;
  final SarhnyColors colors;
  final bool isQuestion;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w700, fontSize: 11)),
          const SizedBox(height: 6),
          Text(text,
              style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 15,
                  height: 1.6,
                  fontWeight: isQuestion ? FontWeight.w700 : FontWeight.w400)),
        ],
      ),
    );
  }
}

class _EndedView extends StatelessWidget {
  const _EndedView({required this.title, required this.subtitle, required this.colors});
  final String title;
  final String subtitle;
  final SarhnyColors colors;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.do_not_disturb_on_outlined, size: 48, color: colors.textSecondary),
            const SizedBox(height: 12),
            Text(title,
                style: TextStyle(
                    color: colors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textSecondary)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/game'),
              child: const Text('عودة'),
            ),
          ],
        ),
      ),
    );
  }
}
