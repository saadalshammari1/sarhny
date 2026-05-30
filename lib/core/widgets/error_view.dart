import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import 'app_button.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: colors.danger),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: context.textStyles.bodyLarge),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              AppButton(
                label: 'إعادة المحاولة',
                onPressed: onRetry,
                variant: AppButtonVariant.secondary,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
