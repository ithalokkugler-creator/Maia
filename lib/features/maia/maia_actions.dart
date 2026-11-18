import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/big_button.dart';

/// Only these numbers may ever be dialed from the Maiá screens.
const _dialable = {'188', '192'};

/// Dials 188 (CVV) or 192 (SAMU). Shows a SnackBar if the device can't.
Future<void> dialHelp(BuildContext context, String number) async {
  assert(_dialable.contains(number));
  if (!_dialable.contains(number)) return;
  final messenger = ScaffoldMessenger.of(context);
  var ok = false;
  try {
    ok = await launchUrl(Uri(scheme: 'tel', path: number));
  } catch (_) {
    ok = false;
  }
  if (!ok) {
    messenger.showSnackBar(SnackBar(
      content: Text('Não consegui abrir o telefone. Disque $number.'),
    ));
  }
}

/// Opens a maps search for CAPS near the person.
Future<void> openCaps(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  var ok = false;
  try {
    ok = await launchUrl(
      Uri.parse('https://www.google.com/maps/search/CAPS+perto+de+mim'),
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {
    ok = false;
  }
  if (!ok) {
    messenger.showSnackBar(const SnackBar(
      content: Text('Não consegui abrir o mapa. Busque "CAPS perto de mim".'),
    ));
  }
}

Widget _sheetHandle(BuildContext context) => Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colors.outlineStrong,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );

/// Demo sheet: trusted contacts live in the safety plan in the full version.
Future<void> showTrustedContactSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: false,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusSheet)),
    ),
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext).textTheme;
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetHandle(sheetContext),
              Text('Alguém de confiança', style: theme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Na versão completa, as pessoas de confiança ficam no seu plano '
                'de segurança, com botão para ligar ou mandar mensagem.',
                style: theme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Por enquanto, pense em alguém que te faz bem e chame essa pessoa. '
                'Se preferir conversar agora, o CVV atende no 188.',
                style: theme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              BigButton(
                label: 'Ligar para o CVV (188)',
                variant: BigButtonVariant.help,
                onPressed: () => dialHelp(sheetContext, '188'),
              ),
              const SizedBox(height: AppSpacing.sm),
              BigButton(
                label: 'Fechar',
                variant: BigButtonVariant.soft,
                onPressed: () => Navigator.of(sheetContext).pop(),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _PlanSection {
  const _PlanSection(this.title, this.question, this.example);
  final String title;
  final String question;
  final String example;
}

const _planSections = [
  _PlanSection(
    '1. Sinais de alerta',
    'Que pensamentos, sentimentos ou situações mostram que uma crise pode estar chegando?',
    'Exemplo: dormir muito pouco, me isolar, sentir que nada importa.',
  ),
  _PlanSection(
    '2. O que eu posso fazer por conta própria',
    'O que me acalma ou me distrai?',
    'Exemplo: tomar um banho, ouvir minha playlist, caminhar um pouco.',
  ),
  _PlanSection(
    '3. Pessoas e lugares que me distraem',
    'Com quem ou onde eu me sinto melhor?',
    'Exemplo: a casa de alguém querido, a pracinha perto de casa.',
  ),
  _PlanSection(
    '4. Pessoas a quem posso pedir ajuda',
    'Nome e telefone, com botão de ligar.',
    'Exemplo: alguém da família ou uma amizade em quem eu confio.',
  ),
  _PlanSection(
    '5. Profissionais e serviços',
    'Quem cuida de mim e onde posso buscar apoio.',
    'Exemplo: meu psicólogo ou psiquiatra, o CAPS da minha região. '
        'CVV 188 e SAMU 192 já vêm preenchidos.',
  ),
  _PlanSection(
    '6. Deixar o ambiente mais seguro',
    'O que posso afastar de mim em momentos difíceis?',
    'Exemplo: pedir a alguém de confiança para me ajudar a deixar o '
        'ambiente mais tranquilo.',
  ),
  _PlanSection(
    '7. Minhas razões',
    'O que importa para mim?',
    'Exemplo: minha família, meu bichinho, ver o mar de novo.',
  ),
];

/// Demo of the safety plan (spec 7.5): 7 expandable sections with examples.
Future<void> showSafetyPlanSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusSheet)),
    ),
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, controller) {
          final colors = context.colors;
          final theme = Theme.of(context).textTheme;
          return ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
            children: [
              _sheetHandle(context),
              Semantics(
                header: true,
                child: Text('Meu plano de segurança', style: theme.titleLarge),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Na versão completa, você preenche com calma, de preferência '
                'com quem cuida de você.',
                style: theme.bodyMedium?.copyWith(color: colors.textMuted),
              ),
              const SizedBox(height: AppSpacing.sm),
              Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: colors.outline),
                child: Column(
                  children: [
                    for (final s in _planSections)
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: const EdgeInsets.only(
                            bottom: AppSpacing.md, right: AppSpacing.xs),
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        expandedAlignment: Alignment.centerLeft,
                        title: Text(s.title, style: theme.titleMedium),
                        children: [
                          Text(s.question, style: theme.bodyLarge),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            s.example,
                            style: theme.bodyMedium
                                ?.copyWith(color: colors.textMuted),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              BigButton(
                label: 'Fechar',
                variant: BigButtonVariant.soft,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    },
  );
}
