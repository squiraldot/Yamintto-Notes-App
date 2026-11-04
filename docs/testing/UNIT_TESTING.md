# Unit testing matrix

Use deterministic fixtures, injected clocks/randomness only in tests, repository fakes and in-memory Drift where practical. Production randomness must remain CSPRNG-backed.

| Component | Required cases | Failure/data-safety assertions |
|---|---|---|
| Database schema/DAO | insert/update/delete, FK, uniqueness, index, nullability | constraint errors mapped; no partial transaction |
| Migrations | fresh schema, every supported upgrade, unknown future version | interruption/rollback; preserve rows and relationships |
| Folder domain | cycle prevention, move, rename, empty/non-empty delete policy | reject invalid parent; no orphaned notes |
| Notes repository | CRUD, sorting, folder refs, validation | concurrent update conflict handled; persistence mapping correct |
| Markdown | supported syntax, serialization round-trip, malformed input | unsafe constructs handled according to policy |
| Autosave | overlapping writes, debounce, cancellation, stale completion | older save never overwrites latest edit |
| Search | normalization, matching, ranking, empty query, updates | trashed filtering; Phase 06 index removal and no persisted plaintext |
| Trash/history | restore, conflict, revision ordering, retention | permanent delete consistency; restore creates new revision |
| Attachments | MIME spoof, size boundary, duplicate names, path traversal, URI failures | no orphan/partial file; Phase 05 plaintext explicitly expected; Phase 06 ciphertext only |
| Crypto | selected library known-answer vectors, wrong key, tamper each field | fail closed; nonce strategy and envelope version validated |
| KDF/wrapping | Argon2id vectors, parameter version, wrong password/recovery key, rotation | neither credential stored; interruption preserves valid path |
| Backup/ZIP | manifest/version, malformed/oversized/truncated, duplicate entries | no path traversal/decompression bomb; rollback preserves live data |
| Statistics/settings | timezone boundaries, counts, preference validation/migration | deterministic values and safe defaults |

Test production code through interfaces; never weaken security for deterministic tests. Record selected library/version and exact vectors only after security review.
