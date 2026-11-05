import 'package:yamintto/core/unicode/unicode_17_data.dart';

/// Deterministic Unicode 17.0 folder-name canonicalization.
///
/// Boundary trimming uses Unicode 17.0 White_Space before NFKC_Casefold.
/// Internal whitespace is preserved. No platform ICU or locale behavior.
abstract final class UnicodeCanonicalizer {
  static final Map<int, List<int>> _nfkc = _parseMappings(
    nfkcCasefoldMappings,
  );
  static final Map<int, List<int>> _decomposition = _parseMappings(
    canonicalDecompositionMappings,
  );
  static final Map<int, int> _combiningClass = _parseIntMap(
    canonicalCombiningClasses,
  );
  static final Map<int, int> _composition = _parseComposition(
    canonicalCompositionMappings,
  );
  static final List<(int, int)> _whiteSpace = _parseRanges(
    unicodeWhiteSpaceRanges,
  );

  static String trimWhiteSpace(String value) {
    final runes = value.runes.toList(growable: false);
    var start = 0;
    var end = runes.length;
    while (start < end && _isWhiteSpace(runes[start])) {
      start++;
    }
    while (end > start && _isWhiteSpace(runes[end - 1])) {
      end--;
    }
    return String.fromCharCodes(runes.sublist(start, end));
  }

  /// Returns the NFKC_Casefold mapping followed by canonical NFC composition.
  static String nfkcCasefold(String value) {
    final mapped = <int>[];
    for (final rune in value.runes) {
      final replacement = _nfkc[rune];
      if (replacement == null) {
        mapped.add(rune);
      } else {
        mapped.addAll(replacement);
      }
    }
    return String.fromCharCodes(normalizeNfcCodePoints(mapped));
  }

  /// Canonical folder key: Unicode White_Space trim, then NFKC_Casefold.
  static String canonicalizeFolderName(String value) {
    return nfkcCasefold(trimWhiteSpace(value));
  }

  static int codePointLength(String value) => value.runes.length;

  /// Public for exhaustive conformance tests and Unicode-aware boundaries.
  static String normalizeNfc(String value) {
    return String.fromCharCodes(normalizeNfcCodePoints(value.runes));
  }

  static List<int> normalizeNfcCodePoints(Iterable<int> input) {
    final decomposed = <int>[];
    for (final rune in input) {
      _decompose(rune, decomposed);
    }
    final ordered = _canonicalOrder(decomposed);
    return _canonicalCompose(ordered);
  }

  static void _decompose(int rune, List<int> output) {
    const sBase = 0xAC00;
    const lBase = 0x1100;
    const vBase = 0x1161;
    const tBase = 0x11A7;
    const lCount = 19;
    const vCount = 21;
    const tCount = 28;
    const nCount = vCount * tCount;
    const sCount = lCount * nCount;

    if (rune >= sBase && rune < sBase + sCount) {
      final index = rune - sBase;
      output
        ..add(lBase + index ~/ nCount)
        ..add(vBase + (index % nCount) ~/ tCount);
      final trailing = index % tCount;
      if (trailing != 0) {
        output.add(tBase + trailing);
      }
      return;
    }

    final decomposition = _decomposition[rune];
    if (decomposition == null) {
      output.add(rune);
      return;
    }
    for (final part in decomposition) {
      _decompose(part, output);
    }
  }

  static List<int> _canonicalOrder(List<int> input) {
    final output = <int>[];
    for (final rune in input) {
      final currentClass = _combiningClass[rune] ?? 0;
      if (currentClass == 0) {
        output.add(rune);
        continue;
      }
      var insertion = output.length;
      while (insertion > 0) {
        final previousClass =
            _combiningClass[output[insertion - 1]] ?? 0;
        if (previousClass == 0 || previousClass <= currentClass) {
          break;
        }
        insertion--;
      }
      output.insert(insertion, rune);
    }
    return output;
  }

  static List<int> _canonicalCompose(List<int> input) {
    if (input.isEmpty) {
      return const <int>[];
    }

    final output = <int>[input.first];
    var starterPosition = 0;
    var starter = input.first;
    var lastClass = _combiningClass[input.first] ?? 0;

    for (var index = 1; index < input.length; index++) {
      final rune = input[index];
      final currentClass = _combiningClass[rune] ?? 0;
      final composite = _composePair(starter, rune);

      if (composite != null &&
          (lastClass < currentClass || lastClass == 0)) {
        output[starterPosition] = composite;
        starter = composite;
        continue;
      }

      if (currentClass == 0) {
        starterPosition = output.length;
        starter = rune;
      }
      output.add(rune);
      lastClass = currentClass;
    }
    return output;
  }

  static int? _composePair(int first, int second) {
    const sBase = 0xAC00;
    const lBase = 0x1100;
    const vBase = 0x1161;
    const tBase = 0x11A7;
    const lCount = 19;
    const vCount = 21;
    const tCount = 28;
    const nCount = vCount * tCount;
    const sCount = lCount * nCount;

    if (first >= lBase &&
        first < lBase + lCount &&
        second >= vBase &&
        second < vBase + vCount) {
      return sBase +
          (first - lBase) * nCount +
          (second - vBase) * tCount;
    }

    if (first >= sBase &&
        first < sBase + sCount &&
        (first - sBase) % tCount == 0 &&
        second > tBase &&
        second < tBase + tCount) {
      return first + second - tBase;
    }

    return _composition[first * 0x110000 + second];
  }

  static bool _isWhiteSpace(int rune) {
    var low = 0;
    var high = _whiteSpace.length - 1;
    while (low <= high) {
      final middle = (low + high) ~/ 2;
      final range = _whiteSpace[middle];
      if (rune < range.$1) {
        high = middle - 1;
      } else if (rune > range.$2) {
        low = middle + 1;
      } else {
        return true;
      }
    }
    return false;
  }

  static Map<int, List<int>> _parseMappings(String data) {
    final result = <int, List<int>>{};
    for (final line in data.split('\n')) {
      if (line.isEmpty) continue;
      final separator = line.indexOf('=');
      final key = int.parse(line.substring(0, separator), radix: 16);
      final raw = line.substring(separator + 1);
      result[key] = raw.isEmpty
          ? const <int>[]
          : raw
              .split(',')
              .map((part) => int.parse(part, radix: 16))
              .toList();
    }
    return result;
  }

  static Map<int, int> _parseIntMap(String data) {
    final result = <int, int>{};
    for (final line in data.split('\n')) {
      if (line.isEmpty) continue;
      final separator = line.indexOf('=');
      result[int.parse(line.substring(0, separator), radix: 16)] =
          int.parse(line.substring(separator + 1));
    }
    return result;
  }

  static Map<int, int> _parseComposition(String data) {
    final result = <int, int>{};
    for (final line in data.split('\n')) {
      if (line.isEmpty) continue;
      final separator = line.indexOf('=');
      final pair = line.substring(0, separator).split(',');
      final first = int.parse(pair[0], radix: 16);
      final second = int.parse(pair[1], radix: 16);
      final composed = int.parse(line.substring(separator + 1), radix: 16);
      result[first * 0x110000 + second] = composed;
    }
    return result;
  }

  static List<(int, int)> _parseRanges(String data) {
    if (data.isEmpty) return const <(int, int)>[];
    return data.split(',').map((part) {
      final bounds = part.split('-');
      return (
        int.parse(bounds[0], radix: 16),
        int.parse(bounds[1], radix: 16),
      );
    }).toList(growable: false);
  }
}
