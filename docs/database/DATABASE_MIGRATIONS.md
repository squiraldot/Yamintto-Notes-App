# Database migration policy — CURRENT SCHEMA V2 IMPLEMENTED

**Architecture status:** Owner approved on 2026-11-05.  
**Implementation status:** Schema version 1 and the Drift `GeneratedDatabase` wrapper are implemented in `lib/core/database/`; the immutable SQL definition is `schema_v1.dart`. Phase 02 repositories and UI are implemented. Source revision `745b8f589afceb783a9b39bafcd03c123e50c395` passed locked dependency, format, analyzer and 69/69 test validation. The owner reports successful Android physical-device smoke testing. The integration-test source is separate; its execution is not claimed. No destructive fallback or database reset path exists.

## Version baseline

- Initial schema version: **1**.
- Drift database `schemaVersion` is authoritative; app version is not the DB version.
- Version 1 contains only `folders` and `notes` as specified in [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md).
- Fresh install creates the current schema directly. Upgrades move one supported schema version at a time.
- Increment schema version whenever persisted structure or its interpretation changes incompatibly.

## Migration organization

Database declaration and migration callbacks live under `lib/core/database/`. Schema v1 is an immutable SQL definition in `schema_v1.dart`; Drift owns connection lifecycle, transaction boundaries, custom SQL execution and `MigrationStrategy`. Versioned migration steps must be added as explicit adjacent forward steps when a future schema version is approved. Do not replace the current database or use destructive fallback. Repository/schema tests live under `test/core/database/` and `test/features/`; physical persistence smoke source is under `integration_test/phase_02_data_smoke_test.dart`.

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

The shared canonicalizer is pinned to Unicode 17.0: boundary trim by `White_Space`, then NFKC_CF mapping, then NFC. The same Dart code is used by validation and the SQLite functions. `NativeDatabase` setup registers all three functions on each connection with `deterministic: true` and `directOnly: false`; the latter is required for schema CHECK usage. The schema depends on these functions and fails closed if registration/probing fails. Do not set `trusted_schema=OFF` without an SQLite API that also marks this pure function innocuous; do not use NOCASE or platform ICU fallback. Host SQLite tests verify schema-level use and reopening; Android/iOS physical runtime remains separately reported.

CI may run host-side DB tests; device integration tests remain owner-run on physical devices under repository policy.

## Phase 06 encryption migration

Phase 02 note bodies and Phase 05 revisions/attachment bytes may be plaintext beta data. A reviewed Phase 06 migration must inventory note/revision columns, attachment files, FTS/token indexes, cached snippets, temp exports/previews, SQLite main DB pages, rollback journal/WAL, backups and logs. Encrypt and verify read-back before switching canonical references. Persist resumable progress without secrets/plaintext. Rebuild/replace tables or DB files as required; a normal row update does not prove old plaintext bytes are gone. Remove persistent plaintext search structures and temporary copies. After migration, content search is unlocked-only transient memory (ADR-0011). Verify all storage locations before completion; interrupted work must be resumable/rollback-safe.

Field-level encryption does not encrypt metadata, SQLite pages, indexes, WAL/journals, temp files or backups. No SQLite encryption or AES-GCM implementation is claimed. Secure overwrite on flash storage cannot be guaranteed.

## Phase boundaries

Phase 02 implements schema version 1 and its supported migration/fresh-install path only. Phase 04 adds search/pin/trash; Phase 05 revisions/attachments; Phase 06 encryption metadata and plaintext migration; Phase 08 backup/import. No later-phase migration is implemented in this task.


## Schema v1 → v2 repair migration — implemented

- Current Drift schema version: **2**. Schema v1 remains immutable.
- Fresh installation executes the v1 create statements, then the same additive v1→v2 statements.
- Upgrade uses an explicit v1→v2 path in `YaminttoDatabase.migration`, inside a SQLite transaction. Unknown versions fail closed.
- Add nullable `folders.color_argb` with CHECK restricted to the ten opaque ARGB palette values. Existing rows receive NULL without changing any v1 field.
- Create `tags`, unique index on Unicode canonical `name_key`, `note_tags` junction with composite primary key and RESTRICT foreign keys, plus a tag lookup index.
- No existing note receives a tag. Existing IDs, names, bodies, parent/folder references, sort orders, timestamps and deleted_at values remain unchanged.
- Migration failure propagates; transaction rollback removes earlier DDL changes from the failed attempt. No drop/recreate fallback or empty-database substitution.
- Tests cover populated v1 upgrade, old soft-deleted rows, post-migration tag creation/assignment, folder color persistence after reopen, FK/integrity checks and forced migration failure/rollback.
- Evidence: Flutter CI run `42177776797`, source SHA `fa8f4ad469786a6a7199360a3d6813d22fac75e6`; 85/85 tests passed. Physical-device integration source is owner-run only and is not claimed as executed.
