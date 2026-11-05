# Encryption specification

Requirements only; no encryption implementation or final cryptographic protocol exists.

Requirements: AES-256-GCM; unique nonce per encryption operation; random 256-bit master key; Argon2id password KDF; authenticated tamper rejection; no plaintext note/revision/attachment content or persistent plaintext content index after Phase 06.

## Conceptual data flow

- Master key encrypts protected note/revision/attachment payloads using independently reviewed AEAD implementation.
- Password and recovery-key paths independently protect access to master key using reviewed wrapping.
- Android Keystore/iOS Keychain provide device-bound local key protection, not the only recovery path.
- Persist only reviewed versioned ciphertext/envelope and approved non-secret metadata.

## Independent security review required

Cipher package/platform support; nonce size/encoding/uniqueness; AAD fields; tag representation; Argon2id version/parameters/salt; password normalization; recovery-key entropy/encoding; wrapping construction; envelope schema; key rotation/separation; migration journal; memory lifetime/zeroization; Keychain/Keystore access controls. Do not invent values or build custom cryptography.

## Phase 02 plaintext boundary and SQLite storage

The proposed Phase 02 `notes.body` and future Phase 05 revision snapshots may contain plaintext during beta. Field-level AES-GCM conversion does not encrypt SQLite pages or automatically remove old plaintext from the main DB, rollback journal, WAL, FTS/token indexes, caches, previews, temporary exports or backups. A Phase 06 design must account for checkpoint/close/rebuild/replace behavior, verify encrypted read-back, and audit every storage location after interruption-safe migration.

Review whether note titles, folder names and other metadata are sensitive; this document does not silently decide they may remain plaintext. Do not claim Drift, SQLite, WAL settings or a ciphertext column provides whole-database encryption. No SQLite encryption extension/page-encryption technology is selected.

## Required properties and migration

Use CSPRNG for master key, salts and recovery secret. Never reuse a nonce with the same AES-GCM key. Authenticate version/context using reviewed AAD. Reject malformed envelope, wrong key and tag mismatch without exposing partial plaintext. Stage ciphertext, verify reads, switch references atomically where possible, then remove plaintext originals/indexes/temp copies. Migration must resume/rollback safely; never delete the only readable source before verification. Search after migration is transient in-memory while unlocked and cleared on lock (ADR-0011).

## Test evidence required before security claims

Known-answer vectors; nonce strategy; tamper every authenticated field; wrong key; corrupt/truncated envelope; KDF metadata version; rotation; interrupted migration; inspect DB, FTS, WAL/journal, files, caches, temp, logs and backups for plaintext; independent security review.
