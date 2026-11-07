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
- The owner explicitly authorized Phase 03 by submitting [the final implementation prompt](development/PHASE_03_IMPLEMENTATION_PROMPT.md). Implementation is on PR [#2](https://github.com/squiraldot/Yamintto-Notes-App/pull/2), branch `phase-03/markdown-autosave`; exact PR-head Flutter CI run [#42333598484](https://github.com/squiraldot/Yamintto-Notes-App/actions/runs/42333598484) passed on `84cfda21288ef4a2ae4137511796ac7b64ef7e5c` with 120/120 tests.
- Phase 03 remains pending PR review and owner physical-device acceptance; it is not yet merged or phase-accepted.
- Exactly the three existing workflows remain. The PR branch now checks out the exact PR-head SHA in Flutter CI and includes the Phase 03 branch in both APK workflow filters. The default-branch APK workflow definitions on `main` still filter only `main` and `dev`, so the PR branch cannot trigger those `workflow_run` workflows before the default-branch definitions change. `main` was not modified and PR #2 was not merged; Phase 03 APK artifacts remain blocked.


## Phase 02 repair status — 2026-11-06

Phase 02 Note Tags and Folder Colors are implemented on schema v2 and **Phase 02 is ACCEPTED**. Flutter CI passed on repair source SHA `fa8f4ad469786a6a7199360a3d6813d22fac75e6` (run `42177776797`, 85/85 tests); universal and ARM64 Debug APK workflows succeeded for that exact SHA (runs `42177872597` and `42177872567`). The owner confirmed successful physical-device testing; this is owner-reported evidence, not an independently attached device log. The separate automated integration-test source's execution is not claimed. Phase 03 is authorized and implemented on PR branch #2; owner device acceptance and merge remain pending.


## Phase 03 implementation status — 2026-11-07

The Markdown editor, safe hybrid renderer, content-format handling and serialized autosave are implemented on `phase-03/markdown-autosave`, PR #2. Exact PR-head CI run `42333598484` checked out `84cfda21288ef4a2ae4137511796ac7b64ef7e5c` directly and passed locked dependency resolution, formatting, analyzer and 120/120 unit/widget tests. Repository stale-write protection, monotonic revision tokens and explicit conflict reload are included. Parser-limit regression tests and rapid-edit-before-navigation integration-test source were added. APK artifacts remain blocked by the default-branch workflow filter; no Phase 03 physical-device pass or iOS native build is claimed.
