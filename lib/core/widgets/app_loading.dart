import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/app_theme.dart';

/// نقطة ذهبية تنبض — شعار صارحني المتحرك.
class SarhnyDotLogo extends StatelessWidget {
  const SarhnyDotLogo({super.key, this.size = 14});
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.moment,
        boxShadow: [
          BoxShadow(
            color: colors.moment.withValues(alpha: 0.45),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.15, 1.15), duration: 1100.ms, curve: Curves.easeInOut);
  }
}

class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SarhnyDotLogo(size: 18),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: context.textStyles.bodyMedium),
          ],
        ],
      ),
    );
  }
}
