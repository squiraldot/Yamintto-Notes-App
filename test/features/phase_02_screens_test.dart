import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yamintto/features/folders/data/folder_providers.dart';
import 'package:yamintto/features/folders/data/folder_repository.dart';
import 'package:yamintto/features/folders/presentation/folder_browser_screen.dart';
import 'package:yamintto/features/notes/data/note_providers.dart';
import 'package:yamintto/features/notes/data/note_repository.dart';
import 'package:yamintto/features/notes/presentation/note_editor_screen.dart';
import 'package:yamintto/core/database/yamintto_database.dart';

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
        GoRoute(path: '/', builder: (context, state) => const FolderBrowserScreen()),
        GoRoute(path: '/folders/:folderId', builder: (context, state) => FolderBrowserScreen(folderId: state.pathParameters['folderId'])),
        GoRoute(path: '/notes/new', builder: (context, state) => NoteEditorScreen(folderId: state.extra as String?)),
        GoRoute(path: '/notes/:noteId/edit', builder: (context, state) => NoteEditorScreen(noteId: state.pathParameters['noteId'])),
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

  testWidgets('creates and saves a plain-text note', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('New note'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Title').first, 'Meeting');
    await tester.enterText(find.widgetWithText(TextField, 'Plain-text body').first, 'Raw source text');
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
    await tester.enterText(find.widgetWithText(TextField, 'Title').first, 'Draft');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Discard unsaved changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('New note'), findsOneWidget);
  });
}
