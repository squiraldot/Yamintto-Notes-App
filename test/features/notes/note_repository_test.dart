import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yamintto/core/database/yamintto_database.dart';
import 'package:yamintto/core/errors/domain_failure.dart';
import 'package:yamintto/features/folders/data/folder_repository.dart';
import 'package:yamintto/features/notes/data/note_repository.dart';

void main() {
  group('NoteRepository', () {
    late YaminttoDatabase database;
    late NoteRepository notes;
    late FolderRepository folders;
    var nextId = 0;
    var now = 1000;

    String createId() {
      nextId++;
      return '00000000-0000-4000-8000-${nextId.toString().padLeft(12, '0')}';
    }

    setUp(() {
      database = YaminttoDatabase.inMemory();
      nextId = 0;
      now = 1000;
      notes = NoteRepository(database, now: () => now++, createId: createId);
      folders = FolderRepository(database, now: () => now++, createId: createId);
    });

    tearDown(() async => database.close());

    test('creates root and folder notes with an empty title allowed', () async {
      final folder = await folders.createFolder(name: 'Notes');
      final rootNote = await notes.createNote();
      final folderNote = await notes.createNote(
        folderId: folder.id,
        title: '',
        body: 'source body',
      );
      expect(rootNote.folderId, isNull);
      expect(rootNote.title, isEmpty);
      expect(folderNote.folderId, folder.id);
      expect(folderNote.body, 'source body');
      expect((await notes.listNotes()).single.id, rootNote.id);
      expect((await notes.listNotes(folderId: folder.id)).single.id,
          folderNote.id);
    });

    test('updates title and body without changing identity, order or creation',
        () async {
      final note = await notes.createNote(title: 'Before', body: 'old');
      now = 5000;
      final updated = await notes.updateNote(
        id: note.id,
        title: 'After',
        body: '# source text',
      );
      expect(updated.id, note.id);
      expect(updated.createdAt, note.createdAt);
      expect(updated.sortOrder, note.sortOrder);
      expect(updated.title, 'After');
      expect(updated.body, '# source text');
      expect(updated.updatedAt, 5000);
    });

    test('moves notes to folders and root while appending destination order',
        () async {
      final folder = await folders.createFolder(name: 'Folder');
      final first = await notes.createNote(title: 'First', folderId: folder.id);
      final second = await notes.createNote(title: 'Second', folderId: folder.id);
      final rootExisting = await notes.createNote(title: 'Root');
      final moved = await notes.moveNote(first.id);
      expect(moved.folderId, isNull);
      expect(moved.id, first.id);
      expect(moved.createdAt, first.createdAt);
      expect(moved.sortOrder, greaterThan(rootExisting.sortOrder));
      final returned = await notes.moveNote(
        moved.id,
        destinationFolderId: folder.id,
      );
      expect(returned.folderId, folder.id);
      expect(returned.sortOrder, greaterThan(second.sortOrder));
    });

    test('soft deletion preserves data and excludes the note from active lists',
        () async {
      final folder = await folders.createFolder(name: 'Folder');
      final note = await notes.createNote(
        folderId: folder.id,
        title: 'Keep me',
        body: 'preserved body',
      );
      await notes.softDeleteNote(note.id);
      final stored = await database.customSelect(
        'SELECT * FROM notes WHERE id = ?',
        variables: [Variable.withString(note.id)],
      ).getSingle();
      expect(stored.data['folder_id'], folder.id);
      expect(stored.data['sort_order'], note.sortOrder);
      expect(stored.data['title'], 'Keep me');
      expect(stored.data['body'], 'preserved body');
      expect(stored.data['deleted_at'], isNotNull);
      expect(await notes.listNotes(folderId: folder.id), isEmpty);
    });

    test('rejects reads, updates and moves on soft-deleted notes', () async {
      final note = await notes.createNote(title: 'Deleted');
      await notes.softDeleteNote(note.id);
      await expectLater(notes.getNote(note.id), throwsA(isA<DomainFailure>()));
      await expectLater(
        notes.updateNote(id: note.id, title: 'No', body: ''),
        throwsA(isA<DomainFailure>()),
      );
      await expectLater(
        notes.moveNote(note.id),
        throwsA(isA<DomainFailure>()),
      );
    });

    test('rejects deleted destination folders and invalid title lengths',
        () async {
      final folder = await folders.createFolder(name: 'Deleted destination');
      final note = await notes.createNote();
      await folders.softDeleteFolder(folder.id);
      await expectLater(
        notes.moveNote(note.id, destinationFolderId: folder.id),
        throwsA(isA<DomainFailure>().having(
          (failure) => failure.code,
          'code',
          DomainFailureCode.invalidDestination,
        )),
      );
      await expectLater(
        notes.createNote(title: '😀' * 256),
        throwsA(isA<DomainFailure>().having(
          (failure) => failure.code,
          'code',
          DomainFailureCode.invalidTitle,
        )),
      );
      await expectLater(
        notes.createNote(title: 'a\u0000b'),
        throwsA(isA<DomainFailure>()),
      );
      await notes.createNote(title: '😀' * 255);
    });

    test('deleted notes still prevent empty-folder deletion', () async {
      final folder = await folders.createFolder(name: 'Has deleted note');
      final note = await notes.createNote(folderId: folder.id);
      await notes.softDeleteNote(note.id);
      await expectLater(
        folders.softDeleteFolder(folder.id),
        throwsA(isA<DomainFailure>().having(
          (failure) => failure.code,
          'code',
          DomainFailureCode.folderNotEmpty,
        )),
      );
    });
  });
}
