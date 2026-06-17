import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme/app_theme.dart';
import '../../application/carrom_controllers.dart';

/// Chip أنيق يعرض رصيد النقاط — clickable يفتح modal بشرح كيفية الكسب.
class CarromWalletChip extends ConsumerWidget {
  const CarromWalletChip({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(carromWalletProvider);
    final colors = context.sarhnyColors;
    return GestureDetector(
      onTap: () => _openModal(context, ref),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 14,
          vertical: compact ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: colors.crystal.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: colors.crystal.withValues(alpha: 0.4),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '✦',
              style: TextStyle(
                color: colors.crystal,
                fontSize: compact ? 14 : 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            wallet.when(
              data: (w) => Text(
                '${w.points}',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: compact ? 13 : 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              loading: () => SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: colors.crystal,
                ),
              ),
              error: (_, __) => Text(
                '--',
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openModal(BuildContext context, WidgetRef ref) {
    final colors = context.sarhnyColors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Consumer(builder: (ctx, ref, _) {
            final wallet = ref.watch(carromWalletProvider);
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                Center(
                  child: wallet.when(
                    data: (w) => Column(
                      children: [
                        Text(
                          '✦ ${w.points}',
                          style: TextStyle(
                            color: colors.crystal,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'رصيدك الحالي',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text(
                      'تعذّر تحميل الرصيد',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _row(colors, '💬', 'كل رسالة صراحة تستقبلها', '+2'),
                _row(colors, '📺', 'مشاهدة إعلان قصير', '+1'),
                _row(colors, '🏆', 'الفوز في مباراة كيرم', '+300'),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('حسناً'),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _row(SarhnyColors colors, String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: colors.textPrimary, fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: colors.crystal,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
