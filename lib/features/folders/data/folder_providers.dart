import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yamintto/app/providers/database_provider.dart';
import 'package:yamintto/features/folders/data/folder_repository.dart';

final folderRepositoryProvider = FutureProvider<FolderRepository>((ref) async {
  final database = await ref.watch(databaseProvider.future);
  return FolderRepository(database);
});
