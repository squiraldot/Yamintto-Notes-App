import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yamintto/core/database/yamintto_database.dart';
import 'package:yamintto/core/errors/domain_failure.dart';
import 'package:yamintto/features/notes/data/note_repository.dart';
import 'package:yamintto/features/notes/domain/note_content_format.dart';

void main() {
  late YaminttoDatabase database;
  late NoteRepository notes;

  setUp(() {
    database = YaminttoDatabase.inMemory();
    notes = NoteRepository(database);
  });

  tearDown(() async => database.close());

  test('creates new Markdown notes with format version 2', () async {
    final note = await notes.createNote(
      title: 'Markdown',
      body: '# source',
      contentFormatVersion: NoteContentFormat.hybridMarkdown,
    );
    expect(note.contentFormatVersion, NoteContentFormat.hybridMarkdown);
    expect(note.body, '# source');
  });

  test('opening and title-only edits preserve version-1 plain text', () async {
    final note = await notes.createNote(
      title: 'Plain',
      body: 'literal *text*',
    );
    expect(note.contentFormatVersion, NoteContentFormat.plainText);

    final updated = await notes.updateNote(
      id: note.id,
      title: 'Renamed',
      body: note.body,
    );
    expect(updated.contentFormatVersion, NoteContentFormat.plainText);
    expect(updated.body, 'literal *text*');
  });

  test('deliberate body edits upgrade only that note to version 2', () async {
    final note = await notes.createNote(title: 'Plain', body: 'original');
    final updated = await notes.updateNote(
      id: note.id,
      title: 'Plain',
      body: '# Markdown source',
    );
    expect(updated.contentFormatVersion, NoteContentFormat.hybridMarkdown);
    expect(updated.body, '# Markdown source');
  });

  test(
    'rejects a stale editor revision without overwriting newer source',
    () async {
      final note = await notes.createNote(
        title: 'Shared',
        body: 'original',
      );
      final first = await notes.updateNote(
        id: note.id,
        title: 'First writer',
        body: 'newer source',
        expectedUpdatedAt: note.updatedAt,
      );

      await expectLater(
        notes.updateNote(
          id: note.id,
          title: 'Stale writer',
          body: 'stale source',
          expectedUpdatedAt: note.updatedAt,
        ),
        throwsA(
          isA<DomainFailure>().having(
            (failure) => failure.code,
            'code',
            DomainFailureCode.staleNoteEdit,
          ),
        ),
      );
      final stored = await notes.getNote(note.id);
      expect(stored.title, first.title);
      expect(stored.body, 'newer source');
    },
  );

  test('unknown future format versions cannot be overwritten', () async {
    final note = await notes.createNote(title: 'Future', body: 'preserve me');
    await database.customStatement(
      'UPDATE notes SET content_format_version = 99 WHERE id = ?',
      [note.id],
    );

    await expectLater(
      notes.updateNote(id: note.id, title: 'Changed', body: 'overwrite'),
      throwsA(
        isA<DomainFailure>().having(
          (failure) => failure.code,
          'code',
          DomainFailureCode.unsupportedContentFormat,
        ),
      ),
    );
    final stored = await database
        .customSelect(
          'SELECT body, content_format_version FROM notes WHERE id = ?',
          variables: [Variable.withString(note.id)],
        )
        .getSingle();
    expect(stored.data['body'], 'preserve me');
    expect(stored.data['content_format_version'], 99);
  });
}
