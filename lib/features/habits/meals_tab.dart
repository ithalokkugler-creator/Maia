import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/cute_card.dart';
import '../../demo/demo_store.dart';

/// Local (unsaved) per-meal note controllers.
class MealNotes {
  final Map<Meal, TextEditingController> _controllers = {
    for (final m in Meal.values) m: TextEditingController(),
  };

  TextEditingController of(Meal m) => _controllers[m]!;

  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
  }
}

class MealsTab extends StatelessWidget {
  const MealsTab({super.key, required this.notes});

  final MealNotes notes;

  static IconData _mealIcon(Meal m) => switch (m) {
        Meal.breakfast => PhosphorIconsRegular.coffee,
        Meal.lunch => PhosphorIconsRegular.forkKnife,
        Meal.snack => PhosphorIconsRegular.cookie,
        Meal.dinner => PhosphorIconsRegular.bowlSteam,
      };

  static IconData _statusIcon(MealStatus s) => switch (s) {
        MealStatus.well => PhosphorIconsRegular.smiley,
        MealStatus.little => PhosphorIconsRegular.smileyMeh,
        MealStatus.skipped => PhosphorIconsRegular.minusCircle,
        MealStatus.none => PhosphorIconsRegular.circle,
      };

  @override
  Widget build(BuildContext context) {
    final store = DemoScope.of(context);
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Aqui é só para lembrar de se alimentar. Sem contar calorias.',
          style: theme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        for (final meal in Meal.values) ...[
          CuteCard(
            title: meal.label,
            leading: PhosphorIcon(_mealIcon(meal),
                color: colors.onPeachContainer, size: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final s in const [
                      MealStatus.well,
                      MealStatus.little,
                      MealStatus.skipped,
                    ])
                      _statusChip(
                        context,
                        status: s,
                        selected: (store.meals[meal] ?? MealStatus.none) == s,
                        onTap: () {
                          final cur = store.meals[meal] ?? MealStatus.none;
                          DemoScope.read(context)
                              .setMeal(meal, cur == s ? MealStatus.none : s);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: notes.of(meal),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Anotação (opcional)',
                    semanticCounterText: null,
                    prefixIcon: Icon(PhosphorIconsRegular.pencilSimple,
                        color: colors.textMuted, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(48, AppSpacing.minTarget),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          ),
          onPressed: () {
            final m = ScaffoldMessenger.of(context);
            m.clearSnackBars();
            m.showSnackBar(const SnackBar(
                content: Text(
                    'Na demo, as configurações não estão disponíveis ainda')));
          },
          child: Text(
            'Não quer acompanhar isso? Dá para desligar nas configurações.',
            style: theme.bodyMedium?.copyWith(
              color: colors.primary,
              decoration: TextDecoration.underline,
              decorationColor: colors.primary,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _statusChip(
    BuildContext context, {
    required MealStatus status,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    return ChoiceChip(
      avatar: Icon(
        selected ? PhosphorIconsBold.check : _statusIcon(status),
        size: 18,
        color: selected ? colors.onPeachContainer : colors.text,
      ),
      label: Text(status.label),
      showCheckmark: false,
      selected: selected,
      selectedColor: colors.peachContainer,
      side: BorderSide(
        color: selected ? colors.peach : colors.outline,
        width: selected ? 2 : 1,
      ),
      labelStyle: TextStyle(
        color: selected ? colors.onPeachContainer : colors.text,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      onSelected: (_) => onTap(),
    );
  }
}
