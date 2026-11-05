# Data retention and deletion policy — NOT IMPLEMENTED

**Status: Retention durations and cleanup policy pending owner approval.** No Trash UI, automatic cleanup, permanent-deletion job, attachment cleanup or retention timer exists.

## Lifecycle terms

| Term | Meaning | Phase |
|---|---|---:|
| Active | deleted_at IS NULL; eligible for ordinary operations | 02 |
| Soft-deleted | Row retained with deleted_at set; relationships/data preserved | 02 foundation |
| Trash | User-facing view/actions over soft-deleted notes/folders; no separate Phase 02 table | 04 |
| Restore | Clear deleted_at after validating destination | 04 |
| Permanent deletion | Explicit physical removal after confirmation and dependent-data cleanup | 04 UI / 05 dependencies |
| Retention expiry | Eligibility rule for permanent deletion; no duration approved | Deferred |
| Backup retention | User backup file lifecycle, separate from DB Trash | 08 |

## Phase 02 proposal

### Notes
Deletion sets notes.deleted_at to UTC Unix milliseconds. Preserve folder_id and sort_order. Exclude deleted notes from normal lists, active counts and default search; do not allow editing/moving until restored. Do not create trash_items or Trash UI in Phase 02. Restore original folder/order when valid. If original folder is missing/deleted, recommended fallback is root with an explicit conflict result; owner approval required.

### Folders
Recommended: deletion only if no child folder and no note row exists, including soft-deleted notes. Set folders.deleted_at; never cascade. Retain parent/name/order. Deleted folders cannot receive notes/children. Phase 04 may expose restore in Trash. Empty-only deletion avoids recursively restoring a subtree.

## Permanent deletion

Permanent deletion is not soft deletion. It requires a future explicit user action and confirmation. No retention timer/background job may silently erase user data. Use RESTRICT foreign keys and explicit domain operations, not implicit cascades. Future revisions and attachment metadata must be handled before deleting a note. Filesystem blobs cannot be deleted atomically with SQLite; Phase 05 must create durable staged cleanup/operation markers and crash recovery. A failed cleanup remains pending; do not report completion while referenced blobs remain. Remove dependent rows/blobs only after approved cleanup. Secure overwrite/forensic erasure on flash storage cannot be guaranteed.

## Retention decisions still open

No duration, count, size or schedule is invented. Owner approval is required for Trash expiry and behavior at expiry; manual-only vs future automatic permanent deletion; revision count/age/size (05); attachment size/type/storage and orphan cleanup (05); backup count/location/expiry (08); migration staging cleanup (06/08); special-case retention. Until approved, proposed safe default is indefinite soft-delete retention and no automatic permanent deletion; this is not configured runtime behavior.

## Encryption and lock lifecycle

Phase 06 must encrypt notes/revisions/attachments using an independently reviewed protocol and remove plaintext indexes, caches, previews, temp files and originals after verified migration. Audit SQLite WAL/rollback journals and DB pages. Search becomes transient in-memory only while unlocked and is cleared on lock. Memory zeroization guarantees require review.
