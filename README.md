# Yamintto

Cross-platform, offline-first notes application built with Flutter. Shared application code lives in Dart; Android and iOS hosts remain independently maintained.

- Version: `0.1.0-beta.1+1`
- Flutter project: `yamintto`
- Android application ID / iOS bundle ID: `com.merrmist.yamintto`
- Platforms: Android and iOS only
- SDK baseline: Dart 3.13.0+, Flutter 3.38.4+ (CI pinned to Flutter 3.47.9)
- Android Gradle wrapper: 8.14.3 (AGP 8.11.1, Kotlin 2.2.20)

This foundation does not implement notes/folders CRUD, Markdown editing, encryption, biometrics, attachments, trash, history, search, or backup.

## Setup

```sh
flutter doctor
flutter pub get --enforce-lockfile
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze --fatal-infos
flutter test
flutter build apk --debug
```

iOS development requires macOS, Xcode, and CocoaPods. Run `cd ios && pod install` after `flutter pub get` when preparing the Xcode workspace.

## Architecture

Feature-first modules live in `lib/features/`; app composition is in `lib/app/`; shared infrastructure is in `lib/core/`. Riverpod handles state/dependency injection, GoRouter handles navigation, and Drift/SQLite is the selected persistence foundation. Platform-specific behavior must be isolated behind Dart-facing adapters.

See [AGENTS.md](AGENTS.md) and [docs/README.md](docs/README.md). Beta builds only; no release signing, AAB, or production publishing.
