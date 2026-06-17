import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router.dart';
import '../../../../../app/theme/app_theme.dart';
import '../../application/carrom_controllers.dart';
import '../../data/carrom_api.dart';
import '../widgets/wallet_chip.dart';

/// Lobby للكيرم — العب عشوائي / تحدّى صديق / انضم بدعوة.
class CarromLobbyPage extends ConsumerStatefulWidget {
  const CarromLobbyPage({super.key});
  @override
  ConsumerState<CarromLobbyPage> createState() => _CarromLobbyPageState();
}

class _CarromLobbyPageState extends ConsumerState<CarromLobbyPage> {
  bool _busy = false;
  final _inviteCtrl = TextEditingController();

  @override
  void dispose() {
    _inviteCtrl.dispose();
    super.dispose();
  }

  Future<void> _startRandom() async {
    setState(() => _busy = true);
    try {
      // ننتقل لشاشة الـ matchmaking — هي تستدعي join تلقائياً.
      if (!mounted) return;
      context.push(AppRoutes.carromMatchmaking);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _createInvite() async {
    setState(() => _busy = true);
    try {
      final inv = await ref.read(carromApiProvider).createInvite();
      if (!mounted) return;
      _showInviteSheet(inv.inviteCode, inv.roomId);
    } on CarromApiException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر إنشاء الدعوة');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _redeemInvite() async {
    final code = _inviteCtrl.text.trim();
    if (code.isEmpty) {
      Fluttertoast.showToast(msg: 'الصق رمز الدعوة أولاً');
      return;
    }
    setState(() => _busy = true);
    try {
      final roomId = await ref.read(carromApiProvider).redeemInvite(code);
      if (!mounted) return;
      context.push(AppRoutes.carromMatch(roomId));
    } on CarromApiException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر الانضمام للدعوة');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showInviteSheet(String code, String roomId) {
    final colors = context.sarhnyColors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'رمز دعوتك',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              SelectableText(
                code,
                style: TextStyle(
                  color: colors.moment,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'صلاحية الرمز 5 دقائق. شارك الرمز مع صديقك ليدخل المباراة.',
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: code));
                        Fluttertoast.showToast(msg: 'نُسخ الرمز');
                      },
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('نسخ'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.push(AppRoutes.carromMatch(roomId));
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                      label: const Text('ادخل الغرفة'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final walletAsync = ref.watch(carromWalletProvider);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('كيرم 1v1'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'رجوع',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.feed);
            }
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: CarromWalletChip(compact: true),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.moment.withValues(alpha: 0.18),
                      colors.crystal.withValues(alpha: 0.10),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.moment.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.border),
                      ),
                      alignment: Alignment.center,
                      child: const Text('🎯', style: TextStyle(fontSize: 36)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'كيرم 1v1',
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          walletAsync.when(
                            data: (w) => Text(
                              'دخول ${w.entryFee} — الفائز يأخذ ${w.pot}',
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            loading: () => Text(
                              'جارٍ تحميل المحفظة...',
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            error: (_, __) => Text(
                              'دخول 300 — الفائز يأخذ 600',
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Live cosmetics preview chip — يعرض اختيار اللاعب الحالي
              // قبل أن يبدأ المباراة. النقر يفتح صفحة الـ picker.
              const _CosmeticsPreviewChip(),
              const SizedBox(height: 16),

              // Primary CTAs
              _PrimaryCta(
                label: 'ابدأ مباراة عشوائية',
                subtitle: 'ابحث عن منافس متاح الآن',
                icon: Icons.shuffle_rounded,
                onTap: _busy ? null : _startRandom,
                colors: colors,
              ),
              const SizedBox(height: 12),
              _PrimaryCta(
                label: 'العب مع صديق',
                subtitle: 'أنشئ رمز دعوة وشاركه',
                icon: Icons.person_add_alt_1_rounded,
                onTap: _busy ? null : _createInvite,
                colors: colors,
              ),
              const SizedBox(height: 22),

              // Redeem invite
              Text(
                'انضم بدعوة',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inviteCtrl,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 16,
                        letterSpacing: 2,
                      ),
                      decoration: InputDecoration(
                        hintText: 'الصق الرمز',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _busy ? null : _redeemInvite,
                    child: const Text('انضم'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick rules
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border.all(color: colors.border, width: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'القواعد السريعة',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._rule(colors,
                        '• اسحب من الستراكر للداخل لتصويب — كل ما طال السحب، زادت القوة'),
                    ..._rule(colors,
                        '• قطع بيضاء = 1 نقطة، سوداء = 2، الملكة = 3 (لكن لازم تغطّيها)'),
                    ..._rule(colors,
                        '• كل دور تأخذه إذا أدخلت قطعة من لونك، وتفقد الدور لو فاولت'),
                    ..._rule(colors,
                        '• الفائز يكشف لخصمه (اختياري) ويأخذ كل النقاط'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Iterable<Widget> _rule(SarhnyColors colors, String text) sync* {
    yield Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 12,
          height: 1.6,
        ),
      ),
    );
  }
}

/// Cosmetics preview + picker entry point. اللاعب يرى لمحة عن خياره
/// الحالي بدون الذهاب للصفحة الكاملة، ويضغط لتعديل التفضيلات.
class _CosmeticsPreviewChip extends ConsumerWidget {
  const _CosmeticsPreviewChip();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sarhnyColors;
    final async = ref.watch(cosmeticsResponseProvider);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push(AppRoutes.carromCosmetics),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.border, width: 0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: async.when(
          loading: () => Row(
            children: [
              Icon(Icons.palette_outlined, color: colors.moment),
              const SizedBox(width: 10),
              Text(
                'تخصيص الطاولة',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 1.6),
              ),
            ],
          ),
          error: (_, __) => Row(
            children: [
              Icon(Icons.palette_outlined, color: colors.moment),
              const SizedBox(width: 10),
              Text(
                'خصّص الطاولة والقطع والمضرب',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_left, color: colors.textSecondary),
            ],
          ),
          data: (resp) {
            final board = resp.catalog.boardByKey(resp.current.boardSkin);
            final pair = resp.catalog.pieceByKey(resp.current.pieceSkin);
            final striker =
                resp.catalog.strikerByKey(resp.current.strikerSkin);
            return Row(
              children: [
                Icon(Icons.palette_outlined, color: colors.moment),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تخصيص لعبتك',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          board?.nameAr ?? '—',
                          pair?.nameAr ?? '—',
                          striker?.nameAr ?? '—',
                        ].join(' · '),
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 11.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (board != null)
                  _CosmeticSwatch(
                    base: board.baseColor,
                    accent: board.accentColor,
                  ),
                if (pair != null) ...[
                  const SizedBox(width: 6),
                  _CosmeticSwatch(base: pair.colorA, accent: pair.colorB),
                ],
                if (striker != null) ...[
                  const SizedBox(width: 6),
                  _CosmeticSwatch(base: striker.color, accent: striker.color),
                ],
                const SizedBox(width: 6),
                Icon(Icons.chevron_left, color: colors.textSecondary),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CosmeticSwatch extends StatelessWidget {
  const _CosmeticSwatch({required this.base, required this.accent});
  final Color base;
  final Color accent;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [base, accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.20),
          width: 0.8,
        ),
      ),
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.colors,
  });
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final SarhnyColors colors;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.border, width: 0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.moment.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: colors.moment),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style:
                        TextStyle(color: colors.textSecondary, fontSize: 12),
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
