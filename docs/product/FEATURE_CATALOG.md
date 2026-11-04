# Feature catalog

Every feature below describes target behavior. Status reflects the audited baseline, not the desired future implementation.

## Notes
- **Purpose:** Capture and manage personal notes.
- **User-facing behavior:** Create, view, edit, and delete notes; preserve title/body and folder relationship.
- **Expected data:** Title, body, folder ID, timestamps, pin/trash state.
- **Dependencies:** Phase 02 database, repository, folder model.
- **Acceptance criteria:** CRUD round-trip; validation; ordering; persistence after restart.
- **Testing requirements:** Unit repository/domain; widget list/detail/editor; integration persistence.
- **Platform considerations:** Android/iOS shared behavior.
- **Implementation phase:** 02
- **Current status:** **Planned / Not implemented**

## Folders
- **Purpose:** Organize notes into a navigable hierarchy.
- **User-facing behavior:** Create, rename, move and delete folders under approved child-note policy.
- **Expected data:** Folder ID, name, parent ID, timestamps, sort order.
- **Dependencies:** Phase 02 database and navigation.
- **Acceptance criteria:** Prevent cycles; preserve/reassign notes safely; maintain references.
- **Testing requirements:** Unit hierarchy; widget navigation/dialogs; integration transactions.
- **Platform considerations:** Shared; IDs must not depend on filesystem paths.
- **Implementation phase:** 02
- **Current status:** **Planned / Not implemented**

## Markdown
- **Purpose:** Write structured notes using Markdown.
- **User-facing behavior:** Edit source and view rendered content.
- **Expected data:** Markdown source and renderer/format version.
- **Dependencies:** Phase 03 notes repository and approved renderer.
- **Acceptance criteria:** Document supported syntax; preserve source round-trip; safely handle unsafe content.
- **Testing requirements:** Unit parser/serializer; widget editor/preview; integration round-trip.
- **Platform considerations:** Shared renderer; test text selection/typography on both.
- **Implementation phase:** 03
- **Current status:** **Planned / Not implemented**

## Autosave
- **Purpose:** Prevent loss of in-progress edits.
- **User-facing behavior:** Save edits automatically and show save/error state.
- **Expected data:** Note ID, dirty revision, save timestamp, pending status.
- **Dependencies:** Phase 03 editor state and repository transactions.
- **Acceptance criteria:** No stale write overwrites newer text; debounce/flush policy; lifecycle persistence.
- **Testing requirements:** Unit race/order; widget status; integration rapid edits/restart.
- **Platform considerations:** Lifecycle behavior differs; validate Android/iOS.
- **Implementation phase:** 03
- **Current status:** **Planned / Not implemented**

## Search
- **Purpose:** Find relevant notes quickly while offline.
- **User-facing behavior:** Search approved fields/content and present matching notes.
- **Expected data:** Query, normalized tokens/index, note references.
- **Dependencies:** Phase 04 notes data and indexes.
- **Acceptance criteria:** Correct results; stable empty/no-match; trashed notes excluded by default.
- **Testing requirements:** Unit matching/ranking; widget results; integration index updates.
- **Platform considerations:** Offline on both platforms.
- **Implementation phase:** 04
- **Current status:** **Planned / Not implemented**

## Pinned notes
- **Purpose:** Keep important notes easy to reach.
- **User-facing behavior:** Pin/unpin notes and display deterministic pinned ordering.
- **Expected data:** Note ID, pinned flag, pin timestamp/order.
- **Dependencies:** Phase 04 notes CRUD and list sorting.
- **Acceptance criteria:** Pin state persists; ordering deterministic; trash behavior defined.
- **Testing requirements:** Unit ordering; widget control; integration restart.
- **Platform considerations:** Shared.
- **Implementation phase:** 04
- **Current status:** **Planned / Not implemented**

## Trash
- **Purpose:** Protect against accidental deletion.
- **User-facing behavior:** Soft-delete and restore notes/folders; offer explicit permanent deletion.
- **Expected data:** Entity ID/type, deletion time, original parent/order, expiry policy.
- **Dependencies:** Phase 04 transactions and retention policy.
- **Acceptance criteria:** Restore valid location; permanent delete explicit; related records consistent.
- **Testing requirements:** Unit lifecycle; widget trash/restore/confirm; integration restore/cascade.
- **Platform considerations:** Shared.
- **Implementation phase:** 04
- **Current status:** **Planned / Not implemented**

