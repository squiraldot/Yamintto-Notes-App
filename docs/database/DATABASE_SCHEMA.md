# Phase 02 database schema proposal — NOT IMPLEMENTED

**Status: Proposed; owner approval required before implementation.** This is a documentation proposal, not executable SQL, Drift declarations, or a migration. Drift + SQLite is accepted by [ADR-0003](../decisions/0003-drift-sqlite.md), but source inspection found no database class, schema, DAO, repository, schema version or migration.

## Phase 02 table inventory

Schema version 1 should contain only:

- `folders` — nested folder metadata.
- `notes` — note metadata and the initial soft-delete state.

Root is represented by NULL `parent_id` or `folder_id`; no synthetic root row is used. Do not create `note_revisions`, `attachments`, `note_tags`, `trash_items`, `encryption_metadata` or `app_settings` in Phase 02. Revisions/attachments belong to Phase 05, encryption metadata to Phase 06, settings to Phase 09; tags have no approved requirement. Trash uses `deleted_at` on the entity row, not a polymorphic table.

## Common conventions — pending owner approval

| Concern | Proposed rule |
|---|---|
| IDs | Canonical lowercase UUID v4 strings, SQLite TEXT, same strategy for future entities |
| Time | UTC Unix epoch milliseconds, SQLite INTEGER |
| created_at | Set once at creation/import; immutable during ordinary edits/moves/restores |
| updated_at | Update after successful content/metadata mutation, including rename, move, soft-delete and restore |
| Missing legacy time | Use import instant for both timestamps; do not invent historical dates |
| Backup/restore | Preserve IDs and timestamps; do not regenerate IDs/reset creation dates |
| Ordering | Explicit integer sort_order scoped to parent/folder |
| FK actions | ON DELETE RESTRICT ON UPDATE RESTRICT; IDs immutable |
| Ownership | One app-scoped DB instance; implementation under lib/core/database; composition under lib/app/providers |
| Access | Repositories expose domain operations; DAOs internal; UI never issues SQL or receives raw DB handles |

UUID v4 is recommended over v7: portable, broadly supported, offline-generated, collision-resistant, and does not reveal approximate creation time. UUID v7's locality benefit is not required for this local app. No ID formats should be mixed.

## Table: folders

| Column | Type | Null? | Default | Rule |
|---|---|---:|---|---|
| id | TEXT | No | none | PK; canonical UUID v4; CHECK length(id)=36 |
| parent_id | TEXT | Yes | NULL | Self-FK to folders.id; NULL=root |
| name | TEXT | No | none | CHECK length(trim(name))>0; max length and duplicate policy pending |
| sort_order | INTEGER | No | 0 | Sibling order; duplicate values allowed |
| created_at | INTEGER | No | none | UTC Unix milliseconds |
| updated_at | INTEGER | No | none | UTC Unix milliseconds |
| deleted_at | INTEGER | Yes | NULL | Soft-delete timestamp |

Constraints: PK(id); FK parent_id REFERENCES folders(id) ON DELETE RESTRICT ON UPDATE RESTRICT; CHECK(parent_id IS NULL OR parent_id <> id). The self-check prevents direct self-parenting only; descendant cycles require transactional ancestry validation. No unique (parent_id,name) constraint until case sensitivity, normalization and duplicate behavior are approved. Index (parent_id, deleted_at, sort_order, created_at, id).

A deleted folder cannot receive new children or notes. Parent/name/order remain retained. Proposed deletion is allowed only when no child folder and no note row (including soft-deleted notes) exists; set deleted_at, do not physically delete.

## Table: notes

| Column | Type | Null? | Default | Rule |
|---|---|---:|---|---|
| id | TEXT | No | none | PK; canonical UUID v4; CHECK length(id)=36 |
| folder_id | TEXT | Yes | NULL | FK to folders.id; NULL=root |
| title | TEXT | No | '' | Maximum length pending approval |
| body | TEXT | No | '' | Editor-independent source text; plaintext only before Phase 06 |
| content_format_version | INTEGER | No | 1 | CHECK >= 1; content format/dialect is Phase 03 |
| sort_order | INTEGER | No | 0 | Order within folder/root collection |
| created_at | INTEGER | No | none | UTC Unix milliseconds |
| updated_at | INTEGER | No | none | UTC Unix milliseconds |
| deleted_at | INTEGER | Yes | NULL | Soft-delete timestamp |

