# Phase 02 database schema — OWNER APPROVED, NOT IMPLEMENTED

**Architecture status:** Accepted by owner on 2026-11-05.  
**Implementation status:** Not implemented. This document is not executable SQL, Drift declarations or a migration. Drift + SQLite is accepted by [ADR-0003](../decisions/0003-drift-sqlite.md).

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
- Check: `length(trim(name)) BETWEEN 1 AND 255` (SQLite length counts Unicode code points).
- Check: `name_key = yamintto_nfkc_casefold(trim(name))`; the deterministic Unicode canonicalizer must be registered on every DB connection before writes/constraint evaluation. App validation calls the same canonicalizer and Unicode data version.
- Check: `length(id) = 36`; UUID generator/domain boundary validates canonical UUID v4 syntax and lowercase representation.
- Check: `parent_id IS NULL OR parent_id <> id`; descendant cycles require domain ancestry validation.
- Unique expression index: `UNIQUE(COALESCE(parent_id, ''), name_key)`. Empty string is reserved as the root scope and cannot be a UUID parent ID. The index includes soft-deleted rows; same-parent name reuse is unavailable until explicit permanent deletion.
- Listing index: `(parent_id, deleted_at, sort_order, created_at, id)`.

SQLite built-in `NOCASE` is ASCII-only and MUST NOT be treated as sufficient Unicode case-insensitive comparison. The canonical key must be computed using Unicode NFKC_Casefold, and the database CHECK + unique index and application validator must share the same deterministic implementation/version. If the function is unavailable on a connection, writes must fail closed rather than bypass uniqueness.

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
- Check: `length(title) <= 255` (Unicode code points; empty is permitted).
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

- Trim leading/trailing whitespace before storage; reject empty names.
- Maximum 255 Unicode code points after trimming.
- Canonical uniqueness key is Unicode NFKC_Casefold of the trimmed display name.
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

No SQL, Drift declarations, generated files, database class, DAO, repository, migration, CRUD, UI, Trash UI, search, pinning, revisions, attachments, encryption, biometrics, backup, restore or legacy import is created by this documentation task.
