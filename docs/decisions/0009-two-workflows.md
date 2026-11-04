# ADR -two: Exactly two workflows

- Status: Accepted
- Date: 2026-11-04

## Context
Only CI and debug artifact are authorized.

## Decision
Only flutter-ci.yml and yamintto-debug-apk.yml.

## Alternatives
Additional release/platform/deploy workflows.

## Consequences
Never add third workflow. Both currently exist.

This ADR is a decision record, not evidence that the capability is implemented.
