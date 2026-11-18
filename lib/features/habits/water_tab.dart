import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/cute_card.dart';
import '../../core/widgets/water_bottle.dart';
import '../../demo/demo_store.dart';

/// Mock water totals (ml) for the six days before today, oldest first.
const List<int> _previousWaterMl = [1800, 2100, 1500, 1900, 2000, 1250];

class WaterTab extends StatelessWidget {
  const WaterTab({super.key});

  @override
  Widget build(BuildContext context) {
    final store = DemoScope.of(context);
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    final width = MediaQuery.sizeOf(context).width;
    final bottleHeight = math.min(260.0, width * 0.6);
    final goalLabel = formatLiters(store.waterGoalMl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CuteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: WaterBottle(
                  ml: store.waterMl,
                  goalMl: store.waterGoalMl,
                  height: bottleHeight,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Semantics(
                label:
                    '${formatLiters(store.waterMl)} de $goalLabel litros hoje',
                child: ExcludeSemantics(
                  child: Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(children: [
                      TextSpan(
                        text: formatLiters(store.waterMl),
                        style: theme.displaySmall,
                      ),
                      TextSpan(
                        text: ' de $goalLabel litros',
                        style: theme.bodyLarge
                            ?.copyWith(color: colors.textMuted),
                      ),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final ml in const [150, 250, 500])
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(48, AppSpacing.minTarget),
                        backgroundColor: colors.waterContainer,
                        foregroundColor: colors.onWaterContainer,
                      ),
                      onPressed: () => DemoScope.read(context).addWater(ml),
                      icon: const Icon(PhosphorIconsBold.plus, size: 18),
                      label: Text('$ml ml'),
                    ),
                ],
              ),
              if (store.canUndoWater)
                Align(
                  alignment: Alignment.center,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                        minimumSize: const Size(48, AppSpacing.minTarget)),
                    onPressed: () => DemoScope.read(context).undoWater(),
                    icon: const Icon(PhosphorIconsRegular.arrowCounterClockwise,
                        size: 18),
                    label: const Text('Desfazer último'),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        CuteCard(
          title: 'Esta semana',
          child: _WeekBars(
            todayMl: store.waterMl,
            goalMl: store.waterGoalMl,
            today: store.today,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Ajuste a meta conforme a orientação de saúde que você recebeu.',
          style: theme.bodySmall?.copyWith(color: colors.textMuted),
        ),
      ],
    );
  }
}

class _WeekBars extends StatelessWidget {
  const _WeekBars({
    required this.todayMl,
    required this.goalMl,
    required this.today,
  });

  final int todayMl;
  final int goalMl;
  final DateTime today;

  static const double _chartHeight = 120;
  static const double _iconRoom = 22;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    final reduce = MediaQuery.disableAnimationsOf(context);

    final values = [..._previousWaterMl, todayMl];
    final days = [
      for (var i = 6; i >= 0; i--) today.subtract(Duration(days: i)),
    ];
    final maxV = math.max(goalMl * 1.2, values.reduce(math.max).toDouble());

    final summary = [
      for (var i = 0; i < 7; i++)
        '${_weekdayName(days[i])}: ${formatLiters(values[i])} litros'
            '${values[i] >= goalMl ? ', meta atingida' : ''}',
    ].join('. ');

    return Semantics(
      container: true,
      label: 'Água esta semana. $summary',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: _chartHeight,
              child: CustomPaint(
                painter: _GoalLinePainter(
                  fraction: goalMl / maxV,
                  reserve: _iconRoom,
                  color: colors.textMuted,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: _iconRoom,
                                child: values[i] >= goalMl
                                    ? Center(
                                        child: PhosphorIcon(
                                            PhosphorIconsFill.drop,
                                            size: 16,
                                            color: colors.water))
                                    : null,
                              ),
                              FractionallySizedBox(
                                widthFactor: 0.5,
                                child: AnimatedContainer(
                              duration: reduce
                                  ? Duration.zero
                                  : const Duration(milliseconds: 300),
                              height: math.max(
                                  4,
                                  (_chartHeight - _iconRoom) *
                                      values[i] /
                                      maxV),
                              decoration: BoxDecoration(
                                color: colors.water,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8)),
                                border: i == 6
                                    ? Border.all(
                                        color: colors.text, width: 1.5)
                                    : null,
                              ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Text(
                      _initial(days[i]),
                      textAlign: TextAlign.center,
                      style: theme.labelMedium?.copyWith(
                        color: i == 6 ? colors.text : colors.textMuted,
                        fontWeight:
                            i == 6 ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Linha tracejada: meta de ${formatLiters(goalMl)} litros. '
              'Gota acima da barra: meta atingida.',
              style: theme.bodySmall?.copyWith(color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  static String _weekdayName(DateTime d) =>
      DateFormat('EEEE', 'pt_BR').format(d);

  static String _initial(DateTime d) =>
      DateFormat('EEEE', 'pt_BR').format(d)[0].toUpperCase();
}

class _GoalLinePainter extends CustomPainter {
  _GoalLinePainter(
      {required this.fraction, required this.color, required this.reserve});

  final double fraction;
  final double reserve;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height - (size.height - reserve) * fraction.clamp(0.0, 1.0);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    const dash = 6.0;
    const gap = 5.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
          Offset(x, y), Offset(math.min(x + dash, size.width), y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_GoalLinePainter old) =>
      old.fraction != fraction ||
      old.color != color ||
      old.reserve != reserve;
}
