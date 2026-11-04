# Project structure

## Current source shape — Phase 01

lib/
  main.dart
  app/
    app.dart
    bootstrap.dart
    configuration/app_configuration.dart
    router/app_router.dart
    providers/                 # root provider composition guidance
  core/
    errors/
    theme/
      app_theme.dart
      tokens/
        app_colors.dart
        app_radii.dart
        app_sizes.dart
        app_spacing.dart
        app_typography.dart
    widgets/
      app_button.dart
      app_card.dart
      app_dialog.dart
      app_text_field.dart
  features/
    foundation/presentation/
      foundation_screen.dart
      splash_screen.dart
  shared/

The foundation feature is a temporary shell, not a product feature. Existing Android/iOS host projects and root tests remain in place. Cross-cutting tests live under test/app/, test/core/theme/ and test/core/widgets/; future product tests should mirror their owning feature.

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
