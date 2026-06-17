import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';

/// Hub لاختيار اللعبة — كيرم نشط، لودو placeholder.
class GamesHubPage extends ConsumerWidget {
  const GamesHubPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sarhnyColors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('الألعاب'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.feed);
            }
          },
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _GameCard(
              title: 'كيرم 1v1',
              subtitle: 'تحدّى منافساً مجهولاً — اربح نقاطه',
              emoji: '🎯',
              available: true,
              onTap: () => context.push(AppRoutes.carromLobby),
              colors: colors,
            ),
            const SizedBox(height: 12),
            _GameCard(
              title: 'تحدّى صريح',
              subtitle: 'حجر/ورقة/مقص + سؤال صراحة',
              emoji: '🃏',
              available: true,
              onTap: () => context.push(AppRoutes.gameLobby),
              colors: colors,
            ),
            const SizedBox(height: 12),
            _GameCard(
              title: 'لودو',
              subtitle: 'قريباً',
              emoji: '🎲',
              available: false,
              onTap: null,
              colors: colors,
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.available,
    required this.onTap,
    required this.colors,
  });
  final String title;
  final String subtitle;
  final String emoji;
  final bool available;
  final VoidCallback? onTap;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: available ? 1 : 0.5,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border, width: 0.6),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colors.elevated,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 32)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
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
              if (available)
                Icon(Icons.chevron_left, color: colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
