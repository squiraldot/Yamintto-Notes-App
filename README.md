# Yamintto

Cross-platform, offline-first notes application built with Flutter. Shared application code lives in Dart; Android and iOS hosts remain independently maintained.

- Version: `0.1.0-beta.1+1`
- Flutter project: `yamintto`
- Android application ID / iOS bundle ID: `com.merrmist.yamintto`
- Platforms: Android and iOS only

This foundation does not implement notes/folders CRUD, Markdown editing, encryption, biometrics, attachments, trash, history, search, or backup.

## Setup

```sh
flutter doctor
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze --fatal-infos
flutter test
flutter build apk --debug
```

iOS development requires macOS, Xcode, and CocoaPods.

## Architecture

Feature-first modules live in `lib/features/`; app composition is in `lib/app/`; shared infrastructure is in `lib/core/`. Riverpod handles state/dependency injection, GoRouter handles navigation, and Drift/SQLite is the selected persistence foundation. Platform-specific behavior must be isolated behind Dart-facing adapters.

See [AGENTS.md](AGENTS.md) and [docs/README.md](docs/README.md). Beta builds only; no release signing, AAB, or production publishing.
