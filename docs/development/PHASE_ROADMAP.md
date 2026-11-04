# Nine-phase development roadmap

This is an ordered plan, not authorization. Phase 01 is the only authorized phase in the current execution. Each feature has one primary phase; cross-phase work is separated.

## Phase 01 — Foundation
- Scope: Flutter project setup verification; app identity; base design system/tokens and initial system light/dark/AMOLED themes; navigation and splash.
- Dependencies: repository/toolchain baseline.
- Prerequisites: explicit authorization; verify Android and iOS host prerequisites.
- Acceptance: app launches; identity correct; approved base tokens documented; root routing/splash work; no product features silently added.
- Unit: configuration/theme-token tests. Widget: splash/theme/route/unknown route. Integration: Android app-shell startup/theme smoke on API 35 emulator; physical Android cold launch/back/relaunch and iOS macOS/Xcode/device smoke remain separate owner/platform gates.
- Docs: architecture, structure, routing, design system, platform support, ADRs.
- Checklist: [x] scope [x] identity [x] tokens/themes/components [x] splash/root/unknown route [x] unit/widget tests [x] docs [x] repository-wide format [x] analyzer [x] Flutter tests (15) [x] integration smoke source [x] emulator CI configuration [ ] verify emulator CI run #68 [x] baseline CI [x] Debug APK build/artifact [ ] Android physical-device launch [ ] iOS build (macOS/Xcode unavailable) [x] final acceptance evidence/commit SHA.
- Status: Foundation implementation and baseline checks pass. Emulator-backed integration run #68 is pending. Physical Android launch remains owner/device validation; iOS native build is blocked by unavailable macOS/Xcode. Phase is not fully accepted until required platform acceptance gates are recorded.

## Phase 02 — Core Management
- Scope: Drift database/migrations; folder management; notes CRUD.
- Dependencies: Phase 01 accepted.
- Prerequisites: approve IDs, schema, nesting, move/delete behavior, FK and transaction rules.
- Acceptance: fresh DB; folders/notes CRUD; no cycles; transactional changes; restart persistence; errors do not corrupt state.
- Unit: schema, DAOs, repository mapping, validation, hierarchy, FK/transaction. Widget: folder and note CRUD. Integration: fresh install, CRUD/restart, interrupted transaction and migration.
- Docs: schema, migration, retention, requirements, feature catalog.
- Checklist: [ ] schema [ ] migration tests [ ] folder CRUD [ ] note CRUD [ ] unit [ ] widget [ ] integration [ ] docs [ ] review/SHA.
- Status: Planned.

## Phase 03 — Editor
- Scope: Markdown editor; viewer; autosave.
- Dependencies: Phase 02 persistence.
- Prerequisites: approve Markdown dialect, safe renderer, editor UX, autosave debounce/flush.
- Acceptance: syntax documented; source round-trips; safe viewer; latest edit wins; pending edits flush on lifecycle; errors retain editable text.
- Unit: parser/serializer, save ordering, stale-write/cancel. Widget: editor/preview/keyboard/save/error. Integration: rapid edits, background/foreground, process termination/restart/data-loss simulations.
- Docs: editor architecture, requirements, catalog, testing.
- Checklist: [ ] dialect [ ] editor [ ] viewer [ ] autosave [ ] unit [ ] widget [ ] lifecycle integration [ ] docs [ ] review/SHA.
- Status: Planned.

## Phase 04 — Organization
- Scope: search; pinned notes; trash and restore.
- Dependencies: Phase 02 data and Phase 03 note content.
- Prerequisites: approve search fields/ranking, index engine availability, pin order, deletion and retention.
- Acceptance: offline search on pre-encryption model; results update on mutations; trash excluded by default; pin order stable; restore safe. Index is transitional: Phase 06 removes persistent plaintext content indexes.
- Unit: normalization/matching/ranking, index updates, sorting, trash lifecycle. Widget: search states, pin, trash/restore/permanent-delete confirmation. Integration: index updates, restart, folder moves, restore and rollback.
- Docs: catalog, DB indexes, retention, search lifecycle and tests.
- Checklist: [ ] search decision [ ] search [ ] pin [ ] trash/restore [ ] unit [ ] widget [ ] integration [ ] Phase 06 migration documented [ ] docs [ ] review/SHA.
- Status: Planned.

## Phase 05 — Productivity
- Scope: note history; local attachment storage/lifecycle; statistics.
- Dependencies: notes CRUD, editor/autosave, organization.
- Prerequisites: approve revision retention, attachment types/size, file policy and metric definitions.
- Acceptance: revision restore creates new current revision; attachments import/open/export/remove safely with validation, atomic metadata and cleanup; statistics reconcile.
- Security boundary: Phase 05 attachment bytes are local but unencrypted. Temporary beta-only behavior, not production-ready. Phase 06 must encrypt existing/future bytes and remove plaintext originals/staging/previews before production readiness.
- Unit: revision ordering/restore, file validation/path, stats/timezone. Widget: history, attachment picker/list/progress/error, statistics. Integration: attachment round-trip, orphan cleanup, storage-full/interrupted copy, revision restore and dataset.
- Docs: database, retention, attachment lifecycle, threat model, tests.
- Checklist: [ ] history [ ] local attachment lifecycle [ ] stats [ ] limits [ ] unit [ ] widget [ ] integration [ ] unencrypted beta warning [ ] docs [ ] review/SHA.
- Status: Planned.

