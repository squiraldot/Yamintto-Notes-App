# Phase 02 database schema — IMPLEMENTED (SCHEMA VERSION 1)

**Architecture status:** Accepted by owner on 2026-11-05.  
**Implementation status:** Schema v1, Drift database wrapper, Unicode canonicalization, folder/note repositories and presentation screens are implemented. Source revision `745b8f589afceb783a9b39bafcd03c123e50c395` passed Flutter CI run `42097059083` (69/69 tests); universal and ARM64 Debug APK artifacts uploaded on runs `42097260846` and `42097260894`. Owner physical-device persistence smoke testing and final acceptance remain pending. Executable schema source: `lib/core/database/schema_v1.dart`; database/migration owner: `lib/core/database/yamintto_database.dart`. Drift + SQLite remains the accepted architecture.

## Schema version 1 inventory

Exactly two Phase 02 domain tables:

- `folders` — nested folder metadata, ordering and soft-delete marker.
- `notes` — note metadata/content, ordering and soft-delete marker.

Do not create `note_revisions`, `attachments`, `note_tags`, `trash_items`, `encryption_metadata` or `app_settings` in Phase 02. Revisions/attachments belong to Phase 05, encryption metadata to Phase 06, settings to Phase 09. Search, pinning and Trash UI belong to Phase 04. Deleted state is stored on the entity row, not in a separate polymorphic table.

## Shared conventions

| Concern | Accepted rule |
|---|---|
| IDs | Canonical lowercase UUID v4 strings, SQLite TEXT, same strategy for future entities |
| Time | UTC Unix epoch milliseconds, SQLite INTEGER |
| created_at | Set at creation/import; immutable during ordinary edits/moves/restores |
| updated_at | Update after successful content/metadata mutation, including rename, move, soft-delete and restore |
| Missing legacy time | Use import instant for missing timestamps; do not fabricate historical dates |
| Backup/restore | Preserve IDs and timestamps; do not regenerate IDs/reset creation dates |
| Ordering | Explicit integer sort_order scoped to parent/folder |
| FK actions | ON DELETE RESTRICT ON UPDATE RESTRICT; IDs immutable |
| DB ownership | One app-private DB, lazy-opened on first repository access and memoized by one app-scoped Riverpod provider |
| Access boundary | Repositories expose domain operations; DAOs internal; UI never issues SQL or receives raw DB/transaction handles |
| Errors | Map SQLite/Drift failures to typed domain/application errors; fail closed on corruption/migration failure |

UUID v4 is the sole ID strategy. UUID v7 and integer autoincrement IDs are not used as portable entity identifiers.

## Table: `folders`

| Column | SQLite type | Null? | Default | Rule |
|---|---|---:|---|---|
| `id` | TEXT | No | none | PK; canonical lowercase UUID v4 |
| `parent_id` | TEXT | Yes | NULL | Self-FK to folders.id; NULL=root |
| `name` | TEXT | No | none | Trimmed display name; 1–255 Unicode code points |
| `name_key` | TEXT | No | none | Unicode NFKC_Casefold of trimmed name; DB-validated |
| `sort_order` | INTEGER | No | 0 | Sibling order; duplicate values allowed |
| `created_at` | INTEGER | No | none | UTC Unix epoch milliseconds |
| `updated_at` | INTEGER | No | none | UTC Unix epoch milliseconds |
| `deleted_at` | INTEGER | Yes | NULL | Soft-delete timestamp |

Constraints and indexes:

- Primary key: `id`.
- Foreign key: `parent_id REFERENCES folders(id) ON DELETE RESTRICT ON UPDATE RESTRICT`.
- Check: `name = yamintto_unicode_trim(name)` and `length(name) BETWEEN 1 AND 255`; the custom trim function uses Unicode 17.0 `White_Space` and SQLite `length()` counts Unicode code points after NUL rejection.
- Check: `name_key = yamintto_folder_name_key(name)`; the deterministic Unicode canonicalizer must be registered on every DB connection before schema checks or writes. Dart validation and SQLite call the same Unicode 17.0 implementation.
- Check: canonical lowercase UUID v4 syntax, including version and variant bits; domain generator and SQL GLOB check enforce the same representation.
- Check: `parent_id IS NULL OR parent_id <> id`; descendant cycles require domain ancestry validation.
- Unique expression index: `UNIQUE(COALESCE(parent_id, ''), name_key)`. Empty string is reserved as the root scope and cannot be a UUID parent ID. The index includes soft-deleted rows; same-parent name reuse is unavailable until explicit permanent deletion.
- Listing index: `(parent_id, deleted_at, sort_order, created_at, id)`.

