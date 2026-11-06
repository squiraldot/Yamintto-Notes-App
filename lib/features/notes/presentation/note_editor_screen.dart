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
  late final ScrollController _previewScroll;

  NoteAutosaveCoordinator? _autosave;
  bool _initialized = false;
  bool _preview = false;
  bool _allowPop = false;
  String? _activeFolderId;
  String? _activeNoteId;
  int _contentFormatVersion = NoteContentFormat.hybridMarkdown;
  int? _expectedUpdatedAt;

  bool get _readOnly =>
      !NoteContentFormat.isSupported(_contentFormatVersion);
  bool get _isPending => _autosave?.isDirty ?? false;
  bool get _isSaving => _autosave?.isSaving ?? false;
  bool get _hasError => _autosave?.hasError ?? false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _activeFolderId = widget.folderId;
    _activeNoteId = widget.noteId;
    _title = TextEditingController();
    _body = TextEditingController();
    _previewScroll = ScrollController();
    _title.addListener(_markDirty);
    _body.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_initialized || _readOnly) return;
    _autosave ??= NoteAutosaveCoordinator(
      save: _persistSnapshot,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _autosave!.update(title: _title.text, body: _body.text);
    if (mounted) setState(() {});
  }

  Future<void> _persistSnapshot(NoteSaveSnapshot snapshot) async {
    final repository = await ref.read(noteRepositoryProvider.future);
    if (_activeNoteId == null) {
      final created = await repository.createNote(
        folderId: _activeFolderId,
        title: snapshot.title,
        body: snapshot.body,
        contentFormatVersion: NoteContentFormat.hybridMarkdown,
      );
      _activeNoteId = created.id;
      _contentFormatVersion = created.contentFormatVersion;
      _expectedUpdatedAt = created.updatedAt;
      ref.invalidate(noteListProvider(_activeFolderId));
      return;
    }

    final updated = await repository.updateNote(
      id: _activeNoteId!,
      title: snapshot.title,
      body: snapshot.body,
      expectedUpdatedAt: _expectedUpdatedAt,
    );
    _contentFormatVersion = updated.contentFormatVersion;
    _expectedUpdatedAt = updated.updatedAt;
    ref.invalidate(noteDetailProvider(_activeNoteId!));
    ref.invalidate(noteListProvider(_activeFolderId));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(_flushBestEffort());
    }
  }

  Future<void> _flushBestEffort() async {
    final autosave = _autosave;
    if (autosave == null || !autosave.isDirty) return;
    try {
      await autosave.flush();
    } catch (_) {
      // The editor remains dirty and exposes Retry when the app resumes.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _title.removeListener(_markDirty);
    _body.removeListener(_markDirty);
    _autosave?.dispose();
    _title.dispose();
    _body.dispose();
    _previewScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final existing = _activeNoteId == null
        ? null
        : ref.watch(noteDetailProvider(_activeNoteId!));
    if (existing != null) {
      return existing.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, _) => Scaffold(
          appBar: AppBar(title: const Text('Note unavailable')),
          body: Center(child: Text(_message(error))),
        ),
        data: (note) {
          if (!_initialized) _initializeFromNote(note);
          return _editor(context);
        },
      );
    }
    if (!_initialized) _initialized = true;
    return _editor(context);
  }

  void _initializeFromNote(Note note) {
    _activeFolderId = note.folderId;
    _title.text = note.title;
    _body.text = note.body;
    _contentFormatVersion = note.contentFormatVersion;
    _expectedUpdatedAt = note.updatedAt;
    _initialized = true;
  }

  Widget _editor(BuildContext context) {
    return PopScope(
      canPop: _allowPop || (!_isPending && !_isSaving && !_hasError),
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _allowPop) return;
        await _flushAndPop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBack,
          ),
          title: Text(_screenTitle),
          actions: [
            if (!_readOnly)
              TextButton(
                onPressed: _isSaving ? null : _flushAndPop,
                child: const Text('Save'),
              ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: Row(
                children: [
                  if (!_readOnly)
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(
                          value: false,
                          icon: Icon(Icons.edit_outlined),
                          label: Text('Editor'),
                        ),
                        ButtonSegment<bool>(
                          value: true,
                          icon: Icon(Icons.visibility_outlined),
                          label: Text('Preview'),
                        ),
                      ],
                      selected: <bool>{_preview},
                      onSelectionChanged: (selection) {
                        setState(() => _preview = selection.first);
                      },
                      showSelectedIcon: false,
                    )
                  else
                    const Text('Unsupported content format'),
                  const Spacer(),
                  Semantics(
                    liveRegion: true,
                    label: _statusLabel,
                    child: Text(
                      _statusLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _hasError
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_readOnly)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'This note uses a newer content format. '
                  'Its original source is preserved and editing is disabled '
                  'until this app supports that format.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            Expanded(
              child: ListView(
                controller: _preview ? _previewScroll : null,
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  TextField(
                    key: const ValueKey('note-title-editor'),
                    controller: _title,
                    readOnly: _readOnly,
                    maxLength: 255,
                    maxLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Untitled note',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_preview)
                    _contentPreview(context)
                  else
                    TextField(
                      key: const ValueKey('note-body-editor'),
                      controller: _body,
                      readOnly: _readOnly,
                      minLines: 12,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      enableSuggestions: true,
                      autocorrect: true,
                      decoration: const InputDecoration(
                        labelText: 'Markdown source',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  if (_hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Could not save. Your edits are still here.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _retrySave,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contentPreview(BuildContext context) {
    if (_contentFormatVersion == NoteContentFormat.plainText) {
      return SelectableText(
        _body.text,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    if (_contentFormatVersion == NoteContentFormat.hybridMarkdown) {
      return SafeMarkdownViewer(source: _body.text);
    }
    return SelectableText(_body.text);
  }

  String get _screenTitle {
    if (_readOnly) return 'View note';
    if (_activeNoteId == null) return 'New note';
    return 'Edit note';
  }

  String get _statusLabel {
    if (_hasError) return 'Save error';
    if (_isSaving) return 'Saving…';
    if (_isPending) return 'Unsaved changes';
    if (_activeNoteId != null) return 'Saved';
    return 'Not saved';
  }

  Future<void> _handleBack() async {
    if (!_isPending && !_isSaving && !_hasError) {
      if (mounted) context.pop();
      return;
    }
    await _flushAndPop();
  }

  Future<void> _flushAndPop() async {
    final autosave = _autosave;
    if (autosave != null && (autosave.isDirty || autosave.isSaving)) {
      try {
        await autosave.flush();
      } catch (_) {
        if (mounted) setState(() {});
        return;
      }
      if (!autosave.isSaved && autosave.isDirty) return;
    } else if (_hasError) {
      return;
    }

    if (!mounted) return;
    setState(() => _allowPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) context.pop();
  }

  Future<void> _retrySave() async {
    try {
      await _autosave?.retry();
    } catch (_) {
      if (mounted) setState(() {});
    }
  }
}

String _message(Object error) {
  if (error is DomainFailure) return error.message;
  return 'The note could not be loaded safely. Please try again.';
}
