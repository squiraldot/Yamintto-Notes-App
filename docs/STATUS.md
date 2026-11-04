# Documentation and implementation status

Snapshot: 2026-11-04; branch main; baseline commit before this audit: `0681b479f84fcfc5dd7efce14e83a364dbd7af3a`.

## Current implementation evidence
- Implemented: Flutter bootstrap; root ProviderScope; YaminttoApp; Material 3 seeded light/dark ThemeData with ThemeMode.system; one GoRouter '/' foundation route; FoundationScreen; one widget test.
- Configured: Flutter Android/iOS host projects; Riverpod, GoRouter, Drift, SQLite packages; two GitHub workflows.
- Not implemented: Drift database/schema/DAOs/migrations; feature repositories/controllers; folders/notes/Markdown/autosave/search/pin/trash/history/attachments/statistics/settings/preferences; encryption/key management/recovery/biometrics; backup/restore/legacy ZIP importer.
- Requires verification: iOS native build and physical iOS behavior. No macOS/Xcode build is evidenced.
- Legacy YRNotes ZIP format: source and sample fixtures not inspected; compatibility unknown.
- Current authorization: **no development phase authorized. Phase 01 is next planned, not started/accepted.**

## Latest GitHub Actions evidence
Latest runs inspected for baseline commit `0681b479...`:
- Flutter CI run #21, run ID `41819675660`: completed/success. Job steps: checkout, Flutter setup, locked dependency install, format, analyzer, Flutter tests all success. Conditional integration step completed but skipped its suite because no integration test source exists. This is not integration coverage.
- Yamintto Debug APK run #21, run ID `41819761349`: completed/success. Checked out exact CI-tested SHA, setup Flutter, installed locked deps, built Debug APK and uploaded artifact successfully.
- CI Flutter version: 3.47.9. pubspec Dart constraint >=3.13.0; Flutter constraint >=3.38.4 (not evidence all lower versions work).
- Exactly two workflows exist: `.github/workflows/flutter-ci.yml`, `.github/workflows/yamintto-debug-apk.yml`.

## Platform and security state
Android host: namespace/application ID `com.merrmist.yamintto`; AGP 8.11.1; Kotlin 2.2.20; Gradle 8.14.3; Java 17; Flutter SDK controls compile/min/target SDK. iOS: bundle ID `com.merrmist.yamintto`; iOS 13.0 target; Xcode Runner project/scheme. iOS build pending macOS/Xcode verification.
Security algorithms and recovery/biometric decisions are requirements only; no cryptographic implementation exists. Phase 05 attachments are unencrypted temporary beta data; Phase 06 migration is mandatory before production. Search Phase 04 index is pre-encryption only; Phase 06 removes persistent plaintext index and uses unlocked transient in-memory search.
Production readiness not achieved. Beta policy remains Debug APK only.

## Audit checklist
- [x] Required docs and ADR set present and inspected.
- [x] Source/config/Android/iOS/two workflows inspected.
- [x] Latest CI and Debug APK workflow jobs inspected.
- [x] Attachment Phase 05/06 ownership clarified.
- [x] Search plaintext index lifecycle clarified.
- [x] Phase 09 settings/theme/font-size ownership clarified.
- [x] Functional and non-functional requirements assigned IDs and phases.
- [x] Unit/widget/integration/security/platform matrices expanded.
- [ ] iOS macOS/Xcode build and physical-device tests.
- [ ] YRNotes source and real ZIP fixtures inspected.
- [ ] Security protocol/package/parameters independently reviewed.
- [ ] Product open decisions approved.
- [ ] Phase 01 explicitly authorized and separately started.
