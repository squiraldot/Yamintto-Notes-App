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
- Flutter CI run #66 passed repository-wide Dart formatting, flutter analyze --fatal-infos and all 15 Flutter tests. Integration tests were skipped because no integration test source exists.
- Debug APK workflow run #63 built and uploaded the Debug APK successfully. Physical Android/iOS launch verification remains pending.

## Documentation audit — 2026-11-04
- Expanded AI agent instructions, phase execution gates, requirements IDs, feature ownership and all nine phase acceptance/test gates.
- Clarified Phase 05 unencrypted attachment lifecycle and Phase 06 encryption migration.
- Defined pre-encryption Phase 04 search and Phase 06 removal of persistent plaintext indexes.
- Assigned settings, theme/font preferences, UI/UX, accessibility, performance and full regression to Phase 09.
- Expanded architecture, proposed DB schema/migrations, security lifecycle and testing matrices.
- Recorded baseline CI/Debug APK evidence; iOS and legacy ZIP compatibility remain unverified.
