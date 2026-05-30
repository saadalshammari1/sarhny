import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/widgets/app_loading.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);

    ref.listen(authStateProvider, (_, next) {
      next.whenData((state) {
        if (state.status == AuthStatus.authenticated) {
          context.go(AppRoutes.feed);
        } else if (state.status == AuthStatus.unauthenticated) {
          context.go(AppRoutes.login);
        }
      });
    });

    final colors = context.sarhnyColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'صارحني',
                  style: AppTypography.tajawal(
                    size: 36,
                    weight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                const SarhnyDotLogo(size: 12),
              ],
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
            const SizedBox(height: 12),
            Text(
              'تعبير أصيل عن الذات',
              style: AppTypography.tajawal(
                size: 14,
                color: colors.textSecondary,
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
            if (auth.isLoading) ...[
              const SizedBox(height: 60),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2, color: colors.moment),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
