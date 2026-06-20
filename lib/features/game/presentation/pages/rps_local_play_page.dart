import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/ads/interstitial_service.dart';
import '../../../../core/haptics/game_haptics.dart';
import '../../application/rps_local_engine.dart';
import '../../data/random_question_repo.dart';

/// Local Rock-Paper-Scissors — Player vs AI on a single device.
///
/// Flow:
///   1. Player picks hand + guess of AI's hand.
///   2. AI privately picks (via [RpsLocalEngine.aiPick]).
///   3. Reveal — both hands flip face-up, scores tick.
///   4. Next round starts automatically after a short pause.
///   5. First to 5 points wins.
///   6. When the match ends:
///        * Player wins → composes a question to "ask the AI" (for
///          fun — there's no submission anywhere; it's the rematch
///          ritual that gives the win meaning).
///        * AI wins → fetches a real question from the shared bank
///          (/api/v1/game/random-question?mood=X) and asks it. The
///          player can type a reflective answer; nothing is recorded.
///        * Draw → calm "round ends in a draw" banner.
class RpsLocalPlayPage extends ConsumerStatefulWidget {
  const RpsLocalPlayPage({super.key});
  @override
  ConsumerState<RpsLocalPlayPage> createState() => _RpsLocalPlayPageState();
}

