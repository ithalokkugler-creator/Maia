import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../app/responsive/responsive_page.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/big_button.dart';
import '../../core/widgets/cute_card.dart';
import '../../core/widgets/dose_tile.dart';
import '../../core/widgets/maia_avatar.dart';
import '../../core/widgets/section_title.dart';
import '../../demo/demo_store.dart';
import 'add_med_sheet.dart';

/// Remédios: today's checklist, as-needed items, list and add form (spec 6.3).
class MedsScreen extends StatelessWidget {
  const MedsScreen({super.key});

  static String _dateLabel(DateTime d) {
    final s = DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(d);
    return s[0].toUpperCase() + s.substring(1);
  }

  static void _toggle(BuildContext context, DemoDose dose) {
    final store = DemoScope.read(context);
    final wasTaken = dose.taken;
    store.toggleDose(dose.id);
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(SnackBar(
      content: Text(wasTaken
          ? '${dose.name}: registro removido'
          : '${dose.name}: registrado. Que bom!'),
      action: SnackBarAction(
        label: 'Desfazer',
        onPressed: () => store.toggleDose(dose.id),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final store = DemoScope.of(context);
    final theme = Theme.of(context).textTheme;
    final colors = context.colors;

    final scheduled = store.doses.where((d) => !d.isAsNeeded).toList()
      ..sort((a, b) => a.minutesOfDay!.compareTo(b.minutesOfDay!));
    final asNeeded = store.doses.where((d) => d.isAsNeeded).toList();

    const periods = <(String, int, int)>[
      ('Madrugada', 0, 5 * 60),
      ('Manhã', 5 * 60, 12 * 60),
      ('Tarde', 12 * 60, 18 * 60),
      ('Noite', 18 * 60, 24 * 60),
    ];

    return ResponsivePage(
      title: 'Remédios',
      subtitle: _dateLabel(store.today),
      children: [
        _SummaryCard(
          taken: store.takenScheduledDoseCount,
          total: store.scheduledDoseCount,
        ),
        for (final p in periods)
          ..._periodSection(
            context,
            p.$1,
            scheduled
                .where(
                    (d) => d.minutesOfDay! >= p.$2 && d.minutesOfDay! < p.$3)
                .toList(),
          ),
        if (asNeeded.isNotEmpty) ...[
          const SectionTitle('Quando necessário'),
          for (final d in asNeeded) _AsNeededCard(dose: d),
        ],
        const SectionTitle('Meus remédios'),
        for (final d in store.doses) _MedCard(dose: d),
        BigButton(
          label: 'Adicionar remédio',
          icon: PhosphorIconsRegular.plus,
          onPressed: () => showAddMedSheet(context),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Text(
            'Em caso de dúvida sobre uma dose esquecida, fale com seu médico ou farmacêutico.',
            textAlign: TextAlign.center,
            style: theme.bodySmall?.copyWith(color: colors.textMuted),
          ),
        ),
      ],
    );
  }

  List<Widget> _periodSection(
      BuildContext context, String title, List<DemoDose> doses) {
    if (doses.isEmpty) return const [];
    return [
      SectionTitle(title),
      for (final d in doses)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: DoseTile(dose: d, onToggle: () => _toggle(context, d)),
        ),
    ];
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.taken, required this.total});
  final int taken;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    final done = total > 0 && taken >= total;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final fraction = total == 0 ? 0.0 : (taken / total).clamp(0.0, 1.0);

    return CuteCard(
      child: Semantics(
        container: true,
        label: '$taken de $total doses registradas hoje'
            '${done ? '. Cuidado em dia' : ''}',
        child: ExcludeSemantics(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$taken de $total doses registradas hoje',
                        style: theme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: fraction),
                        duration: reduce
                            ? Duration.zero
                            : const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        builder: (context, v, _) => LinearProgressIndicator(
                          value: v,
                          minHeight: 12,
                          backgroundColor: colors.mintContainer,
                          color: colors.mint,
                        ),
                      ),
                    ),
                    if (done) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text('Cuidado em dia 💜',
                          style: theme.bodyMedium
                              ?.copyWith(color: colors.textMuted)),
                    ],
                  ],
                ),
              ),
              if (done) ...[
                const SizedBox(width: AppSpacing.sm),
                const MaiaAvatar(size: 48, expression: MaiaExpression.happy),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AsNeededCard extends StatelessWidget {
  const _AsNeededCard({required this.dose});
  final DemoDose dose;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    final taken = dose.taken;
    return CuteCard(
      color: taken ? colors.mintContainer : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _PillBadge(color: dose.color),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dose.name, style: theme.titleMedium),
                    Text(dose.amount,
                        style: theme.bodyMedium?.copyWith(
                            color: taken
                                ? colors.onMintContainer
                                : colors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (taken)
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                PhosphorIcon(PhosphorIconsBold.check,
                    color: colors.onMintContainer, size: 20),
                Text('Registrado hoje',
                    style: theme.bodyMedium
                        ?.copyWith(color: colors.onMintContainer)),
                TextButton(
                  style: TextButton.styleFrom(
                      minimumSize: const Size(48, AppSpacing.minTarget)),
                  onPressed: () => MedsScreen._toggle(context, dose),
                  child: const Text('Desfazer'),
                ),
              ],
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(48, AppSpacing.minTarget),
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimaryContainer,
                ),
                onPressed: () => MedsScreen._toggle(context, dose),
                child: const Text('Tomei agora'),
              ),
            ),
        ],
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCell + 2),
        ),
        alignment: Alignment.center,
        // Pastel dose colors are always light: fixed dark glyph for contrast
        // (same choice as DoseTile).
        child: const PhosphorIcon(PhosphorIconsDuotone.pill,
            size: 24, color: Color(0xFF2D2A3E)),
      ),
    );
  }
}

class _MedCard extends StatelessWidget {
  const _MedCard({required this.dose});
  final DemoDose dose;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    final when = dose.time ?? 'quando necessário';
    final hasInstruction = dose.instruction != null && dose.time != null;
    return Semantics(
      button: true,
      label: '${dose.name}, ${dose.amount}, $when'
          '${hasInstruction ? ', ${dose.instruction}' : ''}. Ver detalhes',
      excludeSemantics: true,
      onTap: () => _open(context),
      child: CuteCard(
        onTap: () => _open(context),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSpacing.minTarget),
          child: Row(
            children: [
              _PillBadge(color: dose.color),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dose.name, style: theme.titleMedium),
                    Text('${dose.amount} · $when',
                        style: theme.bodyMedium
                            ?.copyWith(color: colors.textMuted)),
                    if (hasInstruction)
                      Text(dose.instruction!,
                          style: theme.bodySmall
                              ?.copyWith(color: colors.textMuted)),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              PhosphorIcon(PhosphorIconsRegular.caretRight,
                  color: colors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    final m = ScaffoldMessenger.of(context);
    m.clearSnackBars();
    m.showSnackBar(const SnackBar(
        content: Text('Detalhes disponíveis na versão completa')));
  }
}
