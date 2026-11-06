# Yamintto

Native Flutter notes application for Android and iOS; offline-first by design. Yamintto is an independent application, not a conversion or replacement of the separate YRNotes web app.

| Identity | Value |
|---|---|
| App / package | Yamintto / `yamintto` |
| Android ID | `com.merrmist.yamintto` |
| iOS bundle ID | `com.merrmist.yamintto` |
| Version | `0.1.0-beta.1+1` |
| Production target | `1.0.0` |
| Platforms | Android, iOS |
| CI Flutter | **3.47.9** |
| Dart constraint | `>=3.13.0 <4.0.0` |

## Current project status

<badge>Phase 02 — ACCEPTED</badge>

Phase 01 foundation and Phase 02 core management are implemented. Phase 02 includes nested folders, notes CRUD and soft-delete, reusable note tags with multiple persistent assignments, and optional persisted colors for root and nested folders. The database uses Drift/SQLite schema v2; schema v1 remains the immutable migration baseline.

**Phase 02 acceptance evidence (2026-11-06):**
- Repair source: `fa8f4ad469786a6a7199360a3d6813d22fac75e6`.
- Flutter CI run [#42177776797](https://github.com/squiraldot/Yamintto-Notes-App/actions/runs/42177776797): passed on Flutter 3.47.9; format, analyzer and **85/85 tests** passed.
- Universal Debug APK run [#42177872597](https://github.com/squiraldot/Yamintto-Notes-App/actions/runs/42177872597): successful artifact upload.
- ARM64 Debug APK run [#42177872567](https://github.com/squiraldot/Yamintto-Notes-App/actions/runs/42177872567): successful artifact upload.
- Owner confirmed successful physical-device testing of the repaired features. This is recorded as owner-reported acceptance; no device model, OS version, screenshots or test logs are asserted.
- The separate automated integration-test source exists; its execution is not independently evidenced and is not claimed.

**Phase 03 has not started and is not authorized.** It requires separate explicit owner authorization. Features assigned to later phases remain planned or not implemented; see the [phase roadmap](docs/development/PHASE_ROADMAP.md) and [status record](docs/STATUS.md).

## Implemented Phase 02 capabilities

- Offline local folders and notes with nested hierarchy, ordering and soft-delete.
- Reusable global tags; create, rename and delete tags; assign/remove multiple tags per note.
- Persistent optional folder colors with a validated ten-color opaque ARGB palette, theme-aware default and nested-folder display.
- Forward-only transactional schema v1 → v2 migration with rollback/fail-closed behavior.
- Unit, repository, database/migration and widget regression coverage.

## SDK baseline

CI pins Flutter 3.47.9. The pubspec allows Flutter `>=3.38.4`, but only Flutter 3.47.9 is verified. Use Flutter 3.47.9; its bundled Dart must satisfy Dart >=3.13.0.

## Native platform verification

Android physical-device testing for the Phase 02 repair is owner-reported successful. iOS bundle identity and native project configuration exist, but **iOS native build/device verification remains Not Verified — Environment Unavailable** (macOS/Xcode verification unavailable). This does not block Android-focused Phase 02 acceptance.

## Setup and checks

```sh
flutter doctor
flutter pub get --enforce-lockfile
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
flutter build apk --debug
flutter build apk --debug --target-platform android-arm64
```

iOS requires macOS, Xcode and CocoaPods; native iOS build and device verification have not yet been evidenced.

## Debug APK artifacts

Beta distribution is Debug APK only; no release APK/AAB, release signing or production publishing is authorized. Exactly three protected GitHub Actions workflows remain:
1. Host-only Flutter CI.
2. Universal Android Debug APK build/artifact upload.
3. ARM64-only Android Debug APK build/artifact upload.

The APK workflows build the exact CI-tested SHA and do not run device tests. Artifacts are retained for 14 days. See [Debug APK guide](docs/development/DEBUG_APK_GUIDE.md).

## Architecture and documentation

The codebase uses Flutter, Riverpod, GoRouter and Drift/SQLite with feature-first boundaries. Schema v1 is preserved; schema v2 adds tag definitions/assignments and nullable folder color metadata. See [system architecture](docs/architecture/SYSTEM_ARCHITECTURE.md), [database schema](docs/database/DATABASE_SCHEMA.md), [migration policy](docs/database/DATABASE_MIGRATIONS.md), and [Phase 02 decision register](docs/database/PHASE_02_DECISION_REGISTER.md).

- [Documentation index](docs/README.md)
- [Project status and acceptance evidence](docs/STATUS.md)
- [Changelog](CHANGELOG.md)
- [Nine-phase roadmap](docs/development/PHASE_ROADMAP.md)
- [AI agent instructions](AGENTS.md)

## Project boundary

YRNotes remains a separate web app and must remain untouched. Legacy ZIP import is planned for a later phase; supported variants are unknown until old source and real fixtures are inspected.

## Testing policy

Flutter CI is host-only: locked dependency resolution, formatting, analyzer and unit/widget tests. GitHub Actions must not provision Android emulators, iOS simulators, KVM or virtual devices. Integration tests remain in `integration_test/` and are run by the owner on real physical devices only. Owner-reported device results must remain distinct from automated CI evidence.
