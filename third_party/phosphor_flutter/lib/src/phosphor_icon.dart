import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/src/phosphor_icon_data.dart';

/// Icon widget. Duotone glyphs (font family `PhosphorDuotone`) are drawn as
/// primary + translucent secondary layer.
class PhosphorIcon extends Icon {
  const PhosphorIcon(
    IconData super.icon, {
    super.key,
    super.size,
    super.fill,
    super.weight,
    super.grade,
    super.opticalSize,
    super.color,
    super.shadows,
    super.semanticLabel,
    super.textDirection,
    this.duotoneSecondaryOpacity = 0.20,
    this.duotoneSecondaryColor,
  });

  final double duotoneSecondaryOpacity;
  final Color? duotoneSecondaryColor;

  @override
  Widget build(BuildContext context) {
    final data = icon;
    if (data != null && data.fontFamily == 'PhosphorDuotone') {
      final secondary = phosphorDuotoneSecondary[data.codePoint];
      if (secondary == null) return super.build(context);
      return Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: duotoneSecondaryOpacity,
            child: Icon(
              secondary,
              size: size,
              fill: fill,
              weight: weight,
              grade: grade,
              opticalSize: opticalSize,
              color: duotoneSecondaryColor ?? color,
              shadows: shadows,
              semanticLabel: semanticLabel,
              textDirection: textDirection,
            ),
          ),
          super.build(context),
        ],
      );
    }
    return super.build(context);
  }
}
