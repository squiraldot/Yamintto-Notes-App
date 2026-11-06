# System architecture

## Current implementation — Phase 03 PR branch

`lib/main.dart` calls bootstrap; bootstrap initializes Flutter and runs `ProviderScope(child: YaminttoApp())`. `YaminttoApp` owns one GoRouter instance and an in-memory theme notifier. MaterialApp.router receives Material 3 light, dark and AMOLED themes. GoRouter starts at splash, then opens the root folder browser. `/folders/:folderId` opens nested folders; `/notes/new` and `/notes/:noteId/edit` provide the hybrid Markdown source editor, native Flutter preview and autosave; `/appearance` retains the Phase 01 theme preview. The Phase 02 source includes the folder browser, active root/folder note lists, folder operations, note operations, loading/empty/error/retry states and unsaved-change protection.

The app-scoped Riverpod `databaseProvider` lazily opens and memoizes one Drift/SQLite database. Feature repository providers share that instance. Schema v1 is the immutable migration baseline (`folders`, `notes`); current schema v2 adds `tags`, `note_tags` and nullable `folders.color_argb`. Folder/tag canonicalization uses bundled Unicode 17.0 data and deterministic SQLite functions. Repair source revision `fa8f4ad469786a6a7199360a3d6813d22fac75e6` passed Flutter CI run `42177776797` with 85/85 tests; both exact-SHA Debug APK workflows succeeded. Owner-reported physical-device testing passed and Phase 02 is ACCEPTED. The separate integration-test source exists; its execution is not claimed.

Drift/SQLite implementation is present under `lib/core/database/`: schema v1, database wrapper, DAOs, migration strategy, app-scoped provider and folder/note repositories are implemented. Phase 02 includes the folders/notes workflows described above. Encryption, biometrics, attachments and backup remain future-phase work and are not implemented.

## Accepted constraints

- Native Flutter app for Android/iOS; offline-first core workflows.
- Drift over SQLite is accepted by ADR-0003.
- Riverpod is state/DI; GoRouter owns navigation.
- Feature-first boundaries: presentation -> domain contracts/use cases -> data implementations.
- Shared DB/native services belong under `lib/core`; composition belongs in `lib/app/providers`.
- Features do not import another feature's private data implementation.
- Three protected workflows and beta Debug APK policy remain governed by ADR-0012.

## Accepted Phase 02 data architecture — owner approved (2026-11-05)

- One app-private SQLite database for Android/iOS, opened lazily on first repository access and memoized by one app-scoped provider. Complete open/migration before repositories are exposed.
- Database lifecycle, Drift tables and migrations under `lib/core/database`.
- Root providers compose DB and repositories in `lib/app/providers`; widgets never access SQL or raw DB handles.
- Notes/folders features own presentation/domain/data. Repositories expose domain-safe operations; DAOs remain internal.
- Domain operations validate hierarchy (root level 0, maximum folder level 32), Unicode NFKC_Casefold sibling-name uniqueness, active/deleted state and ordering. Multi-record invariants run in one Drift transaction.
- Map low-level SQLite/Drift errors to typed application failures at the data boundary.
- Enable and test foreign keys on every connection.
- Accepted schema v1 contains only `folders` and `notes`; see [schema](../database/DATABASE_SCHEMA.md) and [decision register](../database/PHASE_02_DECISION_REGISTER.md).

Phase 02 architecture decisions are owner-approved and Phase 02 is accepted. Phase 03 implementation was explicitly authorized on 2026-11-06 and is present on PR branch `phase-03/markdown-autosave`; its exact-SHA Flutter CI passed 113/113 tests. Phase 03 owner physical-device acceptance and merge remain pending. Phase 04–09 require separate authorization.

## Data lifecycle and integrity

Folder hierarchy uses nullable self-referencing `parent_id`; notes use nullable `folder_id`. UUID v4 IDs and UTC epoch-millisecond timestamps are accepted. Root is level 0; maximum folder depth is 32. Moves validate the full subtree and reject cycles/depth overflow atomically. Folder names are trimmed, max 255 Unicode code points, and unique per parent using shared Unicode NFKC_Casefold canonicalization plus a root-aware database constraint (including soft-deleted folders). Note titles are max 255 Unicode code points. Folder deletion rejects any child folder or note, including soft-deleted notes; only empty folders are soft-deleted. Notes use `deleted_at` from schema v1; Phase 04 Trash covers both notes and folders. Soft-deleted data is retained indefinitely initially; no automatic expiry.

Foreign keys use RESTRICT rather than implicit cascades. Permanent deletion must coordinate future revisions and filesystem attachments. SQLite transactions cannot atomically commit filesystem operations; Phase 05 must design staged cleanup and crash recovery before attachments ship.

## Error and transaction behavior

Data layer maps SQLite/Drift exceptions to typed failures such as validation, not-found, conflict, storage-full, unavailable, corrupt-data, migration-failed and unexpected. Do not retry non-idempotent operations blindly. Failed multi-record operations roll back completely. Failed moves leave source relationships/order unchanged.

Transactions are required for folder reparenting, note moves when multiple records/order metadata change, soft-delete/restore with related metadata, permanent deletion, revisions, attachment metadata, migrations and future restore.

## Future security boundary

