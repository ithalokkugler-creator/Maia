import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// Slim bar "Ajuda agora: [CVV 188] [SAMU 192]" that dials with one tap.
class HelpBar extends StatelessWidget {
  const HelpBar({super.key});

  static Future<void> _call(String number) async {
    try {
      await launchUrl(Uri(scheme: 'tel', path: number));
    } catch (_) {
      // Demo: ignore platforms without a dialer (e.g. desktop/web).
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surfaceSoft,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                Text('Ajuda agora:',
                    style: Theme.of(context).textTheme.labelLarge),
                _HelpButton(
                  label: 'CVV 188',
                  semantic: 'Ligar para o CVV, 188',
                  onTap: () => _call('188'),
                ),
                _HelpButton(
                  label: 'SAMU 192',
                  semantic: 'Ligar para o SAMU, 192',
                  onTap: () => _call('192'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HelpButton extends StatelessWidget {
  const _HelpButton({
    required this.label,
    required this.semantic,
    required this.onTap,
  });

  final String label;
  final String semantic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: semantic,
      excludeSemantics: true,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: colors.help,
          foregroundColor: colors.onHelp,
          minimumSize: const Size(AppSpacing.minTarget, AppSpacing.minTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: colors.onHelp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
