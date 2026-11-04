import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yamintto/core/theme/app_theme.dart';
import 'package:yamintto/features/foundation/presentation/foundation_screen.dart';
import 'package:yamintto/features/foundation/presentation/splash_screen.dart';

GoRouter appRouter({
  required ValueListenable<YaminttoThemeMode> themeMode,
  required ValueChanged<YaminttoThemeMode> onThemeModeChanged,
}) {
  return GoRouter(
    initialLocation: '/splash',
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'foundation',
        builder: (context, state) => ValueListenableBuilder<YaminttoThemeMode>(
          valueListenable: themeMode,
          builder: (context, mode, child) => FoundationScreen(
            themeMode: mode,
            onThemeModeChanged: onThemeModeChanged,
          ),
        ),
      ),
    ],
    errorBuilder: (context, state) => const _NotFoundScreen(),
  );
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.route_outlined, size: 40),
              const SizedBox(height: 12),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Go to home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
