# Nine-phase development roadmap

The phase order and scope below are fixed. No phase starts without explicit authorization. This documentation task does not start or complete Phase 01.

## Phase 01 — Foundation
- **Scope / features:** Flutter project setup; application identity and design system; navigation and splash.
- **Dependencies:** Flutter/Dart toolchain and repository baseline; no product-feature dependency.
- **Prerequisites:** Explicit authorization to start Phase 01; confirm package identity and platform build prerequisites.
- **Acceptance criteria:** App launches; Android/iOS identity is correct; approved design tokens exist; navigation and splash states work.
- **Unit tests:** Configuration and theme-token tests.
- **Widget tests:** Splash, theme modes, navigation, loading/error states.
- **Integration tests:** Cold launch, route/back navigation, Android debug device smoke; iOS macOS/Xcode build and device smoke (currently pending).
- **Documentation requirements:** System architecture, project structure, routing, design system, platform support, ADRs.
- **Status:** **Not started/accepted by this documentation task; existing shell is partial scaffolding.**
- **Completion checklist:** [ ] Scope delivered [ ] Acceptance met [ ] Unit tests pass [ ] Widget tests pass [ ] Integration/platform tests pass or documented blocker [ ] Docs updated [ ] Diff reviewed [ ] Commit SHA reported

## Phase 02 — Core Management
- **Scope / features:** Local database; folder management; notes CRUD.
- **Dependencies:** Phase 01 accepted; Drift/SQLite selected.
- **Prerequisites:** Approve schema, IDs, folder nesting/deletion policy, transaction and retention behavior.
- **Acceptance criteria:** Drift schema/migrations exist; CRUD survives restart; hierarchy and referential integrity hold; empty/error states work.
- **Unit tests:** Schema, repository, validation, hierarchy, transaction tests.
- **Widget tests:** Folder navigation, create/rename/move/delete, note list/detail CRUD.
- **Integration tests:** Fresh DB, CRUD/restart, migration and failure rollback.
- **Documentation requirements:** Database schema, migrations, retention, feature catalog, testing docs.
- **Status:** **Planned.**
- **Completion checklist:** [ ] Scope delivered [ ] Acceptance met [ ] Unit tests pass [ ] Widget tests pass [ ] Integration/platform tests pass or documented blocker [ ] Docs updated [ ] Diff reviewed [ ] Commit SHA reported

## Phase 03 — Editor
- **Scope / features:** Markdown editor; Markdown viewer; autosave.
- **Dependencies:** Phase 02 notes repository and persistence.
- **Prerequisites:** Approve Markdown dialect, supported syntax, editor UX and autosave policy.
- **Acceptance criteria:** Markdown source round-trips; viewer renders documented syntax; autosave prevents stale writes and persists lifecycle transitions.
- **Unit tests:** Parser/serializer and save ordering/race tests.
- **Widget tests:** Editor, preview, save status, validation and error states.
- **Integration tests:** Rapid edits, app background/foreground, forced restart and persisted source.
- **Documentation requirements:** Markdown/editor architecture, feature catalog, testing docs.
- **Status:** **Planned.**
- **Completion checklist:** [ ] Scope delivered [ ] Acceptance met [ ] Unit tests pass [ ] Widget tests pass [ ] Integration/platform tests pass or documented blocker [ ] Docs updated [ ] Diff reviewed [ ] Commit SHA reported

## Phase 04 — Organization
- **Scope / features:** Search; pinned notes; trash and restore.
- **Dependencies:** Phase 02 data layer and Phase 03 note/editor behavior.
- **Prerequisites:** Approve search scope/ranking, pinned ordering, trash retention and folder deletion semantics.
- **Acceptance criteria:** Offline search returns correct results; pin ordering stable; restore preserves relationships; permanent deletion is explicit.
- **Unit tests:** Search matching/index, sorting, soft-delete/restore tests.
- **Widget tests:** Search/filter, pin, trash, restore and confirmation flows.
- **Integration tests:** Index updates, restore, permanent delete, restart.
- **Documentation requirements:** Feature catalog, database indexes, retention, testing docs.
- **Status:** **Planned.**
- **Completion checklist:** [ ] Scope delivered [ ] Acceptance met [ ] Unit tests pass [ ] Widget tests pass [ ] Integration/platform tests pass or documented blocker [ ] Docs updated [ ] Diff reviewed [ ] Commit SHA reported

## Phase 05 — Productivity
- **Scope / features:** Note history; attachments; statistics.
- **Dependencies:** Notes CRUD, editor revisions and organization data.
- **Prerequisites:** Approve revision/attachment limits, retention, supported file types and metric definitions.
- **Acceptance criteria:** History restore is safe; attachment lifecycle is reliable; statistics match source records.
- **Unit tests:** Revision ordering, aggregation/time boundaries, file validation tests.
- **Widget tests:** History, attachment UI, statistics and empty/error states.
- **Integration tests:** Revision restore, file round-trip, deletion cleanup and representative datasets.
- **Documentation requirements:** Database, attachment security, product metrics, test strategy.
- **Status:** **Planned.**
- **Completion checklist:** [ ] Scope delivered [ ] Acceptance met [ ] Unit tests pass [ ] Widget tests pass [ ] Integration/platform tests pass or documented blocker [ ] Docs updated [ ] Diff reviewed [ ] Commit SHA reported

