# Documentation and implementation status

Snapshot: 2026-11-05; branch main.

## Phase 01 — Foundation

Status: **Foundation implementation and host-side automated checks passed on an earlier baseline; owner-run physical-device integration and iOS acceptance remain open.**

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
- Exactly three protected workflows:
  - `.github/workflows/flutter-ci.yml` — host-only validation.
  - `.github/workflows/yamintto-debug-apk.yml` — existing universal Debug APK artifact; unchanged by the ARM64 addition.
  - `.github/workflows/yamintto-arm64-debug-apk.yml` — new ARM64-only Debug APK artifact.
- Both APK artifact workflows automatically trigger after successful Flutter CI completion on main/dev, check out the exact tested SHA, build Debug APKs with Flutter 3.47.9 and upload artifacts for 14 days.
- ARM64 workflow command: `flutter build apk --debug --target-platform android-arm64`. It targets `android-arm64` for compatible 64-bit ARM Android devices, including the owner's Redmi Note 10S.
- Flutter CI remains host-only: locked dependencies, formatting, analyzer and unit/widget tests. No emulator/KVM/simulator setup. Physical-device integration is owner-run.
- The new ARM64 workflow is configured in the repository, but its first successful artifact run and actual APK size have not yet been verified.

## Verification evidence

**Baseline Flutter CI run #66**, run ID 41833435924, commit 3db552b243e64204139fa612dc87e4f465ac526d: **success**.
- Locked dependency installation, repository-wide Dart formatting, flutter analyze --fatal-infos and all 15 Flutter tests passed.
- Integration tests were not yet present in that historical run.

**Historical emulator attempts**:
- Integration follow-up run #67 (41845194256) failed because no Android emulator was connected.
- Emulator run #68 (41845417038) failed due to Linux KVM permissions and emulator boot timeout.
- Emulator run #69 (41848892025) was cancelled while the emulator integration step was still running; it is not a passed integration test.
- Emulator/KVM runner configuration was subsequently removed by owner instruction. These historical failures do not describe the current host-only CI configuration.

**Baseline universal Debug APK workflow run #63**, run ID 41833556764, commit 3db552b243e64204139fa612dc87e4f465ac526d: **success**.
- `flutter build apk --debug` and artifact upload passed.
- Artifact: `yamintto-debug-3db552b243e64204139fa612dc87e4f465ac526d`; contained `app-debug.apk` (approximately 155 MiB).
- This historical run verifies the universal workflow only. It does not verify the new ARM64 workflow or its expected size.
- No release APK, AAB, release signing or publishing was produced.

## Platform state and known limitations

Android emulator integration coverage was attempted historically but is prohibited in current CI. It does not substitute for installing the final APK on a physical device and testing cold launch, system back, OEM behavior and relaunch. Physical installation and owner-device smoke verification have not been performed.

The ARM64 artifact is intended for the owner's Redmi Note 10S (Android 13, MIUI 14, ARM64). Installability and runtime behavior must be confirmed on that physical device. The ARM64-only build excludes other ABIs and is not a universal Android distribution artifact.

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
- [x] Configure host-only CI for dependency resolution, formatting, analyzer and unit/widget tests.
- [x] Run repository-wide formatting, analyzer and 15 unit/widget tests on the historical baseline.
- [ ] Run integration smoke test on an owner-provided physical Android device.
- [x] Verify baseline Flutter CI and universal Debug APK artifact workflow.
- [x] Add and document the protected ARM64-only Debug APK workflow.
- [ ] Verify the first ARM64 workflow artifact and measure its actual APK size.
- [ ] Install/cold-launch/back/relaunch on physical Android device.
- [ ] iOS macOS/Xcode build; environment blocker documented.
- [x] Update workflow protection documentation and ADR.

Phase 02–09 work has not been started.

## Current CI and device-testing policy
- Flutter CI runs locked dependency installation, formatting, analyzer and unit/widget tests only.
- Exactly three protected workflows must remain: Flutter CI, universal Debug APK and ARM64-only Debug APK. AI agents must not delete, rename, disable, merge or replace any without explicit owner authorization.
- Both APK artifact workflows run automatically after successful Flutter CI on main/dev. They compile/upload APKs only; they do not run emulator, simulator or physical-device tests.
- Integration tests remain in integration_test/ for owner-run execution on real physical devices only: `flutter devices`, then `flutter test integration_test -d <physical-device-id>`.
- AI agents must not add/configure/run emulators or simulators, virtual-device CI, KVM or emulator-runner actions. Ask the owner before any exception.
