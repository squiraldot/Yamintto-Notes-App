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


## Current owner decisions (2026-11-06)

- [Phase 02 is reopened for note-tag and folder-color repair](STATUS.md).
- [Phase 03 final implementation prompt](development/PHASE_03_IMPLEMENTATION_PROMPT.md) — prepared, gated, and not authorized for execution.
- Existing three protected GitHub Actions workflows remain in force.
