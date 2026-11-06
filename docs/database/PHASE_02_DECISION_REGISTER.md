# Phase 02 architecture decision register

**Owner approval:** Explicitly approved by the repository owner on 2026-11-05.  
**Architecture status:** <strong>ACCEPTED — PHASE 02 DECISION FREEZE COMPLETE</strong>.  
**Implementation status:** Schema v1, Unicode 17.0 canonicalization, folder/note repositories and Phase 02 presentation source are implemented. Latest source revision `745b8f589afceb783a9b39bafcd03c123e50c395` passed Flutter CI run `42097059083` with 69/69 tests (19 Phase 02 screen widget tests); universal and ARM64 Debug APK artifacts uploaded on runs `42097260846` and `42097260894` for that same source SHA. **OWNER-REPORTED — PHASE 02 ANDROID PHYSICAL-DEVICE SMOKE TEST PASSED.** The owner explicitly confirmed successful manual testing in the current project conversation. No device model, Android version, date, command output, screenshots or logs are asserted. The separate `integration_test/phase_02_data_smoke_test.dart` source exists; its execution is not evidenced and is not claimed. **PHASE 02 — ACCEPTED.**  
**Baseline before this approval:** `main` at `9cc09c272faa9ccbb62c240113fcd89bcef046ae`.

This is the authoritative Phase 02 decision register. The owner approved the proposed architecture baseline with the amendments recorded below. No Phase 02 implementation-blocking owner decision remains unresolved. The owner separately authorized Phase 02 implementation on 2026-11-05; implementation source now includes the folder browser and plain-text notes management screens.

## Status vocabulary

- **Accepted:** approved by the owner or already accepted by an applicable ADR.
- **Rejected:** explicitly not selected for the approved baseline.
- **Deferred:** belongs to a later phase and is not a Phase 02 implementation blocker.

## Accepted decision register

