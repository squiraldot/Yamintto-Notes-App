import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yamintto/app/app.dart';
import 'package:yamintto/features/folders/presentation/folder_browser_screen.dart';
import 'package:yamintto/features/foundation/presentation/foundation_screen.dart';
import 'package:yamintto/features/foundation/presentation/splash_screen.dart';

void main() {
  testWidgets('shows splash first and navigates to the folder browser', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: YaminttoApp()));
    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(FolderBrowserScreen), findsOneWidget);
  });

  testWidgets('keeps the existing theme preview available', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: YaminttoApp()));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Appearance preview'));
    await tester.pumpAndSettle();
    expect(find.byType(FoundationScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('theme-mode-selector')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('theme-mode-selector')));
    await tester.pumpAndSettle();
    expect(find.text('AMOLED'), findsWidgets);
    await tester.tap(find.text('AMOLED').last);
    await tester.pumpAndSettle();
    final theme = Theme.of(tester.element(find.byType(FoundationScreen)));
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, Colors.black);
  });
}
