import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../demo/demo_store.dart';

/// One chip per meal. Tap cycles the status; status is shown by icon + text.
class MealChips extends StatelessWidget {
  const MealChips({super.key, required this.store});

  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final meal in Meal.values)
          _MealChip(
            meal: meal,
            status: store.meals[meal] ?? MealStatus.none,
            onTap: () => store.cycleMeal(meal),
          ),
      ],
    );
  }
}

class _MealChip extends StatelessWidget {
  const _MealChip(
      {required this.meal, required this.status, required this.onTap});

  final Meal meal;
  final MealStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;

    final (bg, fg, icon, text) = switch (status) {
      MealStatus.none => (
          colors.surface,
          colors.textMuted,
          PhosphorIconsRegular.circle,
          'Sem registro'
        ),
      MealStatus.well => (
          colors.mintContainer,
          colors.onMintContainer,
          PhosphorIconsFill.checkCircle,
          status.label
        ),
      MealStatus.little => (
          colors.peachContainer,
          colors.onPeachContainer,
          PhosphorIconsRegular.minusCircle,
          status.label
        ),
      MealStatus.skipped => (
          colors.surfaceSoft,
          colors.text,
          PhosphorIconsRegular.prohibit,
          status.label
        ),
    };

    return Semantics(
      button: true,
      label: '${meal.label}: $text. Toque para mudar',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          side: BorderSide(
              color: status == MealStatus.none
                  ? colors.outlineStrong
                  : colors.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
                minHeight: AppSpacing.minTarget + 8,
                minWidth: AppSpacing.minTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PhosphorIcon(icon, color: fg, size: 24),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(meal.label,
                            style:
                                theme.labelLarge?.copyWith(color: colors.text)),
                        Text(text, style: theme.bodySmall?.copyWith(color: fg)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
