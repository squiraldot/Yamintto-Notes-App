# System architecture

## Current implementation — Phase 01

`lib/main.dart` calls bootstrap; bootstrap initializes Flutter and runs `ProviderScope(child: YaminttoApp())`. The root app creates one GoRouter instance and an in-memory theme notifier. MaterialApp.router receives Material 3 themes. GoRouter starts at splash and then the temporary foundation route. Theme tokens and reusable app-shell widgets exist.

The `drift` and SQLite packages in `pubspec.yaml` are dependencies, not a database implementation. `lib/core/database/README.md` contains guidance only. There is no DB class, schema, DAO, repository, feature provider/controller, notes/folders workflow, migration, encryption, biometrics, attachment or backup implementation.

## Accepted constraints

- Native Flutter app for Android/iOS; offline-first core workflows.
- Drift over SQLite is accepted by ADR-0003.
- Riverpod is state/DI; GoRouter owns navigation.
- Feature-first boundaries: presentation -> domain contracts/use cases -> data implementations.
- Shared DB/native services belong under `lib/core`; composition belongs in `lib/app/providers`.
- Features do not import another feature's private data implementation.
- Three protected workflows and beta Debug APK policy remain governed by ADR-0012.

## Proposed Phase 02 data architecture — pending owner approval

- One app-private SQLite database for Android/iOS, owned by one app-scoped provider.
- Database lifecycle, Drift tables and migrations under `lib/core/database`.
- Root providers compose DB and repositories in `lib/app/providers`; widgets never access SQL or raw DB handles.
- Notes/folders features own presentation/domain/data. Repositories expose domain-safe operations; DAOs remain internal.
- Domain operations validate hierarchy, active/deleted state and ordering. Multi-record invariants run in one Drift transaction.
- Map low-level SQLite/Drift errors to typed application failures at the data boundary.
- Enable and test foreign keys on every connection.
- Schema v1 proposal contains only `folders` and `notes`; see [schema](../database/DATABASE_SCHEMA.md) and [decision register](../database/PHASE_02_DECISION_REGISTER.md).

This architecture remains proposed, not implemented or owner-approved.

## Data lifecycle and integrity

Folder hierarchy uses nullable self-referencing `parent_id`; notes use nullable `folder_id`. UUID IDs and UTC epoch-millisecond timestamps are proposed consistently across future entities. Folder/note moves are atomic and reject invalid destinations/cycles. Proposed folder deletion blocks while any child folder or note (including soft-deleted note) remains; an empty folder is soft-deleted. Notes use `deleted_at` from schema v1; Trash UI is Phase 04. No automatic expiry is approved.

Foreign keys use RESTRICT rather than implicit cascades. Permanent deletion must coordinate future revisions and filesystem attachments. SQLite transactions cannot atomically commit filesystem operations; Phase 05 must design staged cleanup and crash recovery before attachments ship.

## Error and transaction behavior

Data layer maps SQLite/Drift exceptions to typed failures such as validation, not-found, conflict, storage-full, unavailable, corrupt-data, migration-failed and unexpected. Do not retry non-idempotent operations blindly. Failed multi-record operations roll back completely. Failed moves leave source relationships/order unchanged.

Transactions are required for folder reparenting, note moves when multiple records/order metadata change, soft-delete/restore with related metadata, permanent deletion, revisions, attachment metadata, migrations and future restore.

## Future security boundary

Phase 06 requirements include AES-256-GCM, unique nonce per operation, random 256-bit master key, Argon2id, Android Keystore, iOS Keychain, independent password/recovery-key paths, and separate APP/VAULT biometric scopes. These are requirements, not implementations.

Field-level encryption does not automatically protect titles, folder names, metadata, SQLite pages, FTS, WAL/rollback journals, temp files, exports or backups. Phase 06 must inventory/migrate every plaintext-bearing location, verify encrypted read-back and remove persistent plaintext indexes/caches. Search after migration is transient in-memory while unlocked only; clear it on lock (ADR-0011). Biometric authorization must not be coupled to note CRUD.

## Future-phase responsibilities

- 03: Markdown source editor/viewer and safe autosave; no editor-widget coupling in persisted content.
- 04: search, pinning, Trash/Restore and explicit permanent deletion.
- 05: revisions, local attachment metadata/files, statistics and explicit file cleanup.
- 06: reviewed encryption/recovery and plaintext migration.
- 07: separate app/vault biometric authorization.
- 08: versioned encrypted backup/restore and verified legacy ZIP import.
- 09: settings and persisted preferences.

No future-phase table, UI, service or behavior is implemented by this document.
