# Database boundary

Drift owns the SQLite connection, lazy open, transactions, migration lifecycle and parameterized query boundary. The schema v1 SQL definition is versioned in `schema_v1.dart`; no generated table models are required for the raw SQL repository boundary.

- `YaminttoDatabase`: Drift `GeneratedDatabase` wrapper and fail-closed v1 migration/open checks.
- `SchemaV1`: exactly two domain tables (`folders`, `notes`) and approved indexes.
- `DatabaseBoundary`: maps storage-layer exceptions to presentation-safe typed failures.
- `databaseProvider`: one lazy, memoized app-scoped Riverpod owner.
- Repositories: domain operations only; widgets never issue SQL or receive transaction handles.

SQLite custom Unicode functions are registered by `NativeDatabase.setup` on every connection before schema operations. See `tool/unicode/17.0.0/README.md` and [DATABASE_SCHEMA.md](../../../docs/database/DATABASE_SCHEMA.md).
