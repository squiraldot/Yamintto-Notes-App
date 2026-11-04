# SECURE_BACKUPS

No backup format or implementation exists. Future backups must be versioned, encrypted, integrity checked, self-describing and consistent snapshots; never include plaintext note data or raw master keys. Validate before restore, stage and rollback on failure, define device migration and key metadata. Legacy YRNotes ZIP structure is unknown: inspect old source and golden fixtures first; do not modify YRNotes. Test round-trip, corrupt/truncated archives, unknown versions and cross-device recovery.
