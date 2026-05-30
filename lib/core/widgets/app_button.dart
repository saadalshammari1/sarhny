import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final Color bg = switch (variant) {
      AppButtonVariant.primary => colors.moment,
      AppButtonVariant.secondary => colors.elevated,
      AppButtonVariant.ghost => Colors.transparent,
      AppButtonVariant.danger => colors.danger,
    };
    final Color fg = switch (variant) {
      AppButtonVariant.primary => Colors.black,
      AppButtonVariant.secondary => colors.textPrimary,
      AppButtonVariant.ghost => colors.textPrimary,
      AppButtonVariant.danger => Colors.white,
    };

    final child = loading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
            ],
          );

    final button = Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: loading ? null : onPressed,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: variant == AppButtonVariant.ghost
                ? Border.all(color: colors.border)
                : null,
          ),
          child: child,
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
