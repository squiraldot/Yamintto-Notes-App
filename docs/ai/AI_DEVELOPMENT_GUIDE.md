# AI development guide

For a new coding agent with no previous chat context.

## Begin with evidence
Read AGENTS.md, the docs index, status, phase rules and roadmap. Inspect branch/head, relevant complete tree, source/tests, pubspec/lockfile, Android/iOS, all three protected workflows and recent Actions job steps. Read phase Feature Catalog entries and linked specs. Current code includes bootstrap + ProviderScope + YaminttoApp + theme tokens/themes + reusable app-shell components + GoRouter splash/foundation route + unit/widget tests + an Android app-shell integration smoke test. Flutter CI is host-only and does not provision virtual devices. Integration tests are reserved for owner-run physical-device validation. Drift is a dependency, not a database. Phase 01 was explicitly authorized; baseline automated CI and Debug APK artifact pass. Owner reports successful real-device Android testing; detailed evidence is not attached. Latest Flutter CI and both Debug APK artifact workflows passed on audited SHA 76ba10c04f0ec421f54e5d6252dd6745058611f9 (run IDs 41981911424, 41982079883 and 41982079971). iOS native build/device verification is Not Verified — Environment Unavailable; continue iOS implementation/configuration alongside shared work and do not block Android-focused phase progression. Phases 02–09 require explicit authorization.

## Plan before editing
Record phase authorization, scope, exact expected paths, forbidden paths, acceptance criteria, data/schema impact, platform requirements, unit/widget/integration/device tests and docs/ADR changes. Stop and ask when product/security decisions are missing.

## Boundaries
Presentation renders UI and calls Riverpod controllers; no SQL, crypto or native APIs in widgets. Controllers coordinate use cases. Domain owns entities, validation, business rules and repository interfaces, independent of Flutter. Data owns Drift DAOs, repository implementations, serialization, local files and error translation. Native capabilities are behind narrow interfaces. Dependencies point inward; features do not import each other's private data implementation. Transactions protect multi-record operations. Do not silently decide folder deletion, Markdown dialect, search ranking, retention, attachment limits, backup format, crypto parameters or biometric fallback.

## Phase 02 database decision gate

Before any Phase 02 code is authorized, read [schema](../database/DATABASE_SCHEMA.md), [migration policy](../database/DATABASE_MIGRATIONS.md), [retention](../database/DATA_RETENTION.md), [decision register](../database/PHASE_02_DECISION_REGISTER.md) and ADR-0013. Drift + SQLite is accepted (ADR-0003), but dependency presence does not mean a database exists. Current lib/core/database contains guidance only.

The proposed schema v1 contains only folders and notes. Do not add revisions, attachments, tags, a separate trash table, encryption metadata or settings in Phase 02. UUID v4, UTC epoch milliseconds, nested folders, explicit ordering, RESTRICT FKs and soft-delete semantics remain recommendations until owner approval. Never turn recommendations into accepted decisions silently.

No Phase 02 implementation may begin until blocking decisions are approved and a separate implementation authorization is given. Trash/search/pinning are Phase 04; revisions/attachments Phase 05; encryption Phase 06; biometrics Phase 07; backup/import Phase 08; settings Phase 09. Phase 06 must account for SQLite pages, WAL/journals, FTS, temp files, caches, exports and backups. Do not claim SQLite or AES-GCM encryption exists.

## Tests and docs
Test success, invalid input, empty/error states, concurrency, lifecycle, rollback and data-loss cases at the right layer. Device-only behavior is unverified until physical-device tests. Distinguish owner-reported results from independently attached evidence and automated CI. Update requirements, feature status, architecture/DB/security/testing docs, phase checklist, ADR and changelog as appropriate. UI presence alone does not mean a feature is implemented.

## Git and report
Use only authorized branch. Never touch YRNotes. Preserve exactly the three protected workflows listed in AGENTS.md; do not delete, rename, disable, merge or replace any of them without explicit owner authorization. Keep beta Debug APK-only. Review diff and links. Report branch/SHA, exact checks/results, skipped/pending tests, Android/iOS evidence, unresolved decisions and risks. Never claim unrun validation.

## Mandatory device-testing boundary
The owner tests integration and end-to-end behavior on real physical Android/iOS devices. iOS native build/device verification is Not Verified — Environment Unavailable when macOS/Xcode is unavailable; continue iOS work in each applicable phase and do not make this a blocker for Android-focused progression. Do not add, configure, boot or run Android emulators or iOS simulators in CI. Do not add emulator-runner actions, KVM/virtualization setup, virtual-device boot steps, simulator CI or related dependencies. Do not independently create/use a virtual device as a substitute for owner testing. Keep Flutter CI host-only: dependency resolution, format, analyzer and unit/widget tests. The two APK artifact workflows only build/upload universal or ARM64-only Debug APKs; they do not perform device testing. Preserve integration_test source where useful; run it only on an owner-provided physical device after coordination (flutter devices, then flutter test integration_test -d <physical-device-id>). Never report device integration tests as passed without real execution evidence. Ask the owner before any proposed exception.
