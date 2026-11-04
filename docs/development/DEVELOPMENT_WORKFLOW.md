# DEVELOPMENT_WORKFLOW

Use Flutter 3.47.9 (CI pinned). pubspec declares Dart >=3.13.0 and Flutter >=3.38.4; lower Flutter versions are not verified. Commands: flutter doctor; flutter pub get --enforce-lockfile; dart format --output=none --set-exit-if-changed .; flutter analyze --fatal-infos; flutter test; owner-run physical-device integration tests only; Android flutter build apk --debug. iOS on macOS only: cd ios && pod install && cd .., then flutter build ios --debug --no-codesign; no Xcode validation currently. Never release build during beta.

## CI and owner-run device testing
GitHub Actions runs dependency resolution, formatting, analysis and unit/widget tests only. Do not add Android emulator, iOS simulator, KVM or virtual-device setup to CI. Integration tests are owner-run on real physical devices:

    flutter devices
    flutter test integration_test -d <physical-device-id>

AI agents must not create/use virtual devices or use them as a fallback. If no physical device is connected, report integration testing as pending.
