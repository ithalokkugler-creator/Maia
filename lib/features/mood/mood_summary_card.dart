import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/mood_palette.dart';
import '../../core/widgets/cute_card.dart';
import '../../core/widgets/mood_face.dart';
import '../../demo/demo_store.dart';

/// Summary of the visible month: days logged, average and distribution.
class MoodSummaryCard extends StatelessWidget {
  const MoodSummaryCard({super.key, required this.month, required this.store});

  /// First day of the month.
  final DateTime month;
  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colors = context.colors;

    final counts = List<int>.filled(5, 0);
    var total = 0;
    var sum = 0;
    store.moods.forEach((day, level) {
      if (day.year == month.year && day.month == month.month) {
        counts[level.clamp(1, 5) - 1]++;
        total++;
        sum += level;
      }
    });
    final maxCount = counts.fold<int>(0, (a, b) => a > b ? a : b);
    final avg = total == 0 ? null : sum / total;
    final avgText = avg?.toStringAsFixed(1).replaceAll('.', ',');

    if (total == 0) {
      return CuteCard(
        title: 'Resumo do mês',
        child: Text(
          'Nenhum registro neste mês. Tudo bem: quando quiser, toque em um dia.',
          style: theme.bodyMedium?.copyWith(color: colors.textMuted),
        ),
      );
    }

    return CuteCard(
      title: 'Resumo do mês',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.xs,
            children: [
              _Stat(value: '$total', label: total == 1 ? 'dia registrado' : 'dias registrados'),
              _Stat(
                  value: avgText!,
                  label: 'média (de 1 a 5)',
                  semantic: 'média $avgText, de 1 a 5'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (var l = 5; l >= 1; l--)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Semantics(
                label: '${MoodPalette.label(l)}: ${counts[l - 1]} '
                    '${counts[l - 1] == 1 ? 'dia' : 'dias'}',
                excludeSemantics: true,
                child: Row(
                  children: [
                    MoodFace(level: l, size: 28),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(
                          children: [
                            Container(height: 12, color: colors.surfaceSoft),
                            FractionallySizedBox(
                              widthFactor: maxCount == 0
                                  ? 0
                                  : counts[l - 1] / maxCount,
                              child: Container(
                                  height: 12, color: context.moodColor(l)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(
                      width: 28,
                      child: Text('${counts[l - 1]}',
                          textAlign: TextAlign.end,
                          style: theme.labelLarge),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.semantic});

  final String value;
  final String label;
  final String? semantic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Semantics(
      label: semantic ?? '$value $label',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: theme.displaySmall),
          Text(label,
              style:
                  theme.bodySmall?.copyWith(color: context.colors.textMuted)),
        ],
      ),
    );
  }
}
