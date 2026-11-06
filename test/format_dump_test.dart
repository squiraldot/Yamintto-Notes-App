import 'dart:convert';
import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dump canonical formatting for editor widget tests', () {
    const path = 'test/features/notes/note_editor_phase_03_test.dart';
    final source = File(path)
        .readAsStringSync()
        .replaceFirst('// dart format off\n', '');
    final formatter = DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    );
    final formatted = formatter.format(source, uri: Uri.file(path));
    stdout.writeln('DART_FORMAT_BEGIN:$path');
    stdout.writeln(base64Encode(utf8.encode(formatted)));
    stdout.writeln('DART_FORMAT_END:$path');
  });
}
