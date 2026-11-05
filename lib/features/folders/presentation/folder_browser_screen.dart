import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yamintto/core/errors/domain_failure.dart';
import 'package:yamintto/core/theme/tokens/app_spacing.dart';
import 'package:yamintto/features/folders/data/folder_providers.dart';
import 'package:yamintto/features/folders/domain/folder.dart';
import 'package:yamintto/features/folders/presentation/folder_providers.dart';
import 'package:yamintto/features/notes/data/note_providers.dart';
import 'package:yamintto/features/notes/domain/note.dart';
import 'package:yamintto/features/notes/presentation/note_providers.dart';

const _cancel = '__cancel__';

class FolderBrowserScreen extends ConsumerWidget {
  const FolderBrowserScreen({this.folderId, super.key});
  final String? folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders = ref.watch(folderListProvider(folderId));
    final notes = ref.watch(noteListProvider(folderId));
    final current = folderId == null
        ? null
        : ref.watch(folderDetailProvider(folderId!));
    final title =
        current?.when(
          data: (f) => f.name,
          loading: () => 'Loading folder…',
          error: (_, _) => 'Folder unavailable',
        ) ??
        'Yamintto';
    return Scaffold(
      appBar: AppBar(
        leading: folderId == null
            ? null
            : BackButton(onPressed: () => _parent(context, ref)),
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Appearance preview',
            onPressed: () => context.push('/appearance'),
            icon: const Icon(Icons.palette_outlined),
          ),
          IconButton(
            tooltip: 'Create folder',
            onPressed: () => _create(context, ref),
            icon: const Icon(Icons.create_new_folder_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/notes/new', extra: folderId),
        icon: const Icon(Icons.note_add_outlined),
        label: const Text('New note'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(folderListProvider(folderId));
          ref.invalidate(noteListProvider(folderId));
          if (folderId != null) ref.invalidate(folderDetailProvider(folderId!));
          await Future.wait([
            ref.read(folderListProvider(folderId).future),
            ref.read(noteListProvider(folderId).future),
          ]);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            if (folderId != null)
              TextButton.icon(
                onPressed: () => _parent(context, ref),
                icon: const Icon(Icons.arrow_upward),
                label: const Text('Parent folder'),
              ),
            Text(
              folderId == null ? 'Folders' : 'Subfolders',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            folders.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => _Error(
                message: _message(e),
                retry: () => ref.invalidate(folderListProvider(folderId)),
              ),
              data: (items) => items.isEmpty
                  ? const _Empty('No folders here yet.')
                  : Column(
                      children: items
                          .map(
                            (f) => _FolderRow(
                              folder: f,
                              open: () => context.push('/folders/${f.id}'),
                              rename: () => _rename(context, ref, f),
                              move: () => _moveFolder(context, ref, f),
                              delete: () => _deleteFolder(context, ref, f),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Notes', style: Theme.of(context).textTheme.titleMedium),
            notes.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => _Error(
                message: _message(e),
                retry: () => ref.invalidate(noteListProvider(folderId)),
              ),
              data: (items) => items.isEmpty
                  ? const _Empty('No notes here yet.')
                  : Column(
                      children: items
                          .map(
                            (n) => _NoteRow(
                              note: n,
                              open: () => context.push('/notes/${n.id}/edit'),
                              move: () => _moveNote(context, ref, n),
                              delete: () => _deleteNote(context, ref, n),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 88),
          ],
        ),
      ),
    );
  }

  Future<void> _parent(BuildContext context, WidgetRef ref) async {
    if (folderId == null) return;
    try {
      final f = await ref.read(folderDetailProvider(folderId!).future);
      if (!context.mounted) return;
      if (f.parentId == null) {
        context.go('/');
      } else {
        context.go('/folders/${f.parentId!}');
      }
    } catch (_) {
      if (context.mounted) context.go('/');
    }
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final name = await _name(context, 'Create folder', '');
    if (name == null || name.trim().isEmpty) return;
    try {
      await (await ref.read(folderRepositoryProvider.future))
          .createFolder(name: name, parentId: folderId);
      ref.invalidate(folderListProvider(folderId));
      ref.invalidate(allFoldersProvider);
    } catch (e) {
      if (context.mounted) _error(context, e);
    }
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    Folder folder,
  ) async {
    final name = await _name(context, 'Rename folder', folder.name);
    if (name == null) return;
    try {
      await (await ref.read(folderRepositoryProvider.future))
          .renameFolder(folder.id, name);
      ref.invalidate(folderListProvider(folder.parentId));
      ref.invalidate(folderDetailProvider(folder.id));
    } catch (e) {
      if (context.mounted) _error(context, e);
    }
  }

  Future<void> _moveFolder(
    BuildContext context,
    WidgetRef ref,
    Folder folder,
  ) async {
    final destination = await _destination(
      context,
      ref,
      folder.id,
      folder.parentId,
    );
    if (destination == _cancel) return;
    try {
      await (await ref.read(folderRepositoryProvider.future))
          .moveFolder(folder.id, destinationParentId: destination);
      ref.invalidate(folderListProvider(folder.parentId));
      ref.invalidate(folderListProvider(destination));
      ref.invalidate(allFoldersProvider);
    } catch (e) {
      if (context.mounted) _error(context, e);
    }
  }

  Future<void> _deleteFolder(
    BuildContext context,
    WidgetRef ref,
    Folder folder,
  ) async {
    final yes = await _confirm(
      context,
      'Delete empty folder?',
      'Only an empty folder can be deleted. Child folders and all notes, including soft-deleted notes, prevent deletion. The folder is retained as soft-deleted data.',
    );
    if (yes != true) return;
    try {
      await (await ref.read(folderRepositoryProvider.future))
          .softDeleteFolder(folder.id);
      ref.invalidate(folderListProvider(folder.parentId));
      ref.invalidate(allFoldersProvider);
    } catch (e) {
      if (context.mounted) _error(context, e);
    }
  }

  Future<void> _moveNote(BuildContext context, WidgetRef ref, Note note) async {
    final destination = await _destination(context, ref, null, note.folderId);
    if (destination == _cancel) return;
    try {
      await (await ref.read(noteRepositoryProvider.future))
          .moveNote(note.id, destinationFolderId: destination);
      ref.invalidate(noteListProvider(note.folderId));
      ref.invalidate(noteListProvider(destination));
    } catch (e) {
      if (context.mounted) _error(context, e);
    }
  }

  Future<void> _deleteNote(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) async {
    final yes = await _confirm(
      context,
      'Delete note?',
      'The note will be soft-deleted and hidden from active lists. Its content, folder and order are retained.',
    );
    if (yes != true) return;
    try {
      await (await ref.read(noteRepositoryProvider.future))
          .softDeleteNote(note.id);
      ref.invalidate(noteListProvider(note.folderId));
    } catch (e) {
      if (context.mounted) _error(context, e);
    }
  }
}

Future<String?> _name(BuildContext context, String title, String initial) =>
    showDialog<String>(
      context: context,
      builder: (dialogContext) =>
          _FolderNameDialog(title: title, initial: initial),
    );

class _FolderNameDialog extends StatefulWidget {
  const _FolderNameDialog({required this.title, required this.initial});

  final String title;
  final String initial;

  @override
  State<_FolderNameDialog> createState() => _FolderNameDialogState();
}

class _FolderNameDialogState extends State<_FolderNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: _controller,
      autofocus: true,
      maxLength: 255,
      decoration: const InputDecoration(labelText: 'Folder name'),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _controller.text),
        child: const Text('Save'),
      ),
    ],
  );
}

