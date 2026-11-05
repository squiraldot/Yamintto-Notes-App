# ADR-0009: Exactly two GitHub Actions workflows

- Status: Superseded by [ADR-0012](0012-arm64-debug-apk-workflow.md)
- Date: 2026-11-04

## Context
The original CI design permitted one validation workflow and one universal beta debug-artifact workflow.

## Decision
This was the original decision: exactly these workflows were allowed: `.github/workflows/flutter-ci.yml` and `.github/workflows/yamintto-debug-apk.yml`.

## Alternatives
Additional release, platform or deployment workflows.

## Consequences
This two-workflow limit is historical and no longer describes the repository. The current protected three-workflow set is documented in ADR-0012. The two original workflows remain unchanged.
