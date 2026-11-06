# Product requirements specification

Target behavior, not proof of implementation. Status snapshot: [docs/STATUS.md](../STATUS.md). Priority: P0 = data integrity/security gate; P1 = core workflow; P2 = productivity/polish. All rows are Planned unless marked otherwise.

## Functional requirements

| ID | Description / user behavior | Priority | Primary phase | Dependencies | Acceptance criteria | Test expectations | Status |
|---|---|---|---:|---|---|---|---|
| FR-01 | Create, rename, move, navigate and delete nested folders | P1 | 02 | Accepted Drift schema, hierarchy/name validation | Max depth 32 (root 0); no cycles; max 255 Unicode code points; case-insensitive unique sibling names incl. root; empty-only soft-delete; safe references and transaction rollback | hierarchy/depth/name-key/DAO unit; widget CRUD; integration restart/rollback | Implemented |
| FR-02 | Create, view, edit and soft-delete notes | P0 | 02 | Accepted Drift schema, FR-01 | Title max 255 Unicode code points; soft-delete from schema v1 preserves folder/order; deleted notes excluded from active lists/default search and require restore before edit/move | repository unit; list/detail widget; persistence integration | Implemented |
| FR-03 | Edit Markdown source | P1 | 03 | FR-02, approved dialect | Supported syntax documented; source round-trip | parser unit; editor widget; fixture integration | Planned |
| FR-04 | Render Markdown safely | P1 | 03 | FR-03, renderer | Output matches dialect; unsafe content handled; semantics accessible | renderer unit; preview widget; fixture integration | Planned |
| FR-05 | Automatically save edits | P0 | 03 | FR-02/03, lifecycle | Latest revision wins; pending edits flush; errors retain text | race unit; status widget; lifecycle/restart integration | Planned |
| FR-06 | Search notes offline | P1 | 04 | FR-02/03, index strategy | Correct results; trash excluded by default; Phase 06 removes persistent plaintext content index | matcher unit; query widget; update/restart + migration integration | Planned |
| FR-07 | Pin/unpin and prioritize notes | P2 | 04 | FR-02 | Stable order and persistence | sort unit; widget action; restart integration | Planned |
| FR-08 | Trash/restore and permanently delete notes and folders | P1 | 04 | FR-01/02, approved indefinite initial retention | Trash includes both entity types; restore notes to original folder/order or root with explicit conflict result; permanent deletion explicit and confirmed; Phase 05 extends dependent cleanup | lifecycle unit; widget; transaction and cleanup-recovery integration | Planned |
| FR-09 | Browse and restore note revisions | P2 | 05 | FR-02/05, retention | Restore creates new current revision | revision unit; history widget; restore integration | Planned |
| FR-10 | Import/open/export/remove local attachments | P1 | 05 | FR-02, file adapters | Validate type/size; atomic association/cleanup; bytes local but unencrypted in Phase 05 | file unit; picker widget; round-trip/deletion/storage-full integration | Planned; not encrypted until FR-11 |
| FR-11 | Encrypt note bodies/revisions and attachments | P0 | 06 | FR-02/09/10, reviewed crypto | AES-256-GCM, unique nonce, 256-bit master key; tamper fails; no plaintext content/index persists after migration | vectors/tamper; at-rest scan; migration/recovery integration; independent review | Planned |
| FR-12 | Password-based master-key recovery | P0 | 06 | FR-11, Argon2id/wrapping review | Correct credential recovers; wrong fails safely; KDF metadata versioned | KDF unit; recovery widget; clean-device integration | Planned |
| FR-13 | Independent recovery-key path | P0 | 06 | FR-11, CSPRNG/wrapping review | Recovery key independently recovers; safe reveal/confirm/rotation | format/rotation unit; reveal widget; clean-device integration | Planned |
| FR-14 | App biometric lock | P1 | 07 | FR-11–13, native adapters | Timeout/fallback/unavailable/lockout/invalidation safe | policy unit; widget states; physical Android/iOS tests | Planned |
| FR-15 | Separate vault biometric lock | P1 | 07 | FR-11/14, separate key policy | App unlock does not implicitly unlock vault; invalidation cannot expose key | policy unit; vault widget; physical-device tests | Planned |
| FR-16 | Export encrypted versioned backup | P1 | 08 | FR-11, attachments, snapshot | Integrity checked; no plaintext/raw master key; consistent snapshot | parser unit; progress widget; round-trip integration | Planned |
| FR-17 | Validate and restore backup | P1 | 08 | FR-16, transactions | Validate before mutation; rollback; preserve relationships | validation unit; restore widget; corruption/rollback integration | Planned |
| FR-18 | Import verified YRNotes ZIP variants | P1 | 08 | Old source and real fixtures inspected | Only verified variants accepted; malformed archives rejected; report explicit | golden fixtures; preview widget; Android/iOS picker integration | Planned; compatibility unknown |
| FR-19 | Display agreed statistics | P2 | 05 | FR-01/02, metric definitions | Counts/time buckets reconcile with records | aggregation unit; widget; dataset integration | Planned |
| FR-20 | Manage app settings | P2 | 09 | preference storage | Defaults, validation, persistence, reset/migration; no secrets in plain settings | unit; settings widget; restart/migration integration | Planned |
| FR-21 | Choose/persist system, light, dark, AMOLED theme | P2 | 09 | Phase 01 tokens, FR-20 | Persists; system follows OS; AMOLED/status bars/contrast correct | selection unit; theme widget; device persistence | Partially configured: system + seeded light/dark only |
| FR-22 | Choose/persist note/editor font size | P2 | 09 | typography tokens, FR-20 | Bounded values; no clipping; accessible scaling | bounds unit; widget scale matrix; persistence integration | Planned |
| FR-23 | UI/UX polish | P2 | 09 | feature-complete UI | Approved review; consistent states; no blocking UX defects | widget/golden/manual regression | Planned |
| FR-24 | Accessibility | P0 | 09 | all screens | TalkBack/VoiceOver, semantics, contrast, focus, text scale, touch targets verified | semantics/widget + physical-device audits | Planned |
| FR-25 | Performance | P1 | 09 | feature-complete app | Measured budgets defined and met; no data loss under load | benchmarks, stress integration, device profiling | Planned |
| FR-26 | Full regression/readiness | P0 | 09 | FR-01–25 | All phase criteria, platform matrix, security review and release gates pass | full unit/widget/integration/security/device matrix | Planned |

