import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yamintto/app/providers/database_provider.dart';
import 'package:yamintto/features/notes/data/note_repository.dart';

final noteRepositoryProvider = FutureProvider<NoteRepository>((ref) async {
  final database = await ref.watch(databaseProvider.future);
  return NoteRepository(database);
});
