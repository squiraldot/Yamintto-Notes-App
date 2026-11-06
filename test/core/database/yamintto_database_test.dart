import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yamintto/core/database/yamintto_database.dart';
import 'package:yamintto/core/ids/uuid_v4.dart';
import 'package:yamintto/core/unicode/unicode_canonicalizer.dart';

void main() {
  group('YaminttoDatabase schema v2', () {
    late YaminttoDatabase database;
    var fixtureClosed = false;

    setUp(() {
      database = YaminttoDatabase.inMemory();
      fixtureClosed = false;
    });

    tearDown(() async {
      if (!fixtureClosed) await database.close();
    });

    test('creates schema v2 tables and enables foreign keys', () async {
      final tables = await database
          .customSelect(
            "SELECT name FROM sqlite_master "
            "WHERE type = 'table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
          )
          .get();
      expect(tables.map((row) => row.data['name']), <String>[
        'folders',
        'notes',
        'note_tags',
        'tags',
      ]);

      final foreignKeys = await database
          .customSelect('PRAGMA foreign_keys')
          .getSingle();
      expect(foreignKeys.data['foreign_keys'], 1);
    });

    test('registers deterministic Unicode functions usable by schema checks', () async {
      final key = await database
          .customSelect("SELECT yamintto_folder_name_key('  Ａ  ') AS value")
          .getSingle();
      expect(key.data['value'], 'a');

      final trimmed = await database
          .customSelect(
            "SELECT yamintto_unicode_trim(?) AS value",
            variables: [Variable.withString('  x  ')],
          )
          .getSingle();
      expect(trimmed.data['value'], 'x');

      await expectLater(
        database.customStatement(
          'INSERT INTO folders '
          '(id, parent_id, name, name_key, sort_order, created_at, updated_at) '
          'VALUES (?, NULL, ?, ?, 0, 1, 1)',
          <Object?>[
            '00000000-0000-4000-8000-000000000001',
            'Alpha',
            'not-alpha',
          ],
        ),
        throwsA(anything),
      );
    });

    test('enforces the root-aware canonical-name unique index in SQLite', () async {
      await database.customStatement(
        'INSERT INTO folders '
        '(id, parent_id, name, name_key, sort_order, created_at, updated_at) '
        'VALUES (?, NULL, ?, ?, 0, 1, 1)',
        <Object?>['00000000-0000-4000-8000-000000000001', 'Alpha', 'alpha'],
      );
      await expectLater(
        database.customStatement(
          'INSERT INTO folders '
          '(id, parent_id, name, name_key, sort_order, created_at, updated_at) '
          'VALUES (?, NULL, ?, ?, 0, 2, 2)',
          <Object?>['00000000-0000-4000-8000-000000000002', 'ALPHA', 'alpha'],
        ),
        throwsA(anything),
      );
    });

    test('enforces foreign keys for note folder references', () async {
      await expectLater(
        database.customStatement(
          'INSERT INTO notes '
          '(id, folder_id, title, body, content_format_version, sort_order, '
          'created_at, updated_at) VALUES (?, ?, ?, ?, 1, 0, 1, 1)',
          <Object?>[
            '00000000-0000-4000-8000-000000000001',
            '00000000-0000-4000-8000-000000000002',
            '',
            '',
          ],
        ),
        throwsA(anything),
      );
    });

    test(
      'enforces ON DELETE and ON UPDATE RESTRICT for referenced folders',
      () async {
        const folderId = '00000000-0000-4000-8000-000000000001';
        await database.customStatement(
          'INSERT INTO folders '
          '(id, parent_id, name, name_key, sort_order, created_at, updated_at) '
          'VALUES (?, NULL, ?, ?, 0, 1, 1)',
          <Object?>[folderId, 'Parent', 'parent'],
        );
        await database.customStatement(
          'INSERT INTO notes '
          '(id, folder_id, title, body, content_format_version, sort_order, '
          'created_at, updated_at) VALUES (?, ?, ?, ?, 1, 0, 1, 1)',
          <Object?>['00000000-0000-4000-8000-000000000002', folderId, '', ''],
        );
        await expectLater(
          database.customStatement('DELETE FROM folders WHERE id = ?', [
            folderId,
          ]),
          throwsA(anything),
        );
        await expectLater(
          database.customStatement(
            'UPDATE folders SET id = ? WHERE id = ?',
            <Object?>['00000000-0000-4000-8000-000000000003', folderId],
          ),
          throwsA(anything),
        );
      },
    );

    test('uses canonical lowercase UUID v4 identifiers', () {
      final id = UuidV4.generate();
      expect(UuidV4.isCanonical(id), isTrue);
      expect(id, id.toLowerCase());
      expect(
        UuidV4.isCanonical('00000000-0000-0000-0000-000000000000'),
        isFalse,
      );
    });

    test('registers functions again after reopening a database', () async {
      await database.close();
      fixtureClosed = true;
      final directory = await Directory.systemTemp.createTemp('yamintto-db-');
      final file = File('${directory.path}/reopen.sqlite');
      final first = YaminttoDatabase.open(file);
      final folder = await first
          .customSelect("SELECT yamintto_folder_name_key('  Ａ  ') AS value")
          .getSingle();
      expect(folder.data['value'], 'a');
      await first.close();

      final reopened = YaminttoDatabase.open(file);
      addTearDown(reopened.close);
      final result = await reopened
          .customSelect("SELECT yamintto_nfkc_casefold('Straße') AS value")
          .getSingle();
      expect(result.data['value'], 'strasse');
      final fk = await reopened.customSelect('PRAGMA foreign_keys').getSingle();
      expect(fk.data['foreign_keys'], 1);

      await directory.delete(recursive: true);
    });

    test(
      'does not silently downgrade a database with a newer user_version',
      () async {
        await database.close();
        fixtureClosed = true;
        final directory = await Directory.systemTemp.createTemp(
          'yamintto-newer-',
        );
        final file = File('${directory.path}/newer.sqlite');
        final initial = YaminttoDatabase.open(file);
        await initial.customSelect('SELECT 1').get();
        await initial.customStatement('PRAGMA user_version = 3');
        await initial.close();

        final reopened = YaminttoDatabase.open(file);
        await expectLater(
          reopened.customSelect('SELECT 1').get(),
          throwsA(anything),
        );
        await reopened.close();
        await directory.delete(recursive: true);
      },
    );

    test(
      'Dart and SQLite folder-name canonicalization remain identical',
      () async {
        const values = <String>[
          'A',
          'Ａ',
          'Straße',
          'Kelvin',
          '\u00A0Mixed  Case\u2009',
          '\u00AD',
          'İ',
        ];
        for (final value in values) {
          final row = await database
              .customSelect(
                'SELECT yamintto_folder_name_key(?) AS value',
                variables: [Variable.withString(value)],
              )
              .getSingle();
          expect(
            row.data['value'],
            UnicodeCanonicalizer.canonicalizeFolderName(value),
          );
        }
      },
    );
  });
}
