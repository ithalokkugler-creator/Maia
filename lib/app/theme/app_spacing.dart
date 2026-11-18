import '../responsive/window_class.dart';

/// Spacing scale (base 4), radii and sizes (spec 9.5).
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;

  static const double radiusCard = 24;
  static const double radiusButton = 16;
  static const double radiusSheet = 28;
  static const double radiusCell = 12;
  static const double radiusBubble = 20;

  /// Minimum touch target.
  static const double minTarget = 48;

  /// Max width for single-column content.
  static const double maxContentWidth = 560;

  /// Max width for two-column layouts.
  static const double maxWideContentWidth = 1040;

  /// Page side margin by window class (12 / 16 / 24).
  static double gutter(WindowClass c) => switch (c) {
        WindowClass.minimal || WindowClass.compact => 12,
        WindowClass.regular => 16,
        WindowClass.expanded => 24,
      };
}
