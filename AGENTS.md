# Yamintto AI agent instructions

Mandatory entry point. Read before any repository change.

## Identity and verified baseline
Repository squiraldot/Yamintto-Notes-App; app Yamintto; Flutter package yamintto; Android ID and iOS bundle ID com.merrmist.yamintto; version 0.1.0-beta.1+1; first production target 1.0.0. CI pins Flutter 3.47.9; pubspec requires Dart >=3.13.0 and Flutter >=3.38.4. Only Flutter 3.47.9 is verified; do not claim all lower pubspec-allowed Flutter versions are compatible.

Current source: Flutter bootstrap and root Riverpod ProviderScope; YaminttoApp; centralized provisional design tokens and Material 3 light/dark/AMOLED themes; reusable app-shell components; GoRouter splash, root folder browser, nested folder routes, plain-text note create/edit routes and appearance preview; lazy app-scoped Drift/SQLite database provider; schema v2 with folders, notes, tags and note_tags; folders include nullable color_argb; Unicode 17.0 canonicalizer/data; folder and note repositories; folder/notes presentation providers and screens; folder CRUD/move/soft-delete UI; note CRUD/move/soft-delete UI; plain-text title/body editor with explicit save and unsaved-change guard; unit/repository and new widget test source; physical-device data smoke-test source. Phase 02 implementation, including the Note Tags + Folder Colors repair, is complete on repair source SHA `fa8f4ad469786a6a7199360a3d6813d22fac75e6`. Flutter CI run `42177776797` passed on Flutter 3.47.9 with 85/85 tests. Universal and ARM64 Debug APK runs `42177872597` and `42177872567` both succeeded for that exact source SHA. Later documentation-only commits do not change application source. owner-reported Android physical-device smoke testing passed; Phase 02 final acceptance is recorded. Drift warnings were traced to tests opening file-backed database instances while an in-memory fixture remained open; the fixture is now closed before file-backed reopen tests, and the latest source-revision CI log contains no Drift multiple-database warnings. Drift debug warnings were traced to database tests opening separate file-backed instances while the per-test in-memory fixture remained open; those tests now close the fixture before opening the file DB. No production duplicate app database is indicated by that stack trace. Phase 01 source implementation is present. Owner reports successful Phase 01 Android real-device testing; detailed evidence is not attached. iOS native build/device verification remains Not Verified — Environment Unavailable and is non-blocking for Android-focused phase progression. Phase 02 repair implementation and owner physical-device acceptance are complete; Phase 02 is ACCEPTED. Phase 03 was explicitly authorized by the owner on 2026-11-06 and is implemented on PR #2 (`phase-03/markdown-autosave`); follow-up stale-write protection and documentation reconciliation are in progress. Owner physical-device acceptance, review and merge remain pending. Phases 04–09 require separate authorization.

## Mandatory start sequence
1. Read docs/README.md, docs/STATUS.md, docs/ai/AI_DEVELOPMENT_GUIDE.md, docs/ai/PHASE_EXECUTION_RULES.md and docs/development/PHASE_ROADMAP.md.
2. Confirm explicit user authorization for phase and scope. Roadmap position is not authorization; if absent, do not modify app code.
3. Read the phase's Feature Catalog, product requirements, architecture, database, security, design and testing docs.
4. Inspect current branch/head, relevant complete tree, actual source/config/tests, pubspec/lockfile, Android/iOS, all three workflows, recent Actions results and diff.
5. Plan exact files, exclusions, acceptance criteria, tests, migration/data-loss risks and docs updates before implementation.

## Truth and architecture
Actual source/config/tests are the truth. Status labels: Implemented (source + evidence), Configured (scaffold/dependency only), In progress, Planned, Not implemented, Requires verification. Never infer implementation from folders, dependencies, ADRs or CI that skipped a suite.
Target: feature-first lib/features/<feature>/{presentation,domain,data}/; shared services in lib/core/; composition/providers/routing/config in lib/app/. Presentation calls Riverpod controllers; domain owns rules/use cases/repository contracts; data owns Drift DAOs, repository implementations, file storage and native adapters. Features do not import another feature's private data layer. Current source is not this full architecture.

## Scope and restrictions
One phase at a time; max 2–3 major features. No unrelated work, scope expansion, skipped phases, premature future work, silent architecture changes or breaking data changes without approved migration. Preserve behavior and add regression tests. Never modify separate YRNotes.
Docs-only tasks may change Markdown docs/indexes/status/ADRs only; never app source/tests, dependencies, pubspec/lockfile, Android or iOS.
Exactly three protected workflows are required:
- .github/workflows/flutter-ci.yml — host-only validation.
- .github/workflows/yamintto-debug-apk.yml — universal Android Debug APK artifact.
- .github/workflows/yamintto-arm64-debug-apk.yml — ARM64-only Android Debug APK artifact.
The two APK artifact workflows automatically run after successful Flutter CI for main/dev and build the exact CI-tested commit. Do not delete, rename, disable, merge, replace or remove either APK workflow from documentation without explicit owner authorization. Do not add further workflows without explicit owner authorization. The ARM64 workflow must remain a minimal ARM64-only debug build; do not add emulator, KVM, simulator, release, signing or publishing steps. Beta is Debug APK only: no release APK/AAB, release signing or production publishing. Workflow changes require explicit owner authorization; docs-only tasks do not edit workflows.

