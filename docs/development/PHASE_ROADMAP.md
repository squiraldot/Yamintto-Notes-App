# Nine-phase development roadmap

This is an ordered plan, not blanket authorization. Phase 02 was explicitly authorized and accepted. Phase 03 implementation was explicitly authorized by the owner on 2026-11-06 and is implemented on PR branch `phase-03/markdown-autosave`; owner device acceptance and merge remain pending. Phase 04–09 require separate authorization. Each feature has one primary phase; cross-phase work is separated.

## Phase 01 — Foundation
- Scope: Flutter project setup verification; app identity; base design system/tokens and initial system light/dark/AMOLED themes; navigation and splash.
- Dependencies: repository/toolchain baseline.
- Prerequisites: explicit authorization; verify Android and iOS host prerequisites.
- Acceptance: app launches; identity correct; approved base tokens documented; root routing/splash work; no product features silently added.
- Unit: configuration/theme-token tests. Widget: splash/theme/route/unknown route. Integration source: Android app-shell startup/theme smoke retained for owner-run physical-device execution only. No emulator, simulator, KVM or virtual-device CI is permitted. iOS native implementation/configuration continues alongside shared development; native build/device verification is environment-dependent and non-blocking for Android-focused phase progression.
- Docs: architecture, structure, routing, design system, platform support, ADRs and testing policy.
- Checklist: [x] scope [x] identity [x] tokens/themes/components [x] splash/root/unknown route [x] unit/widget tests [x] docs [x] repository-wide format [x] analyzer [x] Flutter tests (15) [x] integration smoke source retained [x] host-only Flutter CI [x] universal Debug APK artifact [x] ARM64 Debug APK artifact [x] owner-reported successful physical Android testing (detailed evidence not attached; not independently verified) [ ] iOS native build/device verification (Not Verified — Environment Unavailable; non-blocking).
- Status: Phase 01 source implementation is present. Latest host-only Flutter CI and both APK artifact workflows succeeded on commit 76ba10c04f0ec421f54e5d6252dd6745058611f9 (run IDs 41981911424, 41982079883 and 41982079971). Android real-device testing is owner-reported successful, with detailed evidence not attached. Phase 01 acceptance is recorded as an owner-reported Android pass, not independent device-log verification. No Android device-test failure is currently outstanding. iOS verification is non-gating; continue iOS implementation with applicable phases.

