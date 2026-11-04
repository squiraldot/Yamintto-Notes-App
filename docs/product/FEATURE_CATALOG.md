# Feature catalog and phase ownership

Each feature has exactly one primary implementation phase. Cross-phase obligations are explicit. Current source is a foundation shell; all product workflows below are Planned unless noted.

## Phase 02 — Core Management
### Notes CRUD (primary 02)
Behavior: create/view/edit/delete. Data: ID, title, body, folder ID, timestamps, pin/trash. Dependencies: Drift schema/repository and folders. Acceptance: validated CRUD, transactional relationships, restart persistence. Tests: repository unit, list/detail widget, persistence integration. Platforms: shared Dart + Android/iOS lifecycle. Status: Not implemented.
### Folders (primary 02)
Behavior: create/rename/move/navigate/delete nested folders. Data: ID, parent ID, name, order, timestamps. Dependencies: DB, routing, approved deletion semantics. Acceptance: no cycles, safe note handling, atomic moves/deletes. Tests: hierarchy unit, navigation widget, transaction/rollback integration. Status: Not implemented.

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
Behavior: soft-delete/restore notes/folders, explicit permanent deletion. Data: entity type/ID, deletion time, original location/order, expiry. Dependencies: DB transactions and retention. Acceptance: restore valid location; explicit permanent delete; atomic related cleanup. Tests: lifecycle unit, confirmation widget, cascade/rollback integration. Status: Not implemented.

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