| Decision | Status | Accepted decision | Rationale / implementation consequence | Owner approval required |
|---|---|---|---|---|
| Persistence technology | Accepted — ADR-0003 | Drift + SQLite | Retain the already accepted relational local database; no second database technology | No |
| Offline-first | Accepted — ADR-0002 | Core note/folder workflows work without network or mandatory backend | Preserve local-first product architecture | No |
| DB initialization/ownership | Accepted | One app-private SQLite DB; lazy-open on first repository access; memoized app-scoped Riverpod owner; finish open/migration before repositories are exposed | Single lifecycle owner and controlled failure boundary | No |
| Repository/DAO boundary | Accepted | Repositories expose domain operations; DAOs remain internal; widgets/controllers never issue SQL or receive raw DB handles | Enforceable data boundary and testability | No |
| Error mapping | Accepted | Map Drift/SQLite errors at data boundary to typed domain/application failures; fail closed for corruption/migration failures | No raw SQL/stack traces or silent empty-database fallback | No |
| IDs | Accepted | Canonical lowercase UUID v4 strings stored as SQLite TEXT for folders, notes and future entities | Offline creation, portability, stable references and collision resistance | No |
| UUID v7 / autoincrement IDs | Rejected for this baseline | Do not use UUID v7 or integer autoincrement as portable entity IDs | UUID v4 is the consistent, portable baseline; no timestamp leakage | No |
| Timestamps | Accepted | UTC Unix epoch milliseconds stored as SQLite INTEGER | Platform-independent precision and portable serialization | No |
| Timestamp semantics | Accepted | created_at immutable after creation/import; updated_at changes on successful content/metadata mutation including rename, move, soft-delete and restore; backup preserves source timestamps | Predictable lifecycle and import behavior | No |
| Legacy missing timestamps | Accepted | Use import instant for missing created_at and updated_at; never fabricate historical values | Honest legacy import semantics | No |
| Schema inventory/version | Accepted | Schema version 1 contains only `folders` and `notes` | Minimal Phase 02 scope | No |
| Root representation | Accepted | NULL `parent_id` means root folder; NULL `folder_id` means root note collection; no synthetic root row | Simple, portable hierarchy | No |
| Nested folders | Accepted | Nested folder hierarchy supported | Required product capability | No |
| Maximum folder depth | Accepted — owner amendment | Root is level 0; top-level folders are level 1; maximum folder level is 32 | Prevent pathological recursion while preserving useful nesting | No |
| Folder moves | Accepted | Moves supported; reject self/descendant cycles; validate full moved subtree depth; execute atomically | No cycles and no subtree can exceed level 32 | No |
| Folder names | Accepted — owner amendment | Trimmed non-empty names using Unicode 17.0 `White_Space` boundary trim; internal whitespace preserved; maximum 255 Unicode code points; case-insensitive unique name per parent; same name allowed in different parents | Consistent validation and predictable sibling identity | No |
| Folder-name uniqueness scope | Accepted — explicit schema interpretation | Uniqueness applies to active and soft-deleted folder rows; a name cannot be reused in that parent until the old folder is permanently deleted | Guarantees a deleted folder can be restored without a same-parent name collision | No |
| Folder name canonicalization | Accepted — implementation requirement | Unicode 17.0 NFKC_CF mapping followed by NFC; boundary trim occurs first using Unicode 17.0 `White_Space`; internal whitespace preserved; same deterministic Dart canonicalizer used by app validation and SQLite schema functions; root-aware unique expression index includes soft-deleted rows | SQLite built-in NOCASE is ASCII-only and is insufficient for full Unicode case-insensitivity | No |
| Note title | Accepted — owner amendment | Maximum 255 Unicode code points; empty title remains permitted | Bounded, consistent input contract | No |
| Folder deletion | Accepted — owner amendment | Empty-folder-only; soft-delete empty folder; reject if any child folder or any note row exists, including soft-deleted notes | Prevent recursive or hidden data loss | No |
| Note deletion | Accepted — owner amendment | Soft-delete from schema v1 using nullable deleted_at; preserve original folder_id and sort_order | Phase 04 Trash/Restore compatibility from first schema | No |
| Deleted-note behavior | Accepted | Exclude from active lists/default search; editing and moving require restore first | Clear active/trash boundary | No |
| Trash UI and lifecycle | Accepted phase boundary | Phase 04 Trash must include both deleted notes and deleted folders; support restore and explicit permanent deletion workflows | Complete user-facing lifecycle belongs to Phase 04, not Phase 02 | No Phase 02 approval |
| Note restore | Accepted — owner amendment | Restore original folder/order if valid; otherwise restore to root and return an explicit conflict result | Predictable recovery without losing note | No |
| Folder restore details | Deferred to Phase 04 | Trash includes folders; Phase 04 must define parent availability, name conflict and restore ordering UX while respecting unique sibling names | Not required to implement Phase 02 persistence safely | Phase 04 product review |
| Permanent deletion | Accepted phase boundary | No permanent-delete implementation in Phase 02. Phase 04 owns explicit note/folder permanent-delete workflow; Phase 05 extends cleanup to revisions/attachment metadata/files | Not a Phase 02 blocker; avoid premature dependent-data implementation | No Phase 02 approval |
| Retention | Accepted — owner amendment | Indefinite soft-delete retention initially; no automatic permanent deletion, expiry timer or cleanup job | Prevent silent user-data loss | No |
| Foreign keys | Accepted | Enable and verify SQLite FK enforcement on every connection; ON DELETE RESTRICT and ON UPDATE RESTRICT | Prevent orphans and implicit cascade loss | No |
| Transactions | Accepted | Multi-record operations, hierarchy/note moves and deletion state changes use transactions; failure rolls back all DB changes | Preserve relational invariants | No |
| Ordering | Accepted | Explicit integer sort_order independently scoped per parent/folder; append on create/move; duplicate values allowed; deterministic order by sort_order, created_at, id | Stable ordering without timestamp-as-order | No |
| Migration baseline | Accepted | Drift schemaVersion 1; ordered, versioned, immutable forward migrations | Reproducible upgrades | No |
| Migration failure | Accepted | Fail closed; rollback pre-commit changes; typed failure; never silently replace a failed/corrupt DB with empty DB | Protect user data | No |
| Destructive migrations | Accepted | Prohibited by default; data-preserving rebuild only; Phase 06 plaintext removal requires independent security review | Avoid accidental loss while allowing reviewed security migration | No |
| Permanent-delete dependencies | Deferred | Phase 05 must stage revision/attachment metadata and filesystem cleanup with crash recovery; DB and filesystem are not one ACID transaction | No dependent cleanup is needed in Phase 02's two-table schema | Phase 05 review |
| Search and pinning | Deferred to Phase 04 | No search/pin implementation or tables in Phase 02; Phase 06 removes persistent plaintext content indexes | Preserve phase ownership and encryption compatibility | No |
| Revisions and attachments | Deferred to Phase 05 | Add tables/storage lifecycle only in Phase 05 | Avoid premature schema surface | No |
| Encryption metadata/protocol | Deferred to Phase 06 | Independent security review; no invented nonce/AAD/KDF/wrapping parameters | High-impact security boundary | Phase 06 review |
| Biometrics | Deferred to Phase 07 | APP and VAULT scopes remain separate from CRUD | Avoid auth/data-layer coupling | Phase 07 review |
| Backup/restore/import | Deferred to Phase 08 | Versioned portable format; preserve IDs/relationships/timestamps/deleted state; inspect real legacy fixtures without modifying YRNotes | Compatibility and security evidence | Phase 08 review |
| Settings | Deferred to Phase 09 | No settings table in Phase 02 | Settings are not needed for note/folder foundation | No |

