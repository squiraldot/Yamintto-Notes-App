# Phase 02 architecture decision register

**Review date:** 2026-11-05  
**Baseline:** `main` at `e1c886ade7eb078049a6303ccfd2f6de72527e1b`  
**Overall status:** Decision freeze incomplete — owner approval required.  
**Implementation:** Not started.

This is the single authoritative Phase 02 decision register. Recommendations are not accepted decisions. ADR-0013 records the proposed baseline. Owner approval must be explicit.

## Status vocabulary

- **Accepted:** explicitly approved or already accepted by an applicable ADR.
- **Recommended — pending owner approval:** proposed, not approved for implementation.
- **Rejected:** considered and not selected.
- **Deferred:** belongs to a later phase or requires later-phase review.

## Decision register

| Decision | Current status | Recommendation | Reason | Owner approval required |
|---|---|---|---|---|
| Persistence technology | Accepted (ADR-0003) | Drift + SQLite | Relational local persistence, transactions and migrations | No new approval |
| Offline-first | Accepted (ADR-0002) | Core notes/folders work without network | Product architecture requirement | No new approval |
| DB initialization/ownership | Recommended | Lazy open on first repository access; memoize one app-private DB instance in an app-scoped Riverpod provider; complete migration before exposing repositories | Single lifecycle/connection owner and controlled startup failure | Yes |
| Repository/DAO boundary | Recommended | Repositories expose domain operations; DAOs internal; UI never uses SQL | Testable domain and controlled access | Yes |
| Error mapping | Recommended | Map SQLite/Drift failures to typed app/domain failures at data boundary | Safe, actionable errors | Yes |
| ID strategy | Recommended | Canonical lowercase UUID v4 TEXT for every entity | Offline generation, portability, collision resistance, no time leakage | Yes |
| Autoincrement integer IDs | Rejected | Do not use as the portable entity ID | Less suitable for offline import/backup and future merge/conflict handling | No |
| UUID v7 | Rejected for current baseline | Use UUID v4 unless future measured indexing needs justify v7 | Time leakage and added implementation requirements outweigh current benefit | No |
| Timestamp format | Recommended | UTC Unix epoch milliseconds as INTEGER | Consistent precision and portable serialization | Yes |
| Timestamp semantics | Recommended | created_at immutable; updated_at changes on content/metadata mutations incl. move/delete/restore; backup preserves both | Predictable lifecycle and statistics | Yes |
| Root representation | Recommended | NULL parent_id/folder_id; no synthetic root row | Simple nullable relationships | Yes |
| Nested folders | Recommended | Support nested hierarchy | Required behavior | Yes |
| Maximum depth | Recommended | No arbitrary cap initially; guarded cycle-safe traversal | Avoid premature product limit | Yes |
| Folder movement | Recommended | Allow; reject self/descendant; validate and update atomically | Flexible without cycles | Yes |
| Folder deletion | Recommended; blocker | Reject if any child folder or note (including soft-deleted) exists; soft-delete only empty folder; future UI confirmation; reversible by restore | Avoid recursive data loss and retain recoverability | **Yes — blocking** |
| Recursive folder deletion | Rejected | Do not delete descendants/notes implicitly | High risk of irreversible multi-record data loss | No |
| Move contents to parent/root/Trash on folder delete | Rejected for proposed baseline | Require explicit separate move operations; do not silently relocate data during delete | Avoid surprising location changes and hidden multi-record behavior | No |
| Note deletion | Recommended; blocker | Soft-delete via deleted_at from schema v1; preserve folder/order | Future restore without destructive retrofit | **Yes — blocking** |
| Trash UI | Deferred to Phase 04 | No Trash UI in Phase 02 | Phase ownership | No Phase 02 approval |
| Restore fallback | Recommended; blocker | Restore original folder/order if valid; otherwise root with explicit conflict result | Avoid inaccessible trashed note | **Yes — blocking** |
| Deleted-note access | Recommended | Exclude from active lists/default search; disallow edit/move until restored | Clear active/trash boundary | Yes |
| Permanent deletion | Recommended; blocker | Separate explicit confirmed operation; coordinate revisions/attachments; no implicit cascade | Prevent accidental irreversible loss | **Yes — blocking** |
| Separate polymorphic trash_items table | Rejected | Use nullable deleted_at on folders/notes | Avoid polymorphic references without normal FK enforcement and duplicated location state | No |
| FK CASCADE | Rejected | Use RESTRICT and explicit dependent cleanup | Prevent silent destruction of recoverable data | No |
| Folder naming/depth rules | Recommended; blocker | Non-empty trimmed names; max length, sibling duplicate/case policy and depth limit to be decided | Avoid undocumented input behavior | **Yes — blocking** |
| Schema v1 inventory | Recommended; blocker | Only folders and notes; no tags/revisions/attachments/trash_items/encryption_metadata/app_settings | Minimal phase-owned schema | **Yes — blocking** |
| Schema fields/constraints | Recommended; blocker | Follow DATABASE_SCHEMA.md | Exact nullability/defaults/checks/indexes/FKs | **Yes — blocking** |
| Foreign keys | Recommended; blocker | Enable/test every connection; ON DELETE/UPDATE RESTRICT | Prevent orphans and silent cascade loss | **Yes — blocking** |
| Transactions | Recommended; blocker | All multi-record operations and hierarchy changes atomic | No partially applied relationship changes | **Yes — blocking** |
| Ordering | Recommended | Explicit sort_order per parent/folder; append on create/move; duplicates allowed; tie-break created_at then id | Deterministic without timestamp sorting | Yes |
| Pinning | Deferred to Phase 04 | Add pin fields/indexes through Phase 04 migration | No Phase 02 pin feature | No |
| Search index | Deferred to Phase 04/06; privacy ADR-0011 accepted | Pre-encryption only if engine support verified; remove persistent plaintext index in Phase 06; unlocked transient memory only | Encryption compatibility | No Phase 02 approval |
| Revisions | Deferred to Phase 05 | Add revision table later with stable note IDs and approved retention | Avoid premature schema | No |
| Attachments | Deferred to Phase 05 | Add metadata/filesystem lifecycle later; durable staged cleanup | DB and filesystem are not one transaction | No |
| Encryption metadata | Deferred to Phase 06 | Add only with reviewed crypto envelope/key protocol | Do not invent crypto schema | No |
| Biometrics | Deferred to Phase 07 | Separate APP and VAULT authorization from CRUD | Avoid security/CRUD coupling | No |
| Backup/restore/import | Deferred to Phase 08 | Versioned portable format; preserve IDs, relations, timestamps/deleted state; inspect real YRNotes fixtures without modifying YRNotes | Compatibility and security evidence required | No |
| Settings table | Deferred to Phase 09 | Do not create in Phase 02 | Not needed for core data | No |
| Migration baseline | Recommended; blocker | Drift schemaVersion 1; immutable forward migrations; fresh + every supported prior-version tests | Reproducible safe upgrades | **Yes — blocking** |
| Destructive migrations | Recommended | Prohibit by default; data-preserving rebuilds only; Phase 06 plaintext removal requires security review | Protect user data | Yes |
| Migration failure | Recommended | Abort/rollback before commit, typed failure, fail closed; post-commit recovery uses forward correction or verified backup, not assumed downgrade | Prevent silent data loss | Yes |
| Trash retention | Pending product decision | Indefinite soft-delete until duration approved; no automatic deletion | No duration specified | **Yes — blocking for cleanup policy, not for soft-delete foundation** |
| Revision retention | Deferred to Phase 05 | Approve count/age/size before history ships | Product/storage impact | No |
| Attachment limits | Deferred to Phase 05 | Approve types/size/storage/orphan policy before attachments | Product/storage/security impact | No |
| Backup retention | Deferred to Phase 08 | Approve count/location/expiry before backup | User-owned file lifecycle | No |
| Cryptographic protocol | Deferred to Phase 06 | Independent security review; no invented nonce/AAD/KDF/wrapping values | High-impact security decision | Security review and owner approval later |

## Blocking owner decisions

Before the separate Phase 02 implementation prompt, owner must approve or revise:

1. Two-table schema v1 and its fields/constraints.
2. UUID v4 and UTC Unix-millisecond conventions.
3. Nested hierarchy, NULL root, no hard depth limit, cycle-safe moves.
4. Empty-folder-only soft deletion; no recursive delete or moving contents elsewhere.
5. Note soft deletion from v1, retained folder/order, and no Phase 02 Trash UI.
6. Restore fallback to root when original folder is unavailable.
7. Deleted-note edit/move/search rules and explicit permanent-delete semantics.
8. Ordering and duplicate sort-value tie-break.
9. FK enforcement/RESTRICT and transaction requirements.
10. Schema version 1, forward-only migration and failure policy.
11. No automatic permanent deletion; retention duration remains unset.

Owner may approve all proposals or reply with changes. Do not mark this register Accepted or begin implementation merely because it is documented.
