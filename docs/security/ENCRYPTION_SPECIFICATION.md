# Encryption specification

Requirements: AES-256-GCM; unique nonce per encryption operation; random 256-bit master key; Argon2id password KDF; authenticated tamper rejection; no plaintext note/attachment persistence or persistent plaintext content index after Phase 06.

## Conceptual data flow
- Master key encrypts protected note/revision/attachment payloads using the approved AEAD implementation.
- Password and recovery-key paths independently protect access to the master key using a reviewed wrapping design.
- Device-bound key storage protects local access according to platform capabilities; it does not replace independent recovery.
- Store only versioned ciphertext/envelope and non-secret metadata. Plaintext exists in memory only while required for unlocked operation.

## Decisions requiring independent security review
Cipher package and supported platforms; nonce size/encoding and uniqueness strategy; AAD fields; tag representation; Argon2id version/memory/time/parallelism/salt size; password normalization; recovery-key entropy/encoding; key wrapping construction; envelope/version schema; master-key rotation; key separation; crash-safe migration journal; memory lifetime/zeroization limits; platform Keychain/Keystore access controls. No final values or wrapping protocol are approved here.

## Required properties
Use CSPRNG for master key, salts and recovery secret. Never reuse a nonce with the same AES-GCM key. Authenticate version/context through reviewed AAD design. Reject malformed envelope, wrong key and tag mismatch without exposing partial plaintext. Avoid plaintext temp files and logging. Validate package APIs and current platform docs before implementation; do not roll custom cryptography.

## Migration and search
Phase 06 encrypts pre-existing note bodies/revisions and Phase 05 attachments. It also removes plaintext full-text/token indexes, cached snippets, temp exports and previews. Verify reads from encrypted form before deleting original; stage and journal migration; interrupted migration must be resumable/rollback-safe. Search after migration is unlocked-only transient memory, not persisted plaintext index. No encrypted-search scheme is authorized.

## Test evidence
Known-answer vectors from selected implementation; nonce generation/uniqueness strategy; tamper every authenticated field; wrong key; corrupt/truncated envelope; KDF parameter version; rotation; interrupted migration; inspect SQLite, FTS, files, caches, temp, logs and backup for plaintext; independent review before security claims.
