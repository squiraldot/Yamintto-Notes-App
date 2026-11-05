# Yamintto AI agent instructions

Mandatory entry point. Read before any repository change.

## Identity and verified baseline
Repository squiraldot/Yamintto-Notes-App; app Yamintto; Flutter package yamintto; Android ID and iOS bundle ID com.merrmist.yamintto; version 0.1.0-beta.1+1; first production target 1.0.0. CI pins Flutter 3.47.9; pubspec requires Dart >=3.13.0 and Flutter >=3.38.4. Only Flutter 3.47.9 is verified; do not claim all lower pubspec-allowed Flutter versions are compatible.

Current source: main/bootstrap, root Riverpod ProviderScope, YaminttoApp, centralized provisional color/typography/spacing/sizing/radius tokens, Material 3 light/dark/AMOLED themes, reusable app-shell button/card/text-field/dialog/sheet components, GoRouter splash -> foundation placeholder, unknown-route recovery, configuration/theme/navigation/widget tests, and an Android app-shell integration smoke test. No Drift DB/schema/DAO, feature repository/provider, notes workflow, encryption, biometrics, attachment or backup implementation exists. Phase 01 source implementation is present. Latest host-only Flutter CI and both Debug APK artifact workflows succeeded on commit 76ba10c04f0ec421f54e5d6252dd6745058611f9 (run IDs 41981911424, 41982079883 and 41982079971). Owner reports successful real-device Android testing; detailed device evidence is not attached. iOS source/host configuration is retained, but native macOS/Xcode build and device verification are Not Verified — Environment Unavailable and are non-blocking for Android-focused phase progression. Continue iOS work alongside shared Flutter development. Phases 02–09 require explicit authorization.

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
