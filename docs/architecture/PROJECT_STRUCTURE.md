# Project structure

## Current source shape — Phase 02

lib/
  main.dart
  app/
    app.dart
    bootstrap.dart
    configuration/
    router/app_router.dart
    providers/database_provider.dart
  core/
    database/schema_v1.dart
    database/yamintto_database.dart
    errors/
    ids/
    theme/
      app_theme.dart
      tokens/
    unicode/
      unicode_canonicalizer.dart
      unicode_17_data.dart
    widgets/
  features/
    foundation/presentation/
      foundation_screen.dart
      splash_screen.dart
    folders/
      data/folder_providers.dart
      data/folder_repository.dart
      domain/folder.dart
      presentation/folder_browser_screen.dart
      presentation/folder_providers.dart
    notes/
      data/note_providers.dart
      data/note_repository.dart
      domain/note.dart
      presentation/note_editor_screen.dart
      presentation/note_providers.dart
  shared/

The foundation feature retains splash and appearance-preview behavior; the root route is now the folder browser. Existing Android/iOS host projects remain in place. Database/repository tests live under `test/core/` and `test/features/`; Phase 02 presentation coverage lives in `test/features/phase_02_screens_test.dart`. The physical SQLite persistence smoke source is under `integration_test/phase_02_data_smoke_test.dart` and is owner-run only.

## Target shape (planned)

lib/
  main.dart
  app/                 # bootstrap, app widget, config, root DI, router
  core/                # errors, logging, theme, storage, DB, security
  features/
    notes/{presentation,domain,data}/
    folders/{presentation,domain,data}/
    editor/{presentation,domain,data}/
    search/{presentation,domain,data}/
    attachments/{presentation,domain,data}/
    backup/{presentation,domain,data}/
  shared/              # genuinely shared UI/value types only

Do not create future feature modules before their phase. Native code stays in Android/iOS hosts and is called through Dart adapters. Keep generated Drift files adjacent to schema and follow the chosen deterministic codegen/commit policy.
