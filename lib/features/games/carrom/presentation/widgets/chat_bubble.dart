import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme/app_theme.dart';
import '../../application/carrom_controllers.dart';
import '../../application/carrom_match_state.dart';

/// Bubble عائم يظهر آخر رسالة chat من الخصم — يختفي تلقائياً بعد 3 ثوان.
class CarromChatBubble extends ConsumerWidget {
  const CarromChatBubble({super.key, required this.chat});
  final IncomingChat chat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sarhnyColors;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final asyncPresets = ref.watch(carromChatPresetsProvider);
    return asyncPresets.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (data) {
        final p = data.presets.firstWhere(
          (e) => e.key == chat.presetKey,
          orElse: () => data.presets.isNotEmpty
              ? data.presets.first
              : throw StateError('no presets'),
        );
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Container(
            key: ValueKey(chat.ts.millisecondsSinceEpoch),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.border, width: 0.6),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(p.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  p.label(isAr ? 'ar' : 'en'),
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
