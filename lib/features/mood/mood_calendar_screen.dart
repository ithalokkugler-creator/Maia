import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../app/responsive/responsive_page.dart';
import '../../app/responsive/window_class.dart';
import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/mood_palette.dart';
import '../../core/widgets/big_button.dart';
import '../../core/widgets/cute_card.dart';
import '../../core/widgets/mood_face.dart';
import '../../demo/demo_store.dart';
import 'mood_summary_card.dart';

/// "Humor" tab: month calendar + summary (spec 6.2.2).
class MoodCalendarScreen extends StatefulWidget {
  const MoodCalendarScreen({super.key});

  @override
  State<MoodCalendarScreen> createState() => _MoodCalendarScreenState();
}

class _MoodCalendarScreenState extends State<MoodCalendarScreen> {
  DateTime? _month; // first day of visible month

  @override
  Widget build(BuildContext context) {
    final store = DemoScope.of(context);
    final today = store.today;
    final currentMonth = DateTime(today.year, today.month);
    final month = _month ?? currentMonth;
    final canGoNext = month.isBefore(currentMonth);
    final wide = context.windowClass == WindowClass.expanded;

    final calendar = CuteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MonthHeader(
            month: month,
            canGoNext: canGoNext,
            onPrev: () =>
                setState(() => _month = DateTime(month.year, month.month - 1)),
            onNext: () =>
                setState(() => _month = DateTime(month.year, month.month + 1)),
          ),
          const SizedBox(height: AppSpacing.xs),
          _MonthGrid(month: month, store: store),
          const SizedBox(height: AppSpacing.sm),
          const _Legend(),
        ],
      ),
    );

    final summary = MoodSummaryCard(month: month, store: store);
    final consult = BigButton(
      label: 'Preparar para a consulta',
      icon: PhosphorIconsRegular.stethoscope,
      variant: BigButtonVariant.soft,
      onPressed: () {
        final m = ScaffoldMessenger.of(context);
        m.clearSnackBars();
        m.showSnackBar(
            const SnackBar(content: Text('Disponível na versão completa')));
      },
    );

    return ResponsivePage(
      title: 'Humor',
      maxWidth: wide ? AppSpacing.maxWideContentWidth : AppSpacing.maxContentWidth,
      children: [
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: calendar),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    summary,
                    const SizedBox(height: AppSpacing.md),
                    consult,
                  ],
                ),
              ),
            ],
          )
        else ...[
          calendar,
          summary,
          consult,
        ],
      ],
    );
  }
}

String _monthTitle(DateTime month) {
  final s = DateFormat('MMMM yyyy', 'pt_BR').format(month);
  return s[0].toUpperCase() + s.substring(1);
}

// --- month header -----------------------------------------------------------

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.canGoNext,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final bool canGoNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const target = BoxConstraints(
        minWidth: AppSpacing.minTarget, minHeight: AppSpacing.minTarget);
    return Row(
      children: [
        IconButton(
          tooltip: 'Mês anterior',
          constraints: target,
          onPressed: onPrev,
          icon: PhosphorIcon(PhosphorIconsRegular.caretLeft, color: colors.text),
        ),
        Expanded(
          child: Semantics(
            header: true,
            liveRegion: true,
            child: Text(
              _monthTitle(month),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Próximo mês',
          constraints: target,
          onPressed: canGoNext ? onNext : null,
          icon: PhosphorIcon(
            PhosphorIconsRegular.caretRight,
            color: canGoNext ? colors.text : colors.outlineStrong,
          ),
        ),
      ],
    );
  }
}