## Non-functional requirements

| ID | Description | User/system behavior | Priority | Primary phase | Dependencies | Acceptance criteria | Test expectations | Status |
|---|---|---|---:|---:|---|---|---|---|
| NFR-01 | Offline-first operation | User can create/read/edit/organize/search core notes without network | P0 | 02 | Local DB, repositories, no mandatory remote service | Core workflows succeed in airplane mode; no network dependency in data path | Offline CRUD/search integration; inspect network calls | Planned |
| NFR-02 | Transactional integrity | User never sees partially applied multi-record changes | P0 | 02 | Drift schema, FK policy, transactions | Interrupted writes roll back or recover without orphaned records | FK, rollback, crash/restart and corruption tests | Planned |
| NFR-03 | Encrypted persistence | User's note/revision/attachment content is not stored plaintext after encryption rollout | P0 | 06 | Reviewed crypto/key design, Phase 05 data/files | No plaintext content remains in DB/files/temp/cache/logs/backups after migration | Automated at-rest scan, interrupted migration and tamper tests | Planned |
| NFR-04 | Search privacy | User searches only while unlocked after encryption; persistent plaintext index is absent | P0 | 06 | Phase 04 index, Phase 06 migration and unlock lifecycle | Migration removes FTS/token/snippet/cache; transient in-memory index cleared on lock | Index migration, locked/unlocked behavior, memory lifecycle and storage scan | Planned |
| NFR-05 | Secret handling | User credentials and keys are never exposed in ordinary settings/logs | P0 | 06 | Key manager, logging/error policy | No password/recovery secret/raw key in preferences, logs, crash output or backup | Redaction unit, log/storage scan and review | Planned |
| NFR-06 | Cross-platform parity | User can complete equivalent core workflows on Android and iOS | P1 | 09 | Shared Dart layers, native adapters, both host builds | Same acceptance scenarios pass; native exceptions documented | Android and iOS integration/device matrix; iOS macOS/Xcode build | Planned; iOS build pending |
| NFR-07 | Accessibility/responsive UX | User can use app with assistive tech, large text and different screen sizes | P1 | 09 | Design tokens, semantics and responsive layouts | TalkBack/VoiceOver, contrast, focus, text scaling and target-size checklist passes | Widget semantics/layout matrix and physical-device audits | Planned |
| NFR-08 | Versioned data formats | User data survives supported app upgrades and backup format evolution | P0 | 02 | DB migration framework; later encryption/backup versioning | Every supported DB/envelope/backup version has explicit migration or safe rejection | Fresh/upgrade/unknown-version fixtures and rollback tests | Planned |
| NFR-09 | Honest recovery guarantees | User is informed when recovery is possible or permanently lost | P0 | 06 | Both independent recovery routes and reviewed key lifecycle | Password and recovery-key paths independently recover; total loss of both plus all valid key copies is documented unrecoverable | Clean-device recovery matrix, wrong credentials, rotation and key-loss tests | Planned |
| NFR-10 | Beta distribution control | Testers receive only debug artifacts during beta | P0 | All phases | Two existing workflows and beta policy | Only Debug APK; no release APK/AAB/signing/publishing; 1.0.0 is first production target | Inspect workflow files and artifact type for each release run | Configured policy |

## Phase 02 data lifecycle — IMPLEMENTED AND ACCEPTED (2026-11-06)

