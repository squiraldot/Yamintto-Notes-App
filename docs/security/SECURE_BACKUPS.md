# Secure backups and device migration

No backup format or implementation exists.

Phase 08 backup must be versioned, encrypted, integrity/authentication checked and a consistent snapshot. Never include plaintext note/attachment content or raw master key. Manifest must identify format/schema/envelope versions and required non-secret metadata. Exact archive/envelope/key portability is pending security review; do not invent it.

Restore validates archive structure, versions, integrity and available recovery path before mutating live data. Stage in app-private temporary area; use transaction/swap and rollback so a corrupt/interrupted restore leaves original data usable. Reject traversal, symlinks where applicable, duplicate/conflicting entries, decompression bombs, oversized entries and unknown required versions.

Device migration: biometric/device-bound keys are device-specific and should not be assumed transferable. User must use password or independent recovery key to re-establish master-key access and enroll new device keys. Backup must not make the biometric key the only recovery route.
Legacy YRNotes ZIP format is unknown. Inspect old source and real golden fixtures before implementation; keep YRNotes untouched. Do not claim compatibility based on ZIP extension or guessed structure.
Tests: round-trip; tamper/corrupt/truncated; unknown versions; oversized archive; interrupted export/restore; clean device; wrong/lost credentials; cross-platform portability; legacy golden fixtures.
