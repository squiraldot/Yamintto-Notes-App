# Threat model

## Assets and trust boundaries
Assets: note titles/bodies/revisions, attachments, metadata, master key, password/recovery secret, wrapped keys, search results/index, backups and migration staging. Boundaries: Dart process/memory, SQLite/filesystem, Android Keystore, iOS Keychain, document providers, backup archive parser and OS UI.

## Threats and mitigations
| Threat | Mitigation / evidence |
|---|---|
| Device theft or DB/file extraction | Phase 06 authenticated encryption; inspect DB/files/index/temp/backups |
| Backup theft | Encrypted/versioned backup; no raw master key; clean-device recovery tests |
| Guessing/weak password | Reviewed Argon2id parameters; rate/UX policy; do not invent parameters |
| Nonce reuse/weak randomness | CSPRNG and reviewed unique nonce strategy; tests/review |
| Ciphertext or metadata tampering | AEAD authentication; fail closed; tamper vectors |
| Biometric invalidation/enrollment change | Separate app/vault policy; never bypass; recovery route and physical-device tests |
| Plaintext temp/cache/log leakage | Stage safely, clear search memory on lock, redact logs, storage scans |
| ZIP traversal/decompression bomb | Strict parser, path normalization, limits, reject unsupported entries |
| Migration/restore interruption | Journal/staging, transactions, idempotent recovery, fault injection |
| Malicious/rooted or compromised unlocked device | Minimize key/plaintext lifetime; acknowledge residual OS compromise risk |
| Lost credentials and key copies | Both independent recovery paths; explicit unrecoverable state if all are lost |

## Residual risks
Compromised unlocked OS/process, screen capture, malicious accessibility/keyboard services, memory snapshots, coercion, hardware/vendor flaws, lost all keys, and forensic remnants on flash storage. Secure overwrite cannot be guaranteed. No claim of absolute security or recoverability is permitted.
