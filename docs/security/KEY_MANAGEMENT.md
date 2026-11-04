# KEY_MANAGEMENT

No key manager exists. Intended 256-bit master key is protected by independent password-derived and recovery-key-derived wrapping paths; platform Keystore/Keychain protects device-bound material and biometric access where supported. Generate with CSPRNG; persist wrapped keys and versioned metadata only; never raw keys in preferences/logs/backups. Define setup, unlock, rotation, disable, migration, restore, biometric invalidation and loss behavior. Exact wrapping and platform flags require review.
