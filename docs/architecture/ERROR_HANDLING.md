# Error handling and propagation

Current: sealed `AppException` with only `UnexpectedAppException`; no complete taxonomy/global handler.

Planned flow: catch platform/SQLite/file/crypto exceptions at data boundary -> map to typed app/domain failures -> repository/use case preserve validation semantics -> Riverpod state exposes safe actionable UI message/retry. Never leak raw SQL/plugin stack to widgets.
Suggested categories: validation, not-found, conflict, storage-full, permission-denied, unavailable, corrupt-data, migration-failed, authentication-failed, integrity-failed, unsupported-format and unexpected. Keep categories actionable.
Transactions protect folder moves, trash/restore, revisions, attachment metadata, migrations and restore. Retry only idempotent operations. Crypto/tag failure, malformed archive and unknown schema fail closed. Never log note content, attachment bytes, passwords, recovery keys, raw keys or decrypted snippets.
Tests: low-level mapping, safe messages, rollback, idempotency, redaction and fail-closed errors.
