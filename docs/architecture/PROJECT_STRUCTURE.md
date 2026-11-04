# Project structure

## Current source shape
`lib/main.dart`; `lib/app/{bootstrap.dart,app.dart,configuration/app_configuration.dart,router/app_router.dart}`; `lib/core/{errors/app_exception.dart,theme/app_theme.dart}`; `lib/features/foundation/presentation/foundation_screen.dart`; `test/app/app_test.dart`; `integration_test/README.md`. Other core/shared/features/providers and asset folders contain README placeholders. Android/iOS host projects and docs exist. No feature-first product modules are populated.

## Target shape (planned)
```text
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
```
Tests mirror features: `test/features/<feature>/{domain,data,presentation}/`; cross-cutting tests in `test/core/`; device flows in `integration_test/`. Do not create future feature modules before their phase. Native code stays in Android/iOS hosts and is called through Dart adapters. Keep generated Drift files adjacent to schema and follow the chosen deterministic codegen/commit policy.