SQLite built-in `NOCASE` is ASCII-only and MUST NOT be treated as sufficient Unicode case-insensitive comparison. The canonical key is computed by Unicode 17.0 NFKC_Casefold after Unicode 17.0 White_Space boundary trimming; internal whitespace is preserved. NFKC_CF mappings are followed by NFC as required by the Unicode data-file instructions. The generated tables are bundled in `lib/core/unicode/unicode_17_data.dart`; source files, license, hashes and generator are under `tool/unicode/17.0.0/` and `tool/unicode/generate_unicode_17_data.py`. SQLite registers `yamintto_unicode_trim`, `yamintto_nfkc_casefold` and `yamintto_folder_name_key` as deterministic functions with `directOnly: false`, because schema CHECK expressions must call them. Function registration is part of every NativeDatabase connection setup. Runtime behavior is covered by actual SQLite tests; platform-device execution remains separate. If the function is unavailable on a connection, writes must fail closed rather than bypass uniqueness.

## Table: `notes`

| Column | SQLite type | Null? | Default | Rule |
|---|---|---:|---|---|
| `id` | TEXT | No | none | PK; canonical lowercase UUID v4 |
| `folder_id` | TEXT | Yes | NULL | FK to folders.id; NULL=root |
| `title` | TEXT | No | '' | Maximum 255 Unicode code points; empty title permitted |
| `body` | TEXT | No | '' | Editor-independent source text; plaintext before Phase 06 migration |
| `content_format_version` | INTEGER | No | 1 | CHECK >= 1; dialect/format semantics Phase 03 |
| `sort_order` | INTEGER | No | 0 | Order within folder/root collection |
| `created_at` | INTEGER | No | none | UTC Unix epoch milliseconds |
| `updated_at` | INTEGER | No | none | UTC Unix epoch milliseconds |
| `deleted_at` | INTEGER | Yes | NULL | Soft-delete timestamp |

Constraints and indexes:

- Primary key: `id`.
- Foreign key: `folder_id REFERENCES folders(id) ON DELETE RESTRICT ON UPDATE RESTRICT`.
- Check: `length(id) = 36`; canonical UUID v4 syntax is validated by the ID generator/domain boundary.
- Check: `instr(title, char(0)) = 0` and `length(title) <= 255` (Unicode code points; empty is permitted).
- Check: `content_format_version >= 1`.
- Domain operations reject a deleted folder as a destination.
- Listing index: `(folder_id, deleted_at, sort_order, created_at, id)`.
- No pin fields in Phase 02; Phase 04 adds them by migration. No revision/attachment FKs until Phase 05.

Body stores raw source text, not widget state or rendered output. Phase 03 may edit/save this field using an approved Markdown dialect without binding persistence to a specific editor package.

## Folder hierarchy and depth invariant

- Virtual root is level 0. A top-level folder with `parent_id IS NULL` is level 1.
- Maximum folder level is 32 inclusive.
- Creating a folder requires its new level to be <=32.
- Moving a folder validates the destination and every descendant; reject if `destination_parent_level + 1 + subtree_height > 32`.
- Reject moving a folder into itself or any descendant. Validate and update within one transaction.
- Domain validation and tests must cover root-level create, exactly level 32, attempted level 33, moving a subtree to a deeper parent, moving to root, and cycle attempts.
- No recursive traversal may assume unbounded depth; use guarded traversal with the 32-level invariant.

## Folder-name uniqueness

- Trim leading/trailing Unicode 17.0 `White_Space` before storage; preserve internal whitespace; reject empty names.
- Maximum 255 Unicode code points after trimming.
- Canonical uniqueness key is Unicode 17.0 NFKC_Casefold of the display name after boundary trim. Trimming occurs first; internal whitespace is not collapsed.
- Same canonical key is prohibited among folders with the same parent, including root-level folders and soft-deleted folders. Different parent folders may contain the same display/canonical name.
- The database CHECK validates name_key against the shared canonicalizer. The unique expression index scopes NULL parent to a reserved empty-string root key.
- Application validation must use the same canonicalizer and return a typed duplicate-name conflict; the database unique constraint remains the final race-safe enforcement.
- Because deleted folders retain the unique key, users cannot reuse that sibling name until the deleted folder is permanently deleted in Phase 04.

## Ordering

Folder order is independent per `parent_id`; note order is independent per `folder_id`, including NULL/root. New active items append after the active destination maximum in the same transaction. Moving appends to the destination. Duplicate `sort_order` values are allowed; deterministic display order is `sort_order ASC, created_at ASC, id ASC`. Restore attempts original sort_order; ties use the same deterministic rule without rewriting unrelated rows. Timestamps are tie-breakers only.

## Timestamp semantics

