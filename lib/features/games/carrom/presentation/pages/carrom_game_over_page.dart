import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router.dart';
import '../../../../../app/theme/app_theme.dart';
import '../../../../../core/providers/auth_providers.dart';
import '../../application/carrom_controllers.dart';
import '../../application/carrom_match_state.dart';
import '../../data/admob_service.dart';
import '../../data/carrom_api.dart';

/// شاشة post-game — كشف هوية + إعادة تحدّي + إرسال صراحة للخصم.
///
/// Layout hierarchy (top → bottom):
///   1. HEADER — hero banner (winner/loser/concede states), pot display,
///      optional confetti for winners.
///   2. PRIMARY ACTIONS — two stacked full-width FilledButtons:
///        a) العودة للوبي (brand `moment` color, FilledButton)
///        b) البحث عن منافس آخر (FilledButton.tonal)
///   3. SECONDARY — rematch-with-same-opponent panel (de-emphasized).
///   4. TERTIARY — reveal/hide/sarhny/ad cards (winners + revealOffer only).
///   5. LOSER CLOSURE — "ماذا حدث؟" expandable + "أرسل صراحة" mini-card.
class CarromGameOverPage extends ConsumerStatefulWidget {
  const CarromGameOverPage({
    super.key,
    required this.roomId,
    required this.outcome,
  });
  final String roomId;
  final CarromOutcome outcome;

  @override
  ConsumerState<CarromGameOverPage> createState() =>
      _CarromGameOverPageState();
}

