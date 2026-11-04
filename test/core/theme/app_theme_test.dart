import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yamintto/core/theme/app_theme.dart';
import 'package:yamintto/core/theme/tokens/app_sizes.dart';
import 'package:yamintto/core/theme/tokens/app_spacing.dart';

void main() {
  group('AppTheme', () {
    test('provides Material 3 light and dark themes', () {
      expect(AppTheme.light().useMaterial3, isTrue);
      expect(AppTheme.dark().useMaterial3, isTrue);
      expect(AppTheme.light().brightness, Brightness.light);
      expect(AppTheme.dark().brightness, Brightness.dark);
    });

    test('provides a true-black AMOLED surface', () {
      final theme = AppTheme.amoled();

      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, Colors.black);
      expect(theme.colorScheme.surface, Colors.black);
    });
  });

  test('spacing tokens follow the documented four-point scale', () {
    expect(AppSpacing.xs, 4);
    expect(AppSpacing.sm, 8);
    expect(AppSpacing.md, 16);
    expect(AppSpacing.lg, 24);
    expect(AppSpacing.xl, 32);
  });

  test('sizing tokens preserve minimum touch target guidance', () {
    expect(AppSizes.buttonMinHeight, 48);
    expect(AppSizes.minimumTouchTarget, 48);
  });
}
