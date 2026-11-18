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
import '../../core/widgets/cute_card.dart';
import '../../core/widgets/dose_tile.dart';
import '../../core/widgets/maia_avatar.dart';
import '../../core/widgets/maia_bubble.dart';
import '../../core/widgets/mood_face.dart';
import '../../core/widgets/mood_picker.dart';
import '../../core/widgets/water_bottle.dart';
import '../../demo/demo_store.dart';
import 'meal_chips.dart';

/// "Hoje" tab: a gentle summary of the day with quick actions (spec 6.1).
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = DemoScope.of(context);
    final hour = DateTime.now().hour;
    final stack = context.shouldStackColumns;

    final water = _WaterCard(store: store, stacked: stack);
    final movement = _MovementCard(store: store);

    return ResponsivePage(
      children: [
        _Header(store: store, hour: hour),
        MaiaBubble(
          text: _phrase(hour),
          expression: hour >= 21 || hour < 5
              ? MaiaExpression.caring
              : MaiaExpression.calm,
        ),
        _MoodCard(store: store),
        _MedsCard(store: store),
        if (stack) ...[
          water,
          movement,
        ] else
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: water),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: movement),
              ],
            ),
          ),
        CuteCard(
          title: 'Refeições',
          child: MealChips(store: store),
        ),
        const _MaiaFooter(),
      ],
    );
  }

  static String _phrase(int hour) {
    if (hour < 5) return 'Está tarde. Se puder, descansar já ajuda.';
    if (hour < 12) return 'Que bom te ver por aqui. Um passo de cada vez.';
    if (hour < 18) return 'Como está sendo o seu dia? Sem pressa.';
    return 'Hoje já foi bastante. Cuidar de você inclui descansar.';
  }
}

void _snack(
  BuildContext context,
  String text, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final m = ScaffoldMessenger.of(context);
  m.clearSnackBars();
  m.showSnackBar(SnackBar(
    content: Text(text),
    action: actionLabel == null
        ? null
        : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
  ));
}

// --- header -----------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.store, required this.hour});

  final DemoStore store;
  final int hour;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colors = context.colors;
    final greeting = hour < 5
        ? 'Boa noite'
        : hour < 12
            ? 'Bom dia'
            : hour < 18
                ? 'Boa tarde'
                : 'Boa noite';
    final date = DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(store.today);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text('$greeting, ${store.nickname}',
                    style: theme.displaySmall),
              ),
              Text(date,
                  style: theme.bodyMedium?.copyWith(color: colors.textMuted)),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Aparência',
          constraints: const BoxConstraints(
              minWidth: AppSpacing.minTarget, minHeight: AppSpacing.minTarget),
          icon: PhosphorIcon(PhosphorIconsRegular.gear, color: colors.text),
          onPressed: () => _showAppearance(context),
        ),
      ],
    );
  }

  void _showAppearance(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) => const _AppearanceSheet(),
    );
  }
}

class _AppearanceSheet extends StatelessWidget {
  const _AppearanceSheet();

  @override
  Widget build(BuildContext context) {
    final store = DemoScope.of(context);
    final theme = Theme.of(context).textTheme;
    final colors = context.colors;
    const options = [
      (ThemeMode.system, 'Sistema', 'Segue o ajuste do aparelho'),
      (ThemeMode.light, 'Claro', 'Fundo claro e suave'),
      (ThemeMode.dark, 'Escuro', 'Mais confortável à noite'),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text('Aparência', style: theme.titleLarge),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final (mode, label, hint) in options)
            Semantics(
              button: true,
              selected: store.themeMode == mode,
              label: '$label. $hint',
              excludeSemantics: true,
              onTap: () => store.setThemeMode(mode),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                onTap: () => store.setThemeMode(mode),
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(minHeight: AppSpacing.minTarget + 8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(label, style: theme.bodyLarge),
                              Text(hint,
                                  style: theme.bodySmall
                                      ?.copyWith(color: colors.textMuted)),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: store.themeMode == mode
                              ? PhosphorIcon(PhosphorIconsFill.checkCircle,
                                  color: colors.primary, size: 28)
                              : PhosphorIcon(PhosphorIconsRegular.circle,
                                  color: colors.outlineStrong, size: 28),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- mood -------------------------------------------------------------------

class _MoodCard extends StatelessWidget {
  const _MoodCard({required this.store});

  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final mood = store.todayMood;

    if (mood != null) {
      return CuteCard(
        title: 'Como você está?',
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            MoodFace(level: mood, size: 48),
            Text(MoodPalette.label(mood), style: theme.titleMedium),
            TextButton.icon(
              style: TextButton.styleFrom(
                  minimumSize:
                      const Size(AppSpacing.minTarget, AppSpacing.minTarget)),
              onPressed: () => context.push(AppRoutes.moodEntryFor(store.today)),
              icon: const PhosphorIcon(PhosphorIconsRegular.pencilSimple,
                  size: 20),
              label: const Text('Editar'),
            ),
          ],
        ),
      );
    }

    return CuteCard(
      title: 'Como você está?',
      child: MoodPicker(
        value: null,
        onChanged: (level) {
          store.setMood(store.today, level);
          _snack(
            context,
            'Que bom que você registrou.',
            actionLabel: 'Detalhes',
            onAction: () => context.push(AppRoutes.moodEntryFor(store.today)),
          );
        },
      ),
    );
  }
}

// --- meds -------------------------------------------------------------------

class _MedsCard extends StatelessWidget {
  const _MedsCard({required this.store});

  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colors = context.colors;
    final doses = store.doses.where((d) => !d.isAsNeeded).toList()
      ..sort((a, b) => a.minutesOfDay!.compareTo(b.minutesOfDay!));
    final total = store.scheduledDoseCount;
    final taken = store.takenScheduledDoseCount;

