import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yamintto/core/database/yamintto_database.dart';
import 'package:yamintto/features/folders/data/folder_providers.dart';
import 'package:yamintto/features/folders/data/folder_repository.dart';
import 'package:yamintto/features/folders/presentation/folder_browser_screen.dart';
import 'package:yamintto/features/notes/data/note_providers.dart';
import 'package:yamintto/features/notes/data/note_repository.dart';
import 'package:yamintto/features/notes/presentation/note_editor_screen.dart';

void main() {
  late YaminttoDatabase database;
  late FolderRepository folders;
  late NoteRepository notes;
  late GoRouter router;

  setUp(() {
    database = YaminttoDatabase.inMemory();
    folders = FolderRepository(database);
    notes = NoteRepository(database);
    router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const FolderBrowserScreen(),
        ),
        GoRoute(
          path: '/folders/:folderId',
          builder: (context, state) =>
              FolderBrowserScreen(folderId: state.pathParameters['folderId']),
        ),
        GoRoute(
          path: '/notes/new',
          builder: (context, state) =>
              NoteEditorScreen(folderId: state.extra as String?),
        ),
        GoRoute(
          path: '/notes/:noteId/edit',
          builder: (context, state) =>
              NoteEditorScreen(noteId: state.pathParameters['noteId']),
        ),
      ],
    );
  });

  tearDown(() async {
    router.dispose();
    await database.close();
  });

  Widget app() => ProviderScope(
    overrides: [
      folderRepositoryProvider.overrideWith((ref) async => folders),
      noteRepositoryProvider.overrideWith((ref) async => notes),
    ],
    child: MaterialApp.router(routerConfig: router),
  );

  testWidgets('root screen shows empty folders and notes', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text('No folders here yet.'), findsOneWidget);
    expect(find.text('No notes here yet.'), findsOneWidget);
  });

  testWidgets('creates and opens a nested folder', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Create folder'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Projects');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle();
    expect(find.text('Subfolders'), findsOneWidget);
    expect(find.text('Parent folder'), findsOneWidget);
  });

  testWidgets('renames a folder through its action menu', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Create folder'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Before');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Folder actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'After');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('After'), findsOneWidget);
    expect(find.text('Before'), findsNothing);
  });

  testWidgets('moves a folder into another folder', (tester) async {
    final source = await folders.createFolder(name: 'Source');
    final destination = await folders.createFolder(name: 'Destination');
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Folder actions').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Destination').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move').last);
    await tester.pumpAndSettle();
    expect((await folders.getFolder(source.id)).parentId, destination.id);
    expect(find.text('Source'), findsNothing);
  });

  testWidgets('soft-deletes an empty folder from the active list', (
    tester,
  ) async {
    final folder = await folders.createFolder(name: 'Empty folder');
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Folder actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('Empty folder'), findsNothing);
    expect(
      (await folders.listFolders()).where((item) => item.id == folder.id),
      isEmpty,
    );
  });

  testWidgets('rejects deleting a folder containing a note', (tester) async {
    final folder = await folders.createFolder(name: 'Not empty');
    await notes.createNote(folderId: folder.id, title: 'Retained note');
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Folder actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('Only an empty folder can be deleted.'), findsOneWidget);
    expect(find.text('Not empty'), findsOneWidget);
  });

  testWidgets('creates and saves a plain-text note', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('New note'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Meeting');
    await tester.enterText(find.byType(TextField).last, 'Raw source text');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Meeting'), findsOneWidget);
    expect((await notes.listNotes()).single.body, 'Raw source text');
  });

  testWidgets('prompts before abandoning unsaved note changes', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('New note'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Draft');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Discard unsaved changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('New note'), findsOneWidget);
  });
}
