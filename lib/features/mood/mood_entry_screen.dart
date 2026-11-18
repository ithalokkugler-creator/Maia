import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../app/responsive/window_class.dart';
import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/big_button.dart';
import '../../core/widgets/cute_card.dart';
import '../../core/widgets/maia_avatar.dart';
import '../../core/widgets/mood_picker.dart';
import '../../demo/demo_store.dart';

const _emotions = [
  'Ansiedade',
  'Tristeza',
  'Irritação',
  'Medo',
  'Culpa',
  'Solidão',
  'Cansaço',
  'Vazio',
  'Calma',
  'Alegria',
  'Gratidão',
  'Esperança',
  'Motivação',
  'Confusão',
];
const _emotionsShown = 10;
const _anxietyLevels = ['Nenhuma', 'Leve', 'Moderada', 'Forte'];
const _energyLevels = ['Muito baixa', 'Baixa', 'Média', 'Alta', 'Muito alta'];
const _sleepQuality = ['Ruim', 'Ok', 'Boa'];
const _tags = [
  'Trabalho',
  'Estudos',
  'Família',
  'Relacionamento',
  'Amizades',
  'Saúde',
  'Dinheiro',
  'Sono ruim',
  'Outro',
];

/// Full-screen mood registration for a day (spec 6.2.1).
/// Extra fields are local state only (demo).
class MoodEntryScreen extends StatefulWidget {
  const MoodEntryScreen({super.key, this.day});

  /// Day being registered (null = today).
  final DateTime? day;

  @override
  State<MoodEntryScreen> createState() => _MoodEntryScreenState();
}

class _MoodEntryScreenState extends State<MoodEntryScreen> {
  int? _mood;
  bool _moodInit = false;
  final Set<String> _selectedEmotions = {};
  bool _allEmotions = false;
  int? _anxiety;
  int? _energy;
  double _sleepHours = 7;
  int? _quality;
  final Set<String> _selectedTags = {};
  final TextEditingController _note = TextEditingController();
  bool _forConsult = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.today);
    }
  }

  void _save(DemoStore store, DateTime day) {
    final messenger = ScaffoldMessenger.of(context);
    store.setMood(day, _mood!);
    _close();
    messenger.clearSnackBars();
    messenger
        .showSnackBar(const SnackBar(content: Text('Registro salvo 💜')));
  }

  @override
  Widget build(BuildContext context) {
    final store = DemoScope.read(context);
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    final day = DemoStore.dateOnly(widget.day ?? store.today);
    final isToday = day == store.today;
    if (!_moodInit) {
      _mood = store.moodFor(day);
      _moodInit = true;
    }
    final dateText = isToday
        ? 'Hoje'
        : DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(day);
    final expression = switch (_mood) {
      1 || 2 => MaiaExpression.caring,
      4 || 5 => MaiaExpression.happy,
      _ => MaiaExpression.calm,
    };
    final gutter = AppSpacing.gutter(context.windowClass);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Fechar',
          constraints: const BoxConstraints(
              minWidth: AppSpacing.minTarget, minHeight: AppSpacing.minTarget),
          icon: PhosphorIcon(PhosphorIconsRegular.x, color: colors.text),
          onPressed: _close,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                    gutter, AppSpacing.xs, gutter, AppSpacing.xl),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                        maxWidth: AppSpacing.maxContentWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child:
                              MaiaAvatar(size: 96, expression: expression),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Semantics(
                          header: true,
                          child: Text('Como você está?',
                              textAlign: TextAlign.center,
                              style: theme.headlineSmall),
                        ),
                        Text(dateText,
                            textAlign: TextAlign.center,
                            style: theme.bodyMedium
                                ?.copyWith(color: colors.textMuted)),
                        const SizedBox(height: AppSpacing.md),
                        CuteCard(
                          child: MoodPicker(
                            value: _mood,
                            onChanged: (v) => setState(() => _mood = v),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _optional(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _SaveBar(
              enabled: _mood != null,
              onSave: () => _save(store, day),
              gutter: gutter,
            ),
          ],
        ),
      ),
    );
  }

  Widget _optional(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colors = context.colors;
    final shown = _allEmotions ? _emotions : _emotions.take(_emotionsShown);

    return CuteCard(
      title: 'Quer contar mais? (opcional)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Label('Emoções'),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xxs,
            children: [
              for (final e in shown)
                _MultiChip(
                  label: e,
                  selected: _selectedEmotions.contains(e),
                  onChanged: (v) => setState(() =>
                      v ? _selectedEmotions.add(e) : _selectedEmotions.remove(e)),
                ),
              TextButton(
                style: TextButton.styleFrom(
                    minimumSize: const Size(
                        AppSpacing.minTarget, AppSpacing.minTarget)),
                onPressed: () => setState(() => _allEmotions = !_allEmotions),
                child: Text(_allEmotions ? 'ver menos' : 'ver mais'),
              ),
            ],
          ),
          _Label('Ansiedade'),
          _SingleChoice(
            options: _anxietyLevels,
            value: _anxiety,
            onChanged: (v) => setState(() => _anxiety = v),
          ),
          _Label('Energia'),
          _SingleChoice(
            options: _energyLevels,
            value: _energy,
            onChanged: (v) => setState(() => _energy = v),
          ),
          _Label('Sono'),
          _SleepStepper(
            hours: _sleepHours,
            onChanged: (v) => setState(() => _sleepHours = v),
          ),
          const SizedBox(height: AppSpacing.xs),
          _SingleChoice(
            options: _sleepQuality,
            value: _quality,
            onChanged: (v) => setState(() => _quality = v),
          ),
          _Label('O que marcou o dia'),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xxs,
            children: [
              for (final t in _tags)
                _MultiChip(
                  label: t,
                  selected: _selectedTags.contains(t),
                  onChanged: (v) => setState(
                      () => v ? _selectedTags.add(t) : _selectedTags.remove(t)),
                ),
            ],
          ),
          _Label('Anotação'),
          TextField(
            controller: _note,
            minLines: 3,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            style: theme.bodyMedium,
            decoration: InputDecoration(
              labelText: 'Anotação — só você vê',
              alignLabelWithHint: true,
              filled: true,
              fillColor: colors.surfaceSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                borderSide: BorderSide(color: colors.outlineStrong),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          MergeSemantics(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
              onTap: () => setState(() => _forConsult = !_forConsult),
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(minHeight: AppSpacing.minTarget),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('Levar para a consulta',
                          style: theme.bodyLarge),
                    ),
                    Switch(
                      value: _forConsult,
                      onChanged: (v) => setState(() => _forConsult = v),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
      child: Semantics(
        header: true,
        child: Text(text, style: Theme.of(context).textTheme.labelLarge),
      ),
    );
  }
}