## Folder depth and name enforcement contract

- The virtual root is level 0. A folder whose `parent_id IS NULL` is level 1. The deepest permitted folder is level 32.
- Creating a folder requires `parent_level + 1 <= 32`.
- Moving a folder requires checking every descendant: `destination_parent_level + 1 + subtree_height <= 32`. Reject self/descendant moves and any move exceeding the cap before mutation; perform validation and update in one transaction.
- Count folder names by Unicode code points after trimming; do not use UTF-16 code-unit length as the character count.
- Canonical comparison key is Unicode 17.0 NFKC_Casefold after Unicode 17.0 `White_Space` boundary trim. Trim first; preserve internal whitespace; apply official NFKC_CF mappings then NFC. The application validator and SQLite constraint call the same generated/bundled deterministic Dart implementation. No platform ICU, lowercase approximation or NOCASE fallback.
- The database unique index must normalize NULL parent to a non-colliding root scope and must cover deleted rows as well as active rows. Root-level duplicates are prohibited too.
- Because deleted folders retain their unique key, a same-parent name cannot be reused until the old folder is permanently deleted in Phase 04.

## Phase boundaries

- **Phase 02:** implement approved schema v1, notes/folder CRUD, hierarchy validation and soft-delete foundation only. No Trash UI or physical permanent deletion.
- **Phase 04:** Trash for deleted notes and folders; restore and explicit permanent deletion workflows; search and pinning.
- **Phase 05:** revisions, attachment storage and dependent-data/file cleanup.
- **Phase 06:** reviewed encryption/key migration, including DB pages, WAL/journals, indexes, caches, temp files, exports and backups.
- **Phase 07:** separate app/vault biometric authorization.
- **Phase 08:** backup, restore and legacy import.
- **Phase 09:** persisted settings.

## Freeze result

**All Phase 02 implementation-blocking architecture and product decisions are resolved and owner-approved. Phase 02 architecture decision freeze is COMPLETE.**

No additional owner approval is required for the accepted Phase 02 architecture. The owner explicitly authorized implementation on 2026-11-05. Future-phase product/security approvals remain in their owning phases and do not block Phase 02.


## Superseding owner decision — 2026-11-06

The original schema-v1 architecture freeze remains historical, but the owner has selected **REPAIR** for the omitted note-tags and folder-colors requirements. Therefore Phase 02 implementation acceptance is **REOPENED — REPAIR REQUIRED**. Earlier text in this register stating that all implementation-blocking decisions are resolved or that Phase 02 is accepted is superseded for phase progression.

| Area | Owner decision | Required consequence |
|---|---|---|
| Workflows | Retain three | Preserve the existing Flutter CI, universal Debug APK and ARM64 Debug APK workflows. No consolidation/deletion/rename/disablement/addition without new explicit authorization. |
| Note tags | Repair in Phase 02 | Support multiple reusable tags per note and persistent assignments. Derive detailed normalization/duplicate/deletion/order semantics from the original Phase 02 prompt; document any unresolved choice before coding. |
| Folder colors | Repair in Phase 02 | Persist an optional validated folder color and display it consistently, including nested folders. Define palette/serialization/fallback/contrast before coding. |
| Schema v1 | Immutable baseline | Preserve existing v1; use only a forward-only, data-preserving migration for the repair. |
| Markdown | Hybrid in Phase 03 | Modern Markdown baseline plus explicitly verified legacy YRNotes syntax and safe rendering. |
| Phase progression | Phase 03 blocked | Close Phase 02 repair with tests, three exact-SHA workflows, owner physical-device retest, docs and explicit acceptance before Phase 03 authorization. |