- Drift + SQLite is implemented: schema v1 and the Drift database wrapper are present in source; the schema contains exactly the `folders` and `notes` domain tables.
- Accepted schema v1 contains only `folders` and `notes`. Revisions/attachments are Phase 05, encryption metadata Phase 06, settings Phase 09; no separate polymorphic trash table is proposed.
- Nested folders use NULL as root. Moves reject self/descendant cycles and run transactionally.
- Folder depth is capped at 32 levels (virtual root level 0; top-level folders level 1). Validate creates and complete moved subtrees; reject cycles and any move exceeding level 32.
- Folder names are trimmed, non-empty, maximum 255 Unicode code points, and case-insensitively unique per parent using the same Unicode NFKC_Casefold canonicalizer in app validation and the root-aware database unique constraint. The constraint includes soft-deleted folders; the name is unavailable until permanent deletion. Note titles are maximum 255 Unicode code points.
- Empty-folder-only deletion is accepted: reject if child folders or any notes (including soft-deleted notes) exist; soft-delete only an empty folder. Notes soft-delete from schema v1, preserving folder/order. Deleted notes are excluded from active lists/default search; edit/move requires restore.
- Phase 04 Trash includes deleted notes and folders, with restore and explicit permanent deletion. Restore notes to original folder/order when valid; otherwise restore to root and return an explicit conflict result. Soft-deleted records are retained indefinitely initially; no automatic expiry/cleanup. Permanent deletion and dependent-data cleanup are future-phase work, not Phase 02 blockers.
- See [Phase 02 decision register](../database/PHASE_02_DECISION_REGISTER.md) for the accepted baseline and future-phase decisions.

## Decisions deferred to their owning phases
Markdown dialect and autosave lifecycle (03); folder restore conflict UX, search matching/ranking and pin order (04); revision retention, attachment limits/types and statistics/timezone (05); cryptographic protocol and recovery details (06/07); backup replace/merge and legacy ZIP compatibility (08); theme/font bounds and performance budgets (09). These are not Phase 02 implementation blockers. Security choices are tracked in [Security Overview](../security/SECURITY_OVERVIEW.md).


## Owner-directed requirements reconciliation — 2026-11-06

The owner selected repair for missing Phase 02 note tags and folder colors. Phase 02 is reopened; historical implementation/CI/device evidence does not cover these requirements.

| ID | Requirement | Priority | Primary phase | Acceptance | Status |
|---|---|---:|---:|---|---|
| FR-27 | Create/manage reusable tags and assign/remove multiple tags on notes | P1 | 02 | Persistent local tag definitions/assignments; deterministic normalization, duplicate, ordering and deletion behavior; no note-body mutation; migration preserves existing data | Missing — Phase 02 repair required |
| FR-28 | Set and display folder colors | P2 | 02 | Optional validated persisted color per folder; nested folder display; theme fallback/contrast; no effect on identity, hierarchy or ordering | Missing — Phase 02 repair required |

Tag semantics and color representation must be frozen from the original Phase 02 prompt and an explicit implementation design before coding. Preserve schema v1 and migrate forward without data loss.

## Phase 03 owner decision — hybrid Markdown

FR-03/FR-04 must use a documented hybrid dialect: modern Markdown baseline plus verified legacy YRNotes constructs. Raw HTML is disabled by default except a safe allowlist; unsafe URLs/content are rejected or rendered inert. FR-05 autosave must serialize or revision-guard writes, never let stale saves overwrite newer edits, flush at explicit/lifecycle opportunities, and retain editable dirty text with retry on failure. Phase 03 remains blocked until Phase 02 repair acceptance and separate Phase 03 authorization.


## Phase 02 repair requirements — implemented

### FR-TAG-01 — Reusable note tags
The application shall support local reusable tags, tag CRUD, multiple tags per note, one tag shared by multiple notes, persistent assignment, assigned-tag display and removal. Tag operations shall not mutate note content, identity, folder relationship or timestamps.

### FR-TAG-02 — Tag normalization and lifecycle
Tag names shall be Unicode-trimmed, non-empty, NUL-free and limited to 64 Unicode code points. Uniqueness shall use Unicode 17.0 NFKC_Casefold + NFC and apply globally. Tags shall sort by canonical key/display name/ID. Rename preserves assignments. Delete removes all assignments transactionally. Note soft-delete retains assignments; changing assignments on a deleted note is rejected.

### FR-FOLDER-COLOR-01 — Persistent folder colors
The application shall allow a user to select, change and reset a folder color during folder creation/editing and from folder actions. Colors shall persist for root and nested folders. A finite, validated opaque ARGB palette is stored as nullable SQLite INTEGER; NULL is the theme-aware default. Color shall not affect folder identity, hierarchy, name uniqueness, order or timestamps.

**Implementation status:** implemented in schema v2 and feature UI. Automated evidence: Flutter CI run `42177776797`, source SHA `fa8f4ad469786a6a7199360a3d6813d22fac75e6`, 85/85 tests passed. Owner physical-device acceptance remains pending.
