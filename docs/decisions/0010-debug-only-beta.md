# ADR-0010: Debug-only beta distribution

- Status: Accepted
- Date: 2026-11-04

## Context
Yamintto remains beta until production readiness is demonstrated.

## Decision
Only Debug APK builds/artifacts are permitted during beta. No release APK, AAB, release signing or production publishing. First production release target is 1.0.0.

## Alternatives
Distribute signed release artifacts during beta.

## Consequences
The existing debug artifact workflow is the only beta distribution path. Production requires all phase gates, platform/security evidence and explicit release approval.