    return CuteCard(
      title: 'Remédios de hoje',
      trailing: Semantics(
        label: '$taken de $total tomados',
        excludeSemantics: true,
        child: Text('$taken de $total',
            style: theme.labelLarge?.copyWith(color: colors.textMuted)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (doses.isEmpty)
            Text('Nada agendado para hoje.',
                style: theme.bodyMedium?.copyWith(color: colors.textMuted)),
          for (final d in doses) ...[
            DoseTile(dose: d, onToggle: () => _toggle(context, d)),
            const SizedBox(height: AppSpacing.xs),
          ],
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              style: TextButton.styleFrom(
                  minimumSize:
                      const Size(AppSpacing.minTarget, AppSpacing.minTarget)),
              onPressed: () => context.go(AppRoutes.meds),
              child: const Text('Ver todos'),
            ),
          ),
        ],
      ),
    );
  }

  void _toggle(BuildContext context, DemoDose d) {
    final s = DemoScope.read(context);
    final wasTaken = d.taken;
    s.toggleDose(d.id);
    _snack(
      context,
      wasTaken ? 'Desmarcado: ${d.name}' : 'Marcado como tomado: ${d.name}',
      actionLabel: 'Desfazer',
      onAction: () => s.toggleDose(d.id),
    );
  }
}

// --- water ------------------------------------------------------------------

class _WaterCard extends StatelessWidget {
  const _WaterCard({required this.store, required this.stacked});

  final DemoStore store;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colors = context.colors;
    final amount =
        '${formatLiters(store.waterMl)} de ${formatLiters(store.waterGoalMl)} L';

    final bottle =
        WaterBottle(ml: store.waterMl, goalMl: store.waterGoalMl, height: 104);
    final info = Column(
      crossAxisAlignment:
          stacked ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(amount,
            textAlign: stacked ? TextAlign.start : TextAlign.center,
            style: theme.titleMedium?.copyWith(color: colors.text)),
        const SizedBox(height: AppSpacing.xs),
        FilledButton.tonal(
          style: FilledButton.styleFrom(
            minimumSize: const Size(AppSpacing.minTarget, AppSpacing.minTarget),
            backgroundColor: colors.waterContainer,
            foregroundColor: colors.onWaterContainer,
          ),
          onPressed: () {
            store.addWater(250);
            _snack(
              context,
              'Mais um copo. Obrigado por se cuidar.',
              actionLabel: 'Desfazer',
              onAction: store.undoWater,
            );
          },
          child: const Text('+250 ml'),
        ),
      ],
    );

    return CuteCard(
      title: 'Água',
      child: stacked
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                bottle,
                const SizedBox(width: AppSpacing.md),
                Expanded(child: info),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                bottle,
                const SizedBox(height: AppSpacing.xs),
                info,
              ],
            ),
    );
  }
}

// --- movement ---------------------------------------------------------------

class _MovementCard extends StatelessWidget {
  const _MovementCard({required this.store});

  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colors = context.colors;
    final moved = store.movedToday;
    const target = Size(AppSpacing.minTarget, AppSpacing.minTarget);

    Widget body;
    if (moved == null) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Mexeu o corpo hoje?', style: theme.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: target),
            onPressed: () {
              store.setMoved(true);
              _snack(context, 'Que bom! Seu corpo agradece.');
            },
            child: const Text('Sim'),
          ),
          const SizedBox(height: AppSpacing.xs),
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: target),
            onPressed: () => store.setMoved(false),
            child: const Text('Ainda não'),
          ),
        ],
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PhosphorIcon(
                moved
                    ? PhosphorIconsFill.checkCircle
                    : PhosphorIconsRegular.heart,
                color: moved ? colors.onMintContainer : colors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  moved
                      ? 'Que bom! Seu corpo agradece.'
                      : 'Tudo bem. Se der vontade, um alongamento já ajuda.',
                  style: theme.bodyMedium?.copyWith(
                      color: moved ? colors.onMintContainer : colors.text),
                ),
              ),
            ],
          ),
          TextButton(
            style: TextButton.styleFrom(minimumSize: target),
            onPressed: () => store.setMoved(!moved),
            child: Text(moved ? 'Mudar para ainda não' : 'Mudar para sim'),
          ),
        ],
      );
    }

    return CuteCard(
      title: 'Movimento',
      color: moved == true ? colors.mintContainer : null,
      child: body,
    );
  }
}

// --- footer -----------------------------------------------------------------

class _MaiaFooter extends StatelessWidget {
  const _MaiaFooter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colors = context.colors;
    return Semantics(
      button: true,
      label: 'Precisa de ajuda? Fale com o Maiá',
      excludeSemantics: true,
      onTap: () => context.go(AppRoutes.maia),
      child: Material(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.go(AppRoutes.maia),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(minHeight: AppSpacing.minTarget + 8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              child: Row(
                children: [
                  const MaiaAvatar(size: 36, expression: MaiaExpression.caring),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Precisa de ajuda? ',
                        style: theme.bodyMedium
                            ?.copyWith(color: colors.textMuted),
                        children: [
                          TextSpan(
                            text: 'Fale com o Maiá',
                            style: theme.bodyMedium?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PhosphorIcon(PhosphorIconsRegular.caretRight,
                      color: colors.textMuted, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
