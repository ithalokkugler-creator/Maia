import 'package:flutter/material.dart';

/// Mood scale (spec 9.3). Levels go from 1 (Muito mal) to 5 (Muito bem).
abstract final class MoodPalette {
  static const List<String> labels = [
    'Muito mal',
    'Mal',
    'Mais ou menos',
    'Bem',
    'Muito bem',
  ];

  static const List<Color> _light = [
    Color(0xFFF38BA0), // 1
    Color(0xFFFFAE6E), // 2
    Color(0xFFFFD966), // 3
    Color(0xFFB6DD6F), // 4
    Color(0xFF6CCB8F), // 5
  ];

  static const List<Color> _dark = [
    Color(0xFFE07A90),
    Color(0xFFE89A5E),
    Color(0xFFE8C55C),
    Color(0xFFA3C963),
    Color(0xFF5DB57E),
  ];

  /// Label for [level] (1..5). Out-of-range values are clamped.
  static String label(int level) => labels[level.clamp(1, 5) - 1];

  static Color color(int level, Brightness brightness) =>
      (brightness == Brightness.dark ? _dark : _light)[level.clamp(1, 5) - 1];

  /// Text/feature color to draw on top of a mood color.
  static Color onColor(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0xFF1B1926)
      : const Color(0xFF2D2A3E);
}

extension MoodPaletteX on BuildContext {
  /// Mood color (1..5) for the current brightness.
  Color moodColor(int level) =>
      MoodPalette.color(level, Theme.of(this).brightness);

  /// Readable color for text/faces drawn over [moodColor].
  Color get onMoodColor => MoodPalette.onColor(Theme.of(this).brightness);
}
