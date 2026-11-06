import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yamintto/features/tags/data/tag_providers.dart';
import 'package:yamintto/features/tags/domain/note_tag.dart';

class TagManagementScreen extends ConsumerWidget {
  const TagManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(tagListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Manage tags')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Create tag'),
      ),
      body: tags.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Tags could not be loaded.'),
              TextButton(
                onPressed: () => ref.invalidate(tagListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (items) => items.isEmpty
            ? const Center(child: Text('No tags yet. Create your first tag.'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: items
                    .map(
                      (tag) => ListTile(
                        leading: const Icon(Icons.sell_outlined),
                        title: Text(tag.name),
                        trailing: PopupMenuButton<String>(
                          tooltip: 'Tag actions',
                          onSelected: (action) {
                            if (action == 'rename') {
                              _edit(context, ref, tag);
                            } else if (action == 'delete') {
                              _delete(context, ref, tag);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'rename',
                              child: Text('Rename'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, [
    NoteTag? tag,
  ]) async {
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _TagNameDialog(
        initial: tag?.name ?? '',
        title: tag == null ? 'Create tag' : 'Rename tag',
      ),
    );
    if (value == null || value.trim().isEmpty) return;
    try {
      final repository = await ref.read(tagRepositoryProvider.future);
      if (tag == null) {
        await repository.createTag(value);
      } else {
        await repository.renameTag(tag.id, value);
      }
      ref.invalidate(tagListProvider);
      ref.invalidate(noteTagListProvider);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, NoteTag tag) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete tag?'),
        content: Text('Delete “${tag.name}” and remove it from every note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await (await ref.read(tagRepositoryProvider.future)).deleteTag(tag.id);
      ref.invalidate(tagListProvider);
      ref.invalidate(noteTagListProvider);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

class _TagNameDialog extends StatefulWidget {
  const _TagNameDialog({required this.initial, required this.title});
  final String initial;
  final String title;
  @override
  State<_TagNameDialog> createState() => _TagNameDialogState();
}

class _TagNameDialogState extends State<_TagNameDialog> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: controller,
      autofocus: true,
      maxLength: 64,
      decoration: const InputDecoration(labelText: 'Tag name'),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, controller.text),
        child: const Text('Save'),
      ),
    ],
  );
}
