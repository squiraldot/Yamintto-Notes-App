# DATA_RETENTION

Retention is not implemented and exact periods are undecided. Define trash expiry, revision count/age, attachment orphan cleanup, backup temporary-file cleanup and key metadata lifecycle. Soft delete first; permanent delete explicit or approved expiry. Keep attachment references consistent and do not delete encrypted blobs while referenced. Never store secrets in ordinary settings. Data deletion and retention require transaction tests.