// --- grid -------------------------------------------------------------------

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.month, required this.store});

  final DateTime month;
  final DemoStore store;

  static const _weekdays = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
  static const _weekdayNames = [
    'domingo',
    'segunda',
    'terça',
    'quarta',
    'quinta',
    'sexta',
    'sábado'
  ];
  static const double _gap = 4;

  @override
  Widget build(BuildContext context) {
    // The grid has fixed-size cells; keep their text from outgrowing them.
    final scaler = MediaQuery.textScalerOf(context);
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.2,
      child: LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cellW = (width - _gap * 6) / 7;
        final face = (cellW * 0.58).clamp(18.0, 40.0);
        final cellH = (face + 26).clamp(AppSpacing.minTarget, 80.0);
        final theme = Theme.of(context).textTheme;
        final colors = context.colors;

        final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
        final lead = DateTime(month.year, month.month, 1).weekday % 7;
        final cells = <Widget?>[
          for (var i = 0; i < lead; i++) null,
          for (var d = 1; d <= daysInMonth; d++)
            _DayCell(
              day: DateTime(month.year, month.month, d),
              store: store,
              width: cellW,
              height: cellH,
              textScale: scaler.scale(10) / 10,
            ),
        ];
        while (cells.length % 7 != 0) {
          cells.add(null);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                for (var i = 0; i < 7; i++) ...[
                  if (i > 0) const SizedBox(width: _gap),
                  SizedBox(
                    width: cellW,
                    child: Semantics(
                      label: _weekdayNames[i],
                      excludeSemantics: true,
                      child: Text(
                        _weekdays[i],
                        textAlign: TextAlign.center,
                        style: theme.labelMedium
                            ?.copyWith(color: colors.textMuted),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: _gap),
            for (var r = 0; r < cells.length / 7; r++) ...[
              if (r > 0) const SizedBox(height: _gap),
              Row(
                children: [
                  for (var c = 0; c < 7; c++) ...[
                    if (c > 0) const SizedBox(width: _gap),
                    SizedBox(
                      width: cellW,
                      height: cellH,
                      child: cells[r * 7 + c],
                    ),
                  ],
                ],
              ),
            ],
          ],
        );
      }),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.store,
    required this.width,
    required this.height,
    required this.textScale,
  });

  final DateTime day;
  final DemoStore store;
  final double width;
  final double height;
  final double textScale;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    final today = store.today;
    final isToday = day == today;
    final isFuture = day.isAfter(today);
    final level = store.moodFor(day);
    final radius = BorderRadius.circular(AppSpacing.radiusCell);

    final dateText = DateFormat("d 'de' MMMM", 'pt_BR').format(day);
    final status = isFuture
        ? 'dia futuro'
        : level != null
            ? MoodPalette.label(level)
            : 'sem registro';
    final label = '${isToday ? 'Hoje, ' : ''}$dateText, $status';

    final Color? fill = level != null && !isFuture ? context.moodColor(level) : null;
    final Color fg = fill != null
        ? context.onMoodColor
        : isFuture
            ? colors.textMuted.withValues(alpha: 0.6)
            : colors.text;

    final showFace = fill != null;

    final border = isToday
        ? Border.all(color: colors.primary, width: 3)
        : fill == null
            ? Border.all(
                color: isFuture ? colors.outline : colors.outlineStrong,
                width: 1)
            : null;

    final content = FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${day.day}',
            style: theme.labelMedium?.copyWith(
              fontSize: 11,
              height: 1.1,
              color: fg,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          if (showFace)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: MoodFace(level: level!, size: (width * 0.58).clamp(18.0, 40.0)),
            ),
        ],
      ),
    );

    final box = DecoratedBox(
      decoration:
          BoxDecoration(color: fill, borderRadius: radius, border: border),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: content,
        ),
      ),
    );

    if (isFuture) {
      return Semantics(
        label: label,
        excludeSemantics: true,
        child: Opacity(opacity: 0.55, child: box),
      );
    }

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: () => context.push(AppRoutes.moodEntryFor(day)),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: () => context.push(AppRoutes.moodEntryFor(day)),
          child: box,
        ),
      ),
    );
  }
}

// --- legend -----------------------------------------------------------------

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colors = context.colors;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        for (var l = 1; l <= 5; l++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MoodFace(level: l, size: 20),
              const SizedBox(width: AppSpacing.xxs),
              Text(MoodPalette.label(l),
                  style: theme.bodySmall?.copyWith(color: colors.textMuted)),
            ],
          ),
      ],
    );
  }
}

