import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:yamintto/features/notes/presentation/note_autosave_coordinator.dart';

void main() {
  group('NoteAutosaveCoordinator', () {
    late _FakeTimerFactory timers;

    setUp(() => timers = _FakeTimerFactory());

    test(
      'debounces edits for the configured 700 ms interval',
      () async {
        final saved = <NoteSaveSnapshot>[];
        final coordinator = NoteAutosaveCoordinator(
          save: (snapshot) async => saved.add(snapshot),
          timerFactory: timers.create,
        );
        addTearDown(coordinator.dispose);

        coordinator.update(title: 'One', body: 'Body one');
        expect(timers.latest.duration, const Duration(milliseconds: 700));
        expect(saved, isEmpty);

        timers.latest.fire();
        await coordinator.flush();

        expect(
          saved,
          [const NoteSaveSnapshot(title: 'One', body: 'Body one')],
        );
        expect(coordinator.isSaved, isTrue);
      },
    );

    test(
      'serializes rapid edits and persists the latest revision last',
      () async {
        final firstWrite = Completer<void>();
        final saved = <NoteSaveSnapshot>[];
        final coordinator = NoteAutosaveCoordinator(
          save: (snapshot) async {
            saved.add(snapshot);
            if (saved.length == 1) await firstWrite.future;
          },
          timerFactory: timers.create,
        );
        addTearDown(coordinator.dispose);

        coordinator.update(title: 'First title', body: 'First body');
        final flush = coordinator.flush();
        coordinator.update(title: 'Latest title', body: 'Latest body');
        firstWrite.complete();
        await flush;

        expect(
          saved.map((item) => item.title),
          ['First title', 'Latest title'],
        );
        expect(saved.last.body, 'Latest body');
        expect(coordinator.isSaved, isTrue);
        expect(coordinator.savedRevision, coordinator.editRevision);
      },
    );

    test(
      'keeps dirty state and exposes retry after a write failure',
      () async {
        var shouldFail = true;
        final coordinator = NoteAutosaveCoordinator(
          save: (_) async {
            if (shouldFail) throw StateError('storage unavailable');
          },
          timerFactory: timers.create,
        );
        addTearDown(coordinator.dispose);

        coordinator.update(title: 'Draft', body: 'Retained source');
        await expectLater(
          coordinator.flush(),
          throwsA(isA<StateError>()),
        );
        expect(coordinator.hasError, isTrue);
        expect(coordinator.isDirty, isTrue);
        expect(coordinator.isSaved, isFalse);

        shouldFail = false;
        await coordinator.retry();
        expect(coordinator.isSaved, isTrue);
        expect(coordinator.hasError, isFalse);
      },
    );

    test(
      'keeps title and body in the same atomic revision snapshot',
      () async {
        final saved = <NoteSaveSnapshot>[];
        final coordinator = NoteAutosaveCoordinator(
          save: (snapshot) async => saved.add(snapshot),
          timerFactory: timers.create,
        );
        addTearDown(coordinator.dispose);

        coordinator.update(title: 'Title revision 1', body: 'Body revision 1');
        coordinator.update(title: 'Title revision 2', body: 'Body revision 2');
        await coordinator.flush();

        expect(saved, [
          const NoteSaveSnapshot(
            title: 'Title revision 2',
            body: 'Body revision 2',
          ),
        ]);
      },
    );

    test(
      'does not let a stale completion mark a newer edit saved',
      () async {
        final firstWrite = Completer<void>();
        final saved = <NoteSaveSnapshot>[];
        final coordinator = NoteAutosaveCoordinator(
          save: (snapshot) async {
            saved.add(snapshot);
            if (saved.length == 1) await firstWrite.future;
          },
          timerFactory: timers.create,
        );
        addTearDown(coordinator.dispose);

        coordinator.update(title: 'A', body: 'A');
        final flush = coordinator.flush();
        coordinator.update(title: 'B', body: 'B');
        firstWrite.complete();
        await flush;

        expect(coordinator.savedRevision, 2);
        expect(coordinator.editRevision, 2);
        expect(coordinator.isDirty, isFalse);
      },
    );

    test(
      'uses independent revision streams for separate note sessions',
      () async {
        final firstSaved = <NoteSaveSnapshot>[];
        final secondSaved = <NoteSaveSnapshot>[];
        final first = NoteAutosaveCoordinator(
          save: (snapshot) async => firstSaved.add(snapshot),
          timerFactory: timers.create,
        );
        final second = NoteAutosaveCoordinator(
          save: (snapshot) async => secondSaved.add(snapshot),
          timerFactory: timers.create,
        );
        addTearDown(first.dispose);
        addTearDown(second.dispose);

        first.update(title: 'Note one', body: 'one');
        second.update(title: 'Note two', body: 'two');
        await first.flush();

        expect(firstSaved.single.title, 'Note one');
        expect(secondSaved, isEmpty);
        await second.flush();
        expect(secondSaved.single.title, 'Note two');
      },
    );
  });
}
