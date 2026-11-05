# Integration tests

## What is retained

Phase 01 includes `app_smoke_test.dart`, which exercises the real Yamintto app widget tree through startup, splash transition and theme preview. Phase 02 includes `phase_02_data_smoke_test.dart`, which creates a real SQLite file, creates a folder and note, closes/reopens the database, verifies persisted rows, soft-deletes the note, verifies active-list exclusion and confirms the retained folder/body/order fields. Both tests are source only until the owner executes them on physical hardware.

## Execution policy

Integration tests are **not run in GitHub Actions**. The project deliberately does not use:
- Android emulators in CI.
- iOS simulators in CI.
- KVM, virtual-device runners, emulator boot or simulator setup.
- AI-created or AI-operated emulators/simulators.

Flutter CI is host-only and runs locked dependency resolution, formatting, analyzer and unit/widget tests. The two APK workflows only build and upload universal/ARM64 Debug APK artifacts.

The project owner runs integration/E2E tests on real physical devices only. After the owner connects and authorizes a device:

```sh
flutter devices
flutter test integration_test -d <physical-device-id>
```

Do not claim an integration test passed unless there is actual execution evidence. Record device model, OS version, build/commit SHA, command, scenarios and result when the owner provides them. Do not invent missing details.

Owner-reported physical Android testing may be recorded separately as owner-reported; it must not be presented as an automated CI result. iOS native build/device verification requires macOS/Xcode and remains unverified when that environment is unavailable; this does not block Android-focused phase progression.