## Phase 06 — Encryption
- Scope: AES-256-GCM for notes/revisions/attachments; password and recovery-key recovery; secure search migration.
- Dependencies: Phase 05 data/attachment model.
- Prerequisites: independent security review of packages, envelope/protocol, nonce/AAD, Argon2id parameters, wrapping, rotation and native responsibilities. Agents must not invent protocol parameters.
- Acceptance: random 256-bit master key; AES-256-GCM; unique nonce each operation; both recovery paths independently work; wrong credentials/tampering fail closed; migration removes plaintext notes/revisions/attachments/temp copies and persistent plaintext full-text indexes; locked search unavailable; unlocked search transient memory only.
- Unit: vectors, nonce strategy, tamper, KDF/wrapping, rotation, serialization. Widget: setup, recovery, key reveal/confirm, locked/unlocked search. Integration: plaintext migration, interruption/restart, DB/file/temp/log/index scans, clean-device recovery by each path, lock clears transient search.
- Docs: encryption, key management, recovery, secure attachments/backups, threat model, search, ADR, security tests.
- Checklist: [ ] reviewed protocol [ ] key lifecycle [ ] notes/revisions encrypted [ ] attachments migrated [ ] plaintext indexes removed [ ] both recovery paths [ ] tamper [ ] migration [ ] storage scans [ ] docs/review/SHA.
- Status: Planned.

## Phase 07 — Authentication
- Scope: app biometric lock; separate vault biometric lock; security settings.
- Dependencies: Phase 06 key hierarchy/encrypted data.
- Prerequisites: validate Android Keystore/BiometricPrompt and iOS Keychain/LocalAuthentication semantics, invalidation, device-credential fallback and access-control flags.
- Acceptance: app/vault are distinct authorization scopes; app unlock does not unlock vault; fallback, cancellation, lockout, unavailable hardware, enrollment change and migration never expose keys.
- Unit: policy/state transitions. Widget: prompts/settings/locked/cancel/fallback. Device integration: physical Android/iOS success, lockout, enrollment change, invalidation, reinstall and recovery fallback; simulator alone insufficient.
- Docs: biometric, platform architecture, threat model and device evidence.
- Checklist: [ ] native review [ ] app lock [ ] vault lock [ ] fallback [ ] invalidation [ ] Android device [ ] iOS device [ ] docs/review/SHA.
- Status: Planned.

## Phase 08 — Backup System
- Scope: legacy ZIP import; new encrypted backup; restore.
- Dependencies: Phase 05 attachments and Phase 06 encryption/recovery; Phase 07 auth UX as required.
- Prerequisites: inspect YRNotes source and golden ZIP fixtures without modifying YRNotes; approve format/version, restore policy and key portability.
- Acceptance: encrypted consistent backup; validate before mutation; atomic restore/rollback; explicit result report; only verified legacy variants accepted; corrupt/unknown archives rejected.
- Unit: archive parser, manifest, integrity, version, ZIP path/size limits, compatibility, rollback. Widget: selection/preview/progress/confirmation/errors. Integration: golden fixtures, corrupt/truncated archive, interrupted restore, clean-device/cross-platform round-trip.
- Docs: backup format/security, compatibility matrix, versioning and fixtures.
- Checklist: [ ] legacy audit [ ] fixtures [ ] format [ ] export [ ] restore [ ] rollback [ ] legacy import [ ] Android/iOS picker [ ] docs/review/SHA.
- Status: Planned; legacy compatibility unverified.

## Phase 09 — Final Polish
- Scope: settings; font-size preferences; theme preferences and persistence; UI/UX polish; accessibility; performance; full regression testing.
- Dependencies: Phases 01–08 accepted; stable features; measured baselines and approved design tokens.
- Prerequisites: no critical data-loss/security defects; settings model/preference bounds approved; Android/iOS device matrix.
- Acceptance: settings/default/reset/migration; persisted system/light/dark/AMOLED; persisted font size respects accessibility; polished consistent states; accessibility passes; measured performance budgets met; full regression and readiness evidence signed off.
- Unit: settings validation/migration, theme selection, font bounds, full unit regression. Widget: settings, theme matrix, font scale, responsive, semantics, full widget regression. Integration/device: preference persistence, benchmarks, TalkBack/VoiceOver, Android/iOS physical regression, DB migration, encryption, recovery, biometrics, backup.
- Docs: design, themes, accessibility, responsive, testing, platform matrix, readiness, changelog/status.
- Checklist: [ ] settings [ ] theme persistence [ ] font preference [ ] UI/UX [ ] accessibility [ ] performance budgets [ ] unit/widget/integration [ ] Android device [ ] iOS device [ ] security review [ ] readiness sign-off.
- Status: Planned.

## Cross-phase ownership
02 folders/notes; 03 Markdown/autosave; 04 search/pin/trash; 05 history/local attachments/statistics; 06 encryption/password/recovery key/search-index migration; 07 app/vault biometrics; 08 legacy/new backup/restore; 09 settings/theme preference/font size/polish/accessibility/performance/regression. Phase 01 owns base design tokens only; Phase 09 owns selectable theme preferences and persistence. Phase 05 stores attachments locally unencrypted; Phase 06 encrypts/migrates them. Phase 04 search is introduced pre-encryption; Phase 06 removes persistent plaintext index. No scope expansion, skipped phases or premature future work.
