import 'package:drift/drift.dart';
import 'package:yamintto/core/database/database_boundary.dart';
import 'package:yamintto/core/database/yamintto_database.dart';
import 'package:yamintto/core/errors/domain_failure.dart';
import 'package:yamintto/core/ids/uuid_v4.dart';
import 'package:yamintto/core/unicode/unicode_canonicalizer.dart';
import 'package:yamintto/features/folders/domain/folder.dart';

class FolderRepository {
  FolderRepository(
    this._database, {
    int Function()? now,
    String Function()? createId,
  }) : _now = now ?? _utcNow,
       _createId = createId ?? UuidV4.generate;

  final YaminttoDatabase _database;
  final int Function() _now;
  final String Function() _createId;

  static int _utcNow() => DateTime.now().toUtc().millisecondsSinceEpoch;

  Future<Folder> createFolder({required String name, String? parentId, int? colorArgb}) async {
    final displayName = _validatedName(name);
    _validateColor(colorArgb);
    final nameKey = UnicodeCanonicalizer.canonicalizeFolderName(displayName);
    try {
      return await _database.transaction(() async {
        if (parentId != null) {
          await _requireActiveFolder(parentId);
        }
        final parentLevel = parentId == null ? 0 : await _folderLevel(parentId);
        if (parentLevel + 1 > 32) {
          throw const DomainFailure(
            DomainFailureCode.depthExceeded,
            'Folders cannot be nested deeper than 32 levels.',
          );
        }
        await _ensureNameAvailable(parentId, nameKey);
        final now = _now();
        final id = _createId();
        if (!UuidV4.isCanonical(id)) {
          throw const DomainFailure(
            DomainFailureCode.databaseConstraint,
            'The generated folder identifier is invalid.',
          );
        }
        final order = await _nextFolderOrder(parentId);
        await _database.customStatement(
          'INSERT INTO folders '
          '(id, parent_id, name, name_key, sort_order, created_at, updated_at, color_argb) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
          <Object?>[id, parentId, displayName, nameKey, order, now, now, colorArgb],
        );
        return _requireActiveFolder(id);
      });
    } catch (error) {
      _rethrowMapped(error, nameConflict: true);
    }
  }

  Future<List<Folder>> listFolders({String? parentId}) {
    return DatabaseBoundary.guard(() async {
      if (parentId != null) {
        await _requireActiveFolder(parentId);
      }
      final sql = parentId == null
          ? 'SELECT * FROM folders WHERE parent_id IS NULL '
                'AND deleted_at IS NULL ORDER BY sort_order, created_at, id'
          : 'SELECT * FROM folders WHERE parent_id = ? AND deleted_at IS NULL '
                'ORDER BY sort_order, created_at, id';
      final rows = await _database
          .customSelect(
            sql,
            variables: parentId == null
                ? const <Variable<Object>>[]
                : <Variable<Object>>[Variable.withString(parentId)],
          )
          .get();
      return rows
          .map((row) => Folder.fromRow(row.data))
          .toList(growable: false);
    });
  }

  Future<Folder> getFolder(String id) {
    return DatabaseBoundary.guard(() => _requireActiveFolder(id));
  }

  Future<Folder> renameFolder(String id, String name) async {
    final displayName = _validatedName(name);
    final nameKey = UnicodeCanonicalizer.canonicalizeFolderName(displayName);
    try {
      return await _database.transaction(() async {
        final folder = await _requireActiveFolder(id);
        await _ensureNameAvailable(folder.parentId, nameKey, exceptId: id);
        await _database.customStatement(
          'UPDATE folders SET name = ?, name_key = ?, updated_at = ? '
          'WHERE id = ?',
          <Object?>[displayName, nameKey, _now(), id],
        );
        return _requireActiveFolder(id);
      });
    } catch (error) {
      _rethrowMapped(error, nameConflict: true);
    }
  }

