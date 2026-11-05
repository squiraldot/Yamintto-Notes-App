# Database migration policy — NOT IMPLEMENTED

**Status: Proposed; owner approval required before Phase 02 implementation.** No DB class, schema version, migration, generated schema snapshot or user database exists in current source.

## Version baseline

- Initial schema version: **1** (proposed).
- Drift database schemaVersion is authoritative; do not use app version.
- Version 1 contains only approved Phase 02 `folders` and `notes`.
- Fresh install creates current schema directly. Upgrade paths move one supported version at a time.
- Increment schema version whenever persisted structure or interpretation changes incompatibly.

## Migration organization

Keep migration definitions and schema declarations under `lib/core/database/`; generated schema snapshots follow the approved Drift code-generation convention. Use ordered, immutable migration steps. Exact file naming/codegen layout belongs to implementation, not this docs-only task.

Released migration steps are immutable. Fix mistakes with a new forward migration. Each step documents source/target versions, changed schema, data transformations, disk headroom, duration, interruption recovery and fixtures.

## Safety rules

1. Forward upgrades only; downgrade is not a supported data operation.
2. Destructive migrations prohibited by default. Table rebuilds must preserve and verify all data/relationships. Phase 06 plaintext removal is a security-migration exception requiring independent security review.
3. Unknown/newer schema, corrupt DB or migration failure must fail closed; never silently create an empty replacement.
4. Run schema/data transformations in SQLite transactions whenever possible.
5. On failure, abort/rollback, retain the prior committed data, map to a typed migration failure and prevent normal writes until resolved. Do not blindly retry non-idempotent work.
6. Before risky migrations require a verified app-private backup/snapshot or documented recoverable staging.
7. SQLite and filesystem cannot share an ACID transaction. File migrations need staged writes, integrity/read-back verification, idempotent operation journal, reference switch and crash recovery before source deletion.
8. Never log note content, attachment bytes, credentials, keys, ciphertext payloads or decrypted snippets.

## Required validation per supported previous version

Fresh install; upgrade fixture from every supported prior schema; row counts/IDs/timestamps/relationships/deleted state; PK/FK/check/index definitions; malformed/null/duplicate/orphan records; foreign_key_check and integrity_check; failure injection at each step; app kill/restart; disk full; large DB; repeated migration attempt. A failed migration must never report success or expose a partial schema.

CI may run host-side database tests. Device integration tests remain owner-run on physical devices.

## Phase 06 encryption migration

Phase 02 note bodies and Phase 05 revisions/attachment bytes may be plaintext beta data. A reviewed Phase 06 migration must inventory note/revision columns, attachment files, FTS/token indexes, cached snippets, temp exports/previews, SQLite main DB pages, rollback journal/WAL, backups and logs. Encrypt and verify read-back before switching canonical references. Persist resumable progress without secrets/plaintext. Rebuild/replace tables or DB files as required; a normal row update does not prove old plaintext bytes are gone. Remove persistent plaintext search structures and temporary copies. After migration, content search is unlocked-only transient memory (ADR-0011). Verify all storage locations before completion; interrupted work must be resumable/rollback-safe.

Field-level AES-GCM does not encrypt metadata, SQLite pages, indexes, WAL/journals, temp files or backups. No SQLite encryption or AES-GCM implementation is claimed. Secure overwrite on flash storage cannot be guaranteed.

## Phase boundaries

Phase 02 establishes schema v1 only after approval. Phase 04 adds search/pin/trash, Phase 05 revisions/attachments, Phase 06 encryption metadata and plaintext migration, Phase 08 backup/import. No later-phase migration is implemented here.
