import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5267D8),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF9AA8FF),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }
}
