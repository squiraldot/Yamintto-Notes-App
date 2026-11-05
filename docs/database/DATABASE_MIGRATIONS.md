# Database migration policy — OWNER APPROVED, NOT IMPLEMENTED

**Architecture status:** Owner approved on 2026-11-05.  
**Implementation status:** No database class, schema version, migration, generated schema snapshot or user database exists in current source.

## Version baseline

- Initial schema version: **1**.
- Drift database `schemaVersion` is authoritative; app version is not the DB version.
- Version 1 contains only `folders` and `notes` as specified in [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md).
- Fresh install creates the current schema directly. Upgrades move one supported schema version at a time.
- Increment schema version whenever persisted structure or its interpretation changes incompatibly.

## Migration organization

Keep database declarations and migration definitions under `lib/core/database/`. Store versioned Drift schema snapshots in the dedicated schema-snapshot directory (recommended `drift_schemas/`); keep migration tests/fixtures under `test/core/database/migrations/`. Use immutable adjacent version steps (for example, `v001_to_v002`). Use Drift-supported migration APIs and generated snapshots; do not hand-edit generated snapshots. These paths/names are implementation organization guidance, not files created by this task.

Released migration steps are immutable. Correct a mistake with a new forward migration. Each step documents source/target versions, schema changes, data transformations, disk headroom, duration, interruption recovery and fixtures.

## Safety rules

1. Forward-only upgrades are supported. Downgrade is not a supported data operation.
2. Destructive migrations are prohibited by default. Table rebuilds must preserve and verify all data/relationships. Phase 06 plaintext removal is a security-migration exception requiring independent security review.
3. Unknown/newer schema, corrupt DB or migration failure must fail closed; never silently create an empty replacement.
4. Run schema/data transformations in SQLite transactions whenever SQLite can provide atomicity.
5. On failure before commit, abort/rollback and retain the prior committed data; map to a typed migration failure and prevent normal writes until resolved. After commit, recovery uses a separately tested forward corrective migration or a verified pre-migration backup under an explicit recovery procedure; automatic downgrade is not promised.
6. Before risky migrations require a verified app-private backup/snapshot or documented recoverable staging.
7. SQLite and filesystem cannot share an ACID transaction. File migrations need staged writes, integrity/read-back verification, an idempotent operation journal, reference switch and crash recovery before source deletion.
8. Never log note content, attachment bytes, credentials, keys, ciphertext payloads or decrypted snippets.

## Required validation per supported prior version

- Fresh install at current schema version.
- Upgrade fixture from every supported prior schema version.
- Row counts, IDs, timestamps, folder relationships and deleted state before/after.
- PK/FK/check/index definitions, including root-aware case-insensitive folder-name uniqueness.
- Depth-boundary tests (levels 0, 1, 32 and rejected 33), subtree move depth and cycle tests.
- Unicode canonicalization tests for folder names, same-parent duplicates, case-only/canonical-equivalent duplicates, different-parent allowed duplicates, root-level duplicates, and soft-deleted-name retention.
- Malformed/null/duplicate/orphan legacy records.
- `foreign_key_check` and `integrity_check` after migration.
- Failure injection before/during/after transformations, app kill/restart, disk full, large DB and repeated migration attempts.
- A failed migration never reports success or exposes a partial schema.

The same Unicode NFKC_Casefold canonicalizer and version must be used by application validation and the database constraint. Verify function registration on every Android/iOS SQLite connection; if unavailable, fail closed rather than falling back to SQLite ASCII-only NOCASE.

CI may run host-side DB tests; device integration tests remain owner-run on physical devices under repository policy.

## Phase 06 encryption migration

Phase 02 note bodies and Phase 05 revisions/attachment bytes may be plaintext beta data. A reviewed Phase 06 migration must inventory note/revision columns, attachment files, FTS/token indexes, cached snippets, temp exports/previews, SQLite main DB pages, rollback journal/WAL, backups and logs. Encrypt and verify read-back before switching canonical references. Persist resumable progress without secrets/plaintext. Rebuild/replace tables or DB files as required; a normal row update does not prove old plaintext bytes are gone. Remove persistent plaintext search structures and temporary copies. After migration, content search is unlocked-only transient memory (ADR-0011). Verify all storage locations before completion; interrupted work must be resumable/rollback-safe.

Field-level encryption does not encrypt metadata, SQLite pages, indexes, WAL/journals, temp files or backups. No SQLite encryption or AES-GCM implementation is claimed. Secure overwrite on flash storage cannot be guaranteed.

## Phase boundaries

Phase 02 implements schema version 1 and its supported migration/fresh-install path only. Phase 04 adds search/pin/trash; Phase 05 revisions/attachments; Phase 06 encryption metadata and plaintext migration; Phase 08 backup/import. No later-phase migration is implemented in this task.
