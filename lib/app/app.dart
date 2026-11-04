import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yamintto/app/router/app_router.dart';
import 'package:yamintto/core/theme/app_theme.dart';

/// Root application widget. Theme selection is in-memory only until Phase 09.
class YaminttoApp extends StatefulWidget {
  const YaminttoApp({super.key});

  @override
  State<YaminttoApp> createState() => _YaminttoAppState();
}

class _YaminttoAppState extends State<YaminttoApp> {
  late final ValueNotifier<YaminttoThemeMode> _themeMode;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _themeMode = ValueNotifier(YaminttoThemeMode.system);
    _router = appRouter(
      themeMode: _themeMode,
      onThemeModeChanged: (mode) => _themeMode.value = mode,
    );
  }

  ThemeData _darkTheme(YaminttoThemeMode mode) {
    return mode == YaminttoThemeMode.amoled
        ? AppTheme.amoled()
        : AppTheme.dark();
  }

  ThemeMode _materialThemeMode(YaminttoThemeMode mode) {
    return switch (mode) {
      YaminttoThemeMode.system => ThemeMode.system,
      YaminttoThemeMode.light => ThemeMode.light,
      YaminttoThemeMode.dark || YaminttoThemeMode.amoled => ThemeMode.dark,
    };
  }

  @override
  void dispose() {
    _router.dispose();
    _themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<YaminttoThemeMode>(
      valueListenable: _themeMode,
      builder: (context, mode, child) => MaterialApp.router(
        title: 'Yamintto',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: _darkTheme(mode),
        themeMode: _materialThemeMode(mode),
        routerConfig: _router,
      ),
    );
  }
}
