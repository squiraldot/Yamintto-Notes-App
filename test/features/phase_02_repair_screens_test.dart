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
import 'package:yamintto/features/tags/data/tag_providers.dart';
import 'package:yamintto/features/tags/data/tag_repository.dart';
import 'package:yamintto/features/tags/presentation/note_tag_assignment_screen.dart';
import 'package:yamintto/features/tags/presentation/tag_management_screen.dart';

void main() {
  late YaminttoDatabase database;
  late FolderRepository folders;
  late NoteRepository notes;
  late TagRepository tags;
  late GoRouter router;

  setUp(() {
    database = YaminttoDatabase.inMemory();
    folders = FolderRepository(database);
    notes = NoteRepository(database);
    tags = TagRepository(database);
    router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const FolderBrowserScreen()),
        GoRoute(
          path: '/folders/:folderId',
          builder: (_, state) =>
              FolderBrowserScreen(folderId: state.pathParameters['folderId']),
        ),
        GoRoute(path: '/tags', builder: (_, _) => const TagManagementScreen()),
        GoRoute(
          path: '/notes/:noteId/tags',
          builder: (_, state) =>
              NoteTagAssignmentScreen(noteId: state.pathParameters['noteId']!),
        ),
      ],
    );
  });

  Widget app() => ProviderScope(
    overrides: [
      folderRepositoryProvider.overrideWith((ref) async => folders),
      noteRepositoryProvider.overrideWith((ref) async => notes),
      tagRepositoryProvider.overrideWith((ref) async => tags),
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

  testWidgets('creates, renames and deletes reusable tags', (tester) async {
    await mount(tester);
    router.go('/tags');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create tag'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Work');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Work'), findsOneWidget);

    await tester.tap(find.byTooltip('Tag actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Projects');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Projects'), findsOneWidget);

    await tester.tap(find.byTooltip('Tag actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(await tags.listTags(), isEmpty);
  });

  testWidgets('assigns multiple tags to a note and displays them in its list', (
    tester,
  ) async {
    final note = await notes.createNote(title: 'Tagged note');
    await tags.createTag('Personal');
    await tags.createTag('Work');
    await mount(tester);
    router.go('/notes/${note.id}/tags');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Personal'));
    await tester.tap(find.widgetWithText(FilterChip, 'Work'));
    await tester.tap(find.text('Save tags'));
    await tester.pumpAndSettle();
    expect((await tags.listNoteTags(note.id)).length, 2);

    router.go('/');
    await tester.pumpAndSettle();
    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
  });

  testWidgets('selects and resets a folder color in the folder browser', (
    tester,
  ) async {
    final folder = await folders.createFolder(name: 'Colored');
    await mount(tester);
    await tester.tap(find.byTooltip('Folder actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change color'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ChoiceChip).at(1));
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect((await folders.getFolder(folder.id)).colorArgb, isNotNull);
    expect(find.byIcon(Icons.folder), findsOneWidget);

    await tester.tap(find.byTooltip('Folder actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change color'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Default'));
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect((await folders.getFolder(folder.id)).colorArgb, isNull);
  });

  testWidgets('shows nested folder color in the folder browser', (
    tester,
  ) async {
    final parent = await folders.createFolder(name: 'Parent');
    final child = await folders.createFolder(
      name: 'Child',
      parentId: parent.id,
    );
    await folders.setFolderColor(child.id, 0xFF673AB7);
    await mount(tester);
    router.go('/folders/${parent.id}');
    await tester.pumpAndSettle();
    final icon = tester.widget<Icon>(find.byIcon(Icons.folder));
    expect(icon.color, const Color(0xFF673AB7));
  });
}
