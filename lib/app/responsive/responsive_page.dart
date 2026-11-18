import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'window_class.dart';

/// Scrollable page: SafeArea, side padding by window class (12/16/24),
/// content centered with a max width (default 560).
///
/// [children] are stacked in a column separated by [spacing].
/// [bottom] is pinned under the scroll area (e.g. a `HelpBar`).
class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    super.key,
    required this.children,
    this.title,
    this.subtitle,
    this.titleTrailing,
    this.maxWidth = AppSpacing.maxContentWidth,
    this.spacing = AppSpacing.md,
    this.bottom,
    this.backgroundColor,
  });

  final List<Widget> children;

  /// Optional screen title (headline style, announced as a header).
  final String? title;
  final String? subtitle;
  final Widget? titleTrailing;
  final double maxWidth;
  final double spacing;

  /// Pinned below the scrolling content.
  final Widget? bottom;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    final gutter = AppSpacing.gutter(context.windowClass);

    final all = <Widget>[
      if (title != null)
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(title!, style: theme.headlineSmall),
              ),
            ),
            ?titleTrailing,
          ],
        ),
      if (subtitle != null)
        Text(subtitle!,
            style: theme.bodyMedium?.copyWith(color: colors.textMuted)),
      ...children,
    ];
    final spaced = <Widget>[];
    for (var i = 0; i < all.length; i++) {
      if (i > 0) spaced.add(SizedBox(height: spacing));
      spaced.add(all[i]);
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    gutter, AppSpacing.md, gutter, AppSpacing.xxl),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: spaced,
                    ),
                  ),
                ),
              ),
            ),
            ?bottom,
          ],
        ),
      ),
    );
  }
}
