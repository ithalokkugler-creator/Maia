import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/big_button.dart';

/// Opens the (mock) "Adicionar remédio" form. Nothing is saved in the demo.
Future<void> showAddMedSheet(BuildContext context) {
  final messenger = ScaffoldMessenger.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusSheet)),
    ),
    builder: (sheetContext) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, controller) => _AddMedForm(
        controller: controller,
        onSave: () {
          Navigator.of(sheetContext).pop();
          messenger.clearSnackBars();
          messenger.showSnackBar(const SnackBar(
              content: Text('Na demo, o cadastro não é salvo')));
        },
      ),
    ),
  );
}

class _AddMedForm extends StatefulWidget {
  const _AddMedForm({required this.controller, required this.onSave});
  final ScrollController controller;
  final VoidCallback onSave;

  @override
  State<_AddMedForm> createState() => _AddMedFormState();
}

class _AddMedFormState extends State<_AddMedForm> {
  static const _units = ['comprimido', 'cápsula', 'mg', 'ml', 'gotas'];
  static const _forms = <(String, IconData)>[
    ('Comprimido', PhosphorIconsRegular.pill),
    ('Cápsula', PhosphorIconsRegular.firstAidKit),
    ('Gotas', PhosphorIconsRegular.eyedropper),
    ('Líquido', PhosphorIconsRegular.flask),
    ('Injeção', PhosphorIconsRegular.syringe),
    ('Adesivo', PhosphorIconsRegular.bandaids),
  ];
  static const _freqs = [
    'Todo dia',
    'Dias da semana',
    'A cada X dias',
    'Quando necessário',
  ];

  String _unit = _units.first;
  String _form = _forms.first.$1;
  String _freq = _freqs.first;
  final List<String> _times = ['08:00'];
  int _color = 0;
  bool _insistent = false;

  Future<void> _addTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (t == null || !mounted) return;
    final s =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    if (!_times.contains(s)) setState(() => _times.add(s));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    final swatches = <(String, Color)>[
      ('Lilás', colors.primaryContainer),
      ('Azul', colors.waterContainer),
      ('Menta', colors.mintContainer),
      ('Pêssego', colors.peachContainer),
      ('Lilás forte', colors.primary),
      ('Azul forte', colors.water),
      ('Menta forte', colors.mint),
      ('Pêssego forte', colors.peach),
    ];

    Widget label(String t) => Padding(
          padding: const EdgeInsets.only(
              top: AppSpacing.md, bottom: AppSpacing.xs),
          child:
              Semantics(header: true, child: Text(t, style: theme.titleMedium)),
        );

    return ListView(
      controller: widget.controller,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.viewInsetsOf(context).bottom,
      ),
      children: [
        Text('Adicionar remédio', style: theme.titleLarge),
        label('Nome'),
        const TextField(
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: 'Nome do remédio'),
        ),
        label('Dose'),
        const TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: 'Quantidade (número)'),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final u in _units)
              ChoiceChip(
                label: Text(u),
                selected: _unit == u,
                onSelected: (_) => setState(() => _unit = u),
              ),
          ],
        ),
        label('Forma'),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final f in _forms)
              ChoiceChip(
                avatar: Icon(f.$2, size: 18),
                label: Text(f.$1),
                selected: _form == f.$1,
                onSelected: (_) => setState(() => _form = f.$1),
              ),
          ],
        ),
        label('Frequência'),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final f in _freqs)
              ChoiceChip(
                label: Text(f),
                selected: _freq == f,
                onSelected: (_) => setState(() => _freq = f),
              ),
          ],
        ),
        if (_freq != 'Quando necessário') ...[
          label('Horários'),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final t in _times)
                InputChip(
                  label: Text(t),
                  onDeleted: _times.length > 1
                      ? () => setState(() => _times.remove(t))
                      : null,
                  deleteButtonTooltipMessage: 'Remover horário $t',
                ),
              ActionChip(
                avatar: const Icon(PhosphorIconsRegular.plus, size: 18),
                label: const Text('Adicionar horário'),
                onPressed: _addTime,
              ),
            ],
          ),
        ],
        label('Instruções'),
        const TextField(
          textCapitalization: TextCapitalization.sentences,
          decoration:
              InputDecoration(hintText: 'Ex.: em jejum, depois do almoço'),
        ),
        label('Cor'),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (var i = 0; i < swatches.length; i++)
              Semantics(
                button: true,
                selected: _color == i,
                label: 'Cor ${swatches[i].$1}',
                excludeSemantics: true,
                onTap: () => setState(() => _color = i),
                child: InkResponse(
                  onTap: () => setState(() => _color = i),
                  radius: 28,
                  child: SizedBox(
                    width: AppSpacing.minTarget,
                    height: AppSpacing.minTarget,
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: swatches[i].$2,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _color == i
                                ? colors.text
                                : colors.outlineStrong,
                            width: _color == i ? 3 : 1,
                          ),
                        ),
                        child: _color == i
                            ? Icon(PhosphorIconsBold.check,
                                size: 20, color: colors.text)
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Lembrete insistente', style: theme.bodyLarge),
          subtitle: Text('Se não houver registro em 30 min, lembra de novo.',
              style: theme.bodySmall?.copyWith(color: colors.textMuted)),
          value: _insistent,
          onChanged: (v) => setState(() => _insistent = v),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Cadastre exatamente como seu médico orientou. O app não sugere doses.',
          style: theme.bodySmall?.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: AppSpacing.md),
        BigButton(label: 'Salvar', onPressed: widget.onSave),
      ],
    );
  }
}
