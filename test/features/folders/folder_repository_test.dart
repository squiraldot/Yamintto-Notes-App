import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yamintto/core/database/yamintto_database.dart';
import 'package:yamintto/core/errors/domain_failure.dart';
import 'package:yamintto/features/folders/data/folder_repository.dart';

void main() {
  group('FolderRepository', () {
    late YaminttoDatabase database;
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
      folders = FolderRepository(
        database,
        now: () => now++,
        createId: createId,
      );
    });

    tearDown(() async => database.close());

    test('creates, reads and lists root and nested folders', () async {
      final root = await folders.createFolder(name: '  Projects  ');
      final child = await folders.createFolder(
        name: 'Mobile',
        parentId: root.id,
      );
      expect(root.parentId, isNull);
      expect(root.name, 'Projects');
      expect(root.nameKey, 'projects');
      expect(child.parentId, root.id);
      expect((await folders.getFolder(child.id)).name, 'Mobile');
      expect((await folders.listFolders()).single.id, root.id);
      expect((await folders.listFolders(parentId: root.id)).single.id, child.id);
    });

    test('rejects root-level case-only and normalization-equivalent duplicates',
        () async {
      await folders.createFolder(name: 'Work');
      await expectLater(
        folders.createFolder(name: 'work'),
        throwsA(isA<DomainFailure>().having(
          (failure) => failure.code,
          'code',
          DomainFailureCode.nameConflict,
        )),
      );
      await folders.createFolder(name: 'Ａrchive');
      await expectLater(
        folders.createFolder(name: 'Archive'),
        throwsA(isA<DomainFailure>().having(
          (failure) => failure.code,
          'code',
          DomainFailureCode.nameConflict,
        )),
      );
    });

    test('allows equal names in different parents but not the same parent',
        () async {
      final first = await folders.createFolder(name: 'First');
      final second = await folders.createFolder(name: 'Second');
      await folders.createFolder(name: 'Shared', parentId: first.id);
      await folders.createFolder(name: 'Shared', parentId: second.id);
      await expectLater(
        folders.createFolder(name: 'shared', parentId: first.id),
        throwsA(isA<DomainFailure>()),
      );
    });

    test('soft-deleted folders retain identity and reserve their canonical name',
        () async {
      final folder = await folders.createFolder(name: 'Archive');
      await folders.softDeleteFolder(folder.id);
      final stored = await database.customSelect(
        'SELECT id, name_key, deleted_at FROM folders WHERE id = ?',
        variables: [Variable.withString(folder.id)],
      ).getSingle();
      expect(stored.data['id'], folder.id);
      expect(stored.data['name_key'], 'archive');
      expect(stored.data['deleted_at'], isNotNull);
      await expectLater(
        folders.createFolder(name: 'ARCHIVE'),
        throwsA(isA<DomainFailure>().having(
          (failure) => failure.code,
          'code',
          DomainFailureCode.nameConflict,
        )),
      );
    });

    test('renames folders while preserving identity and enforcing sibling keys',
        () async {
      final folder = await folders.createFolder(name: 'Old name');
      now = 4000;
      final renamed = await folders.renameFolder(folder.id, '  New Name  ');
      expect(renamed.id, folder.id);
      expect(renamed.name, 'New Name');
      expect(renamed.nameKey, 'new name');
      expect(renamed.createdAt, folder.createdAt);
      expect(renamed.updatedAt, 4000);
      await folders.createFolder(name: 'Other');
      await expectLater(
        folders.renameFolder(folder.id, 'other'),
        throwsA(isA<DomainFailure>().having(
          (failure) => failure.code,
          'code',
          DomainFailureCode.nameConflict,
        )),
      );
    });

    test('rejects empty, NUL-containing and overlong folder names', () async {
      for (final value in <String>['  \u2003\u00A0', 'a\u0000b', 'x' * 256]) {
        await expectLater(
          folders.createFolder(name: value),
          throwsA(isA<DomainFailure>().having(
            (failure) => failure.code,
            'code',
            DomainFailureCode.invalidName,
          )),
        );
      }
      await folders.createFolder(name: '😀' * 255);
    });

    test('allows depth 32 and rejects depth 33', () async {
      Folder? parent;
      for (var level = 1; level <= 32; level++) {
        parent = await folders.createFolder(
          name: 'Level $level',
          parentId: parent?.id,
        );
      }
      await expectLater(
        folders.createFolder(name: 'Too deep', parentId: parent!.id),
        throwsA(isA<DomainFailure>().having(
          (failure) => failure.code,
          'code',
          DomainFailureCode.depthExceeded,
        )),
      );
    });

    test('prevents self and descendant cycles', () async {
      final parent = await folders.createFolder(name: 'Parent');
      final child = await folders.createFolder(
        name: 'Child',
        parentId: parent.id,
      );
      await expectLater(
        folders.moveFolder(parent.id, destinationParentId: parent.id),
        throwsA(isA<DomainFailure>()),
      );
      await expectLater(
        folders.moveFolder(parent.id, destinationParentId: child.id),
        throwsA(isA<DomainFailure>().having(
          (failure) => failure.code,
          'code',
          DomainFailureCode.hierarchyCycle,
        )),
      );
    });

    test('validates the complete subtree depth before moving', () async {
      final source = await folders.createFolder(name: 'Source');
      var child = await folders.createFolder(name: 'Child', parentId: source.id);
      for (var level = 2; level <= 20; level++) {
        child = await folders.createFolder(
          name: 'Depth $level',
          parentId: child.id,
        );
      }
      var destination = await folders.createFolder(name: 'Destination');
      for (var level = 2; level <= 13; level++) {
        destination = await folders.createFolder(
          name: 'Destination $level',
          parentId: destination.id,
        );
      }
      await expectLater(
        folders.moveFolder(source.id, destinationParentId: destination.id),
        throwsA(isA<DomainFailure>().having(
          (failure) => failure.code,
          'code',
          DomainFailureCode.depthExceeded,
        )),
      );
      expect((await folders.getFolder(source.id)).parentId, isNull);
    });

    test('moves a folder atomically and only updates the moved folder timestamp',
        () async {
      final sourceParent = await folders.createFolder(name: 'Source parent');
      final destination = await folders.createFolder(name: 'Destination');
      final source = await folders.createFolder(
        name: 'Moved',
        parentId: sourceParent.id,
      );
      final child = await folders.createFolder(
        name: 'Child',
        parentId: source.id,
      );
      final childBefore = await folders.getFolder(child.id);
      now = 9000;
      final moved = await folders.moveFolder(
        source.id,
        destinationParentId: destination.id,
      );
      final childAfter = await folders.getFolder(child.id);
      expect(moved.parentId, destination.id);
      expect(moved.updatedAt, 9000);
      expect(childAfter.updatedAt, childBefore.updatedAt);
      expect(childAfter.parentId, source.id);
    });

    test('soft-deletes an empty folder without discarding its canonical identity',
        () async {
      final folder = await folders.createFolder(name: '  Empty  ');
      now = 7000;
      await folders.softDeleteFolder(folder.id);
      final stored = await database.customSelect(
        'SELECT id, name, name_key, created_at, updated_at, deleted_at '
        'FROM folders WHERE id = ?',
        variables: [Variable.withString(folder.id)],
      ).getSingle();
      expect(stored.data['id'], folder.id);
      expect(stored.data['name'], 'Empty');
      expect(stored.data['name_key'], 'empty');
      expect(stored.data['created_at'], folder.createdAt);
      expect(stored.data['updated_at'], 7000);
      expect(stored.data['deleted_at'], 7000);
    });

    test('only deletes an empty folder, counting deleted child rows too',
        () async {
      final parent = await folders.createFolder(name: 'Parent');
      final child = await folders.createFolder(name: 'Child', parentId: parent.id);
      await folders.softDeleteFolder(child.id);
      await expectLater(
        folders.softDeleteFolder(parent.id),
        throwsA(isA<DomainFailure>().having(
          (failure) => failure.code,
          'code',
          DomainFailureCode.folderNotEmpty,
        )),
      );
    });
  });
}
