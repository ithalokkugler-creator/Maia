import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

enum BigButtonVariant { primary, soft, help }

/// Full-width button, min height 56.
class BigButton extends StatelessWidget {
  const BigButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.variant = BigButtonVariant.primary,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final BigButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (bg, fg) = switch (variant) {
      BigButtonVariant.primary => (colors.primary, colors.onPrimary),
      BigButtonVariant.soft => (colors.primaryContainer, colors.onPrimaryContainer),
      BigButtonVariant.help => (colors.help, colors.onHelp),
    };
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
          textStyle: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 24),
              const SizedBox(width: AppSpacing.xs),
            ],
            Flexible(child: Text(label, textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}
