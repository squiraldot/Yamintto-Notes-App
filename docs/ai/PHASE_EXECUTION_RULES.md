# Phase execution rules

## Authorization
Roadmap is an ordered plan, not blanket permission. Phase 01 is present and Phase 02 is accepted. The owner explicitly authorized Phase 03 by submitting the complete final implementation prompt on 2026-11-06. Phase 03 is implemented on branch `phase-03/markdown-autosave`, PR #2, implementation source SHA `3ab1a24bdb9ee389a1fa0214f1b03d16da823202`; exact-PR-head CI run `42334404037` passed formatting, analyzer and 120/120 tests on PR head `3ab1a24bdb9ee389a1fa0214f1b03d16da823202`. PR review/merge and owner physical-device acceptance remain pending. Phase 04–09 require separate authorization.

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
- Phase 03 Android physical-device verification is currently pending; do not infer it from the 120 passing host tests.


## Current Phase 02 repair gate — 2026-11-06

Phase 02 implementation is complete on source SHA `fa8f4ad469786a6a7199360a3d6813d22fac75e6`. Flutter CI run `42177776797` succeeded with 85/85 tests. The two Debug APK workflows were triggered for the exact same SHA; their conclusions/artifacts must be read from Actions before claims. Owner confirmed successful physical-device testing of tags and folder colors. Phase 02 is **ACCEPTED**. The separate automated integration-test source's execution is not independently evidenced and is not claimed. Historical gate statement superseded: Phase 03 was explicitly authorized by the owner on 2026-11-06 and is implemented on PR #2.


## Phase 03 current gate — 2026-11-06

Owner authorization was granted by submission of `docs/development/PHASE_03_IMPLEMENTATION_PROMPT.md`. Implementation is on PR #2, branch `phase-03/markdown-autosave`, implementation source SHA `3ab1a24bdb9ee389a1fa0214f1b03d16da823202`; latest PR head `3ab1a24bdb9ee389a1fa0214f1b03d16da823202`. Exact-PR-head Flutter CI run `42334404037` passed formatting, analyzer and 120/120 tests. The PR is not merged; owner physical-device acceptance is pending. The original Phase 03 prompt prohibited workflow edits. During this execution, separate commits appeared on the PR branch modifying the three protected workflow files (`a778670ee9104490bd8f6cc7271720c98c3c3888`, `12ae889fc51ee1120ea2956cde24a0c39c00fc22`, `3ab1a24bdb9ee389a1fa0214f1b03d16da823202`). I did not author, alter or revert those workflow commits; they require owner review before merge. The two existing APK workflows were invoked as reusable workflows after successful Flutter CI validation and uploaded universal artifact `13559062230` and ARM64 artifact `13558519592`, both for source SHA `3ab1a24bdb9ee389a1fa0214f1b03d16da823202` under parent run `42334404037`. Do not start Phase 04.
