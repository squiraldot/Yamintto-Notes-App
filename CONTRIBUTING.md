# Contributing

1. Read [AGENTS.md](AGENTS.md), phase rules and relevant docs before editing.
2. Inspect current source/config/tests; docs do not prove implementation.
3. Work only in the explicitly authorized scope and phase. Do not start Phase 01 without authorization.
4. Keep changes focused, preserve behavior, add tests, update docs and record migration impact.
5. Follow effective Dart/Flutter style and avoid unnecessary dependencies or speculative abstractions.
6. Never modify the separate YRNotes web project.
7. Exactly two workflows are permitted; never add another. During beta, debug APK only; no release APK/AAB/signing/publishing.
8. Do not commit secrets, passwords, recovery keys, certificates or signing material.

Checks:
```sh
flutter pub get --enforce-lockfile
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze --fatal-infos
flutter test
```
Run platform/integration checks when available and report skipped checks honestly. iOS native build validation is pending macOS/Xcode verification. PRs/commits must report scope, tests, branch, SHA, risks and docs updated.
