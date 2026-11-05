# Routing and navigation

## Current implementation

- GoRouter is owned by the root app and created once per app state.
- Initial location is `/splash`; SplashScreen advances to `/`.
- `/` renders the root folder browser, including root folders and root notes.
- `/folders/:folderId` renders a folder's child folders and active notes. The app bar and parent-folder action navigate to the parent or root.
- `/notes/new` creates a plain-text note; an optional folder ID is carried as route extra, never note content.
- `/notes/:noteId/edit` opens an active note for editing. Missing/deleted notes render a safe error state.
- `/appearance` retains the Phase 01 theme-preview screen without making it the app home.
- Unknown locations use a recoverable not-found page with a home action.
- The note editor uses PopScope to confirm before discarding unsaved changes. Save is explicit; no autosave or Markdown preview is present.

## Boundaries

- Route builders compose screens only. Folder/note business rules remain in repositories.
- Do not put note body/title or secrets in paths, query strings or route extras.
- App lock and vault lock are future distinct gates. Restore deep-link destinations only after required unlock.

## Tests and device checks

Widget coverage includes root and nested folder navigation, folder create/rename/move/delete, descendant-safe destination choices, note creation in root/folder, note edit/save/cancel, movement to/from root, soft-delete and missing-folder recovery. These checks are included in the 17 Phase 02 screen widget tests. The owner must verify Android system back and iOS navigation conventions on physical devices. Integration/E2E remains owner-run only.
