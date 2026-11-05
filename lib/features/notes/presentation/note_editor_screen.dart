import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yamintto/core/errors/domain_failure.dart';
import 'package:yamintto/core/theme/tokens/app_spacing.dart';
import 'package:yamintto/features/notes/data/note_providers.dart';
import 'package:yamintto/features/notes/presentation/note_providers.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({this.noteId, this.folderId, super.key});
  final String? noteId;
  final String? folderId;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _title;
  late final TextEditingController _body;
  bool _initialized = false;
  bool _saving = false;
  bool _dirty = false;
  String? _activeFolderId;

  @override
  void initState() {
    super.initState();
    _activeFolderId = widget.folderId;
    _title = TextEditingController();
    _body = TextEditingController();
    _title.addListener(_markDirty);
    _body.addListener(_markDirty);
  }

  void _markDirty() {
    if (_initialized && !_dirty) setState(() => _dirty = true);
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.noteId == null
        ? null
        : ref.watch(noteDetailProvider(widget.noteId!));
    if (existing != null) {
      return existing.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, _) => Scaffold(
          appBar: AppBar(title: const Text('Note unavailable')),
          body: Center(child: Text(_message(error))),
        ),
        data: (note) {
          if (!_initialized) {
            _activeFolderId = note.folderId;
            _title.text = note.title;
            _body.text = note.body;
            _initialized = true;
          }
          return _editor(context);
        },
      );
    }
    _initialized = true;
    return _editor(context);
  }

  Widget _editor(BuildContext context) => PopScope(
    canPop: !_dirty && !_saving,
    onPopInvokedWithResult: (didPop, result) async {
      if (didPop || _saving) return;
      if (await _confirmDiscard() && mounted) {
        setState(() => _dirty = false);
        await WidgetsBinding.instance.endOfFrame;
        if (context.mounted) context.pop();
      }
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.noteId == null ? 'New note' : 'Edit note'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          TextField(
            controller: _title,
            maxLength: 255,
            maxLines: 1,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'Untitled note',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _body,
            minLines: 12,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Plain-text body',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    ),
  );

  Future<bool> _confirmDiscard() async =>
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Discard unsaved changes?'),
          content: const Text(
            'Your edits have not been saved. Leave this note without saving?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep editing'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Discard'),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _save() async {
    if (_title.text.contains('\u0000') || _title.text.runes.length > 255) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Title must be 255 Unicode code points or fewer and cannot contain NUL.',
          ),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final repository = await ref.read(noteRepositoryProvider.future);
      if (widget.noteId == null) {
        await repository.createNote(
          folderId: widget.folderId,
          title: _title.text,
          body: _body.text,
        );
      } else {
        await repository.updateNote(
          id: widget.noteId!,
          title: _title.text,
          body: _body.text,
        );
      }
      if (!mounted) return;
      ref.invalidate(noteListProvider(_activeFolderId));
      if (widget.noteId != null) {
        ref.invalidate(noteDetailProvider(widget.noteId!));
      }
      _dirty = false;
      context.pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_message(error))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

String _message(Object error) => error is DomainFailure
    ? error.message
    : 'The note could not be saved. Your text is still available; please try again.';
