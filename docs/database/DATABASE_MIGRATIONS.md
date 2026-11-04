# DATABASE_MIGRATIONS

No schema version or migration exists. Future migrations must version every schema/semantic change, keep released schemas immutable, use Drift migration APIs and schema snapshots, test every supported upgrade path, preserve ciphertext/key semantics, and transact multi-step changes. Test fresh install, old versions, interruption, corruption, FK/index integrity and large datasets. Destructive changes require backup and approved migration plan.
