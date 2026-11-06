import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:yamintto/core/database/schema_v1.dart';
import 'package:yamintto/core/database/schema_v2.dart';
import 'package:yamintto/core/errors/domain_failure.dart';
import 'package:yamintto/core/unicode/unicode_canonicalizer.dart';

/// Drift-managed SQLite database. SQL schema is versioned in [SchemaV1].
///
/// A single app-scoped Riverpod provider owns the production instance. Tests
/// use [YaminttoDatabase.inMemory] but still execute the real SQLite engine.
final class YaminttoDatabase extends GeneratedDatabase {
  YaminttoDatabase._(super.executor);

  factory YaminttoDatabase.open(File file) {
    return YaminttoDatabase._(
      NativeDatabase(file, setup: _registerUnicodeFunctions),
    );
  }

  factory YaminttoDatabase.inMemory() {
    return YaminttoDatabase._(
      NativeDatabase.memory(setup: _registerUnicodeFunctions),
    );
  }

  @override
  int get schemaVersion => SchemaV2.version;

  @override
  Iterable<DatabaseSchemaEntity> get allSchemaEntities =>
      const <DatabaseSchemaEntity>[];

  @override
  Iterable<TableInfo<Table, dynamic>> get allTables =>
      const <TableInfo<Table, dynamic>>[];

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (_) async {
      for (final statement in SchemaV1.createStatements) {
        await customStatement(statement);
      }
      for (final statement in SchemaV2.upgradeFromV1) {
        await customStatement(statement);
      }
    },
    onUpgrade: (_, from, to) async {
      if (from == 1 && to == 2) {
        await transaction(() async {
          for (final statement in SchemaV2.upgradeFromV1) {
            await customStatement(statement);
          }
        });
        return;
      }
      throw DomainFailure(
        DomainFailureCode.migrationUnsupported,
        'No approved database migration exists from schema $from to $to.',
      );
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
      // These pure deterministic functions are used by CHECK constraints.
      // sqlite3's Dart API exposes directOnly/deterministic, but not
      // SQLITE_INNOCUOUS. Keep trusted_schema enabled for this app-private
      // database.
      await customStatement('PRAGMA trusted_schema = ON');
      final trustedSchema = await customSelect('PRAGMA trusted_schema')
          .getSingle();
      if (trustedSchema.data.values.single != 1) {
        throw const DomainFailure(
          DomainFailureCode.databaseInitialization,
          'SQLite schema function execution could not be enabled safely.',
        );
      }
      final foreignKeys = await customSelect('PRAGMA foreign_keys').getSingle();
      if (foreignKeys.data.values.single != 1) {
        throw const DomainFailure(
          DomainFailureCode.databaseInitialization,
          'SQLite foreign-key enforcement could not be enabled.',
        );
      }

      final functionProbe = await customSelect(
        "SELECT yamintto_nfkc_casefold('A') AS canonical, "
        "yamintto_unicode_trim(' x ') AS trimmed, "
        "yamintto_folder_name_key(' A ') AS folder_key, "
        "yamintto_tag_name_key(' A ') AS tag_key",
      ).getSingle();
      if (functionProbe.data['canonical'] != 'a' ||
          functionProbe.data['trimmed'] != 'x' ||
          functionProbe.data['folder_key'] != 'a' ||
          functionProbe.data['tag_key'] != 'a') {
        throw const DomainFailure(
          DomainFailureCode.databaseInitialization,
          'Unicode canonicalization functions are unavailable.',
        );
      }

      final tableCount = await customSelect(
        "SELECT COUNT(*) AS count FROM sqlite_master "
        "WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
      ).getSingle();
      if (tableCount.data['count'] != 4) {
        throw const DomainFailure(
          DomainFailureCode.databaseInitialization,
          'The database schema does not match the approved version 2.',
        );
      }
    },
  );

  static void _registerUnicodeFunctions(dynamic database) {
    database.createFunction(
      functionName: 'yamintto_unicode_trim',
      function: (arguments) {
        final value = arguments.single;
        if (value is! String) {
          throw ArgumentError('Unicode trim expects a text argument.');
        }
        return UnicodeCanonicalizer.trimWhiteSpace(value);
      },
      deterministic: true,
      directOnly: false,
    );
    database.createFunction(
      functionName: 'yamintto_nfkc_casefold',
      function: (arguments) {
        final value = arguments.single;
        if (value is! String) {
          throw ArgumentError('NFKC_Casefold expects a text argument.');
        }
        return UnicodeCanonicalizer.nfkcCasefold(value);
      },
      deterministic: true,
      directOnly: false,
    );
    database.createFunction(
      functionName: 'yamintto_folder_name_key',
      function: (arguments) {
        final value = arguments.single;
        if (value is! String) {
          throw ArgumentError('Folder-name key expects a text argument.');
        }
        return UnicodeCanonicalizer.canonicalizeFolderName(value);
      },
      deterministic: true,
      directOnly: false,
    );
    database.createFunction(
      functionName: 'yamintto_tag_name_key',
      function: (arguments) {
        final value = arguments.single;
        if (value is! String) {
          throw ArgumentError('Tag-name key expects a text argument.');
        }
        return UnicodeCanonicalizer.canonicalizeFolderName(value);
      },
      deterministic: true,
      directOnly: false,
    );
  }
}
