# Security overview and review register

## Approved requirements (not implemented)
- AES-256-GCM authenticated encryption for note content, revisions and attachment bytes.
- Fresh unique nonce for every encryption operation; random 256-bit master key.
- Argon2id password-based key derivation.
- Android Keystore and iOS Keychain integration; secure key wrapping.
- **Both** password-based and independent recovery-key-based recovery.
- **Both** app-level biometric lock and separate vault biometric lock.
- No plaintext note/attachment content or persistent plaintext full-text index after Phase 06 migration. No secrets in source, logs or ordinary preferences.
No key manager, cipher, recovery flow, biometric integration, attachment or backup feature exists in current source.

## Key hierarchy responsibilities (conceptual only)
1. Generate a random 256-bit master key using an approved CSPRNG.
2. Password path: Argon2id derives key material from password + salt + reviewed parameters; reviewed wrapping construction protects a copy/reference of the master key.
3. Recovery-key path: independently generated high-entropy recovery secret protects a separate recovery route to the same master key. Either credential should work without the other.
4. Device-bound protection: Android Keystore/iOS Keychain stores or gates device-specific key material/access. It supports local convenience/biometric policy; it is not the only cross-device recovery route.
5. Vault lock: separately scoped authorization/key material; app lock alone must not unlock vault.
These are responsibilities, not a cryptographic protocol. Do not invent the wrapping primitive, envelope format, AAD, nonce encoding, KDF parameters or native access-control flags.

## Password/recovery lifecycle
Setup: generate master key; create password and recovery-key protection paths; verify both unlock independently; safely display recovery key once and require user confirmation of backup. Unlock: authenticate through chosen path, validate integrity, then expose key only to bounded operation scope. Change password/recovery key: authorize using existing valid path, create replacement wrapped record, verify, then retire old record atomically. Rotation interruption must leave at least one valid route. Do not store plaintext password/recovery key. If both credentials and all valid wrapped/device copies are lost, data is unrecoverable.

## Android Keystore considerations
Use non-exportable key material where API supports; review key purpose, authentication-bound access, invalidation, backup/restore exclusion, hardware-backed availability and API-level differences. Do not promise StrongBox/TEE on all devices. Biometric enrollment changes may invalidate auth-bound keys. Define device-credential fallback separately. Validate real OEM/device behavior.

## iOS Keychain considerations
Review Keychain accessibility class, access-control flags, passcode requirement, biometric set invalidation, synchronizable/device-only behavior, backup migration and Secure Enclave availability. Secure Enclave is not universally available for every key operation; do not promise it. Keychain item accessibility and biometric invalidation must match approved threat model and migration needs.

## App lock vs vault lock
App lock controls entry to Yamintto UI and may protect local app access; it is not encryption by itself. Vault lock is a separate authorization boundary for vault key/content. Unlocking app must not implicitly unlock vault. Define separate timeouts, fallback, relock and recovery policies. Biometric API success alone is not proof that a particular data key is protected correctly.

## Attachments and backup
Phase 05 attachment files are local but unencrypted; this is temporary beta behavior, not production-ready. Phase 06 must encrypt existing and future attachments and remove plaintext originals, staging/previews/temp copies after verified migration. Phase 08 backups must be encrypted, authenticated, versioned and exclude plaintext content/raw master keys. Device migration must use password or recovery key to re-establish key access; biometric-bound device keys are re-enrolled on new device.

## Threats and residual risks
Threats: device theft, DB/file extraction, backup theft, malware/root/jailbreak, unlocked-device access, credential guessing, weak randomness/KDF, nonce reuse, tampering, biometric invalidation, plaintext temp/cache/log leakage, ZIP traversal/decompression bombs, migration interruption and key loss. Mitigations: reviewed AEAD/KDF/wrapping, secure platform storage, strict parser, transaction/journal, secret redaction, storage scans and physical-device tests.
Residual risks: compromised unlocked OS/process, screen capture, malicious accessibility/keyboard services, memory snapshots, coercion, lost credentials/key copies, hardware/vendor vulnerabilities and flash-storage forensic remnants. Secure overwrite cannot be guaranteed.
