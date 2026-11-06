import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:yamintto/core/database/yamintto_database.dart';
import 'package:yamintto/features/notes/data/note_repository.dart';
import 'package:yamintto/features/notes/domain/hybrid_markdown_parser.dart';
import 'package:yamintto/features/notes/domain/note_content_format.dart';
import 'package:yamintto/features/notes/presentation/note_autosave_coordinator.dart';

/// Owner-run on real Android/iOS hardware only. Never run in CI or a simulator.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test('Phase 03 rapid edits flush and survive database reopen', () async {
    final support = await getApplicationSupportDirectory();
    final directory = Directory(path.join(support.path, 'database'));
    await directory.create(recursive: true);
    final file = File(path.join(directory.path, 'yamintto.sqlite'));

    final database = YaminttoDatabase.open(file);
    final notes = NoteRepository(database);
    final note = await notes.createNote(
      title: 'Phase 03',
      body: 'initial',
      contentFormatVersion: NoteContentFormat.hybridMarkdown,
    );
    var expectedUpdatedAt = note.updatedAt;
    final autosave = NoteAutosaveCoordinator(
      save: (snapshot) async {
        final updated = await notes.updateNote(
          id: note.id,
          title: snapshot.title,
          body: snapshot.body,
          expectedUpdatedAt: expectedUpdatedAt,
        );
        expectedUpdatedAt = updated.updatedAt;
      },
    );

    autosave.update(title: 'First', body: '# first revision');
    autosave.update(
      title: 'Final title',
      body: '# final revision\n\n- [ ] source preserved',
    );
    await autosave.flush();
    expect(autosave.isSaved, isTrue);
    await database.close();

    final reopened = YaminttoDatabase.open(file);
    final persisted = await NoteRepository(reopened).getNote(note.id);
    expect(persisted.title, 'Final title');
    expect(persisted.body, '# final revision\n\n- [ ] source preserved');
    expect(persisted.contentFormatVersion, NoteContentFormat.hybridMarkdown);

    final beforePreview = persisted.body;
    const HybridMarkdownParser().parse(beforePreview);
    expect((await NoteRepository(reopened).getNote(note.id)).body, beforePreview);
    autosave.dispose();
    await reopened.close();
  });
}
