# RECOVERY_SPECIFICATION

Approved BOTH: password-based recovery and independent recovery-key-based recovery. Password path uses Argon2id with versioned salt/parameters and reviewed key wrapping. Recovery key must be high entropy, CSPRNG generated, shown safely, confirmed saved, versioned and rotatable. Wrong secret fails without corrupting data. Lost password with recovery key retained, or lost recovery key with password retained, should still permit recovery. If both are lost and no valid key copy remains, data cannot be recovered. No implementation yet.
