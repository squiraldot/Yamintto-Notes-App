import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yamintto/features/folders/data/folder_providers.dart';
import 'package:yamintto/features/folders/domain/folder.dart';

final folderListProvider = FutureProvider.family<List<Folder>, String?>((ref, parentId) async {
  final repository = await ref.watch(folderRepositoryProvider.future);
  return repository.listFolders(parentId: parentId);
});

final folderDetailProvider = FutureProvider.family<Folder, String>((ref, id) async {
  final repository = await ref.watch(folderRepositoryProvider.future);
  return repository.getFolder(id);
});

final allFoldersProvider = FutureProvider<List<Folder>>((ref) async {
  final repository = await ref.watch(folderRepositoryProvider.future);
  final result = <Folder>[];
  final queue = <String?>[null];
  for (var index = 0; index < queue.length; index++) {
    final children = await repository.listFolders(parentId: queue[index]);
    result.addAll(children);
    queue.addAll(children.map((folder) => folder.id));
  }
  return result;
});
