import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yamintto/core/widgets/app_button.dart';
import 'package:yamintto/core/widgets/app_card.dart';
import 'package:yamintto/core/widgets/app_dialog.dart';
import 'package:yamintto/core/widgets/app_text_field.dart';

void main() {
  testWidgets('AppButton invokes its action', (tester) async {
    var presses = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(label: 'Save', onPressed: () => presses++),
        ),
      ),
    );

    await tester.tap(find.text('Save'));
    expect(presses, 1);
  });

  testWidgets('AppButton disables its action while loading', (tester) async {
    var presses = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            label: 'Saving',
            onPressed: () => presses++,
            isLoading: true,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    expect(presses, 0);
  });

  testWidgets('AppCard responds to taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppCard(
            onTap: () => taps++,
            child: const Text('Card content'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Card content'));
    expect(taps, 1);
  });

  testWidgets('AppTextField edits its supplied controller', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTextField(
            controller: controller,
            label: 'Title',
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'Yamintto');
    expect(controller.text, 'Yamintto');
  });

  testWidgets('AppDialog presents a titled dialog', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => AppDialog.show<void>(
                context: context,
                title: 'Confirm',
                content: const Text('Continue?'),
              ),
              child: const Text('Open dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.text('Continue?'), findsOneWidget);
  });
}