  Future<Folder> moveFolder(String id, {String? destinationParentId}) async {
    try {
      return await _database.transaction(() async {
        final source = await _requireActiveFolder(id);
        if (destinationParentId != null) {
          await _requireActiveFolder(destinationParentId);
        }
        if (source.parentId == destinationParentId) return source;

        final subtree = await _collectSubtree(id);
        if (destinationParentId != null &&
            subtree.ids.contains(destinationParentId)) {
          throw const DomainFailure(
            DomainFailureCode.hierarchyCycle,
            'A folder cannot be moved into itself or one of its descendants.',
          );
        }

        final destinationLevel = destinationParentId == null
            ? 0
            : await _folderLevel(destinationParentId);
        if (destinationLevel + 1 + subtree.height > 32) {
          throw const DomainFailure(
            DomainFailureCode.depthExceeded,
            'Moving this folder would exceed the 32-level hierarchy limit.',
          );
        }

        await _ensureNameAvailable(
          destinationParentId,
          source.nameKey,
          exceptId: id,
        );
        final order = await _nextFolderOrder(destinationParentId);
        await _database.customStatement(
          'UPDATE folders SET parent_id = ?, sort_order = ?, updated_at = ? '
          'WHERE id = ?',
          <Object?>[destinationParentId, order, _now(), id],
        );
        return _requireActiveFolder(id);
      });
    } catch (error) {
      _rethrowMapped(error, nameConflict: true);
    }
  }

  Future<void> softDeleteFolder(String id) {
    return DatabaseBoundary.guard(
      () => _database.transaction(() async {
        await _requireActiveFolder(id);
        final children = await _database
            .customSelect(
              'SELECT EXISTS(SELECT 1 FROM folders WHERE parent_id = ?) '
              'AS has_folders, '
              'EXISTS(SELECT 1 FROM notes WHERE folder_id = ?) AS has_notes',
              variables: <Variable<Object>>[
                Variable.withString(id),
                Variable.withString(id),
              ],
            )
            .getSingle();
        if (children.data['has_folders'] == 1 ||
            children.data['has_notes'] == 1) {
          throw const DomainFailure(
            DomainFailureCode.folderNotEmpty,
            'Only an empty folder can be deleted.',
          );
        }
        final now = _now();
        await _database.customStatement(
          'UPDATE folders SET deleted_at = ?, updated_at = ? '
          'WHERE id = ? AND deleted_at IS NULL',
          <Object?>[now, now, id],
        );
      }),
    );
  }


  Future<Folder> setFolderColor(String id, int? colorArgb) async {
    _validateColor(colorArgb);
    return DatabaseBoundary.guard(() => _database.transaction(() async {
      await _requireActiveFolder(id);
      await _database.customStatement(
        'UPDATE folders SET color_argb = ? WHERE id = ? AND deleted_at IS NULL',
        <Object?>[colorArgb, id],
      );
      return _requireActiveFolder(id);
    }));
  }

  void _validateColor(int? colorArgb) {
    const allowed = <int>{
      4294198070, 4293467747, 4294940672, 4294961979, 4283215696,
      4278228616, 4282339765, 4284955319, 4278430196, 4294951175,
    };
    if (colorArgb != null && !allowed.contains(colorArgb)) {
      throw const DomainFailure(
        DomainFailureCode.invalidColor,
        'Choose a color from the available folder palette.',
      );
    }
  }

  String _validatedName(String input) {
    final name = UnicodeCanonicalizer.trimWhiteSpace(input);
    if (name.isEmpty ||
        name.contains('\u0000') ||
        UnicodeCanonicalizer.codePointLength(name) > 255) {
      throw const DomainFailure(
        DomainFailureCode.invalidName,
        'Folder names must contain 1–255 Unicode code points after trimming.',
      );
    }
    return name;
  }

  Future<Folder> _requireActiveFolder(String id) async {
    final rows = await _database
        .customSelect(
          'SELECT * FROM folders WHERE id = ? AND deleted_at IS NULL',
          variables: <Variable<Object>>[Variable.withString(id)],
        )
        .get();
    if (rows.isEmpty) {
      throw const DomainFailure(
        DomainFailureCode.notFound,
        'The requested folder does not exist.',
      );
    }
    return Folder.fromRow(rows.single.data);
  }

