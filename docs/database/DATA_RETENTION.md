# Data retention and deletion policy — OWNER APPROVED; PHASE 02 SOFT-DELETE SOURCE IMPLEMENTED

**Architecture status:** Owner approved on 2026-11-05.  
**Runtime status:** Phase 02 note and empty-folder soft-delete repository/UI operations are implemented in source. No Trash UI, restore, permanent-delete workflow, retention timer or cleanup job is implemented.

## Lifecycle terms

| Term | Meaning | Phase |
|---|---|---:|
| Active | deleted_at IS NULL; eligible for ordinary operations | 02 |
| Soft-deleted | Row remains in its entity table with deleted_at set; original relationships/order retained | 02 |
| Trash | User-facing view/actions for deleted notes and deleted folders | 04 |
| Restore | Clear deleted_at after validating the original/fallback destination | 04 |
| Permanent deletion | Explicit irreversible removal after confirmation and dependent-data cleanup | 04; extended by 05 |
| Retention | How long soft-deleted data is retained before any eligible permanent deletion | Indefinite initially; no expiry |
| Backup retention | Lifecycle of user-created backup files; separate from Trash | 08 |

## Approved Phase 02 lifecycle

### Notes

- Deletion sets `notes.deleted_at` to UTC Unix epoch milliseconds.
- Preserve original `folder_id` and `sort_order`.
- Exclude deleted notes from active lists and default search.
- Editing or moving a deleted note requires restoration first.
- No Trash UI or permanent deletion in Phase 02.
- Phase 04 Trash must show deleted notes and support restore and explicit permanent deletion.
- Restore to original folder/order when valid. If the original folder is unavailable, restore to root and return an explicit conflict result.

### Folders

- Only empty folders may be deleted. A folder is not empty if any child folder or any note row exists, including soft-deleted notes.
- Deletion sets `folders.deleted_at`; no cascade or physical deletion.
- Retain parent, display name, canonical name key and sort order for Trash/restore.
- A soft-deleted folder cannot receive notes or children.
- Phase 04 Trash must include deleted folders and support restore and explicit permanent deletion.
- Folder restore must respect the original parent and the accepted case-insensitive sibling-name uniqueness constraint. Phase 04 owns conflict UX if the original parent is unavailable or a name conflict exists.

## Retention and permanent deletion

- Soft-deleted notes and folders are retained indefinitely initially.
- No automatic expiry, retention timer, background cleanup or silent permanent deletion is permitted.
- Permanent deletion is a separate explicit user workflow, not a side effect of folder deletion, app startup, migration or database maintenance.
- Phase 02 does not implement permanent deletion and it is not a Phase 02 implementation blocker.
- Phase 04 owns explicit permanent deletion workflows for trashed notes and folders, with confirmation and clear irreversible-action messaging.
- Phase 05 extends note permanent deletion to revision rows, attachment metadata and local file blobs. DB and filesystem cannot share an ACID transaction; Phase 05 must use durable staging/operation markers, integrity verification and crash recovery. A failed cleanup remains pending and must not be reported as complete while referenced blobs remain.
- Secure overwrite/forensic erasure on flash storage cannot be guaranteed.
- Backups are independent copies; deleting an app database record does not silently delete user-created backup copies. Phase 08 owns backup retention.

## Future retention decisions

The initial retention decision is settled: indefinite soft-delete retention and no automatic cleanup. Other limits are phase-owned and do not block Phase 02:

- Revision count/age/size: Phase 05 product decision.
- Attachment type/size/storage/orphan cleanup: Phase 05 product/security decision.
- Backup count/location/expiry: Phase 08 product decision.
- Migration staging cleanup: Phase 06/08 design.
- Any future automatic expiry would require a new explicit owner-approved policy and clear user disclosure; it is not authorized by this document.

## Encryption and lock lifecycle

Phase 06 must encrypt notes/revisions/attachments using an independently reviewed protocol and remove plaintext indexes, caches, previews, temp files and originals after verified migration. Audit SQLite WAL/rollback journals and DB pages. Search becomes transient in-memory only while unlocked and is cleared on lock. Memory zeroization guarantees require review.
