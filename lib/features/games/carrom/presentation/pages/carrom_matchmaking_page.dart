import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router.dart';
import '../../../../../app/theme/app_theme.dart';
import '../../application/carrom_match_state.dart';

/// شاشة الانتظار — تستدعي join تلقائياً وتنتقل عند matched.
class CarromMatchmakingPage extends ConsumerStatefulWidget {
  const CarromMatchmakingPage({super.key});
  @override
  ConsumerState<CarromMatchmakingPage> createState() =>
      _CarromMatchmakingPageState();
}

class _CarromMatchmakingPageState extends ConsumerState<CarromMatchmakingPage>
    with TickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void initState() {
    super.initState();
    // أطلق البحث بعد الإطار الأول (after providers initialize).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(carromMatchmakingControllerProvider.notifier).start();
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final snap = ref.watch(carromMatchmakingControllerProvider);

    // matched → navigate
    ref.listen<CarromMatchmakingSnapshot>(
      carromMatchmakingControllerProvider,
      (prev, next) {
        final id = next.roomId;
        if (id != null && (prev?.roomId == null)) {
          context.pushReplacement(AppRoutes.carromMatch(id));
        }
      },
    );

    final elapsed = snap.elapsedSeconds;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.topStart,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 28),
                  onPressed: () async {
                    await ref
                        .read(carromMatchmakingControllerProvider.notifier)
                        .cancel();
                    if (context.mounted) context.pop();
                  },
                ),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _pulse,
                builder: (ctx, _) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      for (var i = 0; i < 3; i++)
                        Opacity(
                          opacity: (1 - ((_pulse.value + i / 3) % 1)),
                          child: Container(
                            width: 120 + ((_pulse.value + i / 3) % 1) * 140,
                            height: 120 + ((_pulse.value + i / 3) % 1) * 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.moment.withValues(alpha: 0.6),
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
                        child: const Text('🎯',
                            style: TextStyle(fontSize: 52)),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 40),
              Text(
                snap.error != null
                    ? 'تعذّر البحث عن منافس'
                    : 'البحث عن منافس...',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                snap.queuePosition != null
                    ? 'ترتيبك في الطابور: ${snap.queuePosition}'
                    : (snap.error ?? 'متوسط الانتظار أقل من 30 ثانية'),
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${(elapsed ~/ 60).toString().padLeft(2, '0')}:${(elapsed % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: colors.crystal,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                ),
              ),
              if (elapsed > 30) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border.all(color: colors.border, width: 0.6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'الانتظار طال؟',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'مباراة ضد الكمبيوتر — قريباً',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref
                        .read(carromMatchmakingControllerProvider.notifier)
                        .cancel();
                    if (context.mounted) context.pop();
                  },
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('إلغاء البحث'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
