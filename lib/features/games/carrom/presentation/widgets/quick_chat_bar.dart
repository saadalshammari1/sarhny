import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme/app_theme.dart';
import '../../application/carrom_controllers.dart';
import '../../domain/chat_preset.dart';

/// شريط 12 chat preset مع cooldown مرئي.
class CarromQuickChatBar extends ConsumerStatefulWidget {
  const CarromQuickChatBar({super.key, required this.onSend});
  final void Function(String presetKey) onSend;

  @override
  ConsumerState<CarromQuickChatBar> createState() => _CarromQuickChatBarState();
}

class _CarromQuickChatBarState extends ConsumerState<CarromQuickChatBar> {
  DateTime? _cooldownUntil;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  bool get _onCooldown {
    final cu = _cooldownUntil;
    return cu != null && cu.isAfter(DateTime.now());
  }

  void _trigger(String key, int cooldownSec) {
    if (_onCooldown) return;
    widget.onSend(key);
    setState(() {
      _cooldownUntil = DateTime.now().add(Duration(seconds: cooldownSec));
    });
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer(Duration(seconds: cooldownSec), () {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final asyncPresets = ref.watch(carromChatPresetsProvider);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border, width: 0.5)),
      ),
      child: asyncPresets.when(
        loading: () => const SizedBox(
          height: 56,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (_, __) => SizedBox(
          height: 56,
          child: Center(
            child: Text(
              'تعذّر تحميل الرسائل',
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
          ),
        ),
        data: (data) {
          final presets = data.presets;
          final cooldown = data.cooldownSeconds;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final p in presets)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _ChatPill(
                      preset: p,
                      isAr: isAr,
                      onCooldown: _onCooldown,
                      cooldownEnd: _cooldownUntil,
                      cooldownSec: cooldown,
                      onTap: () => _trigger(p.key, cooldown),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ChatPill extends StatelessWidget {
  const _ChatPill({
    required this.preset,
    required this.isAr,
    required this.onCooldown,
    required this.cooldownEnd,
    required this.cooldownSec,
    required this.onTap,
  });
  final CarromChatPreset preset;
  final bool isAr;
  final bool onCooldown;
  final DateTime? cooldownEnd;
  final int cooldownSec;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final remaining = cooldownEnd == null
        ? 0
        : cooldownEnd!.difference(DateTime.now()).inSeconds;
    final progress = onCooldown ? (remaining / cooldownSec).clamp(0.0, 1.0) : 0.0;
    return Opacity(
      opacity: onCooldown ? 0.5 : 1.0,
      child: Material(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onCooldown ? null : onTap,
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(preset.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      preset.label(isAr ? 'ar' : 'en'),
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (onCooldown)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: LinearProgressIndicator(
                        value: 1 - progress,
                        minHeight: 2,
                        backgroundColor: Colors.transparent,
                        color: colors.moment,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
