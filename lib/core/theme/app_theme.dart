import 'package:flutter/material.dart';
import 'package:yamintto/core/theme/tokens/app_colors.dart';
import 'package:yamintto/core/theme/tokens/app_radii.dart';
import 'package:yamintto/core/theme/tokens/app_typography.dart';

/// Theme variants available to the app shell.
///
/// Persisting a user's selection belongs to Phase 09.
enum YaminttoThemeMode { system, light, dark, amoled }

abstract final class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.lightSeed,
      surface: AppColors.lightSurface,
    );
    return _build(colorScheme, scaffoldBackgroundColor: AppColors.lightSurface);
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.darkSeed,
      brightness: Brightness.dark,
      surface: AppColors.darkSurface,
    );
    return _build(colorScheme, scaffoldBackgroundColor: AppColors.darkSurface);
  }

  /// True-black surfaces for OLED displays; not a persisted preference yet.
  static ThemeData amoled() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.darkSeed,
      brightness: Brightness.dark,
    ).copyWith(
      surface: AppColors.amoledSurface,
      surfaceContainerLowest: AppColors.amoledSurface,
      surfaceContainerLow: AppColors.amoledSurface,
      surfaceContainer: AppColors.amoledSurface,
      surfaceContainerHigh: AppColors.amoledSurface,
      surfaceContainerHighest: AppColors.amoledSurface,
    );
    return _build(
      colorScheme,
      scaffoldBackgroundColor: AppColors.amoledSurface,
    );
  }

  static ThemeData _build(
    ColorScheme colorScheme, {
    required Color scaffoldBackgroundColor,
  }) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      textTheme: AppTypography.textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackgroundColor,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(
              alpha: isDark ? 0.35 : 0.55,
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.55 : 0.7,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        modalBackgroundColor: colorScheme.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.xl),
          ),
        ),
      ),
    );
  }
}
