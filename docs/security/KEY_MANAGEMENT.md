# Key management lifecycle

No key manager exists. This describes required roles, not final crypto protocol.

## Key roles
- Master key: random 256-bit secret; encrypts app protected payloads. Never stored raw in DB/preferences/logs/backups.
- Password recovery path: password -> Argon2id-derived material -> independently wrapped master-key access using a reviewed construction.
- Recovery-key path: independently generated high-entropy recovery secret -> separate wrapped master-key access.
- Device-bound key: non-exportable/platform-protected local key material or reference in Android Keystore/iOS Keychain; gates local access and optional biometric use. Not the sole recovery mechanism.
- Vault key/policy: separate authorization scope for vault; exact key separation/wrapping requires review.

## Lifecycle
1. Provision: generate master key and recovery secret with CSPRNG; establish both independent recovery routes; validate each path; show recovery secret safely and require acknowledgement.
2. Unlock: validate credential path, unwrap only as needed, keep key exposure bounded, clear transient decrypted/search data on lock.
3. Credential change/rotation: authenticate with an existing route; create and verify replacement wrap; atomically commit before retiring old wrap. Interruption must preserve at least one valid route.
4. Device enrollment: establish new device-bound key after password/recovery-key authentication; biometric policy re-enrolled on new device.
5. Biometric invalidation: never bypass. Re-authenticate via password/recovery key and re-establish local protected key according to approved policy.
6. Backup/restore: backup must not contain raw master key. Recovery material must be sufficient to re-establish key access; exact portability envelope is pending security review.
7. Destruction: remove wrapped key metadata only after explicit destructive confirmation and clear app data per policy. If all recovery paths and valid key copies are lost, ciphertext is unrecoverable.

## Platform constraints
Android Keystore key exportability, hardware backing, auth-bound keys and invalidation vary by API/device/OEM; StrongBox/TEE is not universal. iOS Keychain accessibility, synchronizable/device-only semantics, passcode requirements and biometric access-control behavior vary. Secure Enclave is not guaranteed. Validate exact API flags and backup behavior against current docs and physical devices.
Open: key hierarchy/wrapping protocol, key separation, device migration, backup key envelope, rotation journal, recovery-key encoding and secure deletion semantics.
