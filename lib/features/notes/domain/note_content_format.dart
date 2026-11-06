/// Stable contract for the meaning of notes.body.
///
/// These are content-format versions, independent of the SQLite schema version.
abstract final class NoteContentFormat {
  /// Historical body content is literal plain text.
  static const int plainText = 1;

  /// Body content follows docs/editor/MARKDOWN_DIALECT.md.
  static const int hybridMarkdown = 2;

  static bool isSupported(int version) =>
      version == plainText || version == hybridMarkdown;
}