class _MultiChip extends StatelessWidget {
  const _MultiChip(
      {required this.label, required this.selected, required this.onChanged});

  final String label;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: true,
      onSelected: onChanged,
      selectedColor: colors.primaryContainer,
      checkmarkColor: colors.onPrimaryContainer,
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: selected ? colors.onPrimaryContainer : colors.text),
      side: BorderSide(color: selected ? colors.primary : colors.outlineStrong),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}

class _SingleChoice extends StatelessWidget {
  const _SingleChoice(
      {required this.options, required this.value, required this.onChanged});

  final List<String> options;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xxs,
      children: [
        for (var i = 0; i < options.length; i++)
          ChoiceChip(
            label: Text(options[i]),
            selected: value == i,
            showCheckmark: true,
            onSelected: (v) => onChanged(v ? i : null),
            selectedColor: colors.primaryContainer,
            checkmarkColor: colors.onPrimaryContainer,
            labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: value == i ? colors.onPrimaryContainer : colors.text),
            side: BorderSide(
                color: value == i ? colors.primary : colors.outlineStrong),
            materialTapTargetSize: MaterialTapTargetSize.padded,
          ),
      ],
    );
  }
}

class _SleepStepper extends StatelessWidget {
  const _SleepStepper({required this.hours, required this.onChanged});

  final double hours;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final text = '${hours.toStringAsFixed(1).replaceAll('.', ',')} h';
    const target = BoxConstraints(
        minWidth: AppSpacing.minTarget, minHeight: AppSpacing.minTarget);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.xs,
      children: [
        IconButton.filledTonal(
          tooltip: 'Diminuir meia hora',
          constraints: target,
          onPressed: hours > 0 ? () => onChanged(hours - 0.5) : null,
          icon: const PhosphorIcon(PhosphorIconsBold.minus),
        ),
        Semantics(
          liveRegion: true,
          label: 'Horas de sono: $text',
          excludeSemantics: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 72),
            child: Text(text,
                textAlign: TextAlign.center, style: theme.titleMedium),
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Aumentar meia hora',
          constraints: target,
          onPressed: hours < 14 ? () => onChanged(hours + 0.5) : null,
          icon: const PhosphorIcon(PhosphorIconsBold.plus),
        ),
      ],
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar(
      {required this.enabled, required this.onSave, required this.gutter});

  final bool enabled;
  final VoidCallback onSave;
  final double gutter;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    return Material(
      color: colors.surface,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colors.outline))),
        padding: EdgeInsets.fromLTRB(gutter, AppSpacing.sm, gutter, AppSpacing.sm),
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (enabled)
                  BigButton(label: 'Salvar', onPressed: onSave)
                else ...[
                  FilledButton(
                    onPressed: null,
                    style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56)),
                    child: const Text('Salvar'),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Escolha uma carinha para poder salvar.',
                      textAlign: TextAlign.center,
                      style: theme.bodySmall
                          ?.copyWith(color: colors.textMuted)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
