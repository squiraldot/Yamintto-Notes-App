import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yamintto/core/database/schema_v1.dart';
import 'package:yamintto/core/database/yamintto_database.dart';
import 'package:yamintto/core/unicode/unicode_canonicalizer.dart';
import 'package:yamintto/features/tags/data/tag_repository.dart';

void main() {
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('yamintto-v1-');
  });
  tearDown(() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  test('upgrades a populated v1 database and preserves every old note/folder field', () async {
    final file = File('${directory.path}/populated.sqlite');
    final legacy = _V1Fixture(file);
    await legacy.customStatement(
      'INSERT INTO folders(id, parent_id, name, name_key, sort_order, created_at, updated_at, deleted_at) '
      'VALUES (?, NULL, ?, ?, ?, ?, ?, ?)',
      <Object?>[
        '00000000-0000-4000-8000-000000000001',
        'Legacy',
        'legacy',
        7,
        11,
        12,
        13,
      ],
    );
    await legacy.customStatement(
      'INSERT INTO notes(id, folder_id, title, body, content_format_version, sort_order, created_at, updated_at, deleted_at) '
      'VALUES (?, ?, ?, ?, 1, ?, ?, ?, ?)',
      <Object?>[
        '00000000-0000-4000-8000-000000000002',
        '00000000-0000-4000-8000-000000000001',
        'Old title',
        'Old body',
        9,
        21,
        22,
        23,
      ],
    );
    await legacy.close();

    final upgraded = YaminttoDatabase.open(file);
    final folder = await upgraded
        .customSelect('SELECT * FROM folders')
        .getSingle();
    final note = await upgraded.customSelect('SELECT * FROM notes').getSingle();
    expect(folder.data['id'], '00000000-0000-4000-8000-000000000001');
    expect(folder.data['name'], 'Legacy');
    expect(folder.data['parent_id'], isNull);
    expect(folder.data['sort_order'], 7);
    expect(folder.data['created_at'], 11);
    expect(folder.data['updated_at'], 12);
    expect(folder.data['deleted_at'], 13);
    expect(folder.data['color_argb'], isNull);
    expect(note.data['id'], '00000000-0000-4000-8000-000000000002');
    expect(note.data['folder_id'], '00000000-0000-4000-8000-000000000001');
    expect(note.data['title'], 'Old title');
    expect(note.data['body'], 'Old body');
    expect(note.data['sort_order'], 9);
    expect(note.data['created_at'], 21);
    expect(note.data['updated_at'], 22);
    expect(note.data['deleted_at'], 23);

    const newNoteId = '00000000-0000-4000-8000-000000000003';
    await upgraded.customStatement(
      'INSERT INTO notes(id, folder_id, title, body, content_format_version, sort_order, created_at, updated_at) '
      'VALUES (?, NULL, ?, ?, 1, 0, 30, 30)',
      <Object?>[newNoteId, 'New', 'Body'],
    );
    final tags = TagRepository(
      upgraded,
      createId: () => '00000000-0000-4000-8000-000000000004',
    );
    final tag = await tags.createTag('Migrated');
    await tags.assignTags(newNoteId, <String>[tag.id]);
    await upgraded.customStatement(
      'UPDATE folders SET color_argb = ? WHERE id = ?',
      <Object?>[0xFFF44336, '00000000-0000-4000-8000-000000000001'],
    );
    expect((await tags.listNoteTags(newNoteId)).single.name, 'Migrated');
    final fk = await upgraded.customSelect('PRAGMA foreign_key_check').get();
    expect(fk, isEmpty);
    final integrity = await upgraded
        .customSelect('PRAGMA integrity_check')
        .getSingle();
    expect(integrity.data.values.single, 'ok');
    await upgraded.close();

    final reopened = YaminttoDatabase.open(file);
    final persisted = await reopened
        .customSelect(
          'SELECT color_argb FROM folders WHERE id = ?',
          variables: [
            Variable.withString('00000000-0000-4000-8000-000000000001'),
          ],
        )
        .getSingle();
    expect(persisted.data['color_argb'], 0xFFF44336);
    await reopened.close();
  });

  test(
    'failed migration rolls back the schema change and retains v1 data',
    () async {
      final file = File('${directory.path}/failed.sqlite');
      final legacy = _V1Fixture(file);
      await legacy.customStatement(
        'INSERT INTO folders(id, parent_id, name, name_key, sort_order, created_at, updated_at) '
        'VALUES (?, NULL, ?, ?, 0, 1, 1)',
        <Object?>['00000000-0000-4000-8000-000000000011', 'Keep', 'keep'],
      );
      // Force the v2 CREATE TABLE step to fail after ALTER TABLE has begun.
      await legacy.customStatement('CREATE TABLE tags (conflicting INTEGER)');
      await legacy.close();

      final failed = YaminttoDatabase.open(file);
      await expectLater(
        failed.customSelect('SELECT 1').get(),
        throwsA(anything),
      );
      await failed.close();

      final inspect = _V1Fixture(file);
      final retained = await inspect
          .customSelect('SELECT id, name FROM folders')
          .getSingle();
      expect(retained.data['id'], '00000000-0000-4000-8000-000000000011');
      expect(retained.data['name'], 'Keep');
      final version = await inspect
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(version.data.values.single, 1);
      final columns = await inspect
          .customSelect('PRAGMA table_info(folders)')
          .get();
      expect(columns.any((row) => row.data['name'] == 'color_argb'), isFalse);
      await inspect.close();
    },
  );
}

class _V1Fixture extends GeneratedDatabase {
  _V1Fixture(File file)
    : super(NativeDatabase(file, setup: _registerFunctions));

  @override
  int get schemaVersion => 1;

  @override
  Iterable<DatabaseSchemaEntity> get allSchemaEntities => const [];

  @override
  Iterable<TableInfo<Table, dynamic>> get allTables => const [];

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (_) async {
      for (final statement in SchemaV1.createStatements) {
        await customStatement(statement);
      }
    },
    onUpgrade: (_, from, to) async =>
        throw StateError('Unsupported fixture upgrade'),
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA trusted_schema = ON');
    },
  );

  static void _registerFunctions(dynamic db) {
    db.createFunction(
      functionName: 'yamintto_unicode_trim',
      function: (args) =>
          UnicodeCanonicalizer.trimWhiteSpace(args.single as String),
      deterministic: true,
      directOnly: false,
    );
    db.createFunction(
      functionName: 'yamintto_nfkc_casefold',
      function: (args) =>
          UnicodeCanonicalizer.nfkcCasefold(args.single as String),
      deterministic: true,
      directOnly: false,
    );
    db.createFunction(
      functionName: 'yamintto_folder_name_key',
      function: (args) =>
          UnicodeCanonicalizer.canonicalizeFolderName(args.single as String),
      deterministic: true,
      directOnly: false,
    );
  }
}
