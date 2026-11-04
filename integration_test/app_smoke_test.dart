import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:yamintto/app/app.dart';
import 'package:yamintto/core/theme/app_theme.dart';
import 'package:yamintto/features/foundation/presentation/foundation_screen.dart';
import 'package:yamintto/features/foundation/presentation/splash_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cold launch reaches foundation and applies theme preview', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: YaminttoApp()));

    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.byType(FoundationScreen), findsOneWidget);
    expect(find.text('Application foundation is ready.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('theme-mode-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('AMOLED').last);
    await tester.pumpAndSettle();

    final theme = Theme.of(tester.element(find.byType(FoundationScreen)));
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, Colors.black);
    expect(AppTheme.amoled().colorScheme.surface, Colors.black);
  });
}
