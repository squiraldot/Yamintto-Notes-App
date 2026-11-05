import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:yamintto/core/database/yamintto_database.dart';
import 'package:yamintto/features/folders/data/folder_repository.dart';
import 'package:yamintto/features/notes/data/note_repository.dart';

/// Owner-run on a real Android/iOS device only. Never run in virtual-device CI.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Phase 02 database persists folder and note lifecycle',
    () async {
      final support = await getApplicationSupportDirectory();
      final directory = Directory(path.join(support.path, 'database'));
      await directory.create(recursive: true);
      final file = File(path.join(directory.path, 'yamintto.sqlite'));

      final database = YaminttoDatabase.open(file);
      final folders = FolderRepository(database);
      final notes = NoteRepository(database);

      final marker = DateTime.now().toUtc().microsecondsSinceEpoch;
      final folder = await folders.createFolder(name: 'device-smoke-$marker');
      final note = await notes.createNote(
        folderId: folder.id,
        title: 'Phase 02 device smoke',
        body: 'Persistent source body',
      );
      await database.close();

      final reopened = YaminttoDatabase.open(file);
      final reopenedFolders = FolderRepository(reopened);
      final reopenedNotes = NoteRepository(reopened);
      expect(
        (await reopenedFolders.getFolder(folder.id)).name,
        folder.name,
      );
      expect(
        (await reopenedNotes.getNote(note.id)).body,
        'Persistent source body',
      );

      await reopenedNotes.softDeleteNote(note.id);
      expect(await reopenedNotes.listNotes(folderId: folder.id), isEmpty);
      final retained = await reopened.customSelect(
        'SELECT folder_id, body, deleted_at FROM notes WHERE id = ?',
        variables: [Variable.withString(note.id)],
      ).getSingle();
      expect(retained.data['folder_id'], folder.id);
      expect(retained.data['body'], 'Persistent source body');
      expect(retained.data['deleted_at'], isNotNull);
      await reopened.close();
    },
  );
}
