import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/providers/auth_providers.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final auth = ref.watch(authStateProvider);
    final colors = context.sarhnyColors;
    final brightness = Theme.of(context).brightness;

    ref.listen(authStateProvider, (_, next) {
      next.whenData((state) {
        if (state.status == AuthStatus.authenticated) {
          context.go(AppRoutes.feed);
        } else if (state.status == AuthStatus.unauthenticated) {
          context.go(AppRoutes.login);
        }
      });
    });

    return Scaffold(
      backgroundColor: colors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.3),
            radius: 1.4,
            colors: [
              brightness == Brightness.light
                  ? colors.moment.withValues(alpha: 0.12)
                  : colors.moment.withValues(alpha: 0.18),
              colors.background,
            ],
            stops: const [0.0, 0.7],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hero logo block
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      colors.moment,
                      colors.moment.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: colors.moment.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  'صـ',
                  style: TextStyle(
                    color: brightness == Brightness.light
                        ? Colors.white
                        : Colors.black,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              )
                  .animate()
                  .scale(
                    duration: 450.ms,
                    curve: Curves.easeOutBack,
                    begin: const Offset(0.6, 0.6),
                  )
                  .then(delay: 100.ms)
                  .shimmer(duration: 1200.ms, color: Colors.white24),
              const SizedBox(height: 28),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l.appName,
                    style: AppTypography.tajawal(
                      size: 36,
                      weight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.moment,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 500.ms)
                  .slideY(begin: 0.15, end: 0),
              const SizedBox(height: 10),
              Text(
                l.tagline,
                style: AppTypography.tajawal(
                  size: 14,
                  color: colors.textSecondary,
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
              const SizedBox(height: 56),
              if (auth.isLoading)
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.moment),
                  ),
                ).animate().fadeIn(delay: 900.ms),
            ],
          ),
        ),
      ),
    );
  }
}
