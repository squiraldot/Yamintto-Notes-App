# Yamintto

Native Flutter notes application for Android and iOS; offline-first by design. This is a new independent app, not a conversion/replacement of the separate YRNotes web app.

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

## Current status
The repository currently implements the Phase 01 foundation shell: Flutter bootstrap, root Riverpod ProviderScope, YaminttoApp, centralized provisional design tokens, Material 3 light/dark/AMOLED themes, reusable UI primitives, GoRouter splash/foundation navigation and unknown-route recovery. Configuration/theme/navigation/widget tests and an Android app-shell integration test source are present. Phase 02+ product workflows, database schema/migrations, repositories, encryption, biometrics, attachments, backup and notes CRUD are not implemented.

## SDK baseline
CI pins Flutter 3.47.9. pubspec declares Flutter `>=3.38.4`, but that lower bound is not verified compatibility. Use Flutter 3.47.9; its bundled Dart must satisfy Dart >=3.13.0. Do not claim lower Flutter versions are tested.

## Native configuration
Android: AGP 8.11.1, Kotlin 2.2.20, Gradle 8.14.3, Java 17; Flutter supplies SDK defaults. iOS: deployment target 13.0 and CocoaPods/Xcode project configured. **No macOS/Xcode build has been verified; iOS native build validation is pending.**

## Setup and checks
```sh
flutter doctor
flutter pub get --enforce-lockfile
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze --fatal-infos
flutter test
flutter build apk --debug
flutter build apk --debug --target-platform android-arm64
```
iOS requires macOS, Xcode and CocoaPods; use `cd ios && pod install` after dependency resolution, then verify a Debug build on macOS. Not yet validated here.

## Debug APK artifacts
Beta builds are Debug APKs only. Exactly three protected workflows exist: one host-only Flutter CI workflow and two Debug APK artifact workflows. The two artifact workflows run automatically after successful Flutter CI on main/dev, each checking out the tested SHA and using Flutter 3.47.9:
- **Yamintto Debug APK** — universal APK for broad Android ABI compatibility; artifact name `yamintto-debug-<sha>`.
- **ARM64-only Debug APK** — APK targeting `android-arm64`, intended for compatible 64-bit Android devices such as the Redmi Note 10S; artifact name `yamintto-arm64-debug-<sha>`.
Both artifacts are retained for 14 days. GitHub Actions -> select the corresponding workflow -> successful run -> Artifacts. The original universal workflow remains unchanged. No release APK, AAB, signing or publishing.

## Architecture
Target: feature-first modules with presentation/domain/data boundaries; shared services in `lib/core/`; composition/providers/routing in `lib/app/`; Drift/SQLite local persistence. Current code is only the shell, not the complete target architecture.

## Project boundary
YRNotes remains a separate web app and must remain untouched. Legacy ZIP import is planned, but its format is unknown until old source and real fixtures are inspected. See [AGENTS.md](AGENTS.md), [docs index](docs/README.md), [status](docs/STATUS.md), and [nine-phase roadmap](docs/development/PHASE_ROADMAP.md).

## Testing policy
Flutter CI is host-only: locked dependency resolution, formatting, analyzer and unit/widget tests. GitHub Actions must not provision Android emulators, iOS simulators, KVM or virtual devices. Integration tests remain in integration_test/ and are run by the owner on real physical devices only (flutter devices, then flutter test integration_test -d <physical-device-id>). The owner reports successful Android real-device testing; detailed evidence is not attached. iOS development/configuration continues alongside shared Flutter work; native build/device verification is Not Verified — Environment Unavailable and does not block Android-focused phase progression.