Constraints: PK(id); FK folder_id REFERENCES folders(id) ON DELETE RESTRICT ON UPDATE RESTRICT; CHECK length(id)=36; CHECK content_format_version>=1. Domain operations must reject a deleted folder as destination. Index (folder_id, deleted_at, sort_order, created_at, id). No pin fields in Phase 02; Phase 04 adds them through a migration. No revision/attachment FKs until Phase 05.

Body stores raw source, not widget state or rendered output. Phase 03 can edit/save it using an approved Markdown dialect without binding persistence to an editor package.

## Ordering

Folder order is independent per parent_id; note order is independent per folder_id, including NULL/root. New active items append after the active destination maximum in the same transaction. Moving an item appends to the destination. Duplicate sort_order values are allowed; deterministic order is sort_order ASC, created_at ASC, id ASC. Restore tries the original sort_order; ties use the same deterministic rule without rewriting unrelated rows. Timestamps are tie-breakers only, never the primary ordering mechanism.

## Hierarchy and transactions

Nested folders are supported; NULL is root. No arbitrary depth limit is recommended initially, but guarded traversal and cycle prevention are mandatory; whether a product-visible depth cap is required is pending approval.

Folder move transaction: verify source/destination exist and are active; reject self; inspect destination ancestry and reject if source is an ancestor; update parent_id, destination sort_order and moved folder updated_at; commit only if all checks pass. Failure rolls back entirely. Note move similarly validates active destination and atomically updates folder_id, sort_order and updated_at. Do not update unrelated ancestors or siblings.

## Deletion lifecycle

- Note delete sets deleted_at; preserve folder_id and sort_order. Exclude from normal lists/default search; disallow edit/move while deleted. Trash UI/restore UX is Phase 04.
- Restore clears deleted_at and retains original location/order if valid. If the original folder is missing/deleted, recommended fallback is root with an explicit conflict result; owner approval required.
- Folder deletion is recommended to reject if any child folder or any note row (including soft-deleted note) exists; soft-delete empty folder only.
- Permanent deletion is a distinct explicit operation, never a side effect of folder deletion/startup. Future revisions/attachment metadata/files require coordinated cleanup.
- No FK cascade may silently destroy recoverable data. Filesystem deletion is not atomic with SQLite; Phase 05 must design staged cleanup and crash recovery.
- No automatic retention cleanup is implemented or approved.

## Initialization and error boundaries

Use one app-private SQLite database on Android/iOS, owned by an app-scoped provider. Initialization failure must surface as a typed startup/storage failure, never silently replace user data with an empty DB. Repositories/domain operations are the persistence contract; DAOs are internal. Map SQLite/Drift failures to typed app/domain failures; never expose raw SQL or stack traces to widgets. All multi-record invariants run in one Drift transaction. Enable and test foreign keys on every connection.

## Future-phase compatibility

- 03: source text + format version; serialized autosave must prevent stale writes.
- 04: deleted_at supports Trash/Restore; pin fields added by migration; default queries exclude deleted. Search privacy follows ADR-0011.
- 05: add revisions/attachments with stable note IDs and explicit retention/file cleanup.
- 06: migrate body/revision plaintext to reviewed encrypted envelopes; rebuild/remove plaintext columns after verification. Audit metadata, FTS, DB pages, WAL/journals, caches, temp files, exports and backups. No SQLite/AES-GCM encryption exists now.
- 07: biometric authorization stays outside CRUD/repositories.
- 08: stable IDs, relationships, timestamps and schema version support portable backup/import; preserve deleted state and validate before mutation.

## Explicitly out of scope

No SQL, Drift declarations, generated files, database class, DAO, repository, migration, CRUD, UI, Trash UI, search, pinning, revisions, attachments, encryption, biometrics, backup, restore or legacy import is created here.
