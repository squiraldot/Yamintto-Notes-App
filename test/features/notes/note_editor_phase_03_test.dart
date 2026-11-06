import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yamintto/core/database/yamintto_database.dart';
import 'package:yamintto/features/notes/data/note_providers.dart';
import 'package:yamintto/features/notes/data/note_repository.dart';
import 'package:yamintto/features/notes/domain/note.dart';
import 'package:yamintto/features/notes/domain/note_content_format.dart';
import 'package:yamintto/features/notes/presentation/note_editor_screen.dart';
import 'package:yamintto/features/notes/presentation/safe_markdown_viewer.dart';

void main() {
  late YaminttoDatabase database;
  late NoteRepository notes;
  late GoRouter router;

  setUp(() {
    database = YaminttoDatabase.inMemory();
    notes = NoteRepository(database);
    router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/notes/new',
          builder: (_, _) => const NoteEditorScreen(),
        ),
        GoRoute(
          path: '/notes/:noteId/edit',
          builder: (_, state) =>
              NoteEditorScreen(noteId: state.pathParameters['noteId']),
        ),
      ],
    );
  });

  Widget app() => ProviderScope(
    overrides: [noteRepositoryProvider.overrideWith((ref) async => notes)],
    child: MaterialApp.router(routerConfig: router),
  );

  Future<void> mount(WidgetTester tester, {String? path}) async {
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
      await database.close();
    });
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    if (path != null) {
      unawaited(router.push(path));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('safe Markdown links and images stay inert', (tester) async {
    const source =
        '[Safe link](https://example.com) ![Alt](https://example.com/image.png)';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeMarkdownViewer(source: source),
        ),
      ),
    );

    expect(find.text('Safe link'), findsOneWidget);
    expect(find.text('[Image: Alt]'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('preview respects text scaling and selection', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(1.4)),
          child: const Scaffold(
            body: SafeMarkdownViewer(source: '# Accessible heading'),
          ),
        ),
      ),
    );

    expect(find.byType(SelectionArea), findsOneWidget);
    expect(find.text('Accessible heading'), findsOneWidget);
  });

  testWidgets('switches between source and preview without rewriting source', (
    tester,
  ) async {
    await mount(tester, path: '/notes/new');
    const source = '# Preview heading\n\n**Bold source**';
    await tester.enterText(
      find.byKey(const ValueKey('note-body-editor')),
      source,
    );
    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    expect(find.text('Preview heading'), findsOneWidget);
    final savedNote = (await notes.listNotes()).single;
    expect(savedNote.body, source);
    expect(savedNote.contentFormatVersion, NoteContentFormat.hybridMarkdown);

    await tester.tap(find.text('Editor'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('note-body-editor')))
          .controller!
          .text,
      source,
    );
    expect((await notes.getNote(savedNote.id)).body, source);
  });

  testWidgets('autosaves after 700 ms and persists Markdown format v2', (
    tester,
  ) async {
    await mount(tester, path: '/notes/new');
    const source = '# Durable source\n\n- [ ] pending';
    await tester.enterText(
      find.byKey(const ValueKey('note-title-editor')),
      'Autosave',
    );
    await tester.enterText(
      find.byKey(const ValueKey('note-body-editor')),
      source,
    );

    await tester.pump(const Duration(milliseconds: 699));
    expect(await notes.listNotes(), isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();

    final saved = (await notes.listNotes()).single;
    expect(saved.title, 'Autosave');
    expect(saved.body, source);
    expect(saved.contentFormatVersion, NoteContentFormat.hybridMarkdown);
    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('flushes pending edits before navigation', (tester) async {
    await mount(tester, path: '/notes/new');
    await tester.enterText(
      find.byKey(const ValueKey('note-title-editor')),
      'Before back',
    );
    await tester.enterText(
      find.byKey(const ValueKey('note-body-editor')),
      'Immediate flush',
    );

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    final saved = (await notes.listNotes()).single;
    expect(saved.title, 'Before back');
    expect(saved.body, 'Immediate flush');
  });

  testWidgets('flushes pending edits on lifecycle backgrounding', (
    tester,
  ) async {
    await mount(tester, path: '/notes/new');
    await tester.enterText(
      find.byKey(const ValueKey('note-body-editor')),
      'Lifecycle flush',
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();

    expect((await notes.listNotes()).single.body, 'Lifecycle flush');
  });

  testWidgets('unknown future formats remain visible and read-only', (
    tester,
  ) async {
    final note = await notes.createNote(
      title: 'Future',
      body: 'preserve source',
    );
    await database.customStatement(
      'UPDATE notes SET content_format_version = 99 WHERE id = ?',
      [note.id],
    );
    await mount(tester, path: '/notes/${note.id}/edit');

    expect(find.text('Unsupported content format'), findsOneWidget);
    final sourceEditor = tester.widget<TextField>(
      find.byKey(const ValueKey('note-body-editor')),
    );
    expect(sourceEditor.readOnly, isTrue);
    expect(sourceEditor.controller!.text, 'preserve source');
    expect(find.textContaining('newer content format'), findsOneWidget);
    expect((await notes.getNote(note.id)).body, 'preserve source');
  });

  testWidgets(
    'retains editable source and exposes retry after a save failure',
    (tester) async {
      final failing = _FailingNoteRepository(database);
      notes = failing;
      await mount(tester, path: '/notes/new');
      await tester.enterText(
        find.byKey(const ValueKey('note-body-editor')),
        'Retry source',
      );

      await tester.pump(const Duration(milliseconds: 701));
      await tester.pumpAndSettle();
      expect(find.text('Save error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('note-body-editor')))
            .controller!
            .text,
        'Retry source',
      );

      failing.failWrites = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Saved'), findsOneWidget);
      expect((await notes.listNotes()).single.body, 'Retry source');
    },
  );

  testWidgets('version-1 plain text preview does not reinterpret Markdown', (
    tester,
  ) async {
    final note = await notes.createNote(
      title: 'Legacy',
      body: 'literal **text**',
    );
    await mount(tester, path: '/notes/${note.id}/edit');
    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    expect(find.text('literal **text**'), findsOneWidget);
    expect((await notes.getNote(note.id)).contentFormatVersion, 1);
  });
}

class _FailingNoteRepository extends NoteRepository {
  // ignore: use_super_parameters
  _FailingNoteRepository(YaminttoDatabase database) : super(database);

  bool failWrites = true;

  @override
  Future<Note> createNote({
    String? folderId,
    String title = '',
    String body = '',
    int contentFormatVersion = NoteContentFormat.plainText,
  }) {
    if (failWrites) {
      return Future<Note>.error(StateError('simulated storage failure'));
    }
    return super.createNote(
      folderId: folderId,
      title: title,
      body: body,
      contentFormatVersion: contentFormatVersion,
    );
  }
}
