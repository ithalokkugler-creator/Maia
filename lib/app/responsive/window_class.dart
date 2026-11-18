import 'package:flutter/widgets.dart';

/// Width classes (spec 10.1).
enum WindowClass { minimal, compact, regular, expanded }

extension WindowClassX on BuildContext {
  WindowClass get windowClass {
    final w = MediaQuery.sizeOf(this).width;
    if (w < 320) return WindowClass.minimal;
    if (w < 360) return WindowClass.compact;
    if (w < 600) return WindowClass.regular;
    return WindowClass.expanded;
  }

  /// True when two side-by-side cards should stack (width < 360 or text scale > 1.3).
  bool get shouldStackColumns =>
      MediaQuery.sizeOf(this).width < 360 ||
      MediaQuery.textScalerOf(this).scale(10) / 10 > 1.3;
}
