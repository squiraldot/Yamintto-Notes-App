# Phase execution rules

## Authorization
Roadmap is an ordered plan, not permission. User must explicitly authorize phase and scope. Current: no phase authorized; Phase 01 is next planned and not started/accepted.

## Rules
1. One phase at a time; maximum 2–3 major features.
2. No unrelated work, scope expansion, skipped phases or premature future-phase implementation without approval.
3. No completion claim without acceptance criteria, tests, documentation and evidence.
4. No breaking schema/data/backup/encryption change without approved, tested migration.
5. Avoid unnecessary dependencies; security dependencies need independent review.
6. Preserve behavior and add regression tests.
7. YRNotes remains untouched.
8. Exactly two workflows; never add another. Docs-only tasks do not edit workflows.
9. Beta is Debug APK only; no release APK/AAB/signing/publishing.
10. Phase 05 attachment bytes are temporary unencrypted beta data; Phase 06 must encrypt/migrate before production-ready claims.

## Gate
Before: confirm explicit authorization, prerequisites, feature IDs, source state, scope and exclusions. During: stop for unresolved architecture/schema/security decisions. After: test every criterion, inspect migration/data-loss behavior, update docs/ADR/status, review diff/links, report SHA and evidence. Do not start next phase before acceptance.
