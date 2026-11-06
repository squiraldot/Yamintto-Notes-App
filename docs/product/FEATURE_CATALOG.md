# Feature catalog and phase ownership

Each feature has exactly one primary implementation phase. Cross-phase obligations are explicit. Phase 01 foundation is present. Phase 02 database/repositories and the folder/notes presentation source are implemented and host-validated on source revision `745b8f589afceb783a9b39bafcd03c123e50c395` (Flutter CI run `42097059083`, 69/69 tests). owner-reported Android physical-device testing of the repaired tags/colors features passed; Phase 02 is ACCEPTED.

## Phase 01 — Foundation

### Flutter project and identity (primary 01)
Behavior: configure the Flutter app identity and preserve Android/iOS host identity, dependency lock, linting and bootstrap. Acceptance: package name yamintto; Android application ID and iOS bundle ID com.merrmist.yamintto; beta version; app launches from the configured entry point. Tests: configuration unit tests; Android host identity configured and owner-reported physical-device testing successful (detailed evidence not attached); iOS native build/device verification is environment-dependent. Current: implemented/configured; iOS verification is Not Verified — Environment Unavailable and non-blocking for Android-focused phase progression.

### Base design system (primary 01)
Behavior: centralized provisional color, typography, spacing and radius tokens; Material 3 light, dark and true-black AMOLED theme variants; reusable app-shell button, card, text field, dialog and sheet primitives. Acceptance: tokens centralized, theme variants construct, AMOLED surfaces are true black, shared components compile and remain accessible. Tests: token/theme unit tests and component widget tests. Current: implemented in app shell; final brand system and detailed screen design remain subject to approval.

### Splash and navigation foundation (primary 01)
Behavior: splash as initial route, navigation to the root folder browser, unknown-route recovery. Acceptance: app opens on splash, transitions to the root folder browser, route errors recover to home. Tests: splash/navigation and unknown-route widget tests; owner-run physical Android cold-launch/device checks. Current: Dart implementation and widget coverage present; owner reports successful Android real-device testing (detailed evidence not attached). iOS native build/device behavior remains Not Verified — Environment Unavailable and is non-gating.

Phase 01 does not include notes, folders, editor, search, database, security, attachments, backups, settings or persisted theme/font preferences. Theme preference persistence belongs to Phase 09. Status: **Source implementation present; host CI and APK artifacts verified; Android device testing owner-reported successful with detailed evidence not attached; iOS verification non-gating and unavailable. Acceptance is recorded as an owner-reported Android pass, not independent device-log verification.**

## Phase 02 — Core Management
### Notes CRUD (primary 02)
Behavior: create/view/edit and soft-delete notes; no Trash UI or physical permanent deletion in Phase 02. Accepted data: canonical lowercase UUID v4 ID, title (max 255 Unicode code points), editor-independent source body, optional folder ID, explicit sort order, UTC epoch-millisecond timestamps and nullable deleted_at. Acceptance: validated CRUD, transactional relationships, restart persistence, deleted notes excluded from active queries/default search; editing/moving requires restore. Status: Implemented in source and covered by repository/widget tests: root/folder listing, create, open, plain-text edit/save/cancel, unsaved-change guard, move to/from root, soft-delete and active-list exclusion. Latest source revision CI passed 69/69 tests, including 19 Phase 02 screen widget tests; owner-reported Android physical-device smoke testing passed.
### Folders (primary 02)
Behavior: create/rename/move/navigate/delete nested folders. Accepted data: UUID v4 ID, nullable parent ID, trimmed name (1–255 Unicode code points), Unicode NFKC_Casefold name_key, sibling order, timestamps and nullable deleted_at. Names are unique case-insensitively within the same parent, including root and soft-deleted folders; different parents may reuse names. Maximum depth 32 (root 0); create/move validation checks entire subtree and cycles. Delete only empty folders; soft-delete. Status: Implemented in source and covered by widget/repository tests: root/nested browsing, create/rename/move, descendant-safe move targets, move to root, empty-only soft-delete, non-empty rejection and parent navigation. Latest source revision CI passed 69/69 tests, including 19 Phase 02 screen widget tests; owner-reported Android physical-device smoke testing passed.

