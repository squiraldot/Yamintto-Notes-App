# Yamintto agent instructions

Read this file and relevant `docs/` references before changing code. Inspect existing implementation and tests; never assume planned features exist. Do not modify the separate YRNotes web application.

## Architecture
- Feature-first modules: `lib/features/<feature>/{data,domain,presentation}/`; create only when a feature is authorized.
- Shared infrastructure: `lib/core/`; composition, providers, routing, and config: `lib/app/`.
- Riverpod for state/DI, GoRouter for navigation, repository interfaces for data access, Drift/SQLite for local persistence.
- Keep Android/iOS implementation out of shared feature logic. Use Dart-facing interfaces and isolated platform adapters.
- Avoid speculative abstractions, empty placeholders, duplicated business logic, and giant files.

## Quality and security
- Follow effective Dart/Flutter style; format and analyze all Dart changes.
- Add appropriate unit, widget, and integration tests alongside behavior.
- Model loading, empty, success, and error states.
- Never commit API keys, passwords, private certificates, signing material, or encryption secrets.
- No release signing, release APK/AAB, production publishing, or automatic deployment without explicit authorization.

## Validation
Run `flutter pub get --enforce-lockfile`, `dart format --output=none --set-exit-if-changed lib test integration_test`, `flutter analyze --fatal-infos`, and `flutter test`. Run platform builds when toolchains are available. Report every unrun check honestly.

## Scope
The foundation does not authorize notes CRUD, folders, Markdown editing, encryption, biometrics, attachments, trash, history, search, or backup. Wait for an explicitly scoped feature task.
