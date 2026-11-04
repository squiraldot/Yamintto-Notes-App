import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yamintto/app/router/app_router.dart';
import 'package:yamintto/core/theme/app_theme.dart';

void main() {
  testWidgets('unknown locations show a recoverable not-found page', (
    tester,
  ) async {
    final themeMode = ValueNotifier(YaminttoThemeMode.system);
    final router = appRouter(
      themeMode: themeMode,
      onThemeModeChanged: (mode) => themeMode.value = mode,
    );
    addTearDown(() {
      router.dispose();
      themeMode.dispose();
    });

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    router.go('/route-that-does-not-exist');
    await tester.pumpAndSettle();

    expect(find.text('Page not found'), findsOneWidget);
    expect(find.text('Go to home'), findsOneWidget);
  });
}
