# SECURITY_TESTING

Before security claims: AES-GCM/Argon2id known-answer vectors; nonce strategy; ciphertext/nonce/tag/AAD tamper rejection; wrong credentials and corrupted metadata; rotation interruption; inspect DB/files/temp/backups/logs for plaintext/secrets; biometric invalidation/lockout/fallback; ZIP traversal, decompression bombs, malformed entries, duplicate names and unknown versions; restore rollback. Independent security review required.
