import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../app/responsive/responsive_page.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import 'meals_tab.dart';
import 'movement_tab.dart';
import 'water_tab.dart';

/// Hábitos: Água | Movimento | Alimentação (spec 6.4).
class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  int _tab = 0;

  // Local (unsaved) drafts live here so they survive tab switches.
  final MovementDraft _movement = MovementDraft();
  final MealNotes _notes = MealNotes();

  @override
  void dispose() {
    _movement.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePage(
      title: 'Hábitos',
      children: [
        _HabitTabs(
          selected: _tab,
          onSelected: (i) => setState(() => _tab = i),
        ),
        switch (_tab) {
          0 => const WaterTab(),
          1 => MovementTab(draft: _movement),
          _ => MealsTab(notes: _notes),
        },
      ],
    );
  }
}

class _HabitTabs extends StatelessWidget {
  const _HabitTabs({required this.selected, required this.onSelected});
  final int selected;
  final ValueChanged<int> onSelected;

  static const _items = <(String, IconData)>[
    ('Água', PhosphorIconsRegular.drop),
    ('Movimento', PhosphorIconsRegular.personSimpleWalk),
    ('Alimentação', PhosphorIconsRegular.forkKnife),
  ];

  @override
  Widget build(BuildContext context) {
    final big = MediaQuery.textScalerOf(context).scale(14) > 19;
    final tabs = [
      for (var i = 0; i < _items.length; i++)
        _Segment(
          label: _items[i].$1,
          icon: _items[i].$2,
          selected: selected == i,
          stacked: !big,
          onTap: () => onSelected(i),
        ),
    ];
    return Semantics(
      container: true,
      label: 'Escolha o hábito',
      child: big
          // Large text: stack the tabs vertically so nothing overflows.
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final t in tabs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: t,
                  ),
              ],
            )
          : Row(
              children: [
                for (var i = 0; i < tabs.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.xs),
                  Expanded(child: tabs[i]),
                ],
              ],
            ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.stacked,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool stacked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    final bg = selected ? colors.primaryContainer : colors.surface;
    final fg = selected ? colors.onPrimaryContainer : colors.text;
    final text = Text(
      label,
      textAlign: TextAlign.center,
      style: theme.labelLarge?.copyWith(
        color: fg,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
    final iconW = PhosphorIcon(
      selected ? _filled(icon) : icon,
      size: 24,
      color: fg,
    );
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          side: BorderSide(
            color: selected ? colors.primary : colors.outline,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
              child: stacked
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [iconW, const SizedBox(height: 2), text],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        iconW,
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(child: text),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  static IconData _filled(IconData regular) {
    if (regular == PhosphorIconsRegular.drop) return PhosphorIconsFill.drop;
    if (regular == PhosphorIconsRegular.personSimpleWalk) {
      return PhosphorIconsFill.personSimpleWalk;
    }
    return PhosphorIconsFill.forkKnife;
  }
}
