import 'package:drift/drift.dart' hide isNotNull, isNull;
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

  Widget app() => ProviderScope(
    overrides: [
      folderRepositoryProvider.overrideWith((ref) async => folders),
      noteRepositoryProvider.overrideWith((ref) async => notes),
    ],
    child: MaterialApp.router(routerConfig: router),
  );

  Future<void> mount(WidgetTester tester) async {
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
      await database.close();
    });
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
  }

  testWidgets('root screen shows empty folders and notes', (tester) async {
    await mount(tester);
    expect(find.text('No folders here yet.'), findsOneWidget);
    expect(find.text('No notes here yet.'), findsOneWidget);
  });

  testWidgets('creates and opens a nested folder', (tester) async {
    await mount(tester);
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
    await mount(tester);
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
    await mount(tester);
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
    await mount(tester);
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
    final retained = await notes.createNote(
      folderId: folder.id,
      title: 'Retained note',
    );
    await notes.softDeleteNote(retained.id);
    await mount(tester);
    await tester.tap(find.byTooltip('Folder actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('Only an empty folder can be deleted.'), findsOneWidget);
    expect(find.text('Not empty'), findsOneWidget);
  });

  testWidgets('creates and autosaves a Markdown note', (tester) async {
    await mount(tester);
    await tester.tap(find.text('New note'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Meeting');
    await tester.enterText(find.byType(TextField).last, '# Raw source text');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Meeting'), findsOneWidget);
    expect((await notes.listNotes()).single.body, '# Raw source text');
    expect((await notes.listNotes()).single.contentFormatVersion, 2);
  });

  testWidgets('flushes pending note changes before back navigation', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.text('New note'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Draft');
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Discard unsaved changes?'), findsNothing);
    expect((await notes.listNotes()).single.title, 'Draft');
    expect(find.text('Draft'), findsOneWidget);
  });

  testWidgets('excludes descendants from folder move destinations', (
    tester,
  ) async {
    final parent = await folders.createFolder(name: 'Parent');
    await folders.createFolder(name: 'Child', parentId: parent.id);
    await mount(tester);
    await tester.tap(find.byTooltip('Folder actions').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();
    expect(find.text('Child'), findsNothing);
    await tester.tap(find.text('Root').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets('edits an existing note and saves Markdown source', (
    tester,
  ) async {
    final note = await notes.createNote(title: 'Before', body: 'Old body');
    await mount(tester);
    await tester.tap(find.text('Before'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'After');
    await tester.enterText(find.byType(TextField).last, 'Updated raw body');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    final saved = await notes.getNote(note.id);
    expect(saved.title, 'After');
    expect(saved.body, 'Updated raw body');
    expect(saved.contentFormatVersion, 2);
  });

  testWidgets('back navigation flushes existing note edits', (tester) async {
    final note = await notes.createNote(
      title: 'Original',
      body: 'Original body',
    );
    await mount(tester);
    await tester.tap(find.text('Original'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Unsaved title');
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    final updated = await notes.getNote(note.id);
    expect(updated.title, 'Unsaved title');
    expect(updated.body, 'Original body');
    expect(find.text('Unsaved title'), findsOneWidget);
  });

  testWidgets('moves a root note into a selected folder', (tester) async {
    final destination = await folders.createFolder(name: 'Destination');
    final note = await notes.createNote(title: 'Move me');
    await mount(tester);
    await tester.tap(find.byTooltip('Note actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Destination').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move').last);
    await tester.pumpAndSettle();
    expect((await notes.getNote(note.id)).folderId, destination.id);
    expect(find.text('Move me'), findsNothing);
  });

  testWidgets('soft-deletes a note and removes it from active listing', (
    tester,
  ) async {
    final note = await notes.createNote(title: 'Delete me');
    await mount(tester);
    await tester.tap(find.byTooltip('Note actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('Delete me'), findsNothing);
    expect(await notes.listNotes(), isEmpty);
    final retained = await database
        .customSelect(
          'SELECT deleted_at FROM notes WHERE id = ?',
          variables: [Variable.withString(note.id)],
        )
        .getSingle();
    expect(retained.data['deleted_at'], isNotNull);
  });

  testWidgets('missing folder route shows a recoverable error state', (
    tester,
  ) async {
    await mount(tester);
    router.go('/folders/missing-folder-id');
    await tester.pumpAndSettle();
    expect(find.text('Folder unavailable'), findsOneWidget);
    expect(find.text('Retry'), findsWidgets);
  });

  testWidgets('moves a nested folder back to root', (tester) async {
    final parent = await folders.createFolder(name: 'Parent');
    final child = await folders.createFolder(
      name: 'Child',
      parentId: parent.id,
    );
    await mount(tester);
    await tester.tap(find.text('Parent'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Folder actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Root').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move').last);
    await tester.pumpAndSettle();
    expect((await folders.getFolder(child.id)).parentId, isNull);
  });

  testWidgets('creates a note inside the current folder', (tester) async {
    final folder = await folders.createFolder(name: 'Notes folder');
    await mount(tester);
    await tester.tap(find.text('Notes folder'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New note'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Folder note');
    await tester.enterText(find.byType(TextField).last, 'Folder body');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    final created = await notes.listNotes(folderId: folder.id);
    expect(created.single.title, 'Folder note');
    expect(created.single.body, 'Folder body');
  });

  testWidgets('moves a folder note back to root', (tester) async {
    final folder = await folders.createFolder(name: 'Source folder');
    final note = await notes.createNote(
      folderId: folder.id,
      title: 'Move to root',
    );
    await mount(tester);
    router.go('/folders/${folder.id}');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Note actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Root').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move').last);
    await tester.pumpAndSettle();
    expect((await notes.getNote(note.id)).folderId, isNull);
  });

  // Dismissing a destination picker must never be interpreted as Root.
  testWidgets('dismissing a folder move dialog preserves its parent', (
    tester,
  ) async {
    final parent = await folders.createFolder(name: 'Parent');
    final child = await folders.createFolder(
      name: 'Child',
      parentId: parent.id,
    );
    await mount(tester);
    await tester.tap(find.text('Parent'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Folder actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect((await folders.getFolder(child.id)).parentId, parent.id);
  });

  testWidgets('dismissing a note move dialog preserves its folder', (
    tester,
  ) async {
    final folder = await folders.createFolder(name: 'Notes folder');
    final note = await notes.createNote(
      folderId: folder.id,
      title: 'Keep in folder',
    );
    await mount(tester);
    router.go('/folders/${folder.id}');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Note actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect((await notes.getNote(note.id)).folderId, folder.id);
  });
}
