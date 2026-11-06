/// Immutable additive migration from schema v1 to schema v2.
abstract final class SchemaV2 {
  static const int version = 2;

  static const List<String> upgradeFromV1 = <String>[
    '''
    ALTER TABLE folders ADD COLUMN color_argb INTEGER NULL
      CHECK (color_argb IS NULL OR color_argb IN (
        4294198070, 4293467747, 4294940672, 4294961979, 4283215696,
        4278228616, 4282339765, 4284955319, 4278430196, 4294951175
      ))
    ''',
    '''
    CREATE TABLE tags (
      id TEXT NOT NULL PRIMARY KEY
        CHECK (length(id) = 36 AND
          id GLOB '[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]-[0-9a-f][0-9a-f][0-9a-f][0-9a-f]-4[0-9a-f][0-9a-f][0-9a-f]-[89ab][0-9a-f][0-9a-f][0-9a-f]-[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]),
      name TEXT NOT NULL
        CHECK (name = yamintto_unicode_trim(name))
        CHECK (instr(name, char(0)) = 0)
        CHECK (length(name) BETWEEN 1 AND 64),
      name_key TEXT NOT NULL
        CHECK (name_key = yamintto_tag_name_key(name))
    )
    ''',
    'CREATE UNIQUE INDEX tags_name_key_unique ON tags(name_key)',
    '''
    CREATE TABLE note_tags (
      note_id TEXT NOT NULL
        REFERENCES notes(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
      tag_id TEXT NOT NULL
        REFERENCES tags(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
      PRIMARY KEY (note_id, tag_id)
    )
    ''',
    'CREATE INDEX note_tags_tag_id ON note_tags(tag_id, note_id)',
  ];
}