Phase 06 requirements include AES-256-GCM, unique nonce per operation, random 256-bit master key, Argon2id, Android Keystore, iOS Keychain, independent password/recovery-key paths, and separate APP/VAULT biometric scopes. These are requirements, not implementations.

Field-level encryption does not automatically protect titles, folder names, metadata, SQLite pages, FTS, WAL/rollback journals, temp files, exports or backups. Phase 06 must inventory/migrate every plaintext-bearing location, verify encrypted read-back and remove persistent plaintext indexes/caches. Search after migration is transient in-memory while unlocked only; clear it on lock (ADR-0011). Biometric authorization must not be coupled to note CRUD.

## Future-phase responsibilities

- 03: Markdown source editor/viewer and safe autosave; implementation is on PR #2 and no editor-widget coupling is persisted.
- 04: search, pinning, Trash/Restore and explicit permanent deletion.
- 05: revisions, local attachment metadata/files, statistics and explicit file cleanup.
- 06: reviewed encryption/recovery and plaintext migration.
- 07: separate app/vault biometric authorization.
- 08: versioned encrypted backup/restore and verified legacy ZIP import.
- 09: settings and persisted preferences.

Phase 03 implementation is described in [editor architecture](../editor/EDITOR_ARCHITECTURE.md) and [hybrid Markdown dialect](../editor/MARKDOWN_DIALECT.md). No Phase 04–09 table, UI, service or behavior is implemented by this document.


## Owner decision reconciliation — 2026-11-06

Phase 02 is reopened because note tags and folder colors required by the original scope are absent from the implemented baseline. Preserve schema v1 as an immutable migration baseline and add approved capabilities only through a forward-only, data-preserving migration. Tag persistence belongs behind repository/domain boundaries; widgets must not issue SQL. Folder color is optional presentation metadata and must not affect folder identity, hierarchy or ordering.

Phase 03 uses the owner-selected hybrid Markdown direction: modern Markdown baseline plus explicitly verified legacy YRNotes syntax. Persist source text, not rendered widget state. Treat `content_format_version` as a real format contract. Raw HTML is disabled by default except explicit safe legacy allowlisting; URL/image handling must be security- and privacy-conscious. Autosave must prevent stale asynchronous writes from replacing newer edits and retain dirty text after failure.

The existing three protected GitHub Actions workflows remain authoritative. No workflow consolidation or removal is approved.


## Current Phase 02 repair architecture — schema v2

The app-scoped Riverpod database provider continues to own the single Drift/SQLite instance. Widgets call Riverpod providers/controllers and do not access SQL handles. The new `TagRepository` owns tag and junction operations; tag domain validation is in `NoteTag`; `tag_providers.dart` exposes repository/list/assigned-tag providers. The existing `FolderRepository` owns color validation and persistence; `FolderColorPalette` owns the fixed UI palette.

Schema v2 adds `tags`, `note_tags` and nullable `folders.color_argb`. Tag assignment replacement, tag deletion and folder color updates execute through repository/database boundaries. Note/tag foreign keys are RESTRICT; explicit tag deletion removes junction rows in the same transaction. Existing notes/folders are retained through an additive v1→v2 migration.

Repair source SHA `fa8f4ad469786a6a7199360a3d6813d22fac75e6` passed Flutter CI run `42177776797` on Flutter 3.47.9 with 85/85 tests. Both exact-SHA Debug APK workflows succeeded and uploaded artifacts (see [status](../STATUS.md)). Owner confirmed successful physical-device verification of repaired features; Phase 02 is ACCEPTED. Earlier schema-v1-only statements above remain historical and are superseded for current architecture. Phase 03 functionality is implemented on PR branch #2; owner device acceptance and merge remain pending.


## Phase 03 editor architecture — current implementation

The editor remains inside the existing notes feature boundaries. `NoteEditorScreen` owns only presentation state and TextEditingControllers. `NoteAutosaveCoordinator` owns the per-editor debounce/revision state machine and calls a repository callback with an immutable title/body snapshot. `NoteRepository` owns transactional persistence and content-format version transitions. `HybridMarkdownParser` produces a bounded Markdown AST; `SafeMarkdownViewer` maps only reviewed AST elements to Flutter widgets. No WebView, HTML renderer or SQL access is used by presentation.

### Content format contract
- Version 1 is literal plain text and is rendered as selectable text without interpreting Markdown.
- Version 2 is the documented hybrid Markdown dialect.
- New editor-created notes use v2. A v1 note remains v1 on open, preview and title-only edits; a deliberate body edit upgrades only that note to v2 in the same repository transaction.
- Unknown versions are read-only and repository writes reject them. There is no schema migration or bulk content rewrite.

### Autosave behavior
- Debounce: 700 ms.
- Each editor has a monotonically increasing edit revision and one serialized flush future.
- A save persists one atomic title/body snapshot. If a newer revision arrives during a write, the coordinator persists the newer snapshot before reporting Saved.
- Explicit save, preview transition, back navigation and app lifecycle backgrounding attempt to flush. Lifecycle flush is best-effort; process termination before a completed flush may lose the pending debounce window.
- Failures preserve editor source and expose an error/retry state. Saved is shown only when the latest revision has been persisted.

### Current verification
PR #2 source SHA `fc8912781b4ee38efd22be1dcea24f324674cd40` passed Flutter CI run `42200165499`: formatting, analyzer and 113/113 unit/widget tests. Phase 03 owner physical-device acceptance remains pending.
