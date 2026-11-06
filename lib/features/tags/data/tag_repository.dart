import 'package:drift/drift.dart';
import 'package:yamintto/core/database/database_boundary.dart';
import 'package:yamintto/core/database/yamintto_database.dart';
import 'package:yamintto/core/errors/domain_failure.dart';
import 'package:yamintto/core/ids/uuid_v4.dart';
import 'package:yamintto/features/tags/domain/note_tag.dart';

class TagRepository {
  TagRepository(this._database, {String Function()? createId})
      : _createId = createId ?? UuidV4.generate;

  final YaminttoDatabase _database;
  final String Function() _createId;

  Future<NoteTag> createTag(String input) async {
    final name = NoteTag.normalizeName(input);
    final key = NoteTag.canonicalKey(name);
    final id = _createId();
    if (!UuidV4.isCanonical(id)) {
      throw const DomainFailure(
        DomainFailureCode.databaseConstraint,
        'The generated tag identifier is invalid.',
      );
    }
    try {
      return await _database.transaction(() async {
        final duplicate = await _database.customSelect(
          'SELECT id FROM tags WHERE name_key = ?',
          variables: <Variable<Object>>[Variable.withString(key)],
        ).get();
        if (duplicate.isNotEmpty) {
          throw const DomainFailure(
            DomainFailureCode.nameConflict,
            'A tag with this name already exists.',
          );
        }
        await _database.customStatement(
          'INSERT INTO tags(id, name, name_key) VALUES (?, ?, ?)',
          <Object?>[id, name, key],
        );
        return _getTag(id);
      });
    } on DomainFailure {
      rethrow;
    } catch (error) {
      if (error.toString().contains('UNIQUE constraint failed: tags.name_key')) {
        throw const DomainFailure(
          DomainFailureCode.nameConflict,
          'A tag with this name already exists.',
        );
      }
      throw const DomainFailure(
        DomainFailureCode.databaseConstraint,
        'The tag could not be created.',
      );
    }
  }

  Future<List<NoteTag>> listTags() => DatabaseBoundary.guard(() async {
    final rows = await _database.customSelect(
      'SELECT * FROM tags ORDER BY name_key, name, id',
    ).get();
    return rows.map((row) => NoteTag.fromRow(row.data)).toList(growable: false);
  });

  Future<NoteTag> renameTag(String id, String input) async {
    final name = NoteTag.normalizeName(input);
    final key = NoteTag.canonicalKey(name);
    try {
      return await _database.transaction(() async {
        await _getTag(id);
        final duplicate = await _database.customSelect(
          'SELECT id FROM tags WHERE name_key = ? AND id <> ?',
          variables: <Variable<Object>>[
            Variable.withString(key),
            Variable.withString(id),
          ],
        ).get();
        if (duplicate.isNotEmpty) {
          throw const DomainFailure(
            DomainFailureCode.nameConflict,
            'A tag with this name already exists.',
          );
        }
        await _database.customStatement(
          'UPDATE tags SET name = ?, name_key = ? WHERE id = ?',
          <Object?>[name, key, id],
        );
        return _getTag(id);
      });
    } on DomainFailure {
      rethrow;
    } catch (error) {
      if (error.toString().contains('UNIQUE constraint failed: tags.name_key')) {
        throw const DomainFailure(
          DomainFailureCode.nameConflict,
          'A tag with this name already exists.',
        );
      }
      throw const DomainFailure(
        DomainFailureCode.databaseConstraint,
        'The tag could not be renamed.',
      );
    }
  }

  Future<void> deleteTag(String id) => DatabaseBoundary.guard(
    () => _database.transaction(() async {
      await _getTag(id);
      await _database.customStatement('DELETE FROM note_tags WHERE tag_id = ?', <Object?>[id]);
      await _database.customStatement('DELETE FROM tags WHERE id = ?', <Object?>[id]);
    }),
  );

  Future<List<NoteTag>> listNoteTags(String noteId) => DatabaseBoundary.guard(() async {
    final rows = await _database.customSelect(
      'SELECT tags.* FROM tags INNER JOIN note_tags ON note_tags.tag_id = tags.id '
      'WHERE note_tags.note_id = ? ORDER BY tags.name_key, tags.name, tags.id',
      variables: <Variable<Object>>[Variable.withString(noteId)],
    ).get();
    return rows.map((row) => NoteTag.fromRow(row.data)).toList(growable: false);
  });

  Future<void> assignTags(String noteId, List<String> tagIds) =>
      DatabaseBoundary.guard(() => _database.transaction(() async {
        final note = await _database.customSelect(
          'SELECT deleted_at FROM notes WHERE id = ?',
          variables: <Variable<Object>>[Variable.withString(noteId)],
        ).get();
        if (note.isEmpty) {
          throw const DomainFailure(DomainFailureCode.notFound, 'The requested note does not exist.');
        }
        if (note.single.data['deleted_at'] != null) {
          throw const DomainFailure(DomainFailureCode.deletedEntity, 'Tags cannot be changed on a deleted note.');
        }
        final ids = tagIds.toSet().toList(growable: false);
        for (final id in ids) {
          await _getTag(id);
        }
        await _database.customStatement('DELETE FROM note_tags WHERE note_id = ?', <Object?>[noteId]);
        for (final id in ids) {
          await _database.customStatement(
            'INSERT INTO note_tags(note_id, tag_id) VALUES (?, ?)',
            <Object?>[noteId, id],
          );
        }
      }));

  Future<void> removeTagFromNote(String noteId, String tagId) =>
      DatabaseBoundary.guard(() => _database.transaction(() async {
        final note = await _database.customSelect(
          'SELECT deleted_at FROM notes WHERE id = ?',
          variables: <Variable<Object>>[Variable.withString(noteId)],
        ).get();
        if (note.isEmpty) {
          throw const DomainFailure(DomainFailureCode.notFound, 'The requested note does not exist.');
        }
        if (note.single.data['deleted_at'] != null) {
          throw const DomainFailure(DomainFailureCode.deletedEntity, 'Tags cannot be changed on a deleted note.');
        }
        await _database.customStatement(
          'DELETE FROM note_tags WHERE note_id = ? AND tag_id = ?',
          <Object?>[noteId, tagId],
        );
      }));

  Future<NoteTag> _getTag(String id) async {
    final rows = await _database.customSelect(
      'SELECT * FROM tags WHERE id = ?',
      variables: <Variable<Object>>[Variable.withString(id)],
    ).get();
    if (rows.isEmpty) {
      throw const DomainFailure(DomainFailureCode.notFound, 'The requested tag does not exist.');
    }
    return NoteTag.fromRow(rows.single.data);
  }
}
