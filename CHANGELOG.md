# Changelog

## 0.1.0-beta.1+1 — 2026-11-04
- Initial Flutter foundation, Android/iOS host scaffolding, root Riverpod scope, Material 3 system theme, one GoRouter route and foundation widget test.
- Flutter CI and Debug APK workflows configured.
- Product features, database, encryption, biometrics, attachments and backup are not implemented.

## Phase 01 foundation — 2026-11-04
- Retained existing Flutter bootstrap, package identity, Android/iOS identifiers and dependency set.
- Added provisional semantic color, typography, spacing, sizing and radius tokens.
- Added Material 3 light, dark and true-black AMOLED theme variants.
- Added reusable button, card, text-field, dialog and modal-sheet primitives.
- Added splash-to-foundation navigation and unknown-route recovery.
- Added an in-memory theme preview; persistence remains assigned to Phase 09.
- Added configuration, theme, splash/navigation, route and reusable-widget tests.
- Updated architecture, routing, design, platform, testing and implementation status documentation.
- Baseline Flutter CI run #66 passed repository-wide Dart formatting, flutter analyze --fatal-infos and all 15 Flutter tests.
- Baseline Debug APK workflow run #63 built and uploaded the Debug APK successfully. Physical Android/iOS launch verification remains pending.

## Phase 01 integration audit and CI repair — 2026-11-04
- Added an Android app-shell integration smoke test for splash -> foundation -> AMOLED preview.
- Configured the existing Flutter CI workflow to provision an Android API 35 emulator.
- CI run #68 exposed the exact root cause: the runner user lacked permissions for /dev/kvm, so the emulator timed out during boot.
- Applied the official Android Emulator Runner KVM udev permission setup before emulator startup; added /dev/kvm visibility check and increased boot timeout to 900 seconds.
- Latest Flutter CI run #69 passed formatting, analyzer, all 15 unit/widget tests and the KVM setup step; emulator integration is still running and must not be marked passed until the workflow completes.
- Debug APK workflow runs following failed CI attempts were skipped by design, not failed; the build workflow is gated on successful Flutter CI.
- The repository still has exactly two workflows. Physical Android device and iOS macOS/Xcode acceptance remain pending.


## Phase 01 acceptance and testing-policy reconciliation — 2026-11-05
- Removed the obsolete Android API 35 emulator execution instructions from the integration-test README; integration test source remains retained for owner-run physical-device execution.
- Confirmed the current CI policy is host-only: locked dependency resolution, formatting, analyzer and unit/widget tests. No Android emulator, iOS simulator, KVM or AI-created virtual-device testing is used in CI.
- Reconciled the current protected workflow policy to exactly three workflows under ADR-0012: Flutter CI, universal Debug APK and ARM64-only Debug APK. ADR-0009 remains historical and superseded.
- Recorded successful Flutter CI run 41981911424, universal Debug APK run 41982079883 and ARM64 Debug APK run 41982079971, all on commit 76ba10c04f0ec421f54e5d6252dd6745058611f9. Both APK artifacts uploaded successfully.
- Recorded Android device testing as owner-reported success; detailed evidence not attached. This is not represented as independent device-log verification.
- iOS native build/device verification remains Not Verified — Environment Unavailable; continue iOS implementation/configuration alongside applicable phases and do not block Android-focused phase progression.


## Phase 02 Note Tags + Folder Colors repair and final acceptance — 2026-11-06

- Added reusable global note tags, normalized tag identity, multiple persistent note-to-tag assignments, tag management and note assignment UI.
- Added nullable persisted folder ARGB colors, a validated ten-color palette, root/nested folder display, theme-aware fallback and color reset.
- Preserved schema v1 unchanged and added a transactional, forward-only schema v1 → v2 migration with fail-closed rollback behavior.
- Added migration, repository, unit and widget regression coverage. No dependency or pubspec/lockfile changes were required.
- Exact repair source SHA: `fa8f4ad469786a6a7199360a3d6813d22fac75e6`. Flutter CI run `42177776797` passed on Flutter 3.47.9: formatting, analyzer and **85/85 tests**.
- Universal Debug APK run `42177872597` and ARM64 Debug APK run `42177872567` both succeeded and uploaded artifacts for that same source SHA.
- Owner confirmed successful physical-device testing of the repaired application. Recorded as **owner-reported PASS**; no device model, OS version, screenshots, logs or exact test command are asserted.
- Documentation reconciled after owner acceptance. **Phase 02 — ACCEPTED. Phase 03 was subsequently authorized and implemented on PR #2; owner device acceptance and merge remain pending.**


## Phase 03 — Hybrid Markdown editor and autosave — 2026-11-06
- Added a documented hybrid Markdown dialect using the Dart team's `markdown` AST parser; modern Markdown and source-verified legacy YRNotes syntax are supported through an explicit safe allowlist.
- Added a native Flutter AST viewer. Raw HTML is not rendered; links are styled but inert, images remain alt-text placeholders, and arbitrary HTML/CSS/scripts/handlers are not executed.
- Added note content-format semantics: v1 remains literal plain text; new editor notes use v2 hybrid Markdown; editing a v1 body upgrades only that note; unknown future formats remain read-only and cannot be overwritten.
- Added serialized per-editor autosave with a 700 ms debounce, revision-aware writes, latest-snapshot persistence, explicit/navigation/lifecycle flush, dirty/error state and retry.
- Added repository and widget coverage for source preservation, parser limits, malicious input, version behavior, autosave races/failures, preview, navigation and lifecycle flush; added owner-run physical-device integration source for system-back flush, lifecycle backgrounding and database reopen.
- Fixed the initial CI formatting and analyzer blockers, the markdown AST element-constructor API mismatch, missing repository format-version handling, and rich-text test assumptions.
- Updated the previous Phase 02 discard-confirmation tests to assert Phase 03 autosave-before-navigation behavior.
- Implementation source SHA `4af7577caf8bfeed06772c25693e4a9bce8fe629`; exact PR-head SHA `8748150721f2a262716cc3786c76932e6b1f53e3` passed Flutter CI run `42333273779`: Dart formatting, `flutter analyze --fatal-infos`, and **120/120 unit/widget tests**.
- Implementation is on PR [#2](https://github.com/squiraldot/Yamintto-Notes-App/pull/2), not merged. Phase 03 owner physical-device acceptance remains pending; no APK artifact or iOS native build/device pass is claimed.


## Phase 03 integrity follow-up — 2026-11-07
- Restored optimistic `updated_at` revision checks at the existing note-repository boundary so a stale editor cannot overwrite a newer persisted note.
- Made successful note updates advance `updated_at` monotonically, including multiple writes within one clock millisecond.
- Added a confirmed Reload latest flow for stale-editor conflicts; the local draft remains intact until the owner explicitly chooses to reload.
- Fixed NUL-title validation to reject the actual NUL character at the domain boundary instead of relying on SQLite to reject it.
- Added regression coverage for stale-writer rejection, source preservation, editor conflict/reload behavior and domain-level NUL validation.
- Exact PR-head Flutter CI run `42333273779` passed on PR head `8748150721f2a262716cc3786c76932e6b1f53e3`: formatting, analyzer and 120/120 tests. Both APK workflow files include the Phase 03 branch filter on this PR branch; their default-branch definitions still exclude Phase 03, so artifacts remain blocked without a permitted default-branch update or merge.