class _CarromGameOverPageState extends ConsumerState<CarromGameOverPage>
    with TickerProviderStateMixin {
  late final AnimationController _confettiCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );

  bool _revealing = false;
  bool _whatHappenedExpanded = false;
  // Rematch flow state — drives the bottom-of-screen panel.
  // Phases: none | waiting | matched | declined | timeout
  String _rematchPhase = 'none';
  Timer? _rematchPoll;
  Timer? _rematchWindow;
  int _rematchSecondsLeft = 20;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.invalidate(carromWalletProvider);
      // Pre-load the rewarded ad — by the time the user taps the button
      // it should be ready, eliminating the loading spinner.
      ref.read(admobRewardServiceProvider).loadRewardedAd();
    });
    // We honour reduce-motion at paint time (see build); animating the
    // controller cheaply is fine because the painter early-outs.
    _confettiCtrl.forward();
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _rematchPoll?.cancel();
    _rematchWindow?.cancel();
    super.dispose();
  }

  /// Tap "Rematch with same opponent". Sends accept + drives the poll loop.
  Future<void> _acceptRematch() async {
    if (widget.outcome.matchId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذّر بدء الإعادة الآن')),
      );
      return;
    }
    setState(() => _rematchPhase = 'waiting');
    try {
      final res = await ref
          .read(carromApiProvider)
          .rematch(widget.outcome.matchId, 'accept');
      if (!mounted) return;
      if (res.status == 'matched' && res.roomId != null) {
        _goToNewRoom(res.roomId!);
        return;
      }
      if (res.status == 'declined') {
        setState(() => _rematchPhase = 'declined');
        return;
      }
      _rematchSecondsLeft = res.windowSeconds ?? 20;
      _rematchWindow = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() => _rematchSecondsLeft -= 1);
        if (_rematchSecondsLeft <= 0) {
          t.cancel();
          if (_rematchPhase == 'waiting') {
            setState(() => _rematchPhase = 'timeout');
            _rematchPoll?.cancel();
          }
        }
      });
      _rematchPoll = Timer.periodic(const Duration(seconds: 2), (_) async {
        try {
          final st = await ref
              .read(carromApiProvider)
              .rematchStatus(widget.outcome.matchId);
          if (!mounted) return;
          if (st.status == 'matched' && st.roomId != null) {
            _rematchPoll?.cancel();
            _rematchWindow?.cancel();
            _goToNewRoom(st.roomId!);
          } else if (st.status == 'declined') {
            _rematchPoll?.cancel();
            _rematchWindow?.cancel();
            setState(() => _rematchPhase = 'declined');
          }
        } catch (_) {
          // poll again on next tick
        }
      });
    } on CarromApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
      setState(() => _rematchPhase = 'none');
    } catch (_) {
      if (!mounted) return;
      setState(() => _rematchPhase = 'none');
    }
  }

  /// Tap "Search another opponent" → best-effort decline, then go to
  /// matchmaking. We do not wait for the decline to avoid blocking the
  /// user — the opponent's wait window will time out anyway.
  Future<void> _searchOther() async {
    if (widget.outcome.matchId != 0) {
      unawaited(
        ref
            .read(carromApiProvider)
            .rematch(widget.outcome.matchId, 'decline')
            .catchError(
              (_) => const CarromRematchStatus(status: 'declined'),
            ),
      );
    }
    if (!mounted) return;
    context.go(AppRoutes.carromMatchmaking);
  }

  void _goToNewRoom(String roomId) {
    if (!mounted) return;
    context.go(AppRoutes.carromMatch(roomId));
  }

  /// System back / programmatic pop → always return to the carrom lobby.
  /// We bypass the default navigator pop because the previous route is the
  /// stale match page, which would re-render a dead WebSocket session.
  void _handleSystemBack() {
    if (!mounted) return;
    context.go(AppRoutes.carromLobby);
  }

  Future<void> _doReveal(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    if (widget.outcome.matchId == 0) {
      // Fallback لو الـ matchId غير متاح (server out-of-date).
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذّر تنفيذ الإجراء حالياً')),
      );
      return;
    }
    setState(() => _revealing = true);
    try {
      await ref
          .read(carromApiProvider)
          .revealAction(widget.outcome.matchId, action);
      ref.invalidate(carromWalletProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            action == 'reveal'
                ? 'تم — لو وافق خصمك، تتبادلون الهوية'
                : 'بقيت مجهولاً',
          ),
        ),
      );
    } on CarromApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر إرسال الطلب')),
        );
      }
    } finally {
      if (mounted) setState(() => _revealing = false);
    }
  }

  Future<void> _openSarhnyComposer(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final colors = context.sarhnyColors;
    final ctrl = TextEditingController();
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 18,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'رسالة صراحة لخصمك',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'ستصل لـ inbox الخصم مع علامة "لعب معك كيرم"',
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 4,
              maxLength: 280,
              decoration: const InputDecoration(
                hintText: 'اكتب رسالتك...',
              ),
            ),
            FilledButton.icon(
              onPressed: () async {
                final msg = ctrl.text.trim();
                if (msg.length < 3) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('الرسالة قصيرة جداً')),
                  );
                  return;
                }
                try {
                  await ref.read(carromApiProvider).sendSarhnyToOpponent(
                        widget.outcome.matchId,
                        msg,
                      );
                  if (ctx.mounted) Navigator.of(ctx).pop(true);
                } on CarromApiException catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text(e.message)),
                    );
                  }
                } catch (_) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('تعذّر الإرسال')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.send_rounded),
              label: const Text('إرسال'),
            ),
          ],
        ),
      ),
    );
    ctrl.dispose();
    if (sent == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('وصلت رسالتك للخصم')),
      );
    }
  }

  Future<void> _watchRewardedAd(BuildContext context, WidgetRef ref) async {
    final svc = ref.read(admobRewardServiceProvider);
    try {
      final res = await svc.showRewardedAd();
      if (res == null) {
        // User dismissed before earning — no UX noise.
        return;
      }
      ref.invalidate(carromWalletProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('+${res.credited} نقطة — رصيدك: ${res.balance}')),
      );
    } on AdRewardException catch (e) {
      if (!context.mounted) return;
      final ar = switch (e.code) {
        'daily_cap_reached' => 'وصلت الحد اليومي (10 إعلانات)',
        'ad_unavailable' => 'الإعلان غير متاح حالياً — حاول لاحقاً',
        'invalid_signature' => 'تعذّر التحقق من الإعلان',
        'ads_unsupported_platform' => 'الإعلانات غير مدعومة على هذه المنصة',
        _ => 'تعذّر إضافة المكافأة',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ar)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final myUserId = ref.watch(authStateProvider).value?.userId;
    final won = myUserId != null && widget.outcome.winnerId == myUserId;
    final pot = widget.outcome.pot;
    final byConcede = widget.outcome.byConcede;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final showConfetti = won && !reduceMotion;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleSystemBack();
      },
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Stack(
            children: [
              if (showConfetti)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _confettiCtrl,
                      builder: (_, __) => CustomPaint(
                        painter: _ConfettiPainter(_confettiCtrl.value),
                      ),
                    ),
                  ),
                ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── 1. HEADER — hero banner + pot.
                    _Header(
                      won: won,
                      pot: pot,
                      byConcede: byConcede,
                      colors: colors,
                    ),
                    const SizedBox(height: 12),

                    // ── 2. PRIMARY ACTIONS — promoted to top of fold.
                    _PrimaryActions(
                      colors: colors,
                      onLobby: _handleSystemBack,
                      onSearchOther: _searchOther,
                    ),
                    const SizedBox(height: 12),

                    // ── 3. SECONDARY — rematch with same opponent.
                    _RematchPanel(
                      phase: _rematchPhase,
                      secondsLeft: _rematchSecondsLeft,
                      colors: colors,
                      onAccept: _acceptRematch,
                      onSearchOther: _searchOther,
                    ),

                    // ── 4. TERTIARY — viral / monetization cards.
                    // Winners always see these; losers only if revealOffer.
                    if (widget.outcome.revealOffer || won) ...[
                      const SizedBox(height: 12),
                      _OptionCard(
                        title: 'اكشف هويتك للخصم',
                        subtitle: 'تتبادلون الكشف — مجاناً',
                        icon: Icons.visibility_outlined,
                        onTap: _revealing
                            ? null
                            : () => _doReveal(context, ref, 'reveal'),
                        colors: colors,
                        accent: colors.face,
                      ),
                      const SizedBox(height: 8),
                      _OptionCard(
                        title: 'أخفِ هويتي',
                        subtitle: 'تبقى مجهولاً — يخصم 10 نقاط',
                        icon: Icons.shield_outlined,
                        onTap: _revealing
                            ? null
                            : () => _doReveal(context, ref, 'hide'),
                        colors: colors,
                        accent: colors.mind,
                      ),
                      const SizedBox(height: 8),
                      _OptionCard(
                        title: 'أرسل رسالة صراحة',
                        subtitle: 'إلى inbox الخصم — مع سياق المباراة',
                        icon: Icons.mail_outline_rounded,
                        onTap: () => _openSarhnyComposer(context, ref),
                        colors: colors,
                        accent: colors.moment,
                      ),
                      const SizedBox(height: 8),
                      _OptionCard(
                        title: 'شاهد إعلان لـ +1 نقطة',
                        subtitle: 'حدّ أقصى 10 إعلانات يومياً',
                        icon: Icons.ondemand_video_outlined,
                        onTap: () => _watchRewardedAd(context, ref),
                        colors: colors,
                        accent: colors.crystal,
                      ),
                    ],

                    // ── 5. LOSER CLOSURE — "what happened?" + sarhny mini.
                    // Always shown for losers (not just on revealOffer)
                    // to give them an emotional landing pad.
                    if (!won) ...[
                      const SizedBox(height: 12),
                      _WhatHappenedCard(
                        colors: colors,
                        expanded: _whatHappenedExpanded,
                        onToggle: () => setState(() =>
                            _whatHappenedExpanded = !_whatHappenedExpanded),
                      ),
                      // Avoid duplicating the sarhny card if the user is
                      // already seeing the full TERTIARY block above.
                      if (!widget.outcome.revealOffer) ...[
                        const SizedBox(height: 8),
                        _OptionCard(
                          title: 'أرسل صراحة',
                          subtitle: 'أرسل رسالة لخصمك — بدون كشف هويتك',
                          icon: Icons.mail_outline_rounded,
                          onTap: () => _openSarhnyComposer(context, ref),
                          colors: colors,
                          accent: colors.moment,
                        ),
                      ],
                    ],

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  HEADER
// ════════════════════════════════════════════════════════════════════

