# YAMINTTO — PHASE 03 FINAL IMPLEMENTATION PROMPT
## Markdown Editor, Safe Hybrid Renderer, Viewer, and Reliable Autosave

> **PHASE 02 PREREQUISITE — ACCEPTED; PHASE 03 EXECUTION AUTHORIZATION IS THIS PROMPT**
>
> Phase 02 Note Tags + Folder Colors repair is accepted. The implementation source SHA `fa8f4ad469786a6a7199360a3d6813d22fac75e6` passed Flutter CI run `42177776797` (85/85 tests); universal Debug APK run `42177872597` and ARM64 Debug APK run `42177872567` succeeded for that exact SHA. The owner confirmed successful Android physical-device smoke testing. Integration-test source exists, but its execution is not independently evidenced and must not be claimed.
>
> **This prompt is prepared for execution, not executed by the audit/documentation task.** When the owner submits this complete prompt to an execution-capable agent as a new implementation request, that submission is the separate explicit authorization required by `AGENTS.md` and the phase execution rules. Until then, make no Phase 03 source changes.

## 1. Role and repository

Act as Principal Flutter Architect, Markdown/Parser Engineer, Application Security Reviewer, Offline Data Integrity Engineer, QA Lead, and GitHub Actions Verification Engineer.

Repository: `squiraldot/Yamintto-Notes-App`; Flutter/Dart, Riverpod, GoRouter, Drift + SQLite. Phase 02 current DB schema is v2 (immutable v1 baseline + tags/note_tags/folder color). Existing note source is `notes.body`; existing format marker is `notes.content_format_version` (existing plain-text records use version 1). Start from the latest `main` HEAD at execution time; never reset or rewrite history. The separate legacy YRNotes app/repository is read-only; never modify it.

## 2. Mandatory start sequence

1. Read `AGENTS.md`, `docs/README.md`, status, AI execution rules, roadmap, product requirements/catalog, architecture, database/migrations, security, design and testing docs.
2. Verify Phase 02 acceptance evidence above against current `main` and verify that the owner has submitted this prompt as an implementation request. If the prompt is merely being reviewed/edited or the owner has not invoked it for execution, STOP without source changes.
3. Inspect branch/head/working tree, actual source, routes/providers/repositories, database schema/migrations, format-version handling, lockfile, Android/iOS projects, all three workflows and recent exact-SHA Actions results.
4. Inspect old YRNotes renderer/source and real legacy fixtures read-only. Record the actual syntax found; do not rely on assumptions or modify YRNotes.
5. Before implementation, write a concise plan naming files, package choices, tests, security decisions, migration risks and exclusions.

## 3. Owner decisions and immutable constraints

- Markdown compatibility is **HYBRID**: a documented modern Markdown baseline plus explicit compatibility for verified legacy YRNotes syntax.
- Retain exactly these three protected workflows: `.github/workflows/flutter-ci.yml`, `.github/workflows/yamintto-debug-apk.yml`, and `.github/workflows/yamintto-arm64-debug-apk.yml`. Do not consolidate, delete, rename, disable, replace or add workflows.
- CI remains host-only: locked dependency resolution, formatting, analyzer and unit/widget tests. No emulator, simulator, KVM, virtual device or AI-operated device.
- APK workflows build/upload their respective Debug APKs only. No release APK/AAB, release signing or publishing.
- Preserve offline-first behavior. No network/backend dependency for editor, viewer or autosave.
- Do not implement Phase 04 search/pinning/Trash, Phase 05 revisions/attachments/statistics, Phase 06 encryption, Phase 07 biometrics, Phase 08 backup/import or Phase 09 settings.

## 4. Hybrid Markdown dialect

Before code, create `docs/editor/MARKDOWN_DIALECT.md` with a syntax matrix: modern supported, legacy supported, unsupported/safely degraded. Do not claim full CommonMark/GFM unless parser behavior and tests prove it.

### Modern baseline
Support and test paragraphs, line breaks, ATX headings 1–6, bold/italic/strikethrough, inline/fenced code, ordered/unordered nested lists, blockquotes, horizontal rules, tables, task lists, links and images subject to the safety policy.

Select a maintained Dart/Flutter-compatible parser after checking maintenance, license, Flutter compatibility, transitive dependencies and security. Record the decision. Do not build a regex-only parser.

### Legacy compatibility
Inspect and fixture-test the actual old YRNotes implementation. Consider verified support for `<details>`/`<summary>`, `<kbd>`, `<ins>`, `<del>`, `<br>`, legacy checklists, tables, blockquotes, code blocks, links and images. Legacy colored spans may map only finite approved semantic color names/tokens to app theme colors. Never accept arbitrary CSS, inline style or arbitrary raw color injection.

Unsupported legacy constructs must preserve source and have an explicit fallback; never silently discard or rewrite them.

### Source and version semantics
- Persist original Markdown source in `notes.body`; never persist widget trees or rendered HTML.
- Define `content_format_version` as a real version-to-dialect contract. Existing version-1 plain-text notes must remain readable and must not be rewritten merely by opening/rendering.
- Set a new format version only after documenting it. Do not mass-update existing rows without a reviewed migration.
- Unknown future versions must preserve source and show a recoverable unsupported-format state; never overwrite them.
- Round-trip tests must prove source preservation for modern, legacy and unknown constructs.

