import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// Standard rounded card: radius 24, soft colored shadow (light) / none (dark).
class CuteCard extends StatelessWidget {
  const CuteCard({
    super.key,
    this.title,
    this.leading,
    this.trailing,
    required this.child,
    this.color,
    this.onTap,
  });

  final String? title;
  final Widget? leading;
  final Widget? trailing;
  final Widget child;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(AppSpacing.radiusCard);
    final hasHeader = title != null || leading != null || trailing != null;

    final content = Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasHeader) ...[
            Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: AppSpacing.xs),
                ],
                if (title != null)
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        title!,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  LayoutBuilder(
                    builder: (context, _) => ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: (MediaQuery.sizeOf(context).width -
                                2 * AppSpacing.md -
                                2 * AppSpacing.md) *
                            0.45,
                      ),
                      child: trailing!,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          child,
        ],
      ),
    );

    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: colors.isDark
              ? null
              : [
                  BoxShadow(
                    color: colors.shadow,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: color ?? colors.surface,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: onTap == null
              ? content
              : InkWell(onTap: onTap, child: content),
        ),
      ),
    );
  }
}
