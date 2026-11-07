# Yamintto documentation index

This is the project knowledge base. Source/config/tests determine current implementation; product/architecture docs define approved target behavior. See [status and audit checklist](STATUS.md) first.

## Agent start
- [Root AGENTS.md](../AGENTS.md)
- [AI development guide](ai/AI_DEVELOPMENT_GUIDE.md)
- [Phase execution rules](ai/PHASE_EXECUTION_RULES.md)
- [Nine-phase roadmap](development/PHASE_ROADMAP.md)

## Product
[Overview](product/PRODUCT_OVERVIEW.md) · [Requirements and IDs](product/PRODUCT_REQUIREMENTS.md) · [Feature Catalog / phase ownership](product/FEATURE_CATALOG.md) · [Platform support](product/PLATFORM_SUPPORT.md)

## Architecture
[System architecture](architecture/SYSTEM_ARCHITECTURE.md) · [Project structure](architecture/PROJECT_STRUCTURE.md) · [State and DI](architecture/STATE_MANAGEMENT.md) · [Routing](architecture/ROUTING.md) · [Errors](architecture/ERROR_HANDLING.md) · [Platform architecture](architecture/PLATFORM_ARCHITECTURE.md) · [Dependency policy](architecture/DEPENDENCY_POLICY.md)

## Editor
[Editor architecture](editor/EDITOR_ARCHITECTURE.md) · [Hybrid Markdown dialect and safety policy](editor/MARKDOWN_DIALECT.md) · [Physical-device integration test guide](../integration_test/README.md)

## Database
[Schema proposal](database/DATABASE_SCHEMA.md) · [Migrations](database/DATABASE_MIGRATIONS.md) · [Retention](database/DATA_RETENTION.md) · [Phase 02 decision register](database/PHASE_02_DECISION_REGISTER.md)

## Security
[Overview and review register](security/SECURITY_OVERVIEW.md) · [Encryption](security/ENCRYPTION_SPECIFICATION.md) · [Key management](security/KEY_MANAGEMENT.md) · [Recovery](security/RECOVERY_SPECIFICATION.md) · [Biometrics](security/BIOMETRIC_AUTHENTICATION.md) · [Attachments](security/SECURE_ATTACHMENTS.md) · [Backups](security/SECURE_BACKUPS.md) · [Threat model](security/THREAT_MODEL.md)

## Design
[Design system](design/DESIGN_SYSTEM.md) · [Themes](design/THEMING.md) · [Accessibility](design/ACCESSIBILITY.md) · [Responsive layout](design/RESPONSIVE_LAYOUT.md)

## Testing
[Strategy and matrix](testing/TESTING_STRATEGY.md) · [Unit](testing/UNIT_TESTING.md) · [Widget](testing/WIDGET_TESTING.md) · [Integration](testing/INTEGRATION_TESTING.md) · [Security](testing/SECURITY_TESTING.md) · [Platform](testing/PLATFORM_TESTING.md)

## Development and release
[Workflow](development/DEVELOPMENT_WORKFLOW.md) · [Git](development/GIT_WORKFLOW.md) · [Dependencies](development/DEPENDENCY_MANAGEMENT.md) · [Debug APK](development/DEBUG_APK_GUIDE.md) · [Build](development/BUILD_GUIDE.md) · [Versioning](releases/VERSIONING.md) · [Beta policy](releases/BETA_POLICY.md) · [Production readiness](releases/PRODUCTION_READINESS.md)

## Decisions
[ADR index](decisions/README.md). Status vocabulary: Implemented = code and evidence; Configured = scaffold/dependency; In progress = partial; Planned = target; Not implemented = absent; Requires verification = not yet evidenced.


## Current owner decisions and execution status (2026-11-06)

- [Phase 02 Note Tags + Folder Colors repair is ACCEPTED, including owner-reported physical-device PASS](STATUS.md).
- The owner explicitly authorized Phase 03 by submitting [the final implementation prompt](development/PHASE_03_IMPLEMENTATION_PROMPT.md). Implementation is on PR [#2](https://github.com/squiraldot/Yamintto-Notes-App/pull/2), branch `phase-03/markdown-autosave`; exact source SHA `3ab1a24bdb9ee389a1fa0214f1b03d16da823202` passed Flutter CI run [#42334404037](https://github.com/squiraldot/Yamintto-Notes-App/actions/runs/42334404037) with 120/120 tests. Both reusable APK workflows succeeded in that same parent run and uploaded artifacts `13559062230` (universal) and `13558519592` (ARM64).
- Phase 03 remains pending PR review and owner physical-device acceptance; it is not yet merged or phase-accepted.
- Exactly the three existing workflows remain. The Phase 03 PR path uses local `workflow_call` reusable workflows after the Flutter CI validation job, passing the exact PR-head SHA as `source_sha`. The existing `workflow_run` path remains for normal `main` and `dev` builds. This avoids modifying `main`; the two APK jobs share the parent Flutter CI run ID. `main` was not modified and PR #2 was not merged.


## Phase 02 repair status — 2026-11-06

Phase 02 Note Tags and Folder Colors are implemented on schema v2 and **Phase 02 is ACCEPTED**. Flutter CI passed on repair source SHA `fa8f4ad469786a6a7199360a3d6813d22fac75e6` (run `42177776797`, 85/85 tests); universal and ARM64 Debug APK workflows succeeded for that exact SHA (runs `42177872597` and `42177872567`). The owner confirmed successful physical-device testing; this is owner-reported evidence, not an independently attached device log. The separate automated integration-test source's execution is not claimed. Phase 03 is authorized and implemented on PR branch #2; owner device acceptance and merge remain pending.


## Phase 03 implementation status — 2026-11-07

The Markdown editor, safe hybrid renderer, content-format handling and serialized autosave are implemented on `phase-03/markdown-autosave`, PR #2. Exact source SHA `3ab1a24bdb9ee389a1fa0214f1b03d16da823202` passed Flutter CI run `42334404037`, including locked dependency resolution, formatting, analyzer and 120/120 unit/widget tests. Universal and ARM64 reusable APK jobs succeeded after validation in the same parent run and uploaded artifacts `13559062230` and `13558519592`. Repository stale-write protection, monotonic revision tokens, explicit conflict reload, parser-limit regression tests and rapid-edit-before-navigation integration-test source are included. Owner physical-device acceptance and iOS native verification remain pending.