## Phase 06 — Encryption
- **Scope / features:** AES-256-GCM encryption; password recovery; recovery key.
- **Dependencies:** Phase 05 data/attachment model; approved crypto and key-management design.
- **Prerequisites:** Independent security review of packages, protocol, KDF parameters, nonce strategy, key wrapping and test vectors.
- **Acceptance criteria:** Encrypted persistence; unique nonce; authenticated tamper rejection; independent password/recovery-key recovery; honest catastrophic-loss behavior.
- **Unit tests:** Known-answer vectors, KDF/wrapping, tamper, nonce and rotation tests.
- **Widget tests:** Encryption setup, password recovery, recovery-key reveal/confirmation.
- **Integration tests:** At-rest inspection, clean-install recovery via each route, interrupted rotation and backup-key metadata tests.
- **Documentation requirements:** Encryption, key management, recovery, threat model, ADRs and security tests.
- **Status:** **Planned.**
- **Completion checklist:** [ ] Scope delivered [ ] Acceptance met [ ] Unit tests pass [ ] Widget tests pass [ ] Integration/platform tests pass or documented blocker [ ] Docs updated [ ] Diff reviewed [ ] Commit SHA reported

## Phase 07 — Authentication
- **Scope / features:** App biometric lock; vault biometric lock; security settings.
- **Dependencies:** Phase 06 key hierarchy and encrypted vault.
- **Prerequisites:** Validate Android Keystore/iOS Keychain access controls, biometric APIs, invalidation and fallback semantics.
- **Acceptance criteria:** App and vault locks are separate; fallback, invalidation, lockout and recovery are safe on both OSes.
- **Unit tests:** Access policy and state transition tests.
- **Widget tests:** Lock prompts, settings, unavailable/cancel/fallback states.
- **Integration tests:** Real-device biometric success, lockout, enrollment change and key invalidation on Android/iOS.
- **Documentation requirements:** Platform/security/design docs and platform test matrix.
- **Status:** **Planned.**
- **Completion checklist:** [ ] Scope delivered [ ] Acceptance met [ ] Unit tests pass [ ] Widget tests pass [ ] Integration/platform tests pass or documented blocker [ ] Docs updated [ ] Diff reviewed [ ] Commit SHA reported

## Phase 08 — Backup System
- **Scope / features:** Legacy ZIP import; new backup format; backup restore.
- **Dependencies:** Phase 06 encryption/key recovery; Phase 07 authentication; Phase 05 attachments; verified legacy format.
- **Prerequisites:** Inspect YRNotes source and golden ZIP fixtures without modifying YRNotes; approve new backup format, restore policy and key portability.
- **Acceptance criteria:** Encrypted backup round-trip; safe transactional restore; verified legacy variants import with explicit result/loss report.
- **Unit tests:** Archive parser, manifest, integrity, compatibility and rollback tests.
- **Widget tests:** Import/restore preview, progress, confirmation and errors.
- **Integration tests:** Golden legacy fixtures, corrupt/truncated archive, clean-device restore and cross-platform round-trip.
- **Documentation requirements:** Backup security, legacy compatibility matrix, versioning, feature catalog and security tests.
- **Status:** **Planned.**
- **Completion checklist:** [ ] Scope delivered [ ] Acceptance met [ ] Unit tests pass [ ] Widget tests pass [ ] Integration/platform tests pass or documented blocker [ ] Docs updated [ ] Diff reviewed [ ] Commit SHA reported

## Phase 09 — Final Polish
- **Scope / features:** UI/UX polish; performance and accessibility; full regression testing.
- **Dependencies:** Phases 01–08 accepted; all critical defects resolved.
- **Prerequisites:** All feature acceptance criteria closed; production readiness evidence available for review.
- **Acceptance criteria:** Accessibility/performance targets met; complete regression and platform matrix passes; readiness sign-off recorded.
- **Unit tests:** Full unit regression.
- **Widget tests:** Full UI/theme/responsive/accessibility regression.
- **Integration tests:** Full Android/iOS device, security, migration, backup and performance regression.
- **Documentation requirements:** Design, testing, platform, production readiness, changelog and release docs.
- **Status:** **Planned.**
- **Completion checklist:** [ ] Scope delivered [ ] Acceptance met [ ] Unit tests pass [ ] Widget tests pass [ ] Integration/platform tests pass or documented blocker [ ] Docs updated [ ] Diff reviewed [ ] Commit SHA reported

## Global phase gates
One phase at a time; 2–3 major features per phase; no unrelated work; no scope expansion without approval; no skipped phases; no unverified completion; no breaking changes without documented migration; no unnecessary dependencies; no premature future-phase implementation. See [AI phase execution rules](../ai/PHASE_EXECUTION_RULES.md).