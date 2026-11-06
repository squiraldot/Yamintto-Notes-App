import 'package:flutter_test/flutter_test.dart';
import 'package:yamintto/core/database/yamintto_database.dart';
import 'package:yamintto/core/errors/domain_failure.dart';
import 'package:yamintto/features/notes/data/note_repository.dart';
import 'package:yamintto/features/tags/data/tag_repository.dart';

void main() {
  late YaminttoDatabase database;
  late NoteRepository notes;
  late TagRepository tags;
  var nextId = 0;
  String createId() {
    nextId++;
    return '00000000-0000-4000-8000-${nextId.toString().padLeft(12, '0')}';
  }

  setUp(() {
    database = YaminttoDatabase.inMemory();
    notes = NoteRepository(database, createId: createId);
    tags = TagRepository(database, createId: createId);
  });
  tearDown(() => database.close());

  test(
    'trims and Unicode-canonicalizes names and rejects duplicate tags',
    () async {
      final first = await tags.createTag('  Ｓｔｕｄｙ  ');
      expect(first.name, 'Ｓｔｕｄｙ');
      expect(first.nameKey, 'study');
      await expectLater(tags.createTag('STUDY'), throwsA(isA<DomainFailure>()));
    },
  );

  test('rejects empty, NUL and overlong tag names', () async {
    for (final value in <String>['  \u2003 ', 'bad\u0000tag', 'x' * 65]) {
      await expectLater(tags.createTag(value), throwsA(isA<DomainFailure>()));
    }
  });

  test(
    'reuses tags across notes and orders assignments by canonical name',
    () async {
      final noteA = await notes.createNote(title: 'A');
      final noteB = await notes.createNote(title: 'B');
      final z = await tags.createTag('Zulu');
      final a = await tags.createTag('alpha');
      await tags.assignTags(noteA.id, <String>[z.id, a.id, a.id]);
      await tags.assignTags(noteB.id, <String>[a.id]);
      expect(
        (await tags.listNoteTags(noteA.id)).map((tag) => tag.name),
        <String>['alpha', 'Zulu'],
      );
      expect((await tags.listNoteTags(noteB.id)).single.id, a.id);
    },
  );

  test('rename changes shared display name without changing note content or timestamps', () async {
    final note = await notes.createNote(title: 'Keep title', body: 'Keep body');
    final tag = await tags.createTag('Old');
    await tags.assignTags(note.id, <String>[tag.id]);
    final renamed = await tags.renameTag(tag.id, 'New');
    final after = await notes.getNote(note.id);
    expect(renamed.name, 'New');
    expect(after.title, note.title);
    expect(after.body, note.body);
    expect(after.updatedAt, note.updatedAt);
    expect((await tags.listNoteTags(note.id)).single.name, 'New');
  });

  test('delete removes all assignments transactionally', () async {
    final first = await notes.createNote();
    final second = await notes.createNote();
    final tag = await tags.createTag('Shared');
    await tags.assignTags(first.id, <String>[tag.id]);
    await tags.assignTags(second.id, <String>[tag.id]);
    await tags.deleteTag(tag.id);
    expect(await tags.listNoteTags(first.id), isEmpty);
    expect(await tags.listNoteTags(second.id), isEmpty);
    expect(await tags.listTags(), isEmpty);
  });

  test(
    'soft-deleted notes retain assignments and reject assignment changes',
    () async {
      final note = await notes.createNote(title: 'Retained');
      final tag = await tags.createTag('Keep');
      await tags.assignTags(note.id, <String>[tag.id]);
      await notes.softDeleteNote(note.id);
      expect((await tags.listNoteTags(note.id)).single.id, tag.id);
      await expectLater(
        tags.assignTags(note.id, <String>[]),
        throwsA(isA<DomainFailure>()),
      );
      expect((await tags.listNoteTags(note.id)).single.id, tag.id);
    },
  );

  test(
    'removes one assignment without affecting other note assignments',
    () async {
      final note = await notes.createNote();
      final one = await tags.createTag('One');
      final two = await tags.createTag('Two');
      await tags.assignTags(note.id, <String>[one.id, two.id]);
      await tags.removeTagFromNote(note.id, one.id);
      expect((await tags.listNoteTags(note.id)).single.id, two.id);
    },
  );
}
