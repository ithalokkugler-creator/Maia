import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Material 3 themes built from the design tokens.
abstract final class AppTheme {
  static ThemeData light() => _build(AppColors.light, Brightness.light);
  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.primaryContainer,
      onPrimaryContainer: c.onPrimaryContainer,
      secondary: c.water,
      onSecondary: c.onWater,
      secondaryContainer: c.primaryContainer,
      onSecondaryContainer: c.onPrimaryContainer,
      tertiary: c.mint,
      onTertiary: c.onMint,
      tertiaryContainer: c.mintContainer,
      onTertiaryContainer: c.onMintContainer,
      error: c.help,
      onError: c.onHelp,
      surface: c.surface,
      onSurface: c.text,
      onSurfaceVariant: c.textMuted,
      surfaceContainerLowest: c.background,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.surface,
      surfaceContainerHigh: c.surfaceSoft,
      surfaceContainerHighest: c.surfaceSoft,
      outline: c.outlineStrong,
      outlineVariant: c.outline,
      shadow: c.primary,
      scrim: const Color(0x66000000),
    );

    final textTheme = AppTypography.textTheme(c.text);
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
    );
    const minSize = Size(AppSpacing.minTarget, AppSpacing.minTarget);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[c],
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      dividerColor: c.outline,
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(AppSpacing.minTarget, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: minSize,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: minSize,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: buttonShape,
          side: BorderSide(color: c.outlineStrong),
          foregroundColor: c.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: minSize,
          shape: buttonShape,
          foregroundColor: c.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: minSize,
          foregroundColor: c.text,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: c.outlineStrong),
        backgroundColor: c.surface,
        selectedColor: c.primaryContainer,
        labelStyle: textTheme.labelLarge,
        secondaryLabelStyle:
            textTheme.labelLarge?.copyWith(color: c.onPrimaryContainer),
        checkmarkColor: c.onPrimaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.primaryContainer,
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected ? c.onPrimaryContainer : c.textMuted,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? c.onPrimaryContainer : c.textMuted,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.primaryContainer,
        selectedIconTheme: IconThemeData(color: c.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: c.textMuted),
        selectedLabelTextStyle: textTheme.labelSmall
            ?.copyWith(color: c.onPrimaryContainer, fontWeight: FontWeight.w600),
        unselectedLabelTextStyle:
            textTheme.labelSmall?.copyWith(color: c.textMuted),
        labelType: NavigationRailLabelType.all,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: c.surface,
        showDragHandle: true,
        dragHandleColor: c.outlineStrong,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusSheet),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSheet),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.isDark ? c.surfaceSoft : c.text,
        contentTextStyle: textTheme.bodyMedium
            ?.copyWith(color: c.isDark ? c.text : c.background),
        actionTextColor: c.isDark ? c.primary : const Color(0xFFD9D2FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: textTheme.bodyMedium?.copyWith(color: c.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          borderSide: BorderSide(color: c.outlineStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          borderSide: BorderSide(color: c.outlineStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          borderSide: BorderSide(color: c.primary, width: 2),
        ),
      ),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Colors.transparent
              : c.outlineStrong,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        side: BorderSide(color: c.outlineStrong, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: DividerThemeData(color: c.outline, space: 1),
      tooltipTheme: TooltipThemeData(
        textStyle: textTheme.bodySmall?.copyWith(
          color: c.isDark ? c.text : c.background,
        ),
      ),
    );
  }
}
