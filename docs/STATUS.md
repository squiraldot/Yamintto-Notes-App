# Documentation and implementation status

Snapshot: 2026-11-04; branch main; implementation started after explicit user approval.

## Phase 01 — Foundation

Status: **In progress; acceptance not yet verified.**

Implemented in source:
- Existing Flutter package identity and beta version retained: yamintto, 0.1.0-beta.1+1.
- Android application ID/namespace and iOS bundle identifier remain com.merrmist.yamintto.
- Existing bootstrap and root ProviderScope retained.
- Centralized provisional semantic color, typography, spacing and radius tokens added.
- Material 3 light, dark and true-black AMOLED themes added.
- Reusable button, card, text-field, dialog and modal-sheet primitives added.
- GoRouter now starts at a branded splash route, then navigates to the foundation placeholder.
- Unknown-route recovery and in-memory theme preview (system/light/dark/AMOLED) added.
- Theme selection is deliberately not persisted; persistence belongs to Phase 09.
- Configuration, theme, splash/navigation and unknown-route tests added.

Configured / retained:
- Flutter 3.47.9 CI baseline; Dart >=3.13.0 and Flutter >=3.38.4 declared.
- Android and iOS host projects and identity metadata.
- Exactly two workflows: .github/workflows/flutter-ci.yml and .github/workflows/yamintto-debug-apk.yml.

Not in Phase 01 / not implemented:
- Notes, folders, editor, Markdown, search, database schema/DAOs, authentication, encryption, biometrics, attachments, history, backup, settings persistence and font-size preferences.
- Theme preference persistence remains Phase 09.
- No new workflow or release build/signing setup is authorized.

## Verification evidence

The current Phase 01 code has been written to the repository, but no local Flutter SDK execution or successful post-change GitHub Actions result has yet been verified in this report. Do not treat the phase as complete until CI, Debug APK and applicable platform checks are inspected.

The last documented baseline evidence (before Phase 01 changes) was Flutter CI run #21 (41819675660) and Debug APK run #21 (41819761349) for baseline commit 0681b479. Those results do not validate the Phase 01 changes. The CI integration-test step skips when no *_test.dart exists; a skip is not a pass.

## Platform state and known limitations

Android host: namespace/application ID com.merrmist.yamintto; AGP 8.11.1; Kotlin 2.2.20; Gradle 8.14.3; Java 17. Flutter supplies compile/min/target SDK defaults. iOS host: bundle ID com.merrmist.yamintto; iOS 13.0 target. No macOS/Xcode build has been verified; iOS native build validation remains pending.

The approved tokens are provisional app-shell defaults only. Final product brand palette, full screen design and Phase 09 preferences are not approved or implemented. Native OS launch-screen visuals and physical-device cold-launch behavior require platform verification.

Security algorithms and recovery/biometric decisions remain requirements only. Phase 05 attachments are unencrypted temporary beta data; Phase 06 migration is mandatory before production. Phase 04 search is pre-encryption only; Phase 06 removes persistent plaintext indexes and uses transient unlocked memory search.

Production readiness is not achieved. Beta policy remains Debug APK only.

## Phase 01 acceptance checklist

- [x] Explicit Phase 01 authorization and provisional app-shell token approval.
- [x] Preserve existing Flutter bootstrap, package identity and host project configuration.
- [x] Implement centralized base tokens and Material 3 light/dark/AMOLED themes.
- [x] Implement reusable app-shell components.
- [x] Implement splash, initial route, foundation route and unknown-route handling.
- [x] Add configuration, theme, splash/navigation and route tests.
- [ ] Run dart format --output=none --set-exit-if-changed .
- [ ] Run flutter analyze --fatal-infos.
- [ ] Run flutter test.
- [ ] Verify Flutter CI on the implementation commit.
- [ ] Verify Debug APK workflow and artifact.
- [ ] Install/cold-launch on Android device.
- [ ] iOS macOS/Xcode build or record environment blocker.
- [ ] Update final implementation evidence, review diff and record commit SHA.