**Phase 02 schema boundary (owner approved):** schema v1 contains only `folders` and `notes`. Do not add revisions, attachments, tags, trash_items, encryption_metadata or app_settings early. Search/pinning/Trash UI are Phase 04; Phase 04 Trash covers deleted notes and folders, restore and explicit permanent deletion; revisions/attachments Phase 05; encryption metadata Phase 06; settings Phase 09. Soft-delete retention is indefinite initially; no automatic cleanup. Permanent deletion is not a Phase 02 blocker. See [schema](../database/DATABASE_SCHEMA.md), [migrations](../database/DATABASE_MIGRATIONS.md), [retention](../database/DATA_RETENTION.md) and [decision register](../database/PHASE_02_DECISION_REGISTER.md).

## Phase 03 — Editor
### Markdown editor/viewer (primary 03)
Behavior: edit source and render documented dialect. Data: Markdown source and format version. Dependencies: notes repository, approved dialect/safe renderer. Acceptance: source round-trip, safe rendering, accessible semantics. Tests: parser/serializer unit, editor/preview widget, fixture integration. Platforms: shared; test selection/keyboard/typography both. Status: Not implemented.
### Autosave (primary 03)
Behavior: save edits automatically; show saving/saved/error. Data: note ID, edit revision, dirty state, save time. Dependencies: editor, repository transaction, lifecycle policy. Acceptance: stale save cannot overwrite newer edit; pending edits flush on defined lifecycle; errors retain text. Tests: race unit, status widget, rapid edit/background/kill/restart integration. Status: Not implemented.

## Phase 04 — Organization
### Search (primary 04; privacy migration 06)
Phase 04: offline search against pre-encryption local records; a persisted plaintext content index is temporary pre-encryption design only, after verifying DB engine support. Phase 06: remove persistent plaintext full-text/token/snippet/cache/temp copies. While unlocked, decrypt via repository and build/use transient in-memory index; clear on lock. Content search unavailable while locked. No encrypted-search protocol approved. Data: query, result IDs, transient index; pre-06 index only. Acceptance: correct results, trash excluded by default, mutations reflected, migration proves no plaintext index, lock clears memory. Tests: matcher/index unit, query widget, update/restart integration, migration/storage scan, lock/unlock lifecycle. Platforms: benchmark low-memory devices. Status: Not implemented.
### Pinned notes (primary 04)
Behavior: pin/unpin, deterministic order. Data: note ID, flag, pin time/order. Dependencies: notes/list. Acceptance: persists; trash policy defined. Tests: sort unit, widget action, restart integration. Status: Not implemented.
### Trash/restore (primary 04)
Behavior: browse/restore soft-deleted notes and folders; explicit permanent deletion with confirmation. Restore notes to original folder/order or root with an explicit conflict result if unavailable. Folder restore respects parent and unique sibling-name rules; Phase 04 defines conflict UX. Soft-delete retention is indefinite initially; no automatic expiry. Phase 05 extends permanent-delete cleanup to revisions/attachment metadata/files with staged crash recovery. Status: Not implemented.

