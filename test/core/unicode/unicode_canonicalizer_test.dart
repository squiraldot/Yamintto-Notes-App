import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yamintto/core/unicode/unicode_canonicalizer.dart';
import 'package:yamintto/core/unicode/unicode_17_data.dart';

void main() {
  group(
    'UnicodeCanonicalizer Unicode 17.0',
    () {
      test(
        'pins the approved Unicode data version',
        () {
          expect(unicodeDataVersion, '17.0.0');
        },
      );

      test(
        'trims every Unicode 17.0 White_Space character at boundaries',
        () {
          final source = File('tool/unicode/17.0.0/PropList.txt');
          final rows = source.readAsLinesSync();
          final whiteSpace = <int>[];
          for (final line in rows) {
            final fields = line.split('#').first.trim().split(';');
            if (fields.length < 2 || fields[1].trim() != 'White_Space') {
              continue;
            }
            final bounds = fields[0].trim().split('..');
            final start = int.parse(bounds.first, radix: 16);
            final end = int.parse(bounds.last, radix: 16);
            for (var rune = start; rune <= end; rune++) {
              whiteSpace.add(rune);
            }
          }
          for (final rune in whiteSpace) {
            final character = String.fromCharCode(rune);
            expect(
              UnicodeCanonicalizer.trimWhiteSpace('${character}x${character}'),
              'x',
              reason: 'U+${rune.toRadixString(16).toUpperCase()}',
            );
          }
        },
      );

      test(
        'preserves internal whitespace and trims before NFKC_Casefold',
        () {
          expect(
        UnicodeCanonicalizer.canonicalizeFolderName('\u00A0A  B\u2009'),
        'a  b',
      );
          expect(
        UnicodeCanonicalizer.canonicalizeFolderName('  A\u00A0B  '),
        'a b',
      );
        },
      );

      test(
        'performs full NFKC_Casefold rather than lowercase-only mapping',
        () {
          expect(UnicodeCanonicalizer.nfkcCasefold('Straße'), 'strasse');
          expect(UnicodeCanonicalizer.nfkcCasefold('K'), 'k');
          expect(UnicodeCanonicalizer.nfkcCasefold('ＡＢＣ'), 'abc');
          expect(UnicodeCanonicalizer.nfkcCasefold('\u00AD'), '');
        },
      );

      test(
        'uses Unicode code points for name length',
        () {
          expect(UnicodeCanonicalizer.codePointLength('😀'), 1);
          expect(UnicodeCanonicalizer.codePointLength('a😀b'), 3);
        },
      );

      test(
        'passes every row in Unicode 17.0 NormalizationTest.txt for NFC',
        () {
          final file = File('tool/unicode/17.0.0/NormalizationTest.txt');
          var checked = 0;
          for (final line in file.readAsLinesSync()) {
            final content = line.split('#').first.trim();
            if (content.isEmpty || content.startsWith('@')) continue;
            final columns = content.split(';');
            if (columns.length < 5) continue;
            final values = columns.take(5).map(
              (column) {
                return column
                    .trim()
                    .split(RegExp(r'\s+'))
                    .where((part) => part.isNotEmpty)
                    .map((part) => int.parse(part, radix: 16))
                    .toList();
              },
            ).toList();
            final expected = String.fromCharCodes(values[1]);
            expect(
              UnicodeCanonicalizer.normalizeNfc(
                String.fromCharCodes(values[0]),
              ),
              expected,
            );
            expect(
              UnicodeCanonicalizer.normalizeNfc(
                String.fromCharCodes(values[1]),
              ),
              expected,
            );
            expect(
              UnicodeCanonicalizer.normalizeNfc(
                String.fromCharCodes(values[2]),
              ),
              expected,
            );
            expect(
              UnicodeCanonicalizer.normalizeNfc(
                String.fromCharCodes(values[3]),
              ),
              String.fromCharCodes(values[3]),
            );
            expect(
              UnicodeCanonicalizer.normalizeNfc(
                String.fromCharCodes(values[4]),
              ),
              String.fromCharCodes(values[3]),
            );
            checked++;
          }
          expect(checked, greaterThan(0));
        },
      );

      test(
        'matches every explicit NFKC_CF source mapping',
        () {
          final file = File('tool/unicode/17.0.0/DerivedNormalizationProps.txt');
          var checked = 0;
          for (final line in file.readAsLinesSync()) {
            final fields = line.split('#').first.trim().split(';');
            if (fields.length < 2 || fields[1].trim() != 'NFKC_CF') continue;
            final bounds = fields[0].trim().split('..');
            final start = int.parse(bounds.first, radix: 16);
            final end = int.parse(bounds.last, radix: 16);
            final mapping = fields.length < 3 || fields[2].trim().isEmpty
                ? <int>[]
                : fields[2]
                    .trim()
                    .split(RegExp(r'\s+'))
                    .map((part) => int.parse(part, radix: 16))
                    .toList();
            final expected = UnicodeCanonicalizer.normalizeNfc(
              String.fromCharCodes(mapping),
            );
            for (var rune = start; rune <= end; rune++) {
              expect(
                UnicodeCanonicalizer.nfkcCasefold(String.fromCharCode(rune)),
                expected,
                reason: 'U+${rune.toRadixString(16).toUpperCase()}',
              );
              checked++;
            }
          }
          expect(checked, 10583);
        },
      );
    },
  );
}
