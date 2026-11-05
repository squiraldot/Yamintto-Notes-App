# Contributing

1. Read [AGENTS.md](AGENTS.md), phase rules and relevant docs before editing.
2. Inspect current source/config/tests; docs do not prove implementation.
3. Work only in the explicitly authorized scope and phase. Do not start Phase 01 without authorization.
4. Keep changes focused, preserve behavior, add tests, update docs and record migration impact.
5. Follow effective Dart/Flutter style and avoid unnecessary dependencies or speculative abstractions.
6. Never modify the separate YRNotes web project.
7. Exactly three protected workflows must remain: flutter-ci.yml, yamintto-debug-apk.yml and yamintto-arm64-debug-apk.yml. ADR-0012 supersedes the original two-workflow decision. Do not modify workflow files without explicit owner authorization. During beta, Debug APK only; no release APK/AAB/signing/publishing.
8. Do not commit secrets, passwords, recovery keys, certificates or signing material.

Checks:
```sh
flutter pub get --enforce-lockfile
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze --fatal-infos
flutter test
```
Integration tests are owner-run on real physical devices only; never provision emulator/simulator/KVM CI. The owner reports successful Android real-device testing (detailed evidence not attached). Continue iOS implementation/configuration with each applicable phase; label native build/device verification Not Verified — Environment Unavailable and do not block Android-focused phase progression. PRs/commits must report scope, tests, branch, SHA, risks and docs updated.
