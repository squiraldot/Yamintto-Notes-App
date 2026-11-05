# DEVELOPMENT_WORKFLOW

Use Flutter 3.47.9 (CI pinned). pubspec declares Dart >=3.13.0 and Flutter >=3.38.4; lower Flutter versions are not verified. Commands: flutter doctor; flutter pub get --enforce-lockfile; dart format --output=none --set-exit-if-changed .; flutter analyze --fatal-infos; flutter test; owner-run physical-device integration tests only; Android universal Debug APK: flutter build apk --debug; ARM64-only Debug APK: flutter build apk --debug --target-platform android-arm64. iOS on macOS only: cd ios && pod install && cd .., then flutter build ios --debug --no-codesign; no Xcode validation currently. Never release build during beta.

## CI workflows
Exactly three protected workflows are maintained:
- `.github/workflows/flutter-ci.yml`: host-only dependency resolution, formatting, analysis and unit/widget tests.
- `.github/workflows/yamintto-debug-apk.yml`: universal Android Debug APK artifact.
- `.github/workflows/yamintto-arm64-debug-apk.yml`: ARM64-only Android Debug APK artifact.
Both APK workflows trigger automatically after successful Flutter CI completion on main/dev, check out the exact tested commit, use Flutter 3.47.9 and upload their APK artifacts for 14 days. Keep all three workflows; removal/renaming/disabling requires explicit owner authorization. Do not add emulators, KVM, simulators, release builds, signing or publishing.

## Owner-run physical-device testing
GitHub Actions does not run integration/E2E tests. Do not add Android emulator, iOS simulator, KVM or virtual-device setup to CI. Integration tests are owner-run on real physical devices:

    flutter devices
    flutter test integration_test -d <physical-device-id>

AI agents must not create/use virtual devices or use them as a fallback. If no physical device is connected, report integration testing as pending.
