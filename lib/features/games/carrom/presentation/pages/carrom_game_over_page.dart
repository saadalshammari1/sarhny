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
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Stack(
          children: [
            if (won)
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),
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
                    won
                        ? 'أنت بطل هذه المباراة'
                        : 'كل مباراة فرصة جديدة',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  if (widget.outcome.byConcede)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'بانسحاب الخصم',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  // Pot banner
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
                        Text('✦',
                            style: TextStyle(
                              color: colors.crystal,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            )),
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
                          won ? 'نقطة' : 'نقطة',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // 3 viral options
                  if (widget.outcome.revealOffer || won) ...[
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
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
                    _OptionCard(
                      title: 'أرسل رسالة صراحة',
                      subtitle: 'إلى inbox الخصم — مع سياق المباراة',
                      icon: Icons.mail_outline_rounded,
                      onTap: () => _openSarhnyComposer(context, ref),
                      colors: colors,
                      accent: colors.moment,
                    ),
                    const SizedBox(height: 10),
                    _OptionCard(
                      title: 'شاهد إعلان لـ +1 نقطة',
                      subtitle: 'حدّ أقصى 10 إعلانات يومياً',
                      icon: Icons.ondemand_video_outlined,
                      onTap: () => _watchRewardedAd(context, ref),
                      colors: colors,
                      accent: colors.crystal,
                    ),
                  ],
                  const Spacer(),
                  // ── Rematch flow — same opponent OR search a new one.
                  _RematchPanel(
                    phase: _rematchPhase,
                    secondsLeft: _rematchSecondsLeft,
                    colors: colors,
                    onAccept: _acceptRematch,
                    onSearchOther: _searchOther,
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => context.go(AppRoutes.carromLobby),
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('اللوبي'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom-of-screen rematch decision panel.
///
/// Phases:
///   * none     → two primary buttons (accept rematch / search other)
///   * waiting  → overlay with countdown showing we sent accept and are
///                waiting on the opponent
///   * declined → "opponent declined" + a single "search other" button
///   * timeout  → "window elapsed" + "search other" button
///
/// We deliberately disable the buttons during `waiting` so double-clicks
/// don't fire two accepts (the server's Redis SET is idempotent, but the
/// UI feedback matters).
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.crystal.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            const SizedBox(
              width: 32, height: 32,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 10),
            Text(
              'بانتظار قبول الخصم… ($secondsLeft ث)',
              style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.w700,
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
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: c.danger.withValues(alpha: 0.10),
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [
                c.crystal,
                c.crystal.withValues(alpha: 0.78),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            onPressed: onAccept,
            icon: const Icon(Icons.replay_rounded),
            label: const Text(
              '🔄 إعادة مع نفس الخصم',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
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
    return InkWell(
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
    );
  }
}

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
