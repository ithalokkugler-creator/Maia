import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/responsive/responsive_page.dart';
import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/big_button.dart';
import '../../core/widgets/help_bar.dart';
import '../../core/widgets/maia_avatar.dart';
import 'maia_actions.dart';

/// Emergency screen: calm but unmistakable. Only 188 and 192 are dialable.
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    final hint = theme.bodyMedium?.copyWith(color: colors.textMuted);

    return ResponsivePage(
      title: 'Vamos pedir ajuda agora',
      spacing: AppSpacing.sm,
      bottom: const HelpBar(),
      children: [
        const Center(child: MaiaAvatar(size: 88, expression: MaiaExpression.caring)),
        Text(
          'Você não precisa passar por isso sem ajuda.',
          style: theme.bodyLarge?.copyWith(color: colors.text),
        ),
        const SizedBox(height: AppSpacing.xs),
        BigButton(
          label: 'Ligar para o SAMU (192)',
          variant: BigButtonVariant.help,
          onPressed: () => dialHelp(context, '192'),
        ),
        Text('Se você está em perigo agora ou já se machucou',
            textAlign: TextAlign.center, style: hint),
        const SizedBox(height: AppSpacing.xs),
        BigButton(
          label: 'Ligar para o CVV (188)',
          variant: BigButtonVariant.help,
          onPressed: () => dialHelp(context, '188'),
        ),
        Text('Conversa e apoio emocional, 24 horas, ligação gratuita',
            textAlign: TextAlign.center, style: hint),
        const SizedBox(height: AppSpacing.xs),
        BigButton(
          label: 'Encontrar um CAPS perto de mim',
          variant: BigButtonVariant.soft,
          onPressed: () => openCaps(context),
        ),
        BigButton(
          label: 'Falar com alguém de confiança',
          variant: BigButtonVariant.soft,
          onPressed: () => showTrustedContactSheet(context),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.maia);
            }
          },
          style: TextButton.styleFrom(
            minimumSize:
                const Size(double.infinity, AppSpacing.minTarget),
            foregroundColor: colors.text,
          ),
          child: Text('Estou em um lugar seguro agora',
              textAlign: TextAlign.center, style: theme.bodyLarge),
        ),
      ],
    );
  }
}
