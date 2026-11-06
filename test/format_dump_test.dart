import 'dart:convert';
import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('print canonical Dart formatting for Phase 03 files', () {
    const paths = <String>[
      'lib/features/notes/data/note_repository.dart',
      'lib/features/notes/presentation/note_autosave_coordinator.dart',
      'lib/features/notes/presentation/note_editor_screen.dart',
      'lib/features/notes/presentation/safe_markdown_viewer.dart',
      'test/features/notes/hybrid_markdown_parser_test.dart',
      'test/features/notes/note_autosave_coordinator_test.dart',
      'test/features/notes/note_content_format_test.dart',
      'test/features/notes/note_editor_phase_03_test.dart',
      'test/features/phase_02_screens_test.dart',
    ];
    final formatter = DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    );
    for (final path in paths) {
      try {
        final source = File(path).readAsStringSync();
        final formatted = formatter.format(source, uri: Uri.file(path));
        print('DART_FORMAT_BEGIN:$path');
        print(base64Encode(utf8.encode(formatted)));
        print('DART_FORMAT_END:$path');
      } catch (error) {
        print('DART_FORMAT_ERROR:$path:$error');
      }
    }
  });
}
