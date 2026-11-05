# ADR-0013: Phase 02 relational data model and lifecycle

- Status: **Accepted — owner approved**
- Date: 2026-11-05
- Supersedes: None

## Context

Drift/SQLite and offline-first are accepted by ADR-0003 and ADR-0002. The repository had no database implementation or approved schema. The previous proposal mixed Phase 02 notes/folders with later-phase revisions, attachments, settings, encryption metadata and a polymorphic trash table. It also left folder deletion, note deletion, hierarchy limits, name uniqueness, ID/time semantics, FK actions and migration policy incomplete.

The owner reviewed the Phase 02 decision register and explicitly approved the architecture baseline with amendments: maximum folder depth 32 (root level 0), 255-character folder names and note titles, case-insensitive sibling folder-name uniqueness, Trash for both notes and folders in Phase 04, indefinite soft-delete retention, and permanent deletion deferred to future phases rather than blocking Phase 02.

## Decision

1. Retain Drift + SQLite; no second database technology.
2. Schema version 1 contains only `folders` and `notes`.
3. NULL `parent_id` and `folder_id` represent root; nested folders are supported.
4. Use canonical lowercase UUID v4 TEXT IDs for folders, notes and future entities.
5. Use UTC Unix epoch milliseconds in INTEGER timestamp columns.
6. Use explicit `sort_order` per parent/folder; duplicate values are allowed; deterministic tie-break is `created_at ASC, id ASC`.
7. Folder hierarchy has a maximum depth of 32: virtual root level 0; top-level folder level 1. Validate creates and complete moved subtrees in domain logic and tests; reject cycles.
8. Folder names are trimmed, non-empty, maximum 255 Unicode code points. Note titles are maximum 255 Unicode code points; empty note titles are permitted.
9. Folder names are case-insensitively unique within the same parent; names may repeat in different parents. Use a Unicode NFKC_Casefold comparison key, the same deterministic canonicalizer for application validation and DB constraint, and a root-aware unique index. The constraint includes soft-deleted folders, so a name is not reusable in that parent until permanent deletion.
10. Empty-folder-only deletion: reject when any child folder or any note row (including soft-deleted notes) exists; soft-delete an empty folder.
11. Notes are soft-deleted from schema v1 using nullable `deleted_at`; preserve original `folder_id` and `sort_order`. Exclude deleted notes from active lists/default search; editing/moving requires restore.
12. Phase 04 Trash must include both deleted notes and deleted folders and provide restore and explicit permanent-deletion workflows.
13. Restore notes to original folder/order if valid; if original folder is unavailable, restore to root and return an explicit conflict result.
14. Keep deleted data indefinitely initially. No automatic expiry, permanent deletion or retention cleanup job.
15. Enable SQLite foreign keys on every connection and use ON DELETE/UPDATE RESTRICT. Multi-record operations are transactional.
16. Use schema version 1 and immutable, versioned, forward-only migrations. Fail closed on unknown/corrupt schema or migration errors; do not silently replace the DB with an empty one.
17. Keep revisions, attachments, encryption metadata, settings, search/pinning, Trash UI, biometrics, backup and import out of Phase 02.

## Alternatives considered

- UUID v7: rejected for this baseline; UUID v4 is portable and avoids approximate timestamp leakage.
- Integer/autoincrement IDs: rejected as the cross-entity portable identifier; weaker portability for offline backup/import.
- SQLite built-in NOCASE alone: rejected as the Unicode uniqueness implementation because it is ASCII-only. Use a Unicode canonical comparison key and a root-aware unique index.
- Duplicate folder names in one parent: rejected, including case-only and canonical-equivalent duplicates; names in different parents are allowed.
- Allow reuse of a soft-deleted folder's name: rejected for the baseline; retain unique key until explicit Phase 04 permanent deletion so folder restore cannot collide.
- Recursive folder deletion or moving contents to parent/root/Trash: rejected; empty-only deletion avoids hidden multi-record data movement.
- Immediate permanent note deletion: rejected; soft-delete supports Trash/Restore.
- Separate polymorphic trash table: rejected; row-level `deleted_at` keeps entity relationships enforceable.
- FK CASCADE: rejected; RESTRICT plus explicit lifecycle operations prevents silent loss.
- Create future tables early: rejected; later-phase schema is introduced through authorized migrations.

## Consequences

Phase 02 can implement a minimal two-table schema with stable IDs, bounded hierarchy, enforced sibling-name uniqueness, transactional moves and soft-delete foundations. The depth and name invariants require matching domain validation and database constraints plus tests on Android/iOS SQLite. The Unicode canonicalization function must be registered/available on every connection before constraint evaluation.

Phase 04 adds Trash UI for notes and folders, restore and explicit permanent deletion. Folder restore must respect its original parent and sibling-name uniqueness; Phase 04 owns conflict UX for folder restoration. Phase 05 extends permanent deletion to revisions, attachment metadata and file blobs using durable staging/crash recovery. Phase 06 must migrate plaintext and audit SQLite pages, WAL/journals, indexes, caches, temp files and exports; this ADR does not claim SQLite or AES-GCM encryption. Phase 08 preserves IDs, relationships, timestamps and deleted state in versioned backup/import.

## Related documents

- [Phase 02 decision register](../database/PHASE_02_DECISION_REGISTER.md)
- [Database schema](../database/DATABASE_SCHEMA.md)
- [Database migrations](../database/DATABASE_MIGRATIONS.md)
- [Data retention](../database/DATA_RETENTION.md)
- [System architecture](../architecture/SYSTEM_ARCHITECTURE.md)
- [Product requirements](../product/PRODUCT_REQUIREMENTS.md)
- [Feature catalog](../product/FEATURE_CATALOG.md)
- [Phase roadmap](../development/PHASE_ROADMAP.md)
- [AI development guide](../ai/AI_DEVELOPMENT_GUIDE.md)
- [ADR-0002 Offline-first](0002-offline-first.md)
- [ADR-0003 Drift/SQLite](0003-drift-sqlite.md)
- [ADR-0011 Search privacy](0011-search-index-privacy.md)
