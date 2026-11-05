# Threat model

## Assets and trust boundaries

Assets: note titles/bodies/revisions, folder metadata, attachments, master key, password/recovery secret, wrapped keys, search results/index, backups and migration staging. Boundaries: Dart process/memory, SQLite/filesystem, Android Keystore, iOS Keychain, document providers, archive parser and OS UI.

## Threats and mitigations

| Threat | Mitigation / evidence |
|---|---|
| Device theft or DB/file extraction | Phase 06 authenticated encryption; inspect DB/files/index/temp/backups |
| Backup theft | Encrypted/versioned backup; no raw master key; clean-device recovery tests |
| Guessing/weak password | Reviewed Argon2id parameters; do not invent parameters |
| Nonce reuse/weak randomness | CSPRNG and reviewed unique nonce strategy; tests/review |
| Ciphertext or metadata tampering | AEAD authentication; fail closed; tamper vectors |
| Biometric invalidation/enrollment change | Separate app/vault policy; never bypass; recovery route and physical-device tests |
| Plaintext temp/cache/log leakage | Redact logs, clear search memory on lock, storage scans; include SQLite main DB pages, rollback journal/WAL, FTS, temp exports and backups in Phase 06 verification |
| ZIP traversal/decompression bomb | Strict parser, path normalization, limits, reject unsupported entries |
| Migration/restore interruption | Journal/staging, transactions, idempotent recovery, fault injection |
| Malicious/rooted or compromised unlocked device | Minimize key/plaintext lifetime; acknowledge residual OS compromise risk |
| Lost credentials and key copies | Both independent recovery paths; document unrecoverable state if all are lost |

## Residual risks

Compromised unlocked OS/process, screen capture, malicious accessibility/keyboard services, memory snapshots, coercion, hardware/vendor flaws, loss of all keys, and forensic remnants on flash storage. Secure overwrite cannot be guaranteed. No claim of absolute security or recoverability is permitted.