## Phase 05 — Productivity
### Note history (primary 05)
Behavior: browse and restore revisions. Data: revision ID, note ID, snapshot, sequence/time. Dependencies: notes/autosave/retention. Acceptance: restore creates new current revision; bounded deterministic retention. Tests: ordering unit, history widget, restore integration. Status: Not implemented.
### Local attachments (primary 05; encryption migration 06)
Phase 05: import, associate, list, open/export/remove files in app-private local storage; validate type/size/name, atomic metadata and cleanup. **Bytes are not encrypted by Phase 05. This temporary beta state is not production-ready.** Phase 06 encrypts existing/future bytes and removes plaintext originals, staging, previews and temp copies after verified migration. Data: attachment ID, note ID, display name, media type, size, storage reference, timestamps; envelope metadata after 06. Dependencies: file picker/store, note relation; later reviewed crypto. Tests: Phase 05 validation/path/storage-full/lifecycle; Phase 06 vectors/tamper/migration interruption/rollback/plaintext scan. Platforms: Android SAF/content URI and iOS document picker. Status: Not implemented.
### Statistics (primary 05)
Behavior: agreed counts/activity metrics. Data: aggregates/date buckets. Dependencies: note/folder timestamps and metric definitions. Acceptance: reconcile source records; timezone/deletion policy explicit. Tests: aggregation unit, widget, dataset integration. Status: Not implemented.

## Phase 06 — Encryption and recovery
### Notes, revisions and attachment encryption (primary 06)
Requirements: AES-256-GCM, fresh unique nonce per operation, random 256-bit master key, Argon2id password KDF; no plaintext content/index persisted after migration; tamper fails closed. Dependencies: Phase 05 data, reviewed protocol/key manager. Tests: vectors, nonce/tamper, migration, at-rest scan, recovery integration and independent review. Platforms: reviewed Dart/native adapters. Status: Not implemented.
### Password recovery (primary 06)
Behavior: independently recover master key via Argon2id password path. Data: versioned salt/KDF metadata and wrapped-key data; never password. Acceptance: correct succeeds, wrong fails safely, versioning/rotation documented. Tests: KDF unit, recovery widget, clean-device integration. Status: Not implemented.
### Recovery key (primary 06)
Behavior: independent high-entropy recovery secret, safe reveal/confirmation/rotation. Acceptance: independently restores key; rotation interruption-safe; loss limits clear. Tests: format/rotation unit, reveal widget, clean-device integration. Status: Not implemented.

## Phase 07 — Authentication
### App biometric lock (primary 07)
Behavior: gate app access; device credential fallback per approved policy. Data: app-lock policy and device-bound key reference. Acceptance: timeout/unavailable/cancel/lockout/invalidation safe. Tests: policy unit, widget states, physical Android/iOS. Status: Not implemented.
### Vault biometric lock (primary 07)
Behavior: separately authorize vault; app unlock does not implicitly unlock vault. Data: separate vault policy/key reference. Acceptance: invalidation never exposes key; recovery path clear. Tests: policy unit, widget, physical-device enrollment-change/fallback. Status: Not implemented.

## Phase 08 — Backup
### New encrypted backup (primary 08)
Behavior: export versioned encrypted snapshot. Data: manifest, encrypted DB/attachment payload, integrity/version metadata. Dependencies: encryption, attachments, snapshot consistency. Acceptance: no plaintext/raw master key, integrity checked, consistent snapshot. Tests: parser unit, progress widget, round-trip/corruption integration. Status: Not implemented.
### Restore (primary 08)
Behavior: validate, preview and restore with approved replace/merge policy. Acceptance: validate before mutation, atomic commit/rollback, relationships preserved. Tests: validation unit, restore widget, corruption/rollback/clean-device integration. Status: Not implemented.
### Legacy ZIP import (primary 08)
Behavior: import only verified YRNotes variants. Dependencies: inspect separate YRNotes source and real golden fixtures; never modify YRNotes. Acceptance: compatibility matrix, safe parser, explicit imported/skipped report, no silent loss. Tests: golden fixtures, traversal/decompression/corruption, preview widget, platform file-picker integration. Status: Planned; compatibility unverified.

