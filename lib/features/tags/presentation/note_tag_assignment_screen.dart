import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yamintto/features/tags/data/tag_providers.dart';

class NoteTagAssignmentScreen extends ConsumerStatefulWidget {
  const NoteTagAssignmentScreen({required this.noteId, super.key});
  final String noteId;
  @override
  ConsumerState<NoteTagAssignmentScreen> createState() =>
      _NoteTagAssignmentScreenState();
}

class _NoteTagAssignmentScreenState
    extends ConsumerState<NoteTagAssignmentScreen> {
  Set<String> selected = <String>{};
  bool loaded = false;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repository = await ref.read(tagRepositoryProvider.future);
      final assigned = await repository.listNoteTags(widget.noteId);
      if (!mounted) {
        return;
      }
      setState(() {
        selected = assigned.map((tag) => tag.id).toSet();
        loaded = true;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          loaded = true;
          error = 'Assigned tags could not be loaded.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tags = ref.watch(tagListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Note tags')),
      body: tags.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
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
        data: (items) => !loaded
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('Select any number of tags for this note.'),
                  if (error != null) ...[
                    Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          loaded = false;
                          error = null;
                        });
                        _load();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                  if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No tags yet. Create tags to organize this note.',
                      ),
                    ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: items
                        .map(
                          (tag) => FilterChip(
                            label: Text(tag.name),
                            selected: selected.contains(tag.id),
                            onSelected: (value) => setState(() {
                              if (value) {
                                selected.add(tag.id);
                              } else {
                                selected.remove(tag.id);
                              }
                            }),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await context.push('/tags');
                      ref.invalidate(tagListProvider);
                    },
                    icon: const Icon(Icons.sell_outlined),
                    label: const Text('Manage tags'),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: saving || error != null
                        ? null
                        : () async {
                            setState(() => saving = true);
                            try {
                              await (await ref.read(
                                tagRepositoryProvider.future,
                              )).assignTags(widget.noteId, selected.toList());
                              ref.invalidate(
                                noteTagListProvider(widget.noteId),
                              );
                              if (context.mounted) context.pop();
                            } catch (e) {
                              if (mounted) {
                                setState(() {
                                  error = e.toString();
                                  saving = false;
                                });
                              }
                            }
                          },
                    child: saving
                        ? const CircularProgressIndicator()
                        : const Text('Save tags'),
                  ),
                ],
              ),
      ),
    );
  }
}
