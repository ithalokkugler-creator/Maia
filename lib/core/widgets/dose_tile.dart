import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../demo/demo_store.dart';

/// One row of the medication checklist.
class DoseTile extends StatelessWidget {
  const DoseTile({super.key, required this.dose, required this.onToggle});

  final DemoDose dose;
  final VoidCallback onToggle;

  static String _spokenTime(String hhmm) {
    final p = hhmm.split(':');
    final h = int.parse(p[0]);
    final m = int.parse(p[1]);
    final hours = h == 1 ? '1 hora' : '$h horas';
    return m == 0 ? hours : '$hours e $m minutos';
  }

  bool _isPast() {
    final mins = dose.minutesOfDay;
    if (mins == null) return false;
    final now = DateTime.now();
    return mins < now.hour * 60 + now.minute;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    final taken = dose.taken;
    final noRecord = !taken && _isPast();

    final spoken = [
      dose.name,
      if (dose.time != null) _spokenTime(dose.time!) else 'quando necessário',
      dose.amount,
      if (dose.instruction != null && dose.time != null) dose.instruction!,
      taken
          ? 'tomado. Toque duas vezes para desmarcar'
          : 'não marcado. Toque duas vezes para marcar como tomado',
    ].join(', ');

    final bg = taken ? colors.mintContainer : colors.surfaceSoft;
    final fg = taken ? colors.onMintContainer : colors.text;

    return Semantics(
      container: true,
      button: true,
      checked: taken,
      label: spoken,
      excludeSemantics: true,
      onTap: onToggle,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusButton + 4),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onToggle,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: dose.color,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const PhosphorIcon(
                      PhosphorIconsDuotone.pill,
                      size: 22,
                      color: Color(0xFF2D2A3E),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dose.time ?? 'Quando necessário',
                          style: theme.bodySmall?.copyWith(
                            color: taken
                                ? colors.onMintContainer
                                : colors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          dose.name,
                          style: theme.titleMedium?.copyWith(color: fg),
                        ),
                        Text(
                          [
                            dose.amount,
                            if (dose.instruction != null && dose.time != null)
                              dose.instruction!,
                          ].join(' · '),
                          style: theme.bodySmall?.copyWith(
                            color: taken
                                ? colors.onMintContainer
                                : colors.textMuted,
                          ),
                        ),
                        if (noRecord)
                          Text(
                            'sem registro',
                            style: theme.bodySmall
                                ?.copyWith(color: colors.textMuted),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _CheckBox(taken: taken),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  const _CheckBox({required this.taken});
  final bool taken;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reduce = MediaQuery.disableAnimationsOf(context);
    return SizedBox(
      width: AppSpacing.minTarget,
      height: AppSpacing.minTarget,
      child: Center(
        child: AnimatedContainer(
          duration: reduce ? Duration.zero : const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: taken ? colors.mint : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: taken ? colors.mint : colors.outlineStrong,
              width: 2,
            ),
          ),
          child: taken
              ? PhosphorIcon(PhosphorIconsBold.check,
                  size: 20, color: colors.onMint)
              : null,
        ),
      ),
    );
  }
}
