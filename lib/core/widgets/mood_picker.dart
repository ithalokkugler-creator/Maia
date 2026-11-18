import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/mood_palette.dart';
import 'mood_face.dart';

/// Row of 5 mood faces. Sizes adapt to the available width; every tap target
/// is at least 48dp. Labels: under every face when there is room, otherwise a
/// single label line under the selected one.
class MoodPicker extends StatelessWidget {
  const MoodPicker({
    super.key,
    this.value,
    required this.onChanged,
    this.showLabels = true,
  });

  final int? value;
  final ValueChanged<int> onChanged;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colors = context.colors;
    final scale = MediaQuery.textScalerOf(context).scale(10) / 10;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final slot = width / 5;
        final face = (slot - 10).clamp(36.0, 56.0);
        final target = (face + 12).clamp(48.0, 72.0);
        final allLabels = showLabels && slot >= 84 && scale <= 1.2;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var level = 1; level <= 5; level++)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: value == level,
                      label: 'Humor $level, ${MoodPalette.label(level)}',
                      excludeSemantics: true,
                      onTap: () => onChanged(level),
                      child: InkResponse(
                        onTap: () => onChanged(level),
                        radius: slot / 2,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: target),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: target,
                                child: Center(
                                  child: MoodFace(
                                    level: level,
                                    size: face,
                                    selected: value == level,
                                  ),
                                ),
                              ),
                              if (allLabels)
                                Text(
                                  MoodPalette.label(level),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: theme.bodySmall?.copyWith(
                                    color: value == level
                                        ? colors.text
                                        : colors.textMuted,
                                    fontWeight: value == level
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (showLabels && !allLabels && value != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  MoodPalette.label(value!),
                  textAlign: TextAlign.center,
                  style: theme.labelLarge,
                ),
              ),
          ],
        );
      },
    );
  }
}
