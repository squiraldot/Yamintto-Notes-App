# Database migrations

No schema version, Drift database class or migration currently exists.

Rules:
- Assign schema versions; released migration steps are immutable.
- Use Drift migration APIs and schema snapshots; test fresh install and every supported prior version.
- Preserve PK/FK/unique constraints/indexes and user data. Destructive changes require backup, approval and rollback plan.
- Use transactions where possible. Filesystem + SQLite cannot share a transaction: stage files, maintain an operation journal, make recovery idempotent.
- Test interruption at each step, app kill/restart, disk full, malformed rows, FK integrity, duplicate IDs and large DB.
- Unknown future schema must fail safely; never downgrade by discarding data.
- Phase 06 migration encrypts notes/revisions/attachments and removes plaintext FTS/indexes/snippets/temp copies/attachment originals. Verify absence before marking complete. Never claim encrypted state while plaintext remains. Journal/protocol design requires security review.
- Phase 08 validates/stages backup before transactional swap; failure leaves original data usable.
For every migration document source/target versions, disk space, duration, interruption recovery and test fixtures.
