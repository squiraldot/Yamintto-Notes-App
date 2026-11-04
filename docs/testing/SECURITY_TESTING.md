# Security testing and evidence

Security tests do not replace independent review. Do not publish security claims until protocol, dependencies, parameters and native storage behavior are reviewed.

| Test group | Required cases | Evidence |
|---|---|---|
| AEAD | Selected library known-answer vectors; wrong key; corrupt nonce/tag/AAD/ciphertext; truncated envelope | test vectors and fail-closed result |
| Nonce/randomness | CSPRNG source and approved unique nonce strategy; high-volume collision/strategy tests as appropriate | reviewed design + test results; no invented parameters |
| KDF/wrapping | Argon2id known-answer tests, parameter/version migration, wrong password/recovery key, interrupted rotation | exact reviewed parameter/version record |
| At-rest leakage | scan SQLite rows, FTS/token indexes, files, thumbnails/previews, temp, cache, logs, crash reports and backups | automated scan proving no plaintext note/attachment/index after Phase 06 |
| Search | pre-06 index migration, no persistent plaintext index post-06, locked search blocked, unlock index transient, lock clears it | migration test and memory lifecycle evidence |
| Key lifecycle | master key never raw-persisted; password/recovery paths independent; device key migration/invalidation | storage inspection and recovery tests |
| Biometrics | app/vault separation, cancellation, fallback, lockout, enrollment change, passcode removal and reinstall | Android/iOS physical-device logs without secrets |
| Attachments | Phase 05 path/URI/size handling; Phase 06 ciphertext-only storage, tamper and interrupted migration | filesystem scan, rollback and round-trip |
| Backup/ZIP | authenticated archive, traversal, symlink/path normalization, decompression bomb, duplicate entries, oversized/corrupt archives | hostile fixtures and restore rollback |
| Logging | note text, keys, passwords, recovery secrets, attachment bytes absent | log redaction test and manual review |

Never log secrets or real user content in test failures. Keep synthetic fixtures only. A green CI run is not an independent security review.