- All persisted timestamps are UTC Unix epoch milliseconds as signed 64-bit SQLite INTEGER.
- `created_at` is immutable after initial creation/import.
- `updated_at` changes after successful user-visible content/metadata mutation: note edit, rename, move, soft-delete and restore. A failed/rolled-back operation changes nothing.
- Moving a folder changes the moved folder's updated_at; it does not update descendants or unrelated siblings.
- Backup/restore preserves source timestamps and IDs. Missing legacy timestamps use the import instant and are identified as synthesized by the import report.

## Deletion and relationship behavior

- Note delete sets `notes.deleted_at`; preserve `folder_id` and `sort_order`. Exclude deleted notes from active lists/default search. Editing/moving requires restore.
- Folder delete is allowed only when it has no child folder and no note row at all, including soft-deleted notes. Set `folders.deleted_at`; do not physically delete in Phase 02.
- Soft-deleted folders cannot receive children or notes. Retain parent/name/name_key/order for Trash and restoration.
- Phase 04 Trash must include deleted notes and deleted folders; provide restore and explicit permanent-delete workflows.
- Note restore uses original folder/order if valid. If the original folder is missing or deleted, restore to root and return an explicit conflict result.
- Folder restore must preserve original parent/order when valid and respect sibling name uniqueness; Phase 04 defines the user-facing conflict UX.
- Permanent deletion is not implemented in Phase 02. Phase 04 owns explicit note/folder permanent-delete workflows; Phase 05 extends dependent cleanup to revisions and attachment metadata/files.
- No FK cascade may silently destroy recoverable data. All FK delete/update actions are RESTRICT.
- Filesystem deletion cannot be atomic with SQLite. Phase 05 must design staged cleanup and crash recovery before attachments ship.
- No automatic retention cleanup or expiry.

## Database initialization and boundaries

Use one app-private SQLite database for Android/iOS, opened lazily on first repository access and memoized as one app-scoped provider instance. Complete open and migrations before exposing repositories. Initialization failure must surface as a typed startup/storage failure, never silently replace user data with an empty DB. Repositories/domain operations are the persistence contract; DAOs are internal. Do not leak raw transaction handles to widgets/controllers. Enable and verify foreign keys on every connection.

## Future-phase compatibility

- Phase 03: source text + format version support editor-independent Markdown and serialized autosave that prevents stale writes.
- Phase 04: deleted_at supports Trash for notes/folders, restore and permanent deletion; pin fields/search arrive by migration; default queries exclude deleted rows.
- Phase 05: revisions/attachments reference stable note IDs; permanent-delete cleanup stages DB metadata and filesystem work with crash recovery.
- Phase 06: migrate body/revision plaintext to reviewed encrypted envelopes; audit titles/metadata, FTS, DB pages, WAL/journals, caches, temp files, exports and backups. No SQLite/AES-GCM encryption exists now.
- Phase 07: biometric authorization remains outside CRUD/repository logic.
- Phase 08: stable IDs, relationships, timestamps and deleted-state support portable backup/import; validate ID conflicts before mutation and never silently overwrite local records.
- Phase 09: settings persistence belongs to its phase.

## Explicitly out of scope

Phase 02 implementation source is present for the two-table database, folder/note repositories, Unicode 17.0 canonicalizer, folder browser, note list and plain-text title/body editor. No Markdown preview/rendering/autosave, Trash UI, search, pinning, revisions, attachments, encryption, biometrics, backup, restore or legacy import is included. Host automated validation passed on Flutter 3.47.9 with 69/69 tests. Owner-reported Android physical-device smoke testing passed; Phase 02 is accepted. The integration-test source is present, but execution is not claimed.


## Owner-directed Phase 02 repair — note tags and folder colors (2026-11-06)

The schema v1 definition in this document is the immutable baseline already implemented. It contains exactly `folders` and `notes`, and it does **not** contain note tags or persisted folder colors. The owner selected repair; Phase 02 is reopened until both capabilities are delivered.

Repair requirements:
- Support multiple reusable tags per note, with persistent local tag definitions and note-tag assignments. Define normalization, duplicate handling, ordering, deletion semantics and behavior for soft-deleted notes by inspecting the original Phase 02 prompt; record any unresolved product choice before implementation.
- Persist a nullable, validated color value for each folder. Define palette/serialization, theme fallback and accessible contrast before implementation. Color must not affect folder identity, hierarchy, name uniqueness or ordering.
- Preserve all existing v1 folder/note IDs, content, relationships, sort_order, timestamps and deleted_at values.
- Treat schema v1 as immutable. Any new structure/column must use a forward-only, data-preserving migration from the actual current schema version; test populated-v1 upgrade and fail-closed/rollback behavior.
- Do not add revisions, attachments, search, pinning, Trash UI, encryption metadata, biometrics, backup or settings as part of this repair.

The exact v2 physical schema is intentionally not frozen by this addendum. Inspect the original Phase 02 authorization and current Drift source/migration history, propose the smallest safe additive design, document it, and verify the migration before implementation.