class _RpsLocalPlayPageState extends ConsumerState<RpsLocalPlayPage> {
  final RpsLocalEngine _engine = RpsLocalEngine();
  RpsHand? _myHand;
  RpsHand? _myGuess;
  RpsRound? _lastRound;
  bool _revealing = false;
  bool _firedInterstitial = false;
  String _mood = 'light';
  String? _aiQuestion;
  bool _aiQuestionLoading = false;
  final TextEditingController _myQuestionCtrl = TextEditingController();
  final TextEditingController _myAnswerCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(interstitialAdServiceProvider).preload().catchError((_) {});
    });
  }

  @override
  void dispose() {
    _myQuestionCtrl.dispose();
    _myAnswerCtrl.dispose();
    super.dispose();
  }

  bool get _canLock =>
      _myHand != null && _myGuess != null && !_revealing && !_engine.isOver;

  Future<void> _lockIn() async {
    if (!_canLock) return;
    GameHaptics.uiPop();
    setState(() => _revealing = true);
    // Brief tension pause before the AI shows its hand.
    await Future<void>.delayed(const Duration(milliseconds: 380));
    if (!mounted) return;
    final aiPick = _engine.aiPick();
    final round = _engine.playRound(
      myHand: _myHand!,
      myGuess: _myGuess!,
      oppHand: aiPick.hand,
      oppGuess: aiPick.guess,
    );
    setState(() => _lastRound = round);
    if (_engine.isOver) {
      _onMatchEnded();
      return;
    }
    // Linger on the reveal for ~1.4s, then clear for the next round.
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() {
      _myHand = null;
      _myGuess = null;
      _lastRound = null;
      _revealing = false;
    });
  }

  Future<void> _onMatchEnded() async {
    if (_firedInterstitial) return;
    _firedInterstitial = true;
    if (_engine.winner == 'me') {
      GameHaptics.win();
    }
    // Fetch the AI's question only when the AI actually won.
    if (_engine.winner == 'opp') {
      setState(() => _aiQuestionLoading = true);
      final q = await ref
          .read(randomQuestionRepoProvider)
          .fetch(mood: _mood);
      if (!mounted) return;
      setState(() {
        _aiQuestion = q;
        _aiQuestionLoading = false;
      });
    }
    // Interstitial bookkeeping — shared cadence across local + online.
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      ref.read(interstitialAdServiceProvider).onMatchCompleted();
    });
  }

  void _restart() {
    GameHaptics.uiPop();
    setState(() {
      _engine.reset();
      _myHand = null;
      _myGuess = null;
      _lastRound = null;
      _revealing = false;
      _firedInterstitial = false;
      _aiQuestion = null;
      _aiQuestionLoading = false;
      _myQuestionCtrl.clear();
      _myAnswerCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
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
        title: const Text(
          'تحدّى — تدريب',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        ),
        actions: [
          IconButton(
            tooltip: 'إعادة',
            onPressed: _engine.roundNumber == 1 && !_engine.isOver
                ? null
                : _restart,
            icon: const Icon(Icons.replay_rounded),
          ),
          const Gap(4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MoodPicker(
                current: _mood,
                colors: colors,
                onChange: _engine.roundNumber == 1
                    ? (v) => setState(() => _mood = v)
                    : null,
              ),
              const Gap(12),
              _ScoreHeader(engine: _engine, colors: colors),
              const Gap(14),
              _Stage(
                myHand: _myHand,
                lastRound: _lastRound,
                colors: colors,
              ),
              const Gap(14),
              if (!_engine.isOver) ...[
                _SectionLabel('اختر يدك', colors),
                const Gap(6),
                _HandRow(
                  selected: _myHand,
                  disabled: _revealing,
                  accent: colors.moment,
                  colors: colors,
                  onTap: (h) {
                    GameHaptics.tap();
                    setState(() => _myHand = h);
                  },
                ),
                const Gap(12),
                _SectionLabel('خمّن يد الذكاء', colors),
                const Gap(6),
                _HandRow(
                  selected: _myGuess,
                  disabled: _revealing,
                  accent: colors.face,
                  colors: colors,
                  onTap: (h) {
                    GameHaptics.tap();
                    setState(() => _myGuess = h);
                  },
                ),
                const Gap(14),
                SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _canLock ? _lockIn : null,
                    icon: const Icon(Icons.lock_outline_rounded, size: 18),
                    label: Text(
                      _revealing ? 'يكشف...' : 'ثبّت',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
              if (_engine.isOver) ...[
                _OutcomeBanner(engine: _engine, colors: colors),
                const Gap(12),
                if (_engine.winner == 'me')
                  _MeWinnerComposer(
                    controller: _myQuestionCtrl,
                    colors: colors,
                  )
                else if (_engine.winner == 'opp')
                  _AiWinnerQuestion(
                    question: _aiQuestion,
                    loading: _aiQuestionLoading,
                    answerCtrl: _myAnswerCtrl,
                    colors: colors,
                  ),
                const Gap(14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _restart,
                        icon: const Icon(Icons.replay_rounded, size: 18),
                        label: const Text('مباراة جديدة'),
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
                        label: const Text('الساحة'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mood picker ─────────────────────────────────────────────────────

class _MoodPicker extends StatelessWidget {
  const _MoodPicker({
    required this.current,
    required this.colors,
    this.onChange,
  });
  final String current;
  final SarhnyColors colors;
  /// Null = locked (mid-match, mood changes can't fairly change the
  /// post-game question pool the AI will draw from).
  final ValueChanged<String>? onChange;

  @override
  Widget build(BuildContext context) {
    Widget chip(String key, String label, String emoji) {
      final selected = current == key;
      return Expanded(
        child: GestureDetector(
          onTap: onChange == null ? null : () => onChange!(key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: selected
                  ? colors.moment.withValues(alpha: 0.18)
                  : colors.surface,
              border: Border.all(
                color: selected
                    ? colors.moment.withValues(alpha: 0.80)
                    : colors.border.withValues(alpha: 0.6),
                width: selected ? 1.4 : 0.8,
              ),
            ),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? colors.moment : colors.textPrimary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('light', 'خفيف', '🌤️'),
        chip('bold', 'جريء', '🔥'),
        chip('funny', 'مضحك', '😂'),
      ],
    );
  }
}

// ── Score header ────────────────────────────────────────────────────

class _ScoreHeader extends StatelessWidget {
  const _ScoreHeader({required this.engine, required this.colors});
  final RpsLocalEngine engine;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.surface,
        border: Border.all(color: colors.border.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _scoreSide('أنت', engine.myScore, engine.winScore,
                colors.moment),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: colors.crystal.withValues(alpha: 0.18),
            ),
            child: Text(
              'جولة ${engine.roundNumber}',
              style: TextStyle(
                color: colors.crystal,
                fontWeight: FontWeight.w900,
                fontSize: 11.5,
              ),
            ),
          ),
          Expanded(
            child: _scoreSide('الذكاء', engine.oppScore, engine.winScore,
                colors.face,
                alignEnd: true),
          ),
        ],
      ),
    );
  }

  Widget _scoreSide(String label, int score, int winScore, Color accent,
      {bool alignEnd = false}) {
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
            Text(label,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w900,
                  fontSize: 11.5,
                )),
            const SizedBox(width: 6),
            Text('$score',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                )),
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

// ── Stage (hands area) ──────────────────────────────────────────────

class _Stage extends StatelessWidget {
  const _Stage({
    required this.myHand,
    required this.lastRound,
    required this.colors,
  });
  final RpsHand? myHand;
  final RpsRound? lastRound;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    // While revealing the last round, show both hands.
    final myGlyph = lastRound?.myHand.glyph ?? myHand?.glyph;
    final aiGlyph = lastRound?.oppHand.glyph;
    final revealing = lastRound != null;
    return Container(
      height: 124,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            colors.moment.withValues(alpha: 0.15),
            colors.face.withValues(alpha: 0.10),
          ],
        ),
        border: Border.all(color: colors.border.withValues(alpha: 0.50)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  myGlyph ?? '✋',
                  style: TextStyle(
                    fontSize: 54,
                    color: myGlyph == null
                        ? colors.moment.withValues(alpha: 0.30)
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'أنا',
                  style: TextStyle(
                    color: colors.moment,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              revealing && lastRound != null
                  ? (lastRound!.myPoints > lastRound!.oppPoints
                      ? '+'
                      : (lastRound!.myPoints < lastRound!.oppPoints
                          ? '−'
                          : '='))
                  : 'VS',
              style: TextStyle(
                color: colors.textSecondary,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scaleX: -1,
                  child: Text(
                    aiGlyph ?? '✋',
                    style: TextStyle(
                      fontSize: 54,
                      color: aiGlyph == null
                          ? colors.face.withValues(alpha: 0.30)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الذكاء',
                  style: TextStyle(
                    color: colors.face,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
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

// ── Hand-pick row ───────────────────────────────────────────────────

class _HandRow extends StatelessWidget {
  const _HandRow({
    required this.selected,
    required this.disabled,
    required this.accent,
    required this.colors,
    required this.onTap,
  });
  final RpsHand? selected;
  final bool disabled;
  final Color accent;
  final SarhnyColors colors;
  final ValueChanged<RpsHand> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: RpsHand.values.map((h) {
        final isSel = h == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: disabled ? null : () => onTap(h),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSel
                        ? accent.withValues(alpha: 0.20)
                        : colors.surface,
                    border: Border.all(
                      color: isSel
                          ? accent.withValues(alpha: 0.85)
                          : colors.border.withValues(alpha: 0.6),
                      width: isSel ? 1.4 : 0.8,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isSel
                        ? [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.30),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(h.glyph, style: const TextStyle(fontSize: 30)),
                      const SizedBox(height: 4),
                      Text(
                        h.arabic,
                        style: TextStyle(
                          color: isSel ? accent : colors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Outcome banner ──────────────────────────────────────────────────

class _OutcomeBanner extends StatelessWidget {
  const _OutcomeBanner({required this.engine, required this.colors});
  final RpsLocalEngine engine;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    final iWon = engine.winner == 'me';
    final accent = iWon ? colors.moment : colors.face;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.24),
            accent.withValues(alpha: 0.10),
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Text(iWon ? '🏆' : '🤖', style: const TextStyle(fontSize: 30)),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  iWon ? 'فزت! 🎉' : 'الذكاء فاز',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
                const Gap(2),
                Text(
                  iWon
                      ? 'اطرح سؤالك على الذكاء (للمتعة فقط)'
                      : 'الذكاء يطرح سؤالاً من بنك الأسئلة',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
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

// ── Composers ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, this.colors);
  final String text;
  final SarhnyColors colors;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          text,
          style: TextStyle(
            color: colors.textSecondary,
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 0.2,
          ),
        ),
      );
}

class _MeWinnerComposer extends StatelessWidget {
  const _MeWinnerComposer({
    required this.controller,
    required this.colors,
  });
  final TextEditingController controller;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.surface,
        border: Border.all(color: colors.border.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_rounded, color: colors.moment, size: 18),
              const Gap(8),
              Text(
                'سؤالك للذكاء',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Gap(8),
          TextField(
            controller: controller,
            maxLength: 200,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'اطرح سؤالاً صريحاً... (للمتعة فقط)',
              filled: true,
              fillColor: colors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: colors.border.withValues(alpha: 0.6),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: colors.border.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiWinnerQuestion extends StatelessWidget {
  const _AiWinnerQuestion({
    required this.question,
    required this.loading,
    required this.answerCtrl,
    required this.colors,
  });
  final String? question;
  final bool loading;
  final TextEditingController answerCtrl;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.face.withValues(alpha: 0.08),
        border: Border.all(color: colors.face.withValues(alpha: 0.40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_rounded, color: colors.face, size: 18),
              const Gap(8),
              Text(
                'سؤال الذكاء',
                style: TextStyle(
                  color: colors.face,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Gap(10),
          if (loading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(colors.face),
                    ),
                  ),
                  const Gap(10),
                  Text(
                    'يحضّر سؤالاً...',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              question ?? '—',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          const Gap(10),
          TextField(
            controller: answerCtrl,
            maxLength: 400,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'أجب لنفسك...',
              filled: true,
              fillColor: colors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: colors.border.withValues(alpha: 0.6),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: colors.border.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          const Gap(4),
          Text(
            'الإجابة لك وحدك — لا تُحفظ ولا تُرسل.',
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
