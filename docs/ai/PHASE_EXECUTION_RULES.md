# Phase execution rules

1. One phase at a time.
2. Limit each phase to 2–3 major features.
3. No unrelated features or scope expansion without approval.
4. No skipped phases or unapproved phase transitions.
5. No completion claim without acceptance criteria, required tests, documentation and validation evidence.
6. No breaking changes without documented migration and approval.
7. No unnecessary dependencies; review maintenance, license, security and platform support.
8. No premature future-phase implementation.
9. Preserve existing features; no unrelated refactors.
10. YRNotes remains untouched.
11. Exactly two workflows; never add another.
12. Beta allows debug APK only; no release APK/AAB/signing/publishing.

Before: verify authorization, prerequisites, scope, branch and current state. During: stop for missing decisions or scope changes. After: test, update docs, inspect diff, report SHA and residual risks. Wait for approval before next phase.
