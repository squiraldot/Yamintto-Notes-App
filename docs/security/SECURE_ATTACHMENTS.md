# Secure attachments and phase boundary

No attachment feature exists.

## Phase 05 — local lifecycle only
Import using Android SAF/content URI or iOS document picker. Validate size/type/name; copy to app-private storage; persist opaque reference and metadata; associate atomically; support open/export/remove; cleanup orphaned files. Do not trust supplied filename/path. **Bytes are unencrypted in Phase 05. This is temporary beta-stage storage and is not production-ready.** Avoid claiming confidentiality or shipping a production release with unencrypted attachments.

## Phase 06 — encryption and migration
Encrypt future attachment bytes and migrate all Phase 05 files. Stage ciphertext, verify authenticated read, atomically switch references, then remove plaintext originals, staging files, previews, temp exports and caches. Interruption must resume/rollback safely; do not mark migration complete if plaintext remains. Nonce/envelope details are defined only after security review.

## Metadata
Keep only approved metadata: opaque ID, note ID, display name, media type, byte size, timestamps and encrypted blob reference/envelope version after Phase 06. Metadata sensitivity must be reviewed; do not include note text or secrets.

## Tests
Phase 05: MIME/type spoofing, size boundary, duplicate names, path traversal, content URI permissions, cancellation, storage full, interrupted copy, note deletion, orphan cleanup, export/open and app restart.
Phase 06: encryption vectors, tamper, migration interruption, plaintext scan of file store/temp/cache/preview/log/backup, rollback, storage exhaustion and cross-platform round-trip.
