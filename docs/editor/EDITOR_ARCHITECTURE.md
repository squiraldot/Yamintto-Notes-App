# Yamintto editor architecture

Status: Implemented on PR #2; exact-SHA host CI passed. Owner physical-device acceptance and merge remain pending.

## Responsibilities and boundaries

- `NoteEditorScreen` owns editor/preview presentation state and text controllers. It does not issue SQL or persist widget state.
- `NoteAutosaveCoordinator` owns the 700 ms debounce, per-editor edit/saved revisions, serialized flush future and save/error status.
- `NoteRepository` owns atomic title/body writes and content-format version transitions through the existing Drift transaction boundary. Existing-note autosaves include the last observed `updated_at` token; a mismatch returns `staleNoteEdit` without mutating the newer row. Successful writes advance `updated_at` monotonically even if the clock has not advanced.
- `HybridMarkdownParser` validates input limits and produces a Markdown AST. It never emits HTML.
- `SafeMarkdownViewer` maps only known AST elements to native Flutter widgets. Unknown nodes degrade to selectable text; raw HTML is not interpreted.

## Content format

| Version | Meaning | Behavior |
|---|---|---|
| 1 | Historical plain text | Literal selectable text; open/preview/title-only edit does not rewrite or upgrade |
| 2 | Yamintto hybrid Markdown | New editor-created notes use this version; syntax is defined in [MARKDOWN_DIALECT.md](MARKDOWN_DIALECT.md) |
| Unknown future version | Unknown dialect | Raw source remains visible and read-only; repository rejects overwrites |

A deliberate body edit to a v1 note upgrades only that note to v2 in the same repository transaction. Title-only edits preserve v1. No SQLite schema migration or bulk rewrite is required.

## Autosave state machine

1. A title/body edit creates a complete immutable snapshot and increments the edit revision.
2. The 700 ms debounce restarts on every edit.
3. A flush snapshots the latest revision and writes title/body together through one repository operation.
4. Writes within one editor are serialized. If a newer revision arrives while a write is in flight, the coordinator persists the newer snapshot before it can report Saved. Across separately opened editors, the repository `updated_at` compare token rejects stale snapshots rather than overwriting newer content.
5. Saved is true only when the persisted revision equals the current edit revision and no save error remains.
6. A failed write keeps the source editable, leaves the coordinator dirty, exposes an error and permits retry. A stale-revision conflict offers an explicit confirmed reload of the latest persisted version; it never silently rebases and overwrites the other editor's changes.
7. Preview transition, explicit save, toolbar/system/gesture back navigation and lifecycle inactive/paused/detached events attempt a flush. PopScope prevents a system pop until the pending flush succeeds.

The lifecycle flush is best-effort. A process kill or OS termination before a debounce/flush completes can lose pending edits. The app makes no stronger durability guarantee than the last successfully completed repository write.

## Safe rendering

- Markdown is parsed into AST nodes and rendered natively.
- Raw HTML, script/style/event-handler content, iframes, embedded objects, SVG and arbitrary CSS are not executed or passed to an HTML renderer.
- Only exact verified legacy inline tags are mapped to safe semantic spans/widgets.
- Links are restricted to http/https/mailto for presentation and are not launched automatically in this phase.
- Images are preserved in source and shown as alt-text placeholders; no remote image fetch occurs.
- Parser limits: 256 KiB UTF-8 source, 10,000 AST nodes, 32 nesting levels, 16 nested details blocks, 20 table columns and 100 table rows.
- Note bodies, rendered content and link targets are never logged.

## Verification

PR #2 branch: `phase-03/markdown-autosave`.

Verified source SHA: `cc8295293e85380cd964e26bfc890b0da063643c`.

Flutter CI run [#42202330375](https://github.com/squiraldot/Yamintto-Notes-App/actions/runs/42202330375) passed:
- Dart formatting.
- `flutter analyze --fatal-infos`.
- **114/114 unit and widget tests**.

The unit/widget tests cover parser syntax and limits, source preservation, v1/v2/future version behavior, debounce, serialized revisions, stale completions, failure/retry, editor/preview, inert links/images, navigation flush and lifecycle flush. The owner-run integration source additionally covers system back, lifecycle backgrounding and database reopen. Owner physical-device testing remains pending. No APK artifact or iOS native build/device pass is claimed for this PR SHA.
