import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yamintto/core/database/yamintto_database.dart';
import 'package:yamintto/core/errors/domain_failure.dart';
import 'package:yamintto/features/folders/data/folder_repository.dart';

void main() {
  late YaminttoDatabase database;
  late FolderRepository folders;
  setUp(() {
    database = YaminttoDatabase.inMemory();
    folders = FolderRepository(database);
  });
  tearDown(() => database.close());

  test(
    'stores, changes and resets a folder color without changing metadata',
    () async {
      final folder = await folders.createFolder(name: 'Color test');
      expect(folder.colorArgb, isNull);
      final color = await folders.setFolderColor(folder.id, 0xFFF44336);
      expect(color.colorArgb, 0xFFF44336);
      expect(color.id, folder.id);
      expect(color.name, folder.name);
      expect(color.parentId, folder.parentId);
      expect(color.sortOrder, folder.sortOrder);
      expect(color.createdAt, folder.createdAt);
      expect(color.updatedAt, folder.updatedAt);
      final reset = await folders.setFolderColor(folder.id, null);
      expect(reset.colorArgb, isNull);
    },
  );

  test('rejects colors outside the finite ARGB palette', () async {
    final folder = await folders.createFolder(name: 'Invalid color');
    await expectLater(
      folders.setFolderColor(folder.id, 0xFF123456),
      throwsA(isA<DomainFailure>()),
    );
    expect((await folders.getFolder(folder.id)).colorArgb, isNull);
  });

  test('persists color on a nested folder in SQLite', () async {
    final parent = await folders.createFolder(name: 'Parent');
    final child = await folders.createFolder(
      name: 'Child',
      parentId: parent.id,
    );
    await folders.setFolderColor(child.id, 0xFF673AB7);
    final stored = await database
        .customSelect(
          'SELECT color_argb FROM folders WHERE id = ?',
          variables: [Variable.withString(child.id)],
        )
        .getSingle();
    expect(stored.data['color_argb'], 0xFF673AB7);
  });
}
