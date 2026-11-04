# ADR-0009: Exactly two GitHub Actions workflows

- Status: Accepted
- Date: 2026-11-04

## Context
The project permits one validation workflow and one beta debug-artifact workflow.

## Decision
Exactly these workflows are allowed: `.github/workflows/flutter-ci.yml` and `.github/workflows/yamintto-debug-apk.yml`.

## Alternatives
Additional release, platform or deployment workflows.

## Consequences
Never add a third workflow. Current repository contains exactly these two. Workflow changes require explicit authorization and are prohibited in docs-only work.