Historical CI/APK/device evidence validates only the prior folders/notes baseline; it does not cover tags or folder colors.


## Superseding repair decisions and implementation result — 2026-11-06

The owner reopened Phase 02 for Note Tags and Folder Colors. Historical v1-only implementation freeze and earlier ACCEPTED wording do not represent current acceptance. Schema v1 is retained unchanged; schema v2 is implemented.

| Decision | Implemented contract |
|---|---|
| Tag name | Unicode 17.0 boundary trim; preserve internal whitespace/display spelling; reject empty, NUL and >64 code points |
| Tag identity/duplicates | UUID v4; app-global unique key using Unicode NFKC_Casefold + NFC; duplicate create/rename rejected |
| Tag ordering | `name_key`, display name, ID ascending |
| Tag rename | Preserve ID and all assignments |
| Tag delete | Confirmation; transaction deletes note-tag junction rows then tag |
| Note soft-delete | Keep tag links; reject assignment changes while note is soft-deleted |
| Assignment | Multiple tags per note; one tag shared by many notes; transaction validates full requested set before replacement; no note timestamp/content changes |
| Folder color | Nullable ARGB INTEGER restricted to ten opaque palette values; NULL is default |
| Color UI | Select at create/edit and from folder actions; root/nested display; theme primary fallback; contrast-aware swatch foreground |
| Color metadata | Color changes do not modify ID/name/parent/sort order/timestamps |
| Migration | Immutable schema v1 → transactional additive schema v2; fail closed and rollback DDL on migration failure |

The original November 5 Phase 02 authorization excluded tags and folder colors; it did not establish detailed semantics for them. The November 6 repair authorization supplies the required capabilities. The choices above are the smallest predictable offline-first semantics selected where the repair prompt did not specify exact limits or ordering.

**Implementation evidence:** source SHA `fa8f4ad469786a6a7199360a3d6813d22fac75e6`; Flutter CI run `42177776797`; 85/85 tests passed.


### Exact-SHA Android Debug APK evidence

Both protected APK workflows succeeded on repair source SHA `fa8f4ad469786a6a7199360a3d6813d22fac75e6`:

| Workflow | Run | Artifact | Artifact ID | Archive bytes | SHA-256 |
|---|---:|---|---:|---:|---|
| Universal Debug APK | `42177872597` | `yamintto-debug-fa8f4ad469786a6a7199360a3d6813d22fac75e6` | `13483409802` | 80,077,640 | `ec417ad611bbdbc64ffa402af433cfc96cb70958871aee56b5a70192626c34e2` |
| ARM64 Debug APK | `42177872567` | `yamintto-arm64-debug-fa8f4ad469786a6a7199360a3d6813d22fac75e6` | `13484082037` | 51,786,455 | `f53c2e1caadd41b52dfaf3a657ad0bf95ad82bf36be6a51a532f16c680308837` |

Sizes are GitHub artifact ZIP archive sizes, not extracted APK sizes. Both artifacts were uploaded successfully and were unexpired when inspected; their recorded expiry is 2026-11-20.


Owner physical-device acceptance for tags/colors: **OWNER-REPORTED PASS**. Phase 02 is **ACCEPTED**; Phase 03 remains not started and unauthorized.


## Final Phase 02 owner acceptance — 2026-11-06

The owner explicitly confirmed successful physical-device testing of the repaired application and reported that everything works as expected. Therefore the remaining device-acceptance gate for the Note Tags + Folder Colors repair is closed.

**Phase 02 — ACCEPTED.** Evidence remains scoped as follows: repair source `fa8f4ad469786a6a7199360a3d6813d22fac75e6`; Flutter CI run `42177776797` passed with 85/85 tests; universal Debug APK run `42177872597` and ARM64 Debug APK run `42177872567` both succeeded; owner physical-device testing is **owner-reported PASS**. No device model, OS version, screenshots, test logs, or exact test command are asserted. The integration-test source's execution is not independently evidenced and is not claimed.

This final owner confirmation supersedes the earlier “Owner device acceptance ... remains pending” statement above. **Phase 03 remains NOT STARTED and NOT AUTHORIZED**; separate explicit owner authorization is required.
