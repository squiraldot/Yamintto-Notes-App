# AI development guide

For a new coding agent with no previous chat context.

## Begin with evidence
Read AGENTS.md, the docs index, status, phase rules and roadmap. Inspect branch/head, relevant complete tree, source/tests, pubspec/lockfile, Android/iOS, two workflows and recent Actions job steps. Read phase Feature Catalog entries and linked specs. Current code includes bootstrap + ProviderScope + YaminttoApp + theme tokens/themes + reusable app-shell components + GoRouter splash/foundation route + unit/widget tests + an Android app-shell integration smoke test. Flutter CI is host-only and does not provision virtual devices. Integration tests are reserved for owner-run physical-device validation. Drift is a dependency, not a database. Phase 01 was explicitly authorized; baseline automated CI and Debug APK artifact pass. Physical Android installation/back/relaunch and native iOS build remain unverified. Phases 02–09 are not authorized or started.

## Plan before editing
Record phase authorization, scope, exact expected paths, forbidden paths, acceptance criteria, data/schema impact, platform requirements, unit/widget/integration/device tests and docs/ADR changes. Stop and ask when product/security decisions are missing.

## Boundaries
Presentation renders UI and calls Riverpod controllers; no SQL, crypto or native APIs in widgets. Controllers coordinate use cases. Domain owns entities, validation, business rules and repository interfaces, independent of Flutter. Data owns Drift DAOs, repository implementations, serialization, local files and error translation. Native capabilities are behind narrow interfaces. Dependencies point inward; features do not import each other's private data implementation. Transactions protect multi-record operations. Do not silently decide folder deletion, Markdown dialect, search ranking, retention, attachment limits, backup format, crypto parameters or biometric fallback.

## Tests and docs
Test success, invalid input, empty/error states, concurrency, lifecycle, rollback and data-loss cases at the right layer. Device-only behavior is unverified until physical-device tests. Update requirements, feature status, architecture/DB/security/testing docs, phase checklist, ADR and changelog as appropriate. UI presence alone does not mean a feature is implemented.

## Git and report
Use only authorized branch. Never touch YRNotes. Keep exactly two workflows and Debug APK-only beta. Review diff and links. Report branch/SHA, exact checks/results, skipped/pending tests, Android/iOS evidence, unresolved decisions and risks. Never claim unrun validation.

## Mandatory device-testing boundary
The owner will test integration and end-to-end behavior on real physical Android/iOS devices. Do not add, configure, boot or run Android emulators or iOS simulators in CI. Do not add emulator-runner actions, KVM/virtualization setup, virtual-device boot steps, simulator CI or related dependencies. Do not independently create/use a virtual device as a substitute for owner testing. Keep CI host-only: dependency resolution, format, analyzer and unit/widget tests. Preserve integration_test source where useful; run it only on an owner-provided physical device after coordination (flutter devices, then flutter test integration_test -d <physical-device-id>). Never report device integration tests as passed without real execution evidence. Ask the owner before any proposed exception.
