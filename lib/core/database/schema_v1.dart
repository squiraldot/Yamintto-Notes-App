/// Immutable SQL definition for the approved Phase 02 schema version 1.
abstract final class SchemaV1 {
  static const int version = 1;

  static const List<String> createStatements = <String>[
    '''
    CREATE TABLE folders (
      id TEXT NOT NULL PRIMARY KEY
        CHECK (
          length(id) = 36 AND
          id GLOB '[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]-[0-9a-f][0-9a-f][0-9a-f][0-9a-f]-4[0-9a-f][0-9a-f][0-9a-f]-[89ab][0-9a-f][0-9a-f][0-9a-f]-[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]'
        ),
      parent_id TEXT NULL
        REFERENCES folders(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
      name TEXT NOT NULL
        CHECK (name = yamintto_unicode_trim(name))
        CHECK (instr(name, char(0)) = 0)
        CHECK (length(name) BETWEEN 1 AND 255),
      name_key TEXT NOT NULL
        CHECK (name_key = yamintto_folder_name_key(name)),
      sort_order INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER NULL,
      CHECK (parent_id IS NULL OR parent_id <> id)
    )
    ''',
    '''
    CREATE UNIQUE INDEX folders_parent_name_key_unique
    ON folders (COALESCE(parent_id, ''), name_key)
    ''',
    '''
    CREATE INDEX folders_parent_listing
    ON folders (parent_id, deleted_at, sort_order, created_at, id)
    ''',
    '''
    CREATE TABLE notes (
      id TEXT NOT NULL PRIMARY KEY
        CHECK (
          length(id) = 36 AND
          id GLOB '[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]-[0-9a-f][0-9a-f][0-9a-f][0-9a-f]-4[0-9a-f][0-9a-f][0-9a-f]-[89ab][0-9a-f][0-9a-f][0-9a-f]-[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]'
        ),
      folder_id TEXT NULL
        REFERENCES folders(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
      title TEXT NOT NULL DEFAULT ''
        CHECK (instr(title, char(0)) = 0)
        CHECK (length(title) <= 255),
      body TEXT NOT NULL DEFAULT '',
      content_format_version INTEGER NOT NULL DEFAULT 1
        CHECK (content_format_version >= 1),
      sort_order INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER NULL
    )
    ''',
    '''
    CREATE INDEX notes_folder_listing
    ON notes (folder_id, deleted_at, sort_order, created_at, id)
    ''',
  ];
}
