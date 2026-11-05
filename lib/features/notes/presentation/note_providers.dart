import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yamintto/features/notes/data/note_providers.dart';
import 'package:yamintto/features/notes/domain/note.dart';

final noteListProvider = FutureProvider.family<List<Note>, String?>((
  ref,
  folderId,
) async {
  final repository = await ref.watch(noteRepositoryProvider.future);
  return repository.listNotes(folderId: folderId);
});

final noteDetailProvider = FutureProvider.family<Note, String>((ref, id) async {
  final repository = await ref.watch(noteRepositoryProvider.future);
  return repository.getNote(id);
});
