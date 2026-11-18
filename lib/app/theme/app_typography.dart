import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Poppins type scale (spec 9.4). Sizes scale with the system text scaler.
///
/// Mapping onto Material [TextTheme]:
/// - display  (28/600)  -> `displaySmall`   (big numbers)
/// - headline (22/600)  -> `headlineSmall`  (screen title; also `titleLarge`)
/// - title    (18/600)  -> `titleMedium`    (card title)
/// - bodyLarge(18/400)  -> `bodyLarge`      (Maiá text, crisis mode)
/// - body     (16/400)  -> `bodyMedium`     (default text)
/// - label    (14/500)  -> `labelLarge`     (buttons, chips; also `labelMedium`)
/// - caption  (13/400)  -> `bodySmall`      (support text)
abstract final class AppTypography {
  static TextTheme textTheme(Color text) {
    TextStyle s(double size, FontWeight w, {double? height}) =>
        GoogleFonts.poppins(
          fontSize: size,
          fontWeight: w,
          color: text,
          height: height ?? 1.4,
        );
    return TextTheme(
      displaySmall: s(28, FontWeight.w600, height: 1.2),
      headlineSmall: s(22, FontWeight.w600, height: 1.3),
      titleLarge: s(22, FontWeight.w600, height: 1.3),
      titleMedium: s(18, FontWeight.w600, height: 1.35),
      titleSmall: s(14, FontWeight.w500),
      bodyLarge: s(18, FontWeight.w400, height: 1.5),
      bodyMedium: s(16, FontWeight.w400, height: 1.5),
      bodySmall: s(13, FontWeight.w400),
      labelLarge: s(14, FontWeight.w500),
      labelMedium: s(14, FontWeight.w500),
      labelSmall: s(12, FontWeight.w500),
    );
  }
}