## History
- **Purpose:** Recover earlier versions of notes.
- **User-facing behavior:** Browse revisions and restore a prior version.
- **Expected data:** Revision ID, note ID, encrypted snapshot/reference, timestamp.
- **Dependencies:** Phase 05 notes and retention.
- **Acceptance criteria:** Restore creates a new current revision; retention bounded by approved policy.
- **Testing requirements:** Unit ordering; widget history; integration restore.
- **Platform considerations:** Shared.
- **Implementation phase:** 05
- **Current status:** **Planned / Not implemented**

## Attachments
- **Purpose:** Keep files alongside related notes.
- **User-facing behavior:** Import, view/open, export and remove note attachments.
- **Expected data:** Attachment ID, note ID, metadata, size, encrypted blob reference.
- **Dependencies:** Phase 05 file storage and security design.
- **Acceptance criteria:** Type/size validation; encrypted-at-rest; no orphan blobs; safe lifecycle.
- **Testing requirements:** Unit validation/storage; widget attachment states; integration round-trip/deletion.
- **Platform considerations:** Platform pickers via adapters; scoped storage/document providers.
- **Implementation phase:** 05
- **Current status:** **Planned / Not implemented**

## Encryption
- **Purpose:** Protect persisted note data confidentiality and integrity.
- **User-facing behavior:** Enable encryption and transparently read/write encrypted content.
- **Expected data:** Ciphertext, nonce, authentication tag, envelope/version metadata.
- **Dependencies:** Phase 06 reviewed crypto package/protocol and key manager.
- **Acceptance criteria:** AES-256-GCM; unique nonce; 256-bit random master key; tamper fails closed; no plaintext persistence.
- **Testing requirements:** Unit vectors/tamper/nonce; integration at-rest inspection; security review.
- **Platform considerations:** Validate Dart/native package behavior on both OSes.
- **Implementation phase:** 06
- **Current status:** **Planned / Not implemented**

## Password recovery
- **Purpose:** Provide one recovery route for the encrypted master key.
- **User-facing behavior:** Use password-derived key wrapping to regain access.
- **Expected data:** Argon2id salt/parameters, wrapped key, verifier/version metadata.
- **Dependencies:** Phase 06 KDF and approved wrapping design.
- **Acceptance criteria:** Correct password recovers; wrong password fails safely; parameters versioned.
- **Testing requirements:** Unit KDF/wrong password; widget recovery; integration clean install.
- **Platform considerations:** Validate KDF performance/package on both platforms.
- **Implementation phase:** 06
- **Current status:** **Planned / Not implemented**

## Recovery key
- **Purpose:** Provide independent recovery if password is unavailable.
- **User-facing behavior:** Generate and securely display a recovery secret; confirm saving and support rotation.
- **Expected data:** Random recovery secret, wrapped key, version/rotation metadata.
- **Dependencies:** Phase 06 secure random and key wrapping.
- **Acceptance criteria:** High entropy; one-time reveal; confirmation; rotation safe; loss limitations explicit.
- **Testing requirements:** Unit format/rotation; widget reveal/confirm; integration recovery.
- **Platform considerations:** Clipboard/screenshot exposure reviewed per platform.
- **Implementation phase:** 06
- **Current status:** **Planned / Not implemented**

## App biometric lock
- **Purpose:** Restrict opening Yamintto using device biometrics.
- **User-facing behavior:** Lock/unlock app with documented fallback and timeout.
- **Expected data:** Lock preference, auth policy, platform-protected key references.
- **Dependencies:** Phase 07 native biometric APIs and secure storage.
- **Acceptance criteria:** Enable/disable, timeout, fallback, lockout, unavailable and invalidation safe.
- **Testing requirements:** Unit policy; widget prompts/settings; real-device integration.
- **Platform considerations:** Android BiometricPrompt/Keystore; iOS LocalAuthentication/Keychain.
- **Implementation phase:** 07
- **Current status:** **Planned / Not implemented**

## Vault biometric lock
- **Purpose:** Separately protect an encrypted vault.
- **User-facing behavior:** Require a separate biometric policy to open vault content.
- **Expected data:** Vault state and wrapped vault key/reference.
- **Dependencies:** Phase 07 encryption and app-level security.
- **Acceptance criteria:** Separate from app lock; invalidation/fallback cannot expose key.
- **Testing requirements:** Unit policy; widget vault UX; real-device integration.
- **Platform considerations:** Platform-bound key semantics differ.
- **Implementation phase:** 07
- **Current status:** **Planned / Not implemented**

