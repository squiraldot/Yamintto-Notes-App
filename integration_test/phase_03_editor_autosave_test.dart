import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:yamintto/app/app.dart';
import 'package:yamintto/app/providers/database_provider.dart';
import 'package:yamintto/core/database/yamintto_database.dart';
import 'package:yamintto/features/notes/data/note_repository.dart';

/// Owner-run on a real Android/iOS device only. Never run in virtual-device CI.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Phase 03 editor autosaves on navigation and backgrounding', (
    tester,
  ) async {
      final temporaryDirectory = await getTemporaryDirectory();
      final databaseDirectory = Directory(
        path.join(temporaryDirectory.path, 'yamintto-phase-03'),
      );
      await databaseDirectory.create(recursive: true);
      final databaseFile = File(
        path.join(
          databaseDirectory.path,
          'phase-03-${DateTime.now().microsecondsSinceEpoch}.sqlite',
        ),
      );
      final database = YaminttoDatabase.open(databaseFile);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWith((ref) async => database),
          ],
          child: const YaminttoApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      final marker = DateTime.now().toUtc().microsecondsSinceEpoch;
      final title = 'Phase 03 device note $marker';
      await tester.tap(find.text('New note'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('note-title-editor')),
        title,
      );
      await tester.enterText(
        find.byKey(const ValueKey('note-body-editor')),
        '# Device Markdown\n\n**Saved before navigation**',
      );

      // Simulate the Android system-back gesture/button. PopScope must wait
      // for the pending autosave before the route is removed.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('note-body-editor')), findsNothing);
      expect(find.text(title), findsOneWidget);

      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('note-body-editor')),
        findsOneWidget,
      );
      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Device Markdown', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('Saved before navigation', findRichText: true),
        findsOneWidget,
      );

      // Return to source and verify a lifecycle flush persists a later edit.
      await tester.tap(find.text('Editor'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('note-body-editor')),
        '# Device Markdown\n\n**Saved after backgrounding**',
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      final repository = NoteRepository(database);
      final saved = (await repository.listNotes()).single;
      expect(saved.title, title);
      expect(saved.body, contains('Saved after backgrounding'));
      expect(saved.contentFormatVersion, 2);

      await tester.pumpWidget(const SizedBox.shrink());
      await database.close();

      // A fresh Drift instance must read the last completed editor flush.
      final reopened = YaminttoDatabase.open(databaseFile);
      final reopenedNote = await NoteRepository(reopened).getNote(saved.id);
      expect(reopenedNote.body, contains('Saved after backgrounding'));
      expect(reopenedNote.contentFormatVersion, 2);
      await reopened.close();
      await databaseFile.delete();
      await databaseDirectory.delete(recursive: true);
  });
}