Future<String?> _destination(
  BuildContext context,
  WidgetRef ref,
  String? movingId,
  String? current,
) async {
  final folders = await ref.read(allFoldersProvider.future);
  if (!context.mounted) return _cancel;
  final excludedIds = <String>{};
  if (movingId != null) {
    final childrenByParent = <String, List<String>>{};
    for (final folder in folders) {
      final parentId = folder.parentId;
      if (parentId != null) {
        childrenByParent.putIfAbsent(parentId, () => <String>[]).add(folder.id);
      }
    }
    final pending = <String>[movingId];
    while (pending.isNotEmpty) {
      final parentId = pending.removeLast();
      for (final childId in childrenByParent[parentId] ?? const <String>[]) {
        if (excludedIds.add(childId)) pending.add(childId);
      }
    }
  }
  final choices = folders
      .where(
        (folder) => folder.id != movingId && !excludedIds.contains(folder.id),
      )
      .toList();
  String? selected = current;
  final result = await showDialog<String>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Move to folder'),
      content: DropdownButtonFormField<String?>(
        initialValue: selected,
        decoration: const InputDecoration(labelText: 'Destination'),
        items: [
          const DropdownMenuItem<String?>(value: null, child: Text('Root')),
          ...choices.map(
            (f) => DropdownMenuItem<String?>(value: f.id, child: Text(f.name)),
          ),
        ],
        onChanged: (v) => selected = v,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, _cancel),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(c, selected ?? ''),
          child: const Text('Move'),
        ),
      ],
    ),
  );
  if (result == _cancel) return _cancel;
  return result == '' ? null : result;
}

Future<bool?> _confirm(BuildContext context, String title, String message) =>
    showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

void _error(BuildContext context, Object e) =>
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(_message(e))));
String _message(Object e) => e is DomainFailure
    ? e.message
    : 'The operation could not be completed. Please try again.';

class _FolderRow extends StatelessWidget {
  const _FolderRow({
    required this.folder,
    required this.open,
    required this.rename,
    required this.move,
    required this.delete,
  });
  final Folder folder;
  final VoidCallback open, rename, move, delete;
  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.folder_outlined),
    title: Text(folder.name),
    onTap: open,
    trailing: PopupMenuButton<String>(
      tooltip: 'Folder actions',
      onSelected: (v) {
        if (v == 'rename') rename();
        if (v == 'move') move();
        if (v == 'delete') delete();
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'rename', child: Text('Rename')),
        PopupMenuItem(value: 'move', child: Text('Move')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    ),
  );
}

class _NoteRow extends StatelessWidget {
  const _NoteRow({
    required this.note,
    required this.open,
    required this.move,
    required this.delete,
  });
  final Note note;
  final VoidCallback open, move, delete;
  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.description_outlined),
    title: Text(note.title.isEmpty ? 'Untitled note' : note.title),
    subtitle: Text(
      'Updated ${DateTime.fromMillisecondsSinceEpoch(note.updatedAt, isUtc: true).toLocal()}',
    ),
    onTap: open,
    trailing: PopupMenuButton<String>(
      tooltip: 'Note actions',
      onSelected: (v) {
        if (v == 'move') move();
        if (v == 'delete') delete();
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'move', child: Text('Move')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    ),
  );
}

class _Empty extends StatelessWidget {
  const _Empty(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18),
    child: Center(child: Text(message)),
  );
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.retry});
  final String message;
  final VoidCallback retry;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(message),
      TextButton(onPressed: retry, child: const Text('Retry')),
    ],
  );
}