## Backup
- **Purpose:** Create a portable encrypted copy of app data.
- **User-facing behavior:** Export a versioned archive to user-selected storage.
- **Expected data:** Manifest, format version, encrypted DB and attachment payloads.
- **Dependencies:** Phase 08 encryption, attachments, snapshot semantics.
- **Acceptance criteria:** Integrity checked, encrypted, consistent snapshot; no plaintext or raw master key.
- **Testing requirements:** Unit manifest/validation; widget progress/errors; integration round-trip.
- **Platform considerations:** Platform document providers and temp-file cleanup.
- **Implementation phase:** 08
- **Current status:** **Planned / Not implemented**

## Restore
- **Purpose:** Restore Yamintto data from a backup safely.
- **User-facing behavior:** Validate, preview and restore backup with clear replace/conflict policy.
- **Expected data:** Manifest, validated records, conflict/replace policy.
- **Dependencies:** Phase 08 backup parser and database transactions.
- **Acceptance criteria:** Validate before mutation; rollback on failure; preserve references.
- **Testing requirements:** Unit validation/rollback; widget restore; integration clean restore.
- **Platform considerations:** Android/iOS file selection differs.
- **Implementation phase:** 08
- **Current status:** **Planned / Not implemented**

## Legacy ZIP import
- **Purpose:** Bring supported YRNotes backups into Yamintto.
- **User-facing behavior:** Select legacy ZIP, inspect contents, import verified data and report outcomes.
- **Expected data:** ZIP entries, legacy metadata, source version and import report.
- **Dependencies:** Phase 08 inspection of YRNotes source and real fixtures.
- **Acceptance criteria:** Only verified variants accepted; malformed archives fail safely; golden fixtures pass.
- **Testing requirements:** Unit golden fixtures; widget preview/report; integration import.
- **Platform considerations:** Offline; test platform file pickers.
- **Implementation phase:** 08
- **Current status:** **Planned / Compatibility unverified**

## Statistics
- **Purpose:** Summarize note activity and content.
- **User-facing behavior:** Display defined counts and time-based activity metrics.
- **Expected data:** Aggregates and date buckets derived from local records.
- **Dependencies:** Phase 05 note/folder timestamps.
- **Acceptance criteria:** Metric definitions/timezone/deleted-item policy explicit; values match source.
- **Testing requirements:** Unit aggregation/time boundaries; widget stats; integration dataset.
- **Platform considerations:** Shared; chart alternatives accessible.
- **Implementation phase:** 05
- **Current status:** **Planned / Not implemented**

## Settings
- **Purpose:** Let users configure app behavior.
- **User-facing behavior:** View/change preferences, security and storage options.
- **Expected data:** Typed key/value settings, defaults and schema version.
- **Dependencies:** Phase-specific features; persistence.
- **Acceptance criteria:** Defaults, validation, persistence, reset and migration defined; no secrets in settings.
- **Testing requirements:** Unit validation; widget controls; integration persistence.
- **Platform considerations:** System settings and biometric controls platform-specific.
- **Implementation phase:** 09
- **Current status:** **Planned / Not implemented**

## Themes
- **Purpose:** Let users choose a comfortable appearance.
- **User-facing behavior:** System, light, dark and AMOLED theme modes.
- **Expected data:** Theme preference and semantic design tokens.
- **Dependencies:** Phase 01/09 design system and preference persistence.
- **Acceptance criteria:** All modes consistent; accessible contrast and states.
- **Testing requirements:** Unit selection; widget theme; integration persistence.
- **Platform considerations:** Shared Flutter UI; verify system bars on devices.
- **Implementation phase:** 01 / 09
- **Current status:** **Partially configured: system light/dark seeded themes only**

## Font sizes
- **Purpose:** Improve reading comfort and accessibility.
- **User-facing behavior:** Choose a supported note/editor text size.
- **Expected data:** Font scale or semantic size token and preference.
- **Dependencies:** Phase 09 typography tokens/settings.
- **Acceptance criteria:** Approved range; no clipping; Markdown hierarchy remains legible.
- **Testing requirements:** Unit bounds; widget text scaling/layout; integration persistence.
- **Platform considerations:** Test Android/iOS system scaling.
- **Implementation phase:** 09
- **Current status:** **Planned / Not implemented**

## Status rule
A dependency, placeholder folder, design document or workflow does not make a feature implemented. Change status only with source and test evidence.