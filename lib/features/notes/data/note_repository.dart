import 'package:drift/drift.dart';
import 'package:yamintto/core/database/database_boundary.dart';
import 'package:yamintto/core/database/yamintto_database.dart';
import 'package:yamintto/core/errors/domain_failure.dart';
import 'package:yamintto/core/ids/uuid_v4.dart';
import 'package:yamintto/core/unicode/unicode_canonicalizer.dart';
import 'package:yamintto/features/notes/domain/note.dart';

class NoteRepository {
  NoteRepository(
    this._database, {
    int Function()? now,
    String Function()? createId,
  })  : _now = now ?? _utcNow,
        _createId = createId ?? UuidV4.generate;

  final YaminttoDatabase _database;
  final int Function() _now;
  final String Function() _createId;

  static int _utcNow() => DateTime.now().toUtc().millisecondsSinceEpoch;

  Future<Note> createNote({
    String? folderId,
    String title = '',
    String body = '',
  }) async {
    _validateTitle(title);
    return DatabaseBoundary.guard(
      () => _database.transaction(
        () async {
          if (folderId != null) {
            await _requireActiveFolder(folderId);
          }
          final now = _now();
          final id = _createId();
          if (!UuidV4.isCanonical(id)) {
            throw const DomainFailure(
              DomainFailureCode.databaseConstraint,
              'The generated note identifier is invalid.',
            );
          }
          final order = await _nextOrder(folderId);
          await _database.customStatement(
            'INSERT INTO notes '
            '(id, folder_id, title, body, content_format_version, sort_order, '
            'created_at, updated_at) VALUES (?, ?, ?, ?, 1, ?, ?, ?)',
            <Object?>[id, folderId, title, body, order, now, now],
          );
          return _requireActiveNote(id);
        },
      ),
    );
  }

  Future<Note> getNote(String id) {
    return DatabaseBoundary.guard(() => _requireActiveNote(id));
  }

  Future<List<Note>> listNotes({String? folderId}) {
    return DatabaseBoundary.guard(() async {
      if (folderId != null) {
        await _requireActiveFolder(folderId);
      }
      final sql = folderId == null
          ? 'SELECT * FROM notes WHERE folder_id IS NULL '
              'AND deleted_at IS NULL ORDER BY sort_order, created_at, id'
          : 'SELECT * FROM notes WHERE folder_id = ? AND deleted_at IS NULL '
              'ORDER BY sort_order, created_at, id';
      final rows = await _database.customSelect(
        sql,
        variables: folderId == null
            ? const <Variable<Object>>[]
            : <Variable<Object>>[Variable.withString(folderId)],
      ).get();
      return rows.map((row) => Note.fromRow(row.data)).toList(growable: false);
    });
  }

  Future<Note> updateNote({
    required String id,
    required String title,
    required String body,
  }) async {
    _validateTitle(title);
    return DatabaseBoundary.guard(
      () => _database.transaction(
        () async {
          await _requireActiveNote(id);
          await _database.customStatement(
            'UPDATE notes SET title = ?, body = ?, updated_at = ? '
            'WHERE id = ? AND deleted_at IS NULL',
            <Object?>[title, body, _now(), id],
          );
          return _requireActiveNote(id);
        },
      ),
    );
  }

  Future<Note> moveNote(String id, {String? destinationFolderId}) {
    return DatabaseBoundary.guard(
      () => _database.transaction(
        () async {
          final note = await _requireActiveNote(id);
          if (destinationFolderId != null) {
            await _requireActiveFolder(destinationFolderId);
          }
          if (note.folderId == destinationFolderId) return note;
          final order = await _nextOrder(destinationFolderId);
          await _database.customStatement(
            'UPDATE notes SET folder_id = ?, sort_order = ?, updated_at = ? '
            'WHERE id = ? AND deleted_at IS NULL',
            <Object?>[destinationFolderId, order, _now(), id],
          );
          return _requireActiveNote(id);
        },
      ),
    );
  }

  Future<void> softDeleteNote(String id) {
    return DatabaseBoundary.guard(
      () => _database.transaction(
        () async {
          await _requireActiveNote(id);
          final now = _now();
          await _database.customStatement(
            'UPDATE notes SET deleted_at = ?, updated_at = ? '
            'WHERE id = ? AND deleted_at IS NULL',
            <Object?>[now, now, id],
          );
        },
      ),
    );
  }

  void _validateTitle(String title) {
    if (title.contains('\u0000') ||
        UnicodeCanonicalizer.codePointLength(title) > 255) {
      throw const DomainFailure(
        DomainFailureCode.invalidTitle,
        'Note titles may contain at most 255 Unicode code points.',
      );
    }
  }

  Future<Note> _requireActiveNote(String id) async {
    final rows = await _database.customSelect(
      'SELECT * FROM notes WHERE id = ?',
      variables: <Variable<Object>>[Variable.withString(id)],
    ).get();
    if (rows.isEmpty) {
      throw const DomainFailure(
        DomainFailureCode.notFound,
        'The requested note does not exist.',
      );
    }
    if (rows.single.data['deleted_at'] != null) {
      throw const DomainFailure(
        DomainFailureCode.deletedEntity,
        'The requested note has been deleted.',
      );
    }
    return Note.fromRow(rows.single.data);
  }

  Future<void> _requireActiveFolder(String id) async {
    final rows = await _database.customSelect(
      'SELECT id, deleted_at FROM folders WHERE id = ?',
      variables: <Variable<Object>>[Variable.withString(id)],
    ).get();
    if (rows.isEmpty || rows.single.data['deleted_at'] != null) {
      throw const DomainFailure(
        DomainFailureCode.invalidDestination,
        'The destination folder does not exist or is deleted.',
      );
    }
  }

  Future<int> _nextOrder(String? folderId) async {
    final sql = folderId == null
        ? 'SELECT COALESCE(MAX(sort_order), -1) + 1 AS next_order '
            'FROM notes WHERE folder_id IS NULL AND deleted_at IS NULL'
        : 'SELECT COALESCE(MAX(sort_order), -1) + 1 AS next_order '
            'FROM notes WHERE folder_id = ? AND deleted_at IS NULL';
    final row = await _database.customSelect(
      sql,
      variables: folderId == null
          ? const <Variable<Object>>[]
          : <Variable<Object>>[Variable.withString(folderId)],
    ).getSingle();
    return row.data['next_order']! as int;
  }
}
