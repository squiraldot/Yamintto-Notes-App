class Folder {
  const Folder({
    required this.id,
    required this.parentId,
    required this.name,
    required this.nameKey,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final String? parentId;
  final String name;
  final String nameKey;
  final int sortOrder;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;

  factory Folder.fromRow(Map<String, Object?> row) => Folder(
        id: row['id']! as String,
        parentId: row['parent_id'] as String?,
        name: row['name']! as String,
        nameKey: row['name_key']! as String,
        sortOrder: row['sort_order']! as int,
        createdAt: row['created_at']! as int,
        updatedAt: row['updated_at']! as int,
        deletedAt: row['deleted_at'] as int?,
      );
}