## Phase 09 — Final Polish and preferences
### Settings (primary 09)
Behavior: manage app preferences/settings. Data: typed non-secret values/version. Acceptance: defaults, validation, persistence, reset/migration; secrets excluded. Tests: unit, widget, restart/migration. Status: Not implemented.
### Theme preference/persistence (primary 09)
Behavior: choose system/light/dark/AMOLED. Dependencies: Phase 01 base tokens + settings. Acceptance: persist; system follows OS; approved AMOLED surfaces; accessible contrast/system bars. Tests: unit, widget matrix, restart/device. Phase 01 owns initial tokens/theme foundation only. Current: system mode and seeded light/dark themes configured; no user preference or AMOLED.
### Font-size preference (primary 09)
Behavior: choose/persist note/editor size. Acceptance: approved bounds, no clipping, respects OS scaling. Tests: bounds unit, widget matrix, persistence/device. Status: Not implemented.
### UI/UX polish, accessibility, performance, full regression (primary 09)
Acceptance: approved design review; TalkBack/VoiceOver, semantics, contrast, focus, large text, touch targets; performance budgets measured then met; complete unit/widget/integration/security/platform regression. Status: Not implemented.

Ownership summary: 02 folders/notes; 03 Markdown/autosave; 04 search/pin/trash; 05 history/local attachments/statistics; 06 encryption/password/recovery key/search-index migration; 07 app/vault biometrics; 08 legacy/new backup/restore; 09 settings/theme preference/font size/polish/accessibility/performance/regression.


## Owner-directed scope reconciliation — 2026-11-06

**Phase 02 is REOPENED.** The implemented folders/notes baseline is historical and does not include two required capabilities selected for repair:

### Note tags (primary Phase 02 — missing, repair required)
Support reusable tags and multiple tag assignments per note with persistent local storage. Inspect the original Phase 02 prompt to establish normalization, duplicate handling, ordering, deletion semantics and behavior for soft-deleted notes. Tag changes must not mutate note body/title.

### Folder colors (primary Phase 02 — missing, repair required)
Support an optional persisted, validated color per folder and consistent rendering for nested folders. Define the approved palette/serialization, theme fallback and contrast before implementation. Color must not affect folder identity, hierarchy, name uniqueness or order.

### Phase 03 hybrid editor contract
The owner selected **HYBRID** compatibility: a modern Markdown baseline plus explicitly verified legacy YRNotes constructs. Raw HTML is disabled by default; only safe allowlisted legacy constructs may render. Preserve source text and define `content_format_version` semantics. Autosave must prevent stale writes from overwriting newer edits and retain dirty text on failure.

Phase 03 is blocked until Phase 02 repair is accepted and separate Phase 03 authorization is given. See [the gated Phase 03 implementation prompt](../development/PHASE_03_IMPLEMENTATION_PROMPT.md).


## Phase 02 repair features — implemented in source

### Note tags
Status: **Implemented; automated tests passed; owner-reported physical-device acceptance passed. Phase 02 ACCEPTED.**

Reusable global tags, normalized names, duplicate rejection, rename/delete, multiple note assignments, assignment removal, tag chips in active note lists, tag management and note assignment screens are implemented. Assignments use a normalized `note_tags` junction. Rename preserves links; delete removes links transactionally. Soft-deleted notes retain assignments and reject assignment edits. Tag operations do not change note content or timestamps.

### Folder colors
Status: **Implemented; automated tests passed; owner-reported physical-device acceptance passed. Phase 02 ACCEPTED.**

Ten validated opaque ARGB palette values, nullable default, creation/edit selection, folder action color selection, reset, theme fallback and nested folder display are implemented. Color changes preserve folder identity, hierarchy, sort order and timestamps.

### Current Phase 02 schema and evidence
Schema v1 remains immutable; current schema is v2 with `tags`, `note_tags` and nullable `folders.color_argb`. Repair source SHA `fa8f4ad469786a6a7199360a3d6813d22fac75e6`; Flutter CI run `42177776797`; 85/85 tests passed; both exact-SHA APK workflows succeeded. Owner-reported physical-device testing passed and Phase 02 is ACCEPTED. Earlier missing/repair-required statuses are historical and superseded. Phase 03 remains unauthorized.
