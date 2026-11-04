# AI development guide

For a new coding agent with no previous chat context.

## Begin with evidence
Read AGENTS.md, the docs index, status, phase rules and roadmap. Inspect branch/head, relevant complete tree, source/tests, pubspec/lockfile, Android/iOS, two workflows and recent Actions job steps. Read phase Feature Catalog entries and linked specs. Current code includes bootstrap + ProviderScope + YaminttoApp + theme tokens/themes + reusable app-shell components + GoRouter splash/foundation route + widget tests. Drift is a dependency, not a database. Phase 01 was explicitly authorized; its automated CI and Debug APK build/artifact pass. Physical Android launch and native iOS build remain unverified. Phases 02–09 are not authorized or started.

## Plan before editing
Record phase authorization, feature IDs, scope, exact expected paths, forbidden paths, acceptance criteria, data/schema impact, platform requirements, unit/widget/integration/device tests and docs/ADR changes. Stop and ask when product/security decisions are missing.

## Boundaries
Presentation renders UI and calls Riverpod controllers; no SQL, crypto or native APIs in widgets. Controllers coordinate use cases. Domain owns entities, validation, business rules and repository interfaces, independent of Flutter. Data owns Drift DAOs, repository implementations, serialization, local files and error translation. Native capabilities are behind narrow interfaces. Dependencies point inward; features do not import each other's private data implementation. Transactions protect multi-record operations. Do not silently decide folder deletion, Markdown dialect, search ranking, retention, attachment limits, backup format, crypto parameters or biometric fallback.

## Tests and docs
Test success, invalid input, empty/error states, concurrency, lifecycle, rollback and data-loss cases at the right layer. Device-only behavior is unverified until physical-device tests. Update requirements, feature status, architecture/DB/security/testing docs, phase checklist, ADR and changelog as appropriate. UI presence alone does not mean a feature is implemented.

## Git and report
Use only authorized branch. Never touch YRNotes. Keep exactly two workflows and Debug APK-only beta. Review diff and links. Report branch/SHA, files, exact commands/results, skipped/unavailable tests, Android/iOS evidence, unresolved decisions and risks. Never claim unrun validation.
