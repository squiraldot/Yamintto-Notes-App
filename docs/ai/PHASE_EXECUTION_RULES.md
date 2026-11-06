# Phase execution rules

## Authorization
Roadmap is an ordered plan, not permission. Phase 01 source implementation is present. Phase 02 implementation was explicitly authorized by the owner on 2026-11-05. Source implementation and automated validation are complete on code revision `745b8f589afceb783a9b39bafcd03c123e50c395` (Flutter CI run `42097059083`, 69/69 tests); universal and ARM64 Debug APK artifacts uploaded on runs `42097260846` and `42097260894`. The final documentation-only revision must also be verified on its exact SHA by all three protected workflows. owner-reported Android physical-device testing of the completed tags/colors repair passed; Phase 02 is ACCEPTED. Phase 03–09 remain subject to separate explicit authorization.

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


## Current Phase 02 repair gate — 2026-11-06

Phase 02 implementation is complete on source SHA `fa8f4ad469786a6a7199360a3d6813d22fac75e6`. Flutter CI run `42177776797` succeeded with 85/85 tests. The two Debug APK workflows were triggered for the exact same SHA; their conclusions/artifacts must be read from Actions before claims. Owner confirmed successful physical-device testing of tags and folder colors. Phase 02 is **ACCEPTED**. The separate automated integration-test source's execution is not independently evidenced and is not claimed. Phase 03 requires separate explicit authorization and must not start.
