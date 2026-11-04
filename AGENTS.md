# Yamintto AI agent instructions

This is the primary instruction entry point. Read it before any repository modification.

## Start sequence
1. Read this file, [AI development guide](docs/ai/AI_DEVELOPMENT_GUIDE.md), and [phase rules](docs/ai/PHASE_EXECUTION_RULES.md).
2. Read relevant product, architecture, database, security, design, testing, development, release and ADR documents via [docs index](docs/README.md).
3. Inspect actual source, config, tests, workflows, branch and diff before assumptions.
4. Confirm authorized phase, exact scope and allowed files. Ask if unclear.

## Source of truth and statuses
Actual code/configuration determine current implementation. Docs define target intent, not proof. Classify as Implemented, Configured, Planned, In progress, Not implemented, or Requires verification. Report code/doc conflicts; never silently change architecture.

## Architecture
Target feature-first structure: `lib/features/<feature>/{data,domain,presentation}/`; shared infrastructure `lib/core/`; composition/providers/routing/config `lib/app/`. Riverpod is selected for state/DI, GoRouter for navigation, Drift/SQLite for local persistence. Current implementation is only bootstrap, ProviderScope, one route, theme and foundation screen. No schema, repository, feature provider, encryption or product feature exists.

## Scope and safety
Work only in authorized scope; one phase at a time; no scope expansion, skipped phases, premature future features, unrelated refactors or breaking changes without documented migration and approval. Preserve all features and tests. Never modify YRNotes. Do not start Phase 01 without explicit authorization. No secrets/plaintext note content in source, logs or commits. Do not invent cryptographic protocols.

## Repository restrictions
Exactly two workflows: `.github/workflows/flutter-ci.yml` and `.github/workflows/yamintto-debug-apk.yml`. Never add a third. Do not change workflows unless specifically authorized. Beta permits debug APK only: no release APK/AAB, signing or production publishing. For documentation-only tasks do not modify app source, dependencies, Android/iOS config or workflows.

## Validation and report
Run lockfile-enforced pub get, Dart format check, fatal analyzer and flutter test; run integration/platform checks when available. Do not claim unrun checks. iOS native build remains pending until macOS/Xcode validation. Update docs with behavior/architecture changes. Report changed files, branch, commit SHA, checks/results, unrun checks, platform evidence and unresolved risks.