  Future<void> _ensureNameAvailable(
    String? parentId,
    String nameKey, {
    String? exceptId,
  }) async {
    final parentClause = parentId == null
        ? 'parent_id IS NULL'
        : 'parent_id = ?';
    final exceptClause = exceptId == null ? '' : ' AND id <> ?';
    final variables = <Variable<Object>>[];
    if (parentId != null) {
      variables.add(Variable.withString(parentId));
    }
    variables.add(Variable.withString(nameKey));
    if (exceptId != null) {
      variables.add(Variable.withString(exceptId));
    }
    final rows = await _database
        .customSelect(
          'SELECT id FROM folders WHERE $parentClause '
          'AND name_key = ?$exceptClause LIMIT 1',
          variables: variables,
        )
        .get();
    if (rows.isNotEmpty) {
      throw const DomainFailure(
        DomainFailureCode.nameConflict,
        'A folder with this name already exists in the destination.',
      );
    }
  }

  Future<int> _nextFolderOrder(String? parentId) async {
    final sql = parentId == null
        ? 'SELECT COALESCE(MAX(sort_order), -1) + 1 AS next_order '
              'FROM folders WHERE parent_id IS NULL AND deleted_at IS NULL'
        : 'SELECT COALESCE(MAX(sort_order), -1) + 1 AS next_order '
              'FROM folders WHERE parent_id = ? AND deleted_at IS NULL';
    final row = await _database
        .customSelect(
          sql,
          variables: parentId == null
              ? const <Variable<Object>>[]
              : <Variable<Object>>[Variable.withString(parentId)],
        )
        .getSingle();
    return row.data['next_order']! as int;
  }

  Future<int> _folderLevel(String id) async {
    var cursor = id;
    var level = 0;
    final visited = <String>{};
    while (true) {
      if (!visited.add(cursor)) {
        throw const DomainFailure(
          DomainFailureCode.hierarchyCycle,
          'The stored folder hierarchy contains a cycle.',
        );
      }
      final rows = await _database
          .customSelect(
            'SELECT parent_id, deleted_at FROM folders WHERE id = ?',
            variables: <Variable<Object>>[Variable.withString(cursor)],
          )
          .get();
      if (rows.isEmpty) {
        throw const DomainFailure(
          DomainFailureCode.invalidDestination,
          'The destination folder does not exist.',
        );
      }
      level++;
      if (rows.single.data['deleted_at'] != null) {
        throw const DomainFailure(
          DomainFailureCode.invalidDestination,
          'The destination folder hierarchy contains a deleted parent.',
        );
      }
      final parent = rows.single.data['parent_id'] as String?;
      if (parent == null) return level;
      cursor = parent;
      if (level > 32) {
        throw const DomainFailure(
          DomainFailureCode.depthExceeded,
          'The stored folder hierarchy exceeds its depth limit.',
        );
      }
    }
  }

  Future<({Set<String> ids, int height})> _collectSubtree(String rootId) async {
    final ids = <String>{rootId};
    final queue = <({String id, int depth})>[(id: rootId, depth: 0)];
    var height = 0;
    for (var index = 0; index < queue.length; index++) {
      final current = queue[index];
      final rows = await _database
          .customSelect(
            'SELECT id FROM folders WHERE parent_id = ?',
            variables: <Variable<Object>>[Variable.withString(current.id)],
          )
          .get();
      for (final row in rows) {
        final childId = row.data['id']! as String;
        if (!ids.add(childId)) {
          throw const DomainFailure(
            DomainFailureCode.hierarchyCycle,
            'The stored folder hierarchy contains a cycle.',
          );
        }
        final depth = current.depth + 1;
        if (depth > 32) {
          throw const DomainFailure(
            DomainFailureCode.depthExceeded,
            'The stored folder hierarchy exceeds its depth limit.',
          );
        }
        if (depth > height) height = depth;
        queue.add((id: childId, depth: depth));
      }
    }
    return (ids: ids, height: height);
  }

  Never _rethrowMapped(Object error, {required bool nameConflict}) {
    if (error is DomainFailure) throw error;
    final message = error.toString();
    if (nameConflict && message.contains('UNIQUE constraint failed')) {
      throw const DomainFailure(
        DomainFailureCode.nameConflict,
        'A folder with this name already exists in the destination.',
      );
    }
    throw const DomainFailure(
      DomainFailureCode.databaseConstraint,
      'The folder operation could not be completed.',
    );
  }
}