## Phase 02 — Core Management — ACCEPTED (2026-11-06)
- Scope: implement Drift schema v1 as the immutable baseline and the schema v2 repair migration; nested folder management; note CRUD/soft-delete; reusable note tags with multiple persistent assignments; optional persisted root/nested folder colors. No Trash UI, physical permanent deletion, search, pinning, revisions, attachments, encryption, biometrics, backup or import implementation.
- Dependencies: Phase 01 accepted; owner-approved architecture freeze recorded in [decision register](../database/PHASE_02_DECISION_REGISTER.md) and [ADR-0013](../decisions/0013-phase-02-data-model-lifecycle.md).
- Prerequisite: **satisfied** — owner explicitly authorized Phase 02 implementation on 2026-11-05. Starting baseline `92dcadd7ed2bd2ee9b49ca8893843b13a689bb7e`; continue from the newer `main` head without resetting history.
- Immutable schema v1 baseline: folders and notes; NULL root relationships; canonical lowercase UUID v4 TEXT; UTC epoch-millisecond INTEGER; nullable deleted_at; explicit sort_order; FK enforcement with RESTRICT; transactional multi-record operations. Current schema v2 adds reusable tags, note-tag assignments and nullable folder color.
- Folder hierarchy: virtual root level 0; top-level folders level 1; maximum level 32. Domain validation and tests must check create/move subtree depth and cycle rejection.
- Folder names: trimmed, non-empty, max 255 Unicode code points; case-insensitive unique per parent using the shared Unicode NFKC_Casefold canonicalizer and a root-aware database unique constraint. Includes soft-deleted folders; name reuse only after Phase 04 permanent deletion.
- Note titles: max 255 Unicode code points; empty title allowed.
- Folder deletion: reject if any child folder or any note (including soft-deleted note) exists; soft-delete only empty folders. Note delete soft-deletes and retains folder/order. Deleted notes excluded from active lists/default search; edit/move requires restore.
- Phase 04 Trash must cover deleted notes and folders, restore and explicit permanent deletion. Note restore uses original folder/order or root with explicit conflict result if unavailable. Phase 02 does not implement Trash UI or permanent deletion.
- Retention: indefinite soft-delete retention initially; no automatic expiry or cleanup. Phase 05 extends permanent deletion to revisions/attachment data/files with durable staged cleanup and crash recovery.
- Acceptance after authorization: fresh schema v1; CRUD; depth 32 accepted/33 rejected; no cycles/orphans; sibling name uniqueness including root and soft-deleted rows; FK checks; transaction rollback; restart persistence; soft-delete filters; typed errors.
- Tests: schema/DAO/repository/hierarchy/depth/name canonicalization/order/FK/transaction unit; folder/note widgets; fresh install, CRUD/restart, soft-delete, rollback and migration integration on supported platforms.
- Checklist: [x] schema v1 baseline [x] forward-only schema v2 migration [x] Unicode 17.0 canonicalization [x] folder/note CRUD and hierarchy [x] reusable tags and persistent assignments [x] persistent root/nested folder colors [x] 85 unit/database/repository/widget tests [x] populated-v1 migration and rollback coverage [x] exact-repair-SHA Flutter CI [x] exact-repair-SHA universal and ARM64 Debug APK builds [x] owner-reported physical-device testing [x] final owner acceptance. The automated integration-test source is retained; execution is not claimed.
- Status: **ACCEPTED — IMPLEMENTATION, AUTOMATED VALIDATION AND OWNER-REPORTED ANDROID DEVICE TESTING COMPLETE.** Repaired source revision `fa8f4ad469786a6a7199360a3d6813d22fac75e6` passed locked dependency resolution, formatting, analyzer and all 85 tests. Universal and ARM64 Debug APK workflows succeeded for that exact source SHA. The owner confirmed successful physical-device testing of the repaired tags/colors features. The integration-test source is present; execution is not claimed. No emulator or simulator is used in CI. Phase 03 has not started and is not authorized.

