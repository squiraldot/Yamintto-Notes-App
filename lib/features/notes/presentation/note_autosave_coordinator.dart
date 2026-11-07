import 'dart:async';

typedef NoteSaveCallback = Future<void> Function(NoteSaveSnapshot snapshot);
typedef NoteTimerFactory = Timer Function(
  Duration duration,
  void Function() callback,
);

enum NoteAutosaveStatus { idle, dirty, saving, saved, error }

class NoteSaveSnapshot {
  const NoteSaveSnapshot({required this.title, required this.body});

  final String title;
  final String body;

  @override
  bool operator ==(Object other) =>
      other is NoteSaveSnapshot && other.title == title && other.body == body;

  @override
  int get hashCode => Object.hash(title, body);
}

/// Serializes per-editor writes and prevents stale save completions from
/// acknowledging a newer in-memory revision.
class NoteAutosaveCoordinator {
  NoteAutosaveCoordinator({
    required this.save,
    this.debounce = const Duration(milliseconds: 700),
    NoteTimerFactory? timerFactory,
    this.onStateChanged,
  }) : _timerFactory = timerFactory ?? Timer.new;

  final NoteSaveCallback save;
  final Duration debounce;
  final NoteTimerFactory _timerFactory;
  final void Function()? onStateChanged;

  Timer? _timer;
  Future<void>? _flushFuture;
  NoteSaveSnapshot _latest = const NoteSaveSnapshot(title: '', body: '');
  int _editRevision = 0;
  int _savedRevision = 0;
  bool _saving = false;
  bool _hasError = false;
  bool _disposed = false;

  int get editRevision => _editRevision;
  int get savedRevision => _savedRevision;
  bool get isSaving => _saving;
  bool get hasError => _hasError;
  bool get isDirty => _editRevision > _savedRevision;
  bool get isSaved => _editRevision > 0 && !isDirty && !_hasError;
  NoteAutosaveStatus get status {
    if (_hasError) return NoteAutosaveStatus.error;
    if (_saving) return NoteAutosaveStatus.saving;
    if (isDirty) return NoteAutosaveStatus.dirty;
    if (isSaved) return NoteAutosaveStatus.saved;
    return NoteAutosaveStatus.idle;
  }

  void update({required String title, required String body}) {
    if (_disposed) return;
    _latest = NoteSaveSnapshot(title: title, body: body);
    _editRevision++;
    _hasError = false;
    _timer?.cancel();
    _timer = _timerFactory(debounce, () {
      _timer = null;
      unawaited(flush().catchError((Object _) {}));
    });
    _notify();
  }

  Future<void> flush() {
    _timer?.cancel();
    _timer = null;
    final active = _flushFuture;
    if (active != null) return active;
    if (!isDirty) return Future<void>.value();

    final operation = _runFlush().whenComplete(() {
      _flushFuture = null;
      _notify();
    });
    _flushFuture = operation;
    return operation;
  }

  /// Replaces the local draft after an explicit reload of persisted data.
  /// This is called only after a failed flush has completed.
  void resetToSavedSnapshot({
    required String title,
    required String body,
  }) {
    if (_disposed || _flushFuture != null) return;
    _timer?.cancel();
    _timer = null;
    _latest = NoteSaveSnapshot(
      title: title,
      body: body,
    );
    _editRevision++;
    _savedRevision = _editRevision;
    _saving = false;
    _hasError = false;
    _notify();
  }

  Future<void> retry() {
    _hasError = false;
    _notify();
    return flush();
  }

  Future<void> _runFlush() async {
    while (isDirty) {
      final revision = _editRevision;
      final snapshot = _latest;
      _saving = true;
      _hasError = false;
      _notify();
      try {
        await save(snapshot);
      } catch (_) {
        _saving = false;
        _hasError = true;
        _notify();
        rethrow;
      }
      _savedRevision = revision;
      _saving = false;
      _notify();
      // If a newer edit arrived while the write was in flight, loop and
      // persist that newer complete title/body snapshot before reporting Saved.
    }
  }

  void _notify() {
    if (!_disposed) onStateChanged?.call();
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
  }
}
