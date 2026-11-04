# Proposed database schema — NOT IMPLEMENTED

Drift/SQLite packages are configured, but no database class, table declarations, generated schema, version or migration exists. Proposal only; future approved Drift declarations are the implementation truth.

## Proposed tables
| Table | Candidate fields and purpose | Keys / relationships / indexes |
|---|---|---|
| folders | id TEXT, parent_id TEXT nullable, name TEXT, sort_order INTEGER, created_at/updated_at INTEGER UTC epoch | id PK; parent_id self-FK; index(parent_id) |
| notes | id TEXT, folder_id nullable, title TEXT, body TEXT (plaintext only before Phase 06), created_at/updated_at INTEGER, pinned_at nullable, format_version INTEGER | id PK; folder_id FK; indexes(folder_id), updated_at, pinned_at |
| note_tags | note_id TEXT, tag TEXT normalized, created_at INTEGER | composite PK(note_id,tag); note_id FK; index(tag) |
| attachments | id TEXT, note_id TEXT, display_name, media_type, byte_size, storage_ref opaque, timestamps, encryption metadata after Phase 06 | id PK; note_id FK; index(note_id) |
| note_revisions | id TEXT, note_id TEXT, revision_number INTEGER, body_snapshot TEXT (plaintext only before Phase 06), created_at INTEGER | id PK; note_id FK; unique(note_id,revision_number); index(note_id,created_at) |
| app_settings | key TEXT, serialized value, value_type, updated_at, schema_version | key PK; no passwords/raw keys/recovery secrets |
| encryption_metadata | version, algorithm identifier, envelope version, KDF identifier/salt/parameters, wrapped-key metadata/reference, timestamps | versioned PK; no raw master key or credentials |
| trash_items | id, entity_type, entity_id, deleted_at, original_parent_id, original_sort_order, safe metadata snapshot | id PK; indexes(entity_type,entity_id), deleted_at; polymorphic entity refs validated in transaction |

## Relationships and integrity
Folders form an acyclic parent tree. Notes optionally belong to folders. Notes own tags, attachments and revisions. Deleting a note must not orphan tags/revisions/attachment metadata or leave unreferenced file blobs. Trash is polymorphic; entity_id is not a normal FK. Define restore conflict if original folder no longer exists. Enable/test SQLite foreign keys. Choose RESTRICT/cascade behavior only after product decision; no silent data destruction.

## Indexes and search
Indexes are candidates, not final. Phase 04 may use persistent plaintext content index only before encryption. Verify FTS engine availability in selected SQLite build. Phase 06 drops every persistent plaintext full-text/token/snippet/cache structure. Unlocked search uses transient in-memory index built from decrypted repository records; lock clears it. No encrypted-search protocol approved.

## Transactions and files
Transactions for folder reparent, trash/restore, permanent delete, revision creation, attachment metadata, migration batches, settings migration and backup restore. SQLite and filesystem are not one atomic resource: stage files, track pending operations and cleanup/compensation; design crash recovery before implementation.

## Phase 06 migration
Before Phase 06, note/revision bodies and Phase 05 attachments may be plaintext beta data. Stage encrypted records/files, verify reads, atomically switch metadata/refs, remove plaintext originals/indexes/temp copies and recover after interruption. Never mark migration complete while plaintext content remains. Exact batch/journal/envelope protocol needs security review.