/// Hero block — handles 4 distinct emotional states:
///   * winner-by-concede   → gold "🏳️ خصمك انسحب" banner.
///   * winner-normal       → green "فزت! 🎉" banner.
///   * loser-by-concede    → neutral "انسحبت من هذه المباراة" banner.
///   * loser-normal        → muted "حظ أوفر" banner.
class _Header extends StatelessWidget {
  const _Header({
    required this.won,
    required this.pot,
    required this.byConcede,
    required this.colors,
  });
  final bool won;
  final int pot;
  final bool byConcede;
  final SarhnyColors colors;

  // Hard-coded gold gradient — the theme doesn't expose a dedicated
  // "gold" token, and `crystal` reads more silvery on dark mode.
  static const _goldA = Color(0xFFE7C26B);
  static const _goldB = Color(0xFFC9963A);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 4),
        if (byConcede && won)
          _ConcedeBanner(
            icon: '🏳️',
            title: 'خصمك انسحب',
            subtitle: 'اللقب لك. مباراة جديدة؟',
            gradient: const LinearGradient(
              colors: [_goldA, _goldB],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            titleColor: Colors.white,
            subtitleColor: Colors.white.withValues(alpha: 0.92),
            borderColor: _goldB,
          )
        else if (byConcede && !won)
          _ConcedeBanner(
            icon: null,
            title: 'انسحبت من هذه المباراة',
            subtitle: 'كل مباراة درس. حاول مرة أخرى متى أردت.',
            gradient: LinearGradient(
              colors: [
                colors.surface,
                colors.surface.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            titleColor: colors.textPrimary,
            subtitleColor: colors.textSecondary,
            borderColor: colors.border,
          )
        else
          Column(
            children: [
              const SizedBox(height: 8),
              Text(
                won ? 'فزت! 🎉' : 'حظ أوفر',
                style: TextStyle(
                  color: won ? colors.success : colors.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                won ? 'أنت بطل هذه المباراة' : 'كل مباراة فرصة جديدة',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),
        // Pot banner — unchanged styling, kept inside header block.
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            color: colors.crystal.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.crystal.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '✦',
                style: TextStyle(
                  color: colors.crystal,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                won ? '+$pot' : '−${pot ~/ 2}',
                style: TextStyle(
                  color: won ? colors.success : colors.danger,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'نقطة',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Banner used for the two concede outcomes — a flat title + subtitle
/// over a gradient with an optional emoji glyph.
class _ConcedeBanner extends StatelessWidget {
  const _ConcedeBanner({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.titleColor,
    required this.subtitleColor,
    required this.borderColor,
  });
  final String? icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final Color titleColor;
  final Color subtitleColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$title. $subtitle',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor.withValues(alpha: 0.6)),
        ),
        child: Column(
          children: [
            if (icon != null)
              Text(icon!, style: const TextStyle(fontSize: 32)),
            if (icon != null) const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: titleColor,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: subtitleColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  PRIMARY ACTIONS
// ════════════════════════════════════════════════════════════════════

/// Two stacked full-width FilledButtons. "Back to lobby" gets the loudest
/// `moment` brand fill because it's the action we want most users to take
/// after the (frequent) loss; matchmaking sits one tier below in `tonal`.
class _PrimaryActions extends StatelessWidget {
  const _PrimaryActions({
    required this.colors,
    required this.onLobby,
    required this.onSearchOther,
  });
  final SarhnyColors colors;
  final VoidCallback onLobby;
  final VoidCallback onSearchOther;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          button: true,
          label: 'العودة للوبي',
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: Tooltip(
              message: 'العودة للوبي',
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.moment,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                onPressed: onLobby,
                icon: const Icon(Icons.home_rounded),
                label: const Text('العودة للوبي'),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          button: true,
          label: 'البحث عن منافس آخر',
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: Tooltip(
              message: 'البحث عن منافس آخر',
              child: FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onPressed: onSearchOther,
                icon: const Icon(Icons.search_rounded),
                label: const Text('البحث عن منافس آخر'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  REMATCH PANEL (secondary — de-emphasized)
// ════════════════════════════════════════════════════════════════════

/// Bottom-of-screen rematch decision panel.
///
/// Phases:
///   * none     → de-emphasized "أو أعد مع نفس الخصم" mini button.
///   * waiting  → overlay with countdown showing we sent accept and are
///                waiting on the opponent.
///   * declined → "opponent declined" + a single "search other" button.
///   * timeout  → "window elapsed" + "search other" button.
///
/// In `waiting` we deliberately freeze the buttons so a double-tap doesn't
/// fire two accepts (server is idempotent via Redis SET; the UI feedback
/// is what we're protecting).
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.crystal.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 8),
            Text(
              'بانتظار قبول الخصم… ($secondsLeft ث)',
              style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'لو ضغط الخصم "إعادة"، تبدأ المباراة فوراً',
              style: TextStyle(color: c.textSecondary, fontSize: 11),
            ),
          ],
        ),
      );
    }
    if (phase == 'declined' || phase == 'timeout') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: c.danger.withValues(alpha: 0.08),
          border: Border.all(color: c.danger.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          phase == 'declined'
              ? 'الخصم لم يقبل الإعادة'
              : 'انتهى الوقت — الخصم غير متاح',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: c.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      );
    }
    // Default `none` — de-emphasized "أو أعد مع نفس الخصم" pill.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'أو أعد مع نفس الخصم',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: c.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          button: true,
          label: 'إعادة مع نفس الخصم',
          child: SizedBox(
            height: 44,
            child: Tooltip(
              message: 'إعادة مع نفس الخصم',
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.crystal,
                  side: BorderSide(
                    color: c.crystal.withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                onPressed: onAccept,
                icon: const Icon(Icons.replay_rounded, size: 18),
                label: const Text('إعادة'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  LOSER CLOSURE — "WHAT HAPPENED?" CARD
// ════════════════════════════════════════════════════════════════════

/// Collapsed-by-default upcoming-feature card. Tapping the header toggles
/// the body. We mark it clearly as "قريباً" so users don't expect content
/// that isn't there yet — the card exists to signal product investment in
/// post-game review and to give losers a small interactive moment.
class _WhatHappenedCard extends StatelessWidget {
  const _WhatHappenedCard({
    required this.colors,
    required this.expanded,
    required this.onToggle,
  });
  final SarhnyColors colors;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Semantics(
      button: true,
      label: 'ماذا حدث في هذه المباراة',
      child: Tooltip(
        message: 'مراجعة المباراة (قريباً)',
        child: Material(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.border, width: 0.6),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.help_outline_rounded,
                          color: c.textSecondary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'ماذا حدث؟',
                          style: TextStyle(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: c.crystal.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'قريباً',
                          style: TextStyle(
                            color: c.crystal,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 180),
                        child: Icon(Icons.expand_more,
                            color: c.textSecondary),
                      ),
                    ],
                  ),
                  AnimatedCrossFade(
                    crossFadeState: expanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 180),
                    firstChild: const SizedBox(width: double.infinity),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: c.background.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: c.border.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Text(
                          'راجع آخر حركاتك (قريباً)',
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
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
}

// ════════════════════════════════════════════════════════════════════
//  OPTION CARD (tertiary)
// ════════════════════════════════════════════════════════════════════

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.colors,
    required this.accent,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final SarhnyColors colors;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: Tooltip(
        message: title,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border, width: 0.6),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_left, color: colors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  CONFETTI (winners only, skipped if reduce-motion)
// ════════════════════════════════════════════════════════════════════

/// confetti بسيط — 80 جسيم يسقط من الأعلى بألوان أساسية.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.progress);
  final double progress;

  static final _colors = [
    const Color(0xFFD4A85F),
    const Color(0xFF6DB4D8),
    const Color(0xFFA896DC),
    const Color(0xFFECD9A8),
    const Color(0xFF5FC486),
  ];

  static final _rand = math.Random(42);
  static final _particles = List.generate(80, (i) => _ConfettiParticle.spawn(i));

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final y = (p.startY + progress * (size.height + 200)) % (size.height + 100);
      final x = p.x * size.width + math.sin(progress * p.wobble) * 14;
      final paint = Paint()..color = _colors[p.colorIdx % _colors.length];
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y), width: 6, height: 10),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

class _ConfettiParticle {
  _ConfettiParticle({
    required this.x,
    required this.startY,
    required this.wobble,
    required this.colorIdx,
  });
  final double x;
  final double startY;
  final double wobble;
  final int colorIdx;

  static _ConfettiParticle spawn(int i) => _ConfettiParticle(
        x: _ConfettiPainter._rand.nextDouble(),
        startY: -_ConfettiPainter._rand.nextDouble() * 400,
        wobble: 2 + _ConfettiPainter._rand.nextDouble() * 4,
        colorIdx: i,
      );
}
