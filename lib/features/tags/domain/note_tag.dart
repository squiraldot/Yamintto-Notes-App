import 'package:yamintto/core/errors/domain_failure.dart';
import 'package:yamintto/core/unicode/unicode_canonicalizer.dart';

class NoteTag {
  const NoteTag({required this.id, required this.name, required this.nameKey});

  factory NoteTag.fromRow(Map<String, Object?> row) => NoteTag(
    id: row['id']! as String,
    name: row['name']! as String,
    nameKey: row['name_key']! as String,
  );

  final String id;
  final String name;
  final String nameKey;

  static String normalizeName(String input) {
    final name = UnicodeCanonicalizer.trimWhiteSpace(input);
    if (name.isEmpty ||
        name.contains('\u0000') ||
        UnicodeCanonicalizer.codePointLength(name) > 64) {
      throw const DomainFailure(
        DomainFailureCode.invalidTagName,
        'Tag names must contain 1–64 Unicode code points after trimming.',
      );
    }
    return name;
  }

  static String canonicalKey(String input) =>
      UnicodeCanonicalizer.canonicalizeFolderName(input);
}
