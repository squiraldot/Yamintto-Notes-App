# Documentation and implementation status

Snapshot: 2026-11-04; branch main.

## Phase 01 — Foundation

Status: **Foundation implementation and baseline automated build gates passed; emulator-backed integration verification is pending, and physical-device/iOS acceptance remains open.**

Implemented:
- Existing Flutter package identity and beta version retained: yamintto, 0.1.0-beta.1+1.
- Android application ID/namespace and iOS bundle identifier remain com.merrmist.yamintto.
- Existing bootstrap and root ProviderScope retained.
- Centralized provisional semantic color, typography, spacing, sizing and radius tokens added.
- Material 3 light, dark and true-black AMOLED themes added.
- Reusable button, card, text-field, dialog and modal-sheet primitives added.
- GoRouter starts at a branded splash route, then navigates to the foundation placeholder.
- Unknown-route recovery and in-memory theme preview (system/light/dark/AMOLED) added.
- Theme selection is deliberately not persisted; persistence belongs to Phase 09.
- Configuration, theme, splash/navigation, unknown-route and reusable-widget tests added.
- Android app-shell integration smoke test added for splash -> foundation -> AMOLED preview.

Configured / retained:
- Flutter 3.47.9 CI baseline; Dart >=3.13.0 and Flutter >=3.38.4 declared.
- Android and iOS host projects and identity metadata retained.
- Exactly two workflows: .github/workflows/flutter-ci.yml and .github/workflows/yamintto-debug-apk.yml.
- Flutter CI format check covers the repository with dart format --output=none --set-exit-if-changed ..
- Flutter CI provisions an Android API 35 emulator and configures Linux KVM permissions before emulator startup.

## Verification evidence

**Baseline Flutter CI run #66**, run ID 41833435924, commit 3db552b243e64204139fa612dc87e4f465ac526d: **success**.
- Locked dependency installation, repository-wide Dart formatting, flutter analyze --fatal-infos and all 15 Flutter tests passed.
- Integration tests were not yet present in that historical run.

**Integration follow-up CI run #67**, run ID 41845194256, commit f5449db68e2cb639736e888f8acc962f220e31d0: **failed** because no Android emulator was connected to the Ubuntu runner. Dependency install, format, analyzer and all 15 unit/widget tests passed.

**Emulator CI run #68**, run ID 41845417038, commit 9e96428656c9d92349b711d6cafd24befab58e7f: **failed** because Linux KVM device permissions were missing. Logs explicitly reported: `This user doesn't have permissions to use KVM (/dev/kvm)`, followed by `Timeout waiting for emulator to boot`. Formatting, analyzer and 15 unit/widget tests passed; emulator integration did not run.

**KVM permissions fix** committed as `f2c6c5907af0030300484db77fc0cb25585b91b7`.
- Added the upstream-recommended udev rule (KVM group, mode 0666), reload and trigger before emulator launch.
- Added a visible /dev/kvm check.
- Increased emulator boot timeout to 900 seconds and made headless emulator options explicit.

**Emulator CI run #69**, run ID 41848892025, commit f2c6c5907af0030300484db77fc0cb25585b91b7: **in progress at this update**.
- Locked dependency installation, formatting, analyzer, 15 unit/widget tests and the KVM setup step passed.
- Android emulator integration step is still running. Do not report the full CI or integration test as passed until the workflow completes.

**Baseline Debug APK workflow run #63**, run ID 41833556764, commit 3db552b243e64204139fa612dc87e4f465ac526d: **success**.
- flutter build apk --debug and artifact upload passed.
- Artifact: yamintto-debug-3db552b243e64204139fa612dc87e4f465ac526d; archive contains app-debug.apk (approximately 155 MiB).
- Later Debug APK workflow runs were **skipped**, not failed, because their prerequisite Flutter CI runs failed. The workflow is gated on successful completion of Flutter CI and will run after a successful CI run.
- No release APK, AAB, release signing or publishing was produced.

## Platform state and known limitations

Android emulator integration coverage tests the app-shell startup/navigation/theme flow. It does not substitute for installing the final APK on a physical device and testing cold launch, system back, OEM behavior and relaunch. Physical installation and owner-device smoke verification have not been performed.

iOS host identity and iOS 13.0 target were preserved. No macOS/Xcode environment is available in this execution, so native iOS build and launch remain unverified; this is an environment blocker, not a passed iOS test.

The approved tokens are provisional app-shell defaults only. Final product brand palette, full screen design and Phase 09 preferences are not approved or implemented. Native OS launch-screen visuals and physical-device cold-launch behavior require platform verification.

Security algorithms and recovery/biometric decisions remain requirements only. Phase 05 attachments are unencrypted temporary beta data; Phase 06 migration is mandatory before production. Phase 04 search is pre-encryption only; Phase 06 removes persistent plaintext indexes and uses transient unlocked memory search.

Production readiness is not achieved. Beta policy remains Debug APK only.

## Phase 01 acceptance checklist

- [x] Explicit Phase 01 authorization and provisional app-shell token approval.
- [x] Preserve existing Flutter bootstrap, package identity and host project configuration.
- [x] Implement centralized base tokens and Material 3 light/dark/AMOLED themes.
- [x] Implement reusable app-shell components.
- [x] Implement splash, initial route, foundation route and unknown-route handling.
- [x] Add configuration, theme, splash/navigation, route and reusable-widget tests.
- [x] Add Android app-shell integration smoke test.
- [x] Configure CI to provision Android API 35 emulator and grant KVM permissions.
- [x] Run repository-wide formatting, analyzer and 15 unit/widget tests on the latest CI attempt.
- [ ] Verify emulator-backed integration CI run #69.
- [x] Verify baseline Flutter CI and Debug APK artifact workflow.
- [ ] Install/cold-launch/back/relaunch on physical Android device.
- [ ] iOS macOS/Xcode build; environment blocker documented.
- [x] Final diff review and commit SHA recorded.

Phase 02–09 work has not been started.