## Phase 03 — Editor — IMPLEMENTED ON PR BRANCH; ACCEPTANCE PENDING
- Scope: Markdown source editor; safe native viewer/preview; version-aware note content; reliable autosave.
- Dependencies: Phase 02 persistence — satisfied; owner-selected HYBRID compatibility — satisfied.
- Authorization: owner submitted the final implementation prompt and explicitly authorized execution on 2026-11-06.
- Implementation branch/PR: `phase-03/markdown-autosave`, [PR #2](https://github.com/squiraldot/Yamintto-Notes-App/pull/2).
- Exact source SHA: `fc8912781b4ee38efd22be1dcea24f324674cd40`.
- Acceptance evidence: Flutter CI run [#42200165499](https://github.com/squiraldot/Yamintto-Notes-App/actions/runs/42200165499) passed formatting, analyzer and **113/113 unit/widget tests**.
- Implemented: documented dialect and legacy source inspection; AST parser with limits; explicit allowlisted safe rendering; inert URL handling and image placeholders; v1 plain-text/v2 Markdown semantics; unknown future formats read-only; serialized 700 ms autosave with revision guard, navigation/lifecycle flush and retry.
- Data migration: none. Existing schema v2 remains unchanged; no mass rewrite.
- Unit/widget: passed on the exact PR SHA. The integration/device tests remain owner-run on real physical devices; Phase 03 physical-device acceptance is pending.
- Docs: README, CHANGELOG, status, roadmap, architecture, testing strategy, dialect and editor architecture.
- Checklist: [x] dialect [x] editor [x] viewer [x] autosave [x] unit/widget [x] docs [x] exact-SHA Flutter CI [ ] owner physical-device test [ ] PR review/merge [ ] final owner acceptance.
- Status: Implemented on PR branch; not merged or owner-accepted.

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


## Owner-directed status reconciliation — 2026-11-06

### Phase 02 — Core Management — REOPENED

The owner selected repair for two missing original Phase 02 capabilities: note tags and folder colors. The prior “ACCEPTED” label and completed checklist are historical baseline records and are superseded for phase progression.

Outstanding repair checklist:
- [ ] Inspect original Phase 02 prompt and freeze tag semantics (normalization, duplicates, ordering, deletion and soft-deleted-note behavior).
- [ ] Implement reusable note tags and persistent note-tag assignments.
- [ ] Freeze folder color palette/serialization/fallback/contrast and implement persistence/display.
- [ ] Preserve schema v1 and add a forward-only, data-preserving migration.
- [ ] Add tag/color domain, repository, migration and widget tests.
- [ ] Run locked dependencies, format, analyzer and full unit/widget tests.
- [ ] Verify all three protected workflows on the exact repair SHA.
- [ ] Owner repeats Android physical-device smoke test after repair.
- [ ] Reconcile documentation and receive explicit Phase 02 acceptance.

The earlier 69/69 CI run, universal/ARM64 APK runs and owner-reported device test remain historical evidence for the old baseline only. **Phase 03 is blocked until this repair is accepted.**

### Phase 03 — Editor — IMPLEMENTED ON PR BRANCH

Owner-selected Markdown direction: **HYBRID** — modern Markdown baseline plus explicitly verified legacy YRNotes constructs. The owner submitted [PHASE_03_IMPLEMENTATION_PROMPT.md](PHASE_03_IMPLEMENTATION_PROMPT.md) as an explicit implementation request on 2026-11-06. PR #2 contains the implementation and exact-SHA CI evidence. The older planned/blocked status above is superseded by the current implementation section.


## Phase 02 reopened repair — current gate status (2026-11-06)

**PHASE 02 — ACCEPTED (2026-11-06). Phase 03 remains not started and unauthorized.**

The repair adds reusable note tags and persisted folder colors via schema v2 while preserving schema v1. Implementation source SHA: `fa8f4ad469786a6a7199360a3d6813d22fac75e6`. Flutter CI run `42177776797` succeeded on Flutter 3.47.9 with format, analyzer and 85/85 tests passing.


Exact-SHA Debug APK evidence (source `fa8f4ad469786a6a7199360a3d6813d22fac75e6`):
- Universal run `42177872597` succeeded; artifact `yamintto-debug-fa8f4ad469786a6a7199360a3d6813d22fac75e6`, ID `13483409802`, archive 80,077,640 bytes, SHA-256 `ec417ad611bbdbc64ffa402af433cfc96cb70958871aee56b5a70192626c34e2`.
- ARM64 run `42177872567` succeeded; artifact `yamintto-arm64-debug-fa8f4ad469786a6a7199360a3d6813d22fac75e6`, ID `13484082037`, archive 51,786,455 bytes, SHA-256 `f53c2e1caadd41b52dfaf3a657ad0bf95ad82bf36be6a51a532f16c680308837`.
Archive sizes are ZIP sizes, not extracted APK sizes. Both artifact records showed expiry 2026-11-20.


The physical-device integration test source covers tags and folder colors across close/reopen; its execution is not independently evidenced and is not claimed. The owner separately confirmed successful physical-device testing of the repaired features.

The prior Phase 02 REOPENED/PENDING statements above are historical snapshots and are superseded by the final owner acceptance and documentation reconciliation. Phase 03 remains blocked until separate explicit owner authorization.


## Phase 02 final acceptance — 2026-11-06

**ACCEPTED.** Owner-reported physical-device testing of the Note Tags + Folder Colors repair passed. Repair source `fa8f4ad469786a6a7199360a3d6813d22fac75e6`; Flutter CI `42177776797` passed 85/85 tests; universal and ARM64 Debug APK runs `42177872597` and `42177872567` succeeded. The automated integration-test source's execution is not independently evidenced and is not claimed. **Phase 03 is NOT STARTED / NOT AUTHORIZED.**


## Phase 03 latest execution reconciliation — 2026-11-06

The owner authorized Phase 03 through submission of the final implementation prompt. Implementation is present on PR [#2](https://github.com/squiraldot/Yamintto-Notes-App/pull/2), branch `phase-03/markdown-autosave`, source SHA `fc8912781b4ee38efd22be1dcea24f324674cd40`. Flutter CI run `42200165499` passed formatting, analyzer and 113/113 tests. Owner physical-device testing, PR review/merge and final owner acceptance remain pending. Phase 04–09 remain unauthorized.
