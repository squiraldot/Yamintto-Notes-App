import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yamintto/app/providers/database_provider.dart';
import 'package:yamintto/features/tags/data/tag_repository.dart';
import 'package:yamintto/features/tags/domain/note_tag.dart';

final tagRepositoryProvider = FutureProvider<TagRepository>((ref) async {
  final database = await ref.watch(databaseProvider.future);
  return TagRepository(database);
});

final tagListProvider = FutureProvider<List<NoteTag>>((ref) async {
  final repository = await ref.watch(tagRepositoryProvider.future);
  return repository.listTags();
});

final noteTagListProvider = FutureProvider.family<List<NoteTag>, String>((
  ref,
  noteId,
) async {
  final repository = await ref.watch(tagRepositoryProvider.future);
  return repository.listNoteTags(noteId);
});