## Security boundaries
Requirements, not implemented protocol: AES-256-GCM; unique nonce per encryption; random 256-bit master key; Argon2id password KDF; Android Keystore/iOS Keychain; independent password and recovery-key recovery; separate app and vault biometric protection. Do not invent nonce/AAD/KDF/wrapping/native flags. Validate current authoritative package/platform documentation and independent security review before implementation. Never log note content, secrets, keys or attachment bytes. Phase 05 attachments are locally stored but unencrypted until Phase 06; this temporary beta state is not production-ready. If both recovery paths and every valid key copy are lost, recovery cannot be promised.

## Search privacy lifecycle
Phase 04 search targets the pre-encryption local model. Phase 06 must remove every persistent plaintext content index/cache/snippet/temp copy. While unlocked, search may use a transient in-memory index of decrypted records; clear it on lock. Content search is unavailable while locked. Do not invent encrypted-search cryptography.

## Verification and report
Use Flutter 3.47.9 commands: flutter pub get --enforce-lockfile, dart format --output=none --set-exit-if-changed ., flutter analyze --fatal-infos, flutter test. Integration tests are retained in integration_test/ and run by the owner on real physical devices only; no emulator, simulator, KVM or virtual-device CI is permitted. Record owner-reported results separately from automated CI. iOS implementation/configuration must continue phase-by-phase where applicable; iOS native build/device verification is labelled Not Verified — Environment Unavailable and must not block Android-focused phase progression. A skipped suite is not passed.
Before completion inspect diff/links, verify forbidden paths unchanged, update docs/status, and report phase authorization, scope, files, branch, SHA, exact checks/results, skipped tests, Android/iOS evidence, workflow count and unresolved risks.

## Mandatory physical-device testing policy — do not override
- Never add, configure, boot, install, or run tests on an Android emulator or iOS simulator in GitHub Actions or another CI workflow.
- Never reintroduce emulator-runner actions, KVM/virtualization setup, emulator images, virtual-device boot steps, or simulator-based CI tests.
- AI agents must not independently create or use an emulator/simulator as a substitute for testing. The project owner will perform integration and end-to-end testing on real physical devices.
- Keep automated Flutter CI limited to host-runnable checks: locked dependency resolution, Dart formatting, Flutter analysis, and flutter test (unit/widget tests). APK artifact workflows only compile/upload their respective debug APKs; they do not run device tests.
- Preserve integration_test/ tests where relevant. Run them only on an owner-provided physical device after coordination: flutter devices, then flutter test integration_test -d <physical-device-id>. Never claim these tests passed without actual device execution evidence.
- If a future requirement conflicts with this policy, stop and ask the owner; do not silently change it.


## Current Phase 02 repair status — 2026-11-06

The current main source includes schema v2, reusable note tags, note-tag junction assignments, persistent folder ARGB colors, tag management/assignment UI, folder color selection/display, migration tests, repository tests, widget tests and updated physical-device integration source. Schema v1 is immutable. Current repair source SHA: `fa8f4ad469786a6a7199360a3d6813d22fac75e6`; Flutter CI run `42177776797` passed on Flutter 3.47.9 with 85/85 tests. The universal and ARM64 Debug APK workflows were triggered for that same SHA; verify their exact run conclusions and artifact metadata before claiming success.

**Phase status: ACCEPTED — 2026-11-06.** The owner confirmed successful physical-device testing of the repaired tags and folder-color features. Flutter CI passed 85/85 tests and both exact-source-SHA Debug APK workflows succeeded. The automated integration-test source's execution is not independently evidenced and is not claimed. Phase 03 implementation is present on PR #2; owner physical-device acceptance, review and merge remain pending.


## Final Phase 02 acceptance snapshot — 2026-11-06

Phase 02 is **ACCEPTED**. Repair source SHA `fa8f4ad469786a6a7199360a3d6813d22fac75e6`; Flutter CI `42177776797` passed 85/85 tests; universal and ARM64 Debug APK runs `42177872597` and `42177872567` succeeded; owner-reported physical-device testing passed. Automated integration-test source execution is not claimed. Final documentation acceptance commit: `894e35fde1522f7a7f29947323ccf2cb46107478`. Phase 03 was explicitly authorized on 2026-11-06 and is implemented on PR #2; follow-up exact-SHA Flutter CI passed 119/119 tests. Owner physical-device acceptance, PR review and merge remain pending.
