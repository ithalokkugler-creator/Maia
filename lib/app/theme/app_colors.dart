import 'package:flutter/material.dart';

/// All color tokens of the design system (spec 9.2), light and dark.
///
/// Access from any widget with `context.colors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.isDark,
    required this.background,
    required this.surface,
    required this.surfaceSoft,
    required this.outline,
    required this.outlineStrong,
    required this.text,
    required this.textMuted,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.water,
    required this.onWater,
    required this.waterContainer,
    required this.onWaterContainer,
    required this.mint,
    required this.onMint,
    required this.mintContainer,
    required this.onMintContainer,
    required this.peach,
    required this.onPeach,
    required this.peachContainer,
    required this.onPeachContainer,
    required this.help,
    required this.onHelp,
    required this.shadow,
  });

  final bool isDark;
  final Color background;
  final Color surface;
  final Color surfaceSoft;
  final Color outline;
  final Color outlineStrong;
  final Color text;
  final Color textMuted;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color water;
  final Color onWater;
  final Color waterContainer;
  final Color onWaterContainer;
  final Color mint;
  final Color onMint;
  final Color mintContainer;
  final Color onMintContainer;
  final Color peach;
  final Color onPeach;
  final Color peachContainer;
  final Color onPeachContainer;
  final Color help;
  final Color onHelp;

  /// Soft colored card shadow (transparent in dark mode).
  final Color shadow;

  static const AppColors light = AppColors(
    isDark: false,
    background: Color(0xFFFFF9F4),
    surface: Color(0xFFFFFFFF),
    surfaceSoft: Color(0xFFF6F1FF),
    outline: Color(0xFFE4DEEE),
    outlineStrong: Color(0xFF8E89A6),
    text: Color(0xFF2D2A3E),
    textMuted: Color(0xFF6B6880),
    primary: Color(0xFF5F4FD8),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFECE8FF),
    onPrimaryContainer: Color(0xFF2E2366),
    water: Color(0xFF2B78C2),
    onWater: Color(0xFFFFFFFF),
    waterContainer: Color(0xFFDCEEFF),
    onWaterContainer: Color(0xFF12406B),
    mint: Color(0xFF1F7A52),
    onMint: Color(0xFFFFFFFF),
    mintContainer: Color(0xFFDDF5EA),
    onMintContainer: Color(0xFF0F4A30),
    peach: Color(0xFFA5500F),
    onPeach: Color(0xFFFFFFFF),
    peachContainer: Color(0xFFFFE8D6),
    onPeachContainer: Color(0xFF6B3410),
    help: Color(0xFFB8325F),
    onHelp: Color(0xFFFFFFFF),
    shadow: Color(0x145F4FD8), // primary @ ~8%
  );

  static const AppColors dark = AppColors(
    isDark: true,
    background: Color(0xFF1B1926),
    surface: Color(0xFF252233),
    surfaceSoft: Color(0xFF2F2B40),
    outline: Color(0xFF3D3957),
    outlineStrong: Color(0xFF7A7594),
    text: Color(0xFFF4F1FA),
    textMuted: Color(0xFFB7B2C9),
    primary: Color(0xFFB8ACFF),
    onPrimary: Color(0xFF1F1650),
    primaryContainer: Color(0xFF3A2F7A),
    onPrimaryContainer: Color(0xFFECE8FF),
    water: Color(0xFF8CC4F5),
    onWater: Color(0xFF12406B),
    waterContainer: Color(0xFF183A5C),
    onWaterContainer: Color(0xFFDCEEFF),
    mint: Color(0xFF6CCB8F),
    onMint: Color(0xFF0F4A30),
    mintContainer: Color(0xFF173F2E),
    onMintContainer: Color(0xFFDDF5EA),
    peach: Color(0xFFF2A66B),
    onPeach: Color(0xFF3A1D0B),
    peachContainer: Color(0xFF4A2C1A),
    onPeachContainer: Color(0xFFFFE8D6),
    help: Color(0xFFF08AAB),
    onHelp: Color(0xFF1B1926),
    shadow: Color(0x00000000),
  );

  @override
  AppColors copyWith() => this; // tokens are constants

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return t < 0.5 ? this : other;
  }
}

extension AppColorsX on BuildContext {
  /// Design tokens for the current theme brightness.
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;
}
