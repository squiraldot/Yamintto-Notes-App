# Recovery specification

Decision: **BOTH** password-based and independent recovery-key-based recovery. Neither path is implemented.

## Password path
User supplies password; Argon2id with versioned salt/parameters derives key material; reviewed wrapping design attempts to recover master-key access. Correct credential must succeed; wrong credential, corrupted metadata or tag mismatch fails without altering ciphertext. Never persist password. Exact Argon2id parameters, normalization, wrapping and verifier strategy require independent review.

## Independent recovery-key path
Generate a high-entropy recovery secret with CSPRNG; show it safely; require confirmation that user saved it; do not send to server or log. Recovery key must independently restore master-key access even if password is lost. Rotation requires existing authorization, verified new wrap and interruption-safe atomic replacement. Encoding, entropy bits, checksum and wrapping details require review.

## Recovery matrix
| Situation | Expected outcome |
|---|---|
| Password known, recovery key unavailable | Password route recovers |
| Password lost, recovery key retained | Recovery-key route recovers |
| Recovery key lost, password retained | Password route recovers |
| Device replaced, password or recovery key retained | Re-establish access and enroll new device key |
| Biometric enrollment changed | Do not bypass; use valid recovery credential and re-enroll |
| Both recovery credentials lost, no valid device/wrapped key copy | Data cannot be recovered |
| Ciphertext/metadata corrupted | Fail closed; restore from a valid encrypted backup if available |

Recovery must not silently reset encryption and discard existing notes. Test clean-device restore through each path, wrong secrets, corrupt metadata, rotation interruption and backup portability.