## 5. Safe rendering policy

Raw HTML is disabled by default. Never pass user-authored HTML to a WebView or unsanitized HTML renderer.

- Parse to a structured AST and render safe Flutter widgets.
- Translate only explicit allowlisted legacy tags into safe widgets.
- Reject/render inert unapproved tags, attributes, scripts, event handlers, iframes, embedded objects, SVG payloads, CSS/style attributes and unknown HTML.
- Allow only explicitly reviewed URL schemes (normally https, http, mailto); reject javascript:, data:, file:, content:, intent: and unknown schemes before platform launch.
- Define a privacy-conscious image policy. Do not automatically fetch external images without an explicit security/product decision; preserve source if deferred.
- Code blocks are inert text and never execute.
- Bound input size, nesting depth, table dimensions, URL length and parser work.
- Never log note content or sensitive link targets.
- Add malicious-input tests for script/event injection, malformed/nested tags, URL tricks, HTML entities, oversized documents and deeply nested blocks.

## 6. Editor and viewer UX

Provide source editing plus a rendered viewer/preview. On mobile, use a clear Editor/Preview mode rather than a cramped permanent split. Preserve cursor/selection and scroll where feasible. Support keyboard, selection, copy/paste, text scaling, focus order, semantics and screen-reader labels. Show distinct loading, dirty, saving, saved, error and retry states. Protect pending edits on navigation. Editor widget state must not leak into the domain/database model.

## 7. Autosave and concurrency — P0 integrity

- Use a documented debounce target (default 700 ms unless evidence justifies another); make time deterministic in tests.
- Track monotonically increasing edit revisions per open note.
- Serialize writes per note or revision-guard writes so a slow earlier save cannot overwrite newer text.
- Persist the latest title/body snapshot atomically through the existing repository boundary.
- Show Saved only if persisted revision equals the latest in-memory revision; stale completions must not clear dirty state.
- Flush on explicit save, before confirmed navigation/close, and lifecycle opportunities such as backgrounding. Lifecycle callbacks are best-effort; do not claim process-kill durability for text still inside an unflushed debounce.
- Await in-flight flushes where lifecycle APIs permit; avoid overlapping stale writes.
- On failure, retain editable source, keep dirty/error state, expose retry, and never falsely show Saved.
- Test rapid typing, title/body interleaving, note switching, disposal/reopen, background/resume, DB busy/storage full, write failure and stale completion.

## 8. Architecture and data constraints

Follow actual feature-first boundaries. Presentation uses Riverpod controllers/providers; domain owns editor-independent rules and repository contracts; data owns Drift persistence. Widgets must not issue SQL or receive raw transaction handles. Preserve note IDs, folder relations, order, timestamps and soft-delete behavior. No schema migration should be needed for ordinary body editing; if a format migration is required, justify it and prove data preservation/rollback. Tags and folder colors belong to the prerequisite Phase 02 repair, not Phase 03.

## 9. Required tests

**Unit/repository:** modern and legacy parser/serializer round-trip; golden YRNotes fixtures; unsupported syntax and unknown version; malicious HTML/URL handling; debounce/flush/order/stale completion/retry; repository atomicity and preservation of non-editor fields.

**Widget:** editor/preview; title/body input; keyboard/selection; saving/saved/dirty/error/retry; back/navigation with pending edits and failures; empty/long/nested/malformed/legacy documents; accessibility/text scaling/focus/mobile layout.

**Integration source (owner-run physical devices only):** rapid edits then immediate navigation/reopen; background/resume during debounce/write; restart after completed flush; storage failure where feasible; source unchanged by open/preview; Android/iOS test source may be added but must not be executed by AI or CI virtual devices.

## 10. CI and verification

Use repository-pinned Flutter 3.47.9:
```bash
flutter pub get --enforce-lockfile
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
```

Verify all three protected workflows on the exact final source SHA: Flutter CI, universal Debug APK, ARM64 Debug APK. Do not claim integration/device tests passed without owner-provided physical-device evidence. Do not edit workflow files.

## 11. Documentation

Update as applicable:
- `docs/editor/MARKDOWN_DIALECT.md`
- `docs/editor/EDITOR_ARCHITECTURE.md`
- product requirements and feature catalog (FR-03/04/05)
- system architecture and database format-version semantics
- testing strategy, roadmap and status
- docs index

Only mark implemented when source and exact-SHA evidence exist.

## 12. Explicit exclusions

No search/pinning/Trash, history/attachments/statistics, encryption, biometrics, backup/legacy ZIP import, settings/theme/font persistence, backend/accounts/sync, YRNotes modifications, workflow changes, release builds/signing/publishing.

## 13. Final report

Report authorization/gate evidence; scope/files/architecture; dialect and inspected legacy fixtures; security policy and malicious-input results; autosave race/lifecycle/durability behavior; migration decision; exact commands/test counts; three exact-SHA workflow IDs/artifacts; owner physical-device evidence separately from CI; iOS verification status; commit SHA; docs links; unresolved risks.

**STOP CONDITION:** If Phase 02 acceptance evidence no longer matches current source, or this prompt has not been submitted by the owner as an explicit Phase 03 implementation request, make no source changes and do not start Phase 03.
