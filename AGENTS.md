# Yamintto AI agent instructions

Mandatory entry point. Read before any repository change.

## Identity and verified baseline
Repository `squiraldot/Yamintto-Notes-App`; app Yamintto; Flutter package `yamintto`; Android ID and iOS bundle ID `com.merrmist.yamintto`; version `0.1.0-beta.1+1`; first production target `1.0.0`. CI pins Flutter 3.47.9; pubspec requires Dart >=3.13.0 and Flutter >=3.38.4. Only Flutter 3.47.9 is verified; do not claim all lower pubspec-allowed Flutter versions are compatible.

Actual source: main/bootstrap, root Riverpod ProviderScope, YaminttoApp, Material 3 system light/dark themes, one GoRouter '/' route/foundation screen, one widget test and native host scaffolds. Riverpod/GoRouter/Drift/SQLite packages are configured; no Drift DB/schema/DAO, feature repository/provider, notes workflow, encryption, biometrics, attachment or backup implementation exists. **No phase is currently authorized. Phase 01 is next planned, not started/accepted.**

## Mandatory start sequence
1. Read [docs index](docs/README.md), [status](docs/STATUS.md), [AI guide](docs/ai/AI_DEVELOPMENT_GUIDE.md), [phase rules](docs/ai/PHASE_EXECUTION_RULES.md) and [roadmap](docs/development/PHASE_ROADMAP.md).
2. Confirm explicit user authorization for phase and scope. Roadmap position is not authorization; if absent, do not modify app code.
3. Read the phase's Feature Catalog, product requirements, architecture, database, security, design and testing docs.
4. Inspect current branch/head, relevant complete tree, actual source/config/tests, pubspec/lockfile, Android/iOS, both workflows, recent Actions results and diff.
5. Plan exact files, exclusions, acceptance criteria, tests, migration/data-loss risks and docs updates before implementation.

## Truth and architecture
Actual source/config/tests are the truth. Status labels: Implemented (source + evidence), Configured (scaffold/dependency only), In progress, Planned, Not implemented, Requires verification. Never infer implementation from folders, dependencies, ADRs or CI that skipped a suite.
Target: feature-first `lib/features/<feature>/{presentation,domain,data}/`; shared services in `lib/core/`; composition/providers/routing/config in `lib/app/`. Presentation calls Riverpod controllers; domain owns rules/use cases/repository contracts; data owns Drift DAOs, repository implementations, file storage and native adapters. Features do not import another feature's private data layer. Current source is not this full architecture.

## Scope and restrictions
One phase at a time; max 2–3 major features. No unrelated work, scope expansion, skipped phases, premature future work, silent architecture changes or breaking data changes without approved migration. Preserve behavior and add regression tests. Never modify separate YRNotes.
Docs-only tasks may change Markdown docs/indexes/status/ADRs only; never app source/tests, dependencies, pubspec/lockfile, Android, iOS or workflows.
Exactly two workflows: `.github/workflows/flutter-ci.yml` and `.github/workflows/yamintto-debug-apk.yml`. Never add a third; do not modify either in docs-only work. Beta is Debug APK only: no release APK/AAB, release signing or production publishing.

## Security boundaries
Requirements, not implemented protocol: AES-256-GCM; unique nonce per encryption; random 256-bit master key; Argon2id password KDF; Android Keystore/iOS Keychain; independent password and recovery-key recovery; separate app and vault biometric protection. Do not invent nonce/AAD/KDF/wrapping/native flags. Validate current authoritative package/platform documentation and independent security review before implementation. Never log note content, secrets, keys or attachment bytes. Phase 05 attachments are locally stored but unencrypted until Phase 06; this temporary beta state is not production-ready. If both recovery paths and every valid key copy are lost, recovery cannot be promised.

## Search privacy lifecycle
Phase 04 search targets the pre-encryption local model. Phase 06 must remove every persistent plaintext content index/cache/snippet/temp copy. While unlocked, search may use a transient in-memory index of decrypted records; clear it on lock. Content search is unavailable while locked. Do not invent encrypted-search cryptography.

## Verification and report
Use Flutter 3.47.9 commands: `flutter pub get --enforce-lockfile`, Dart format check, `flutter analyze --fatal-infos`, `flutter test`; add relevant unit/widget/integration/device tests. CI skips integration tests when no `*_test.dart` exists; skipped is not passed. Physical devices are required for biometric/secure-storage evidence. iOS native build remains pending macOS/Xcode.
Before completion inspect diff/links, verify forbidden paths unchanged, update docs/status, and report phase authorization, scope, files, branch, SHA, exact checks/results, skipped tests, platform evidence, workflow count and unresolved risks.
