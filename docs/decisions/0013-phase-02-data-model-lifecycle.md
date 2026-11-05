# ADR-0013: Phase 02 relational data model and lifecycle proposal

- Status: Proposed — pending explicit owner approval; not accepted
- Date: 2026-11-05
- Supersedes: None

## Context

Drift/SQLite and offline-first are accepted (ADR-0003 and ADR-0002), but no database implementation or approved schema exists. The prior schema proposal mixed Phase 02 notes/folders with later-phase revisions, attachments, settings, encryption metadata and a polymorphic trash table. Folder/note deletion, ID/time semantics, FK actions, ordering and migration policy were incomplete.

## Decision

Propose the following coherent baseline for owner approval:

1. Retain Drift + SQLite; do not add a second database technology.
2. Schema version 1 contains only `folders` and `notes`.
3. NULL `parent_id` and `folder_id` represent root; nested folders are supported.
4. Use canonical lowercase UUID v4 TEXT IDs for all entities.
5. Use UTC Unix epoch milliseconds in INTEGER timestamp columns.
6. Use explicit `sort_order` per parent/folder; duplicates allowed, tie-break by created_at then ID.
7. Add nullable `deleted_at` to notes in schema v1; preserve folder/order. Trash UI belongs to Phase 04.
8. Recommend empty-folder-only deletion using `folders.deleted_at`; reject deletion if any child folder or note (including soft-deleted note) exists.
9. Enable SQLite foreign keys on every connection and use RESTRICT for delete/update actions.
10. Require transactions for hierarchy/note moves, deletion/restore, migrations and multi-record invariants.
11. Start at schema version 1; migrations are immutable and forward-only; destructive migrations prohibited by default.
12. No automatic retention expiry or permanent deletion until approved.

These are proposals, not approved product behavior. [Phase 02 decision register](../database/PHASE_02_DECISION_REGISTER.md) is authoritative for owner approvals.

## Alternatives considered

- UUID v7: time-sortable/index-local, but leaks approximate creation time and is not needed for this local baseline; UUID v4 recommended.
- Integer/autoincrement IDs: simpler locally, less portable for offline import/backup and future merge/conflict handling.
- Separate polymorphic trash table: requires manual polymorphic integrity and duplicates entity location state; row-level deleted_at is simpler.
- Immediate permanent note deletion: rejected as incompatible with restore and future dependent data.
- Cascading FK deletes: rejected because they may silently erase recoverable data.
- Recursive folder delete/move contents to parent/root/Trash: not selected; empty-only is safest pending product approval.
- Create all future tables early: rejected as premature schema and lifecycle complexity.

## Consequences

If approved, Phase 02 can implement a minimal two-table schema and soft-delete foundation. Phase 04 adds Trash UI and pin/search fields without changing note identity. Phase 05 adds revisions/attachments with explicit retention and file cleanup. Phase 06 must migrate plaintext content and audit DB pages, WAL/journals, indexes, caches, temp files and exports; this ADR does not claim SQLite or AES-GCM encryption. Phase 08 preserves IDs, relationships, timestamps and deletion state in a versioned portable format.

Owner approval remains required for the register's blocking decisions, especially folder deletion and restore fallback, ID/time conventions, hierarchy/name constraints, ordering, schema v1, FK/transaction and migration/retention policy. Until then, this ADR remains Proposed and Phase 02 implementation is blocked.

## Related documents

- [Database schema](../database/DATABASE_SCHEMA.md)
- [Database migrations](../database/DATABASE_MIGRATIONS.md)
- [Data retention](../database/DATA_RETENTION.md)
- [Decision register](../database/PHASE_02_DECISION_REGISTER.md)
- [System architecture](../architecture/SYSTEM_ARCHITECTURE.md)
- [Product requirements](../product/PRODUCT_REQUIREMENTS.md)
- [Feature catalog](../product/FEATURE_CATALOG.md)
- [Phase roadmap](../development/PHASE_ROADMAP.md)
- [AI development guide](../ai/AI_DEVELOPMENT_GUIDE.md)
- [ADR-0002 Offline-first](0002-offline-first.md)
- [ADR-0003 Drift/SQLite](0003-drift-sqlite.md)
- [ADR-0011 Search privacy](0011-search-index-privacy.md)
