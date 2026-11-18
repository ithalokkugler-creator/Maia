import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/mood_palette.dart';
import '../../core/widgets/cute_card.dart';
import '../../core/widgets/mood_face.dart';
import '../../demo/demo_store.dart';

/// Local, unsaved draft of today's movement details.
class MovementDraft extends ChangeNotifier {
  final Set<String> types = {};
  String? duration;
  String? intensity;
  int? feeling;

  void toggleType(String t) {
    types.contains(t) ? types.remove(t) : types.add(t);
    notifyListeners();
  }

  void setDuration(String? v) {
    duration = v;
    notifyListeners();
  }

  void setIntensity(String? v) {
    intensity = v;
    notifyListeners();
  }

  void setFeeling(int? v) {
    feeling = v;
    notifyListeners();
  }
}

/// Mock movement for the six days before today, oldest first.
const List<bool> _previousMoved = [true, false, true, true, false, true];

class MovementTab extends StatelessWidget {
  const MovementTab({super.key, required this.draft});

  final MovementDraft draft;

  static const _types = [
    'Caminhada',
    'Alongamento/Yoga',
    'Academia',
    'Corrida',
    'Bicicleta',
    'Dança',
    'Esporte',
    'Tarefas ativas',
    'Outro',
  ];
  static const _durations = ['10 min', '20 min', '30 min', '45 min', '60+ min'];
  static const _intensities = ['Leve', 'Moderada', 'Intensa'];

  @override
  Widget build(BuildContext context) {
    final store = DemoScope.of(context);
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    final moved = store.movedToday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CuteCard(
          title: 'Mexeu o corpo hoje?',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  _choice(
                    context,
                    label: 'Sim',
                    icon: PhosphorIconsRegular.check,
                    selected: moved == true,
                    onTap: () => DemoScope.read(context).setMoved(true),
                  ),
                  _choice(
                    context,
                    label: 'Ainda não',
                    icon: PhosphorIconsRegular.clock,
                    selected: moved == false,
                    onTap: () => DemoScope.read(context).setMoved(false),
                  ),
                ],
              ),
              if (moved == false) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Tudo bem. Até um alongamento pequeno conta.',
                  style: theme.bodyMedium?.copyWith(color: colors.textMuted),
                ),
              ],
            ],
          ),
        ),
        if (moved == true) ...[
          const SizedBox(height: AppSpacing.md),
          ListenableBuilder(
            listenable: draft,
            builder: (context, _) => CuteCard(
              title: 'Quer contar mais? (opcional)',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(context, 'Tipo'),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final t in _types)
                        FilterChip(
                          label: Text(t),
                          selected: draft.types.contains(t),
                          onSelected: (_) => draft.toggleType(t),
                        ),
                    ],
                  ),
                  _label(context, 'Duração'),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final d in _durations)
                        ChoiceChip(
                          label: Text(d),
                          selected: draft.duration == d,
                          onSelected: (s) => draft.setDuration(s ? d : null),
                        ),
                    ],
                  ),
                  _label(context, 'Intensidade'),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final i in _intensities)
                        ChoiceChip(
                          label: Text(i),
                          selected: draft.intensity == i,
                          onSelected: (s) => draft.setIntensity(s ? i : null),
                        ),
                    ],
                  ),
                  _label(context, 'Como se sentiu depois?'),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (var l = 1; l <= 5; l++)
                        _FeelingButton(
                          level: l,
                          selected: draft.feeling == l,
                          onTap: () =>
                              draft.setFeeling(draft.feeling == l ? null : l),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        CuteCard(
          title: 'Esta semana',
          child: _WeekDots(
            todayMoved: moved == true,
            today: store.today,
          ),
        ),
      ],
    );
  }

  static Widget _label(BuildContext context, String t) => Padding(
        padding: const EdgeInsets.only(
            top: AppSpacing.md, bottom: AppSpacing.xs),
        child: Semantics(
          header: true,
          child: Text(t, style: Theme.of(context).textTheme.labelLarge),
        ),
      );

  static Widget _choice(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    return ChoiceChip(
      avatar: Icon(selected ? PhosphorIconsBold.check : icon, size: 18),
      label: Text(label),
      showCheckmark: false,
      selected: selected,
      selectedColor: colors.mintContainer,
      labelStyle: TextStyle(
        color: selected ? colors.onMintContainer : colors.text,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      onSelected: (_) => onTap(),
    );
  }
}

class _FeelingButton extends StatelessWidget {
  const _FeelingButton({
    required this.level,
    required this.selected,
    required this.onTap,
  });

  final int level;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Me senti ${MoodPalette.label(level)}',
      excludeSemantics: true,
      onTap: onTap,
      child: InkResponse(
        onTap: onTap,
        radius: 30,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
              minWidth: AppSpacing.minTarget, minHeight: AppSpacing.minTarget),
          child: Center(
            child: MoodFace(level: level, size: 40, selected: selected),
          ),
        ),
      ),
    );
  }
}

class _WeekDots extends StatelessWidget {
  const _WeekDots({required this.todayMoved, required this.today});

  final bool todayMoved;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    final days = [
      for (var i = 6; i >= 0; i--) today.subtract(Duration(days: i)),
    ];
    final moved = [..._previousMoved, todayMoved];
    final count = moved.where((m) => m).length;
    final names = [
      for (var i = 0; i < 7; i++)
        '${DateFormat('EEEE', 'pt_BR').format(days[i])}: '
            '${moved[i] ? 'mexeu o corpo' : 'sem registro'}',
    ].join('. ');

    return Semantics(
      container: true,
      label: 'Movimento esta semana: $count de 7 dias. $names',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                moved[i] ? colors.mint : Colors.transparent,
                            border: Border.all(
                              color: moved[i]
                                  ? colors.mint
                                  : colors.outlineStrong,
                              width: i == 6 ? 2.5 : 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: moved[i]
                              ? PhosphorIcon(PhosphorIconsBold.check,
                                  size: 18, color: colors.onMint)
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          DateFormat('EEEE', 'pt_BR')
                              .format(days[i])[0]
                              .toUpperCase(),
                          style: theme.labelMedium?.copyWith(
                            color: i == 6 ? colors.text : colors.textMuted,
                            fontWeight:
                                i == 6 ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Qualquer movimento conta 💜',
              textAlign: TextAlign.center,
              style: theme.bodyMedium?.copyWith(color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
