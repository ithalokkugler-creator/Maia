import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// 0 to 10 intensity picker: 11 big buttons in a wrapping grid (no slider).
/// Tapping a number answers immediately.
class IntensityScale extends StatelessWidget {
  const IntensityScale({super.key, required this.onSelected});

  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (var i = 0; i <= 10; i++)
              Semantics(
                button: true,
                label: switch (i) {
                  0 => '0, tranquilo',
                  10 => '10, insuportável',
                  _ => '$i',
                },
                excludeSemantics: true,
                child: Material(
                  color: colors.surfaceSoft,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusButton),
                    side: BorderSide(color: colors.outline),
                  ),
                  child: InkWell(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusButton),
                    onTap: () => onSelected(i),
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: Center(
                        child: Text('$i',
                            style: theme.titleMedium
                                ?.copyWith(color: colors.text)),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text('0 = tranquilo',
                  style:
                      theme.bodyMedium?.copyWith(color: colors.textMuted)),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text('10 = insuportável',
                  textAlign: TextAlign.end,
                  style:
                      theme.bodyMedium?.copyWith(color: colors.textMuted)),
            ),
          ],
        ),
      ],
    );
  }
}
