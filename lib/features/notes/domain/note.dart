class Note {
  const Note({
    required this.id,
    required this.folderId,
    required this.title,
    required this.body,
    required this.contentFormatVersion,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final String? folderId;
  final String title;
  final String body;
  final int contentFormatVersion;
  final int sortOrder;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;

  factory Note.fromRow(Map<String, Object?> row) => Note(
        id: row['id']! as String,
        folderId: row['folder_id'] as String?,
        title: row['title']! as String,
        body: row['body']! as String,
        contentFormatVersion: row['content_format_version']! as int,
        sortOrder: row['sort_order']! as int,
        createdAt: row['created_at']! as int,
        updatedAt: row['updated_at']! as int,
        deletedAt: row['deleted_at'] as int?,
      );
}
