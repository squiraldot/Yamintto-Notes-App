# Phase execution rules

## Authorization
Roadmap is an ordered plan, not permission. User must explicitly authorize phase and scope. **Phase 01 source implementation is present.** Latest host-only Flutter CI and both Debug APK artifact workflows succeeded on audited SHA 76ba10c04f0ec421f54e5d6252dd6745058611f9 (run IDs 41981911424, 41982079883 and 41982079971); CI reports 15 unit/widget tests passed. Android real-device testing is owner-reported successful; detailed evidence is not attached. iOS native build/device verification is Not Verified — Environment Unavailable and is non-blocking for Android-focused phase progression. Continue iOS implementation/configuration alongside shared Flutter work. Phases 02–09 remain subject to explicit authorization.

## Rules
1. One phase at a time; maximum 2–3 major features.
2. No unrelated work, scope expansion, skipped phases or premature future-phase implementation without approval.
3. No completion claim without acceptance criteria, tests, documentation and evidence.
4. No breaking schema/data/backup/encryption change without approved, tested migration.
5. Avoid unnecessary dependencies; security dependencies need independent review.
6. Preserve behavior and add regression tests.
7. YRNotes remains untouched.
8. Exactly three protected workflows must remain: flutter-ci.yml, yamintto-debug-apk.yml and yamintto-arm64-debug-apk.yml. Do not delete, rename, disable, merge, replace or omit any from documentation without explicit owner authorization. Do not add more workflows without authorization. Docs-only tasks do not edit workflows.
9. Beta is Debug APK only; no release APK/AAB/signing/publishing.
10. Phase 05 attachment bytes are temporary unencrypted beta data; Phase 06 must encrypt/migrate before production-ready claims.

## Gate
Before: confirm explicit authorization, prerequisites, feature IDs, source state, scope and exclusions. During: stop for unresolved architecture/schema/security decisions. After: test every criterion, inspect migration/data-loss behavior, update docs/ADR/status, review diff/links, report SHA and evidence. Do not start next phase before acceptance.

## Physical-device testing rule
- Flutter CI is host-only: locked dependencies, formatting, analyzer, unit and widget tests.
- The two APK artifact workflows (within the three protected workflows) build universal and ARM64-only Debug APK artifacts after successful Flutter CI; they do not run tests on virtual or physical devices.
- Do not provision or run Android emulators or iOS simulators in CI. Do not add emulator-runner, KVM, virtualization or virtual-device boot steps.
- AI agents must not create/use virtual devices as a substitute for owner testing.
- Integration/E2E tests are owner-run on real physical devices only. Preserve integration_test source; owner can run flutter devices followed by flutter test integration_test -d <physical-device-id>.
- Record owner-reported physical-device results separately from automated CI; do not invent missing evidence. The current Android Phase 01 test is owner-reported successful, with detailed evidence not attached.
- iOS implementation/configuration continues in every applicable phase. When macOS/Xcode verification is unavailable, label iOS native build/device verification `Not Verified — Environment Unavailable`; this is not a blocker for Android-focused phase progression.
- If a required physical-device test has not been run, report that specific test as pending. Ask before any exception.
