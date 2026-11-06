import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yamintto/core/errors/domain_failure.dart';
import 'package:yamintto/core/theme/tokens/app_spacing.dart';
import 'package:yamintto/features/notes/data/note_providers.dart';
import 'package:yamintto/features/notes/domain/note.dart';
import 'package:yamintto/features/notes/domain/note_content_format.dart';
import 'package:yamintto/features/notes/presentation/note_autosave_coordinator.dart';
import 'package:yamintto/features/notes/presentation/note_providers.dart';
import 'package:yamintto/features/notes/presentation/safe_markdown_viewer.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({this.noteId, this.folderId, super.key});

  final String? noteId;
  final String? folderId;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen>
    with WidgetsBindingObserver {
  late final TextEditingController _title;
  late final TextEditingController _body;
  late final NoteAutosaveCoordinator _autosave;

  bool _initialized = false;
  bool _showPreview = false;
  bool _isSaving = false;
  bool _saveError = false;
  bool _isDirty = false;
  bool _unsupportedFormat = false;
  bool _bodyEdited = false;
  String? _savedNoteId;
  String? _activeFolderId;
  String _initialBody = '';
  int _contentFormatVersion = NoteContentFormat.hybridMarkdown;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _activeFolderId = widget.folderId;
    _title = TextEditingController();
    _body = TextEditingController();
    _autosave = NoteAutosaveCoordinator(
      save: _persistSnapshot,
      onStateChanged: _handleAutosaveStateChanged,
    );
    if (widget.noteId == null) {
      _initialized = true;
      _attachListeners();
    }
  }

  void _attachListeners() {
    _title.addListener(_handleEdit);
    _body.addListener(_handleEdit);
  }

  void _handleEdit() {
    if (!_initialized || _unsupportedFormat) return;
    _bodyEdited = _body.text != _initialBody;
    _isDirty = true;
    _saveError = false;
    _autosave.update(title: _title.text, body: _body.text);
  }

  void _handleAutosaveStateChanged() {
    if (!mounted) return;
    setState(() {
      _isSaving = _autosave.isSaving;
      _saveError = _autosave.hasError;
      if (_autosave.isSaved) {
        _isDirty = false;
        _bodyEdited = _body.text != _initialBody;
      }
    });
  }

  void _initializeFromNote(Note note) {
    if (_initialized) return;
    _activeFolderId = note.folderId;
    _savedNoteId = note.id;
    _title.text = note.title;
    _body.text = note.body;
    _initialBody = _body.text;
    _contentFormatVersion = note.contentFormatVersion;
    _unsupportedFormat = !NoteContentFormat.isSupported(_contentFormatVersion);
    _initialized = true;
    _attachListeners();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.noteId != null) {
      final existing = ref.watch(noteDetailProvider(widget.noteId!));
      return existing.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, _) => Scaffold(
          appBar: AppBar(title: const Text('Note unavailable')),
          body: Center(child: Text(_message(error))),
        ),
        data: (note) {
          _initializeFromNote(note);
          return _editor(context);
        },
      );
    }
    return _editor(context);
  }

  Widget _editor(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSaving ? null : _handleBack,
        ),
        title: Text(widget.noteId == null ? 'New note' : 'Edit note'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (_saveError)
            TextButton(onPressed: _retrySave, child: const Text('Retry'))
          else if (_autosave.isSaved)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Center(child: Text('Saved')),
            )
          else if (_isDirty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Center(child: Text('Saving soon')),
            ),
          TextButton(
            onPressed: _isSaving ? null : _saveNow,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_unsupportedFormat) ...[
              Text(
                'Unsupported content format',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              const Text(
                'This note uses a newer content format. Its source is read-only '
                'so it cannot be accidentally overwritten.',
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              key: const ValueKey('note-title-editor'),
              controller: _title,
              readOnly: _unsupportedFormat,
              maxLength: 255,
              maxLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Untitled note',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                TextButton(
                  onPressed: _showPreview
                      ? () => setState(() => _showPreview = false)
                      : null,
                  child: const Text('Editor'),
                ),
                TextButton(
                  onPressed: _unsupportedFormat || _showPreview
                      ? null
                      : _openPreview,
                  child: const Text('Preview'),
                ),
                const Spacer(),
                if (_saveError)
                  Text(
                    'Save error',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(child: _editorContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _editorContent(BuildContext context) {
    if (!_showPreview) {
      return TextField(
        key: const ValueKey('note-body-editor'),
        controller: _body,
        readOnly: _unsupportedFormat,
        expands: true,
        minLines: null,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        textAlignVertical: TextAlignVertical.top,
        decoration: const InputDecoration(
          labelText: 'Note content',
          alignLabelWithHint: true,
          border: OutlineInputBorder(),
        ),
      );
    }

    if (_contentFormatVersion == NoteContentFormat.plainText && !_bodyEdited) {
      return SingleChildScrollView(child: SelectableText(_body.text));
    }
    return SingleChildScrollView(child: SafeMarkdownViewer(source: _body.text));
  }

  Future<void> _openPreview() async {
    try {
      await _autosave.flush();
      if (!mounted) return;
      setState(() => _showPreview = true);
    } catch (_) {
      // Keep the editable source visible when a save fails.
    }
  }

  Future<void> _saveNow() async {
    try {
      await _autosave.flush();
    } catch (_) {
      // The status row exposes a retry action and keeps the source intact.
    }
  }

  Future<void> _retrySave() async {
    try {
      await _autosave.retry();
    } catch (_) {
      // Keep the error state and source available for another retry.
    }
  }

  Future<void> _handleBack() async {
    try {
      await _autosave.flush();
    } catch (_) {
      return;
    }
    if (mounted) context.pop();
  }

  Future<void> _persistSnapshot(NoteSaveSnapshot snapshot) async {
    final repository = await ref.read(noteRepositoryProvider.future);
    final saved = _savedNoteId == null
        ? await repository.createNote(
            folderId: _activeFolderId,
            title: snapshot.title,
            body: snapshot.body,
            contentFormatVersion: NoteContentFormat.hybridMarkdown,
          )
        : await repository.updateNote(
            id: _savedNoteId!,
            title: snapshot.title,
            body: snapshot.body,
          );

    _savedNoteId = saved.id;
    _contentFormatVersion = saved.contentFormatVersion;
    _initialBody = snapshot.body;
    _bodyEdited = _body.text != _initialBody;
    if (mounted) {
      ref.invalidate(noteListProvider(_activeFolderId));
      ref.invalidate(noteDetailProvider(saved.id));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_autosave.flush().catchError((Object _) {}));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autosave.dispose();
    _title.dispose();
    _body.dispose();
    super.dispose();
  }
}

String _message(Object error) => error is DomainFailure
    ? error.message
    : 'The note could not be saved. Your text is still available; please try again.';
