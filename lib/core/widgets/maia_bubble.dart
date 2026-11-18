import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import 'maia_avatar.dart';

/// Maiá avatar + speech bubble with a little tail.
class MaiaBubble extends StatelessWidget {
  const MaiaBubble({
    super.key,
    required this.text,
    this.expression = MaiaExpression.calm,
    this.avatarSize = 56,
  });

  final String text;
  final MaiaExpression expression;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label: 'Maiá diz: $text',
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MaiaAvatar(size: avatarSize, expression: expression),
            const SizedBox(width: AppSpacing.sm + 2),
            Flexible(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: colors.surfaceSoft,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusBubble),
                    ),
                    child: Text(text, style: theme.bodyLarge),
                  ),
                  Positioned(
                    left: -2,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Transform.rotate(
                        angle: math.pi / 4,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors.surfaceSoft,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
