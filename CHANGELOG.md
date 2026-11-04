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
