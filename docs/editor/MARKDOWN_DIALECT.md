# Yamintto hybrid Markdown dialect

Status: Implemented on Phase 03 PR #2; owner physical-device acceptance and merge pending. Source remains authoritative; this matrix is the supported product dialect, not a claim of complete CommonMark/GFM conformance.

## Parser decision

Use the Dart team's `markdown` package, pinned by `pubspec.lock` to 7.3.1. It produces a structured AST, supports the CommonMark/GFM extension set (including fenced code, tables, strikethrough and task-list nodes), is published by the verified `tools.dart.dev` publisher, uses BSD-3-Clause, requires Dart 3.9+, and has only `args` and `meta` runtime dependencies. Both dependencies are already present in this app's lockfile. The application renders AST nodes as Flutter widgets; it never converts note source to HTML or loads it in a WebView.

The package's GFM extension set recognizes inline HTML. Yamintto deliberately omits that extension while retaining the parser's default CommonMark inline syntaxes (including normal links/images) and narrowly scoped legacy inline syntaxes. Raw HTML is otherwise inert text. The parser uses the Document API's default syntax support plus explicit GFM additions; it does not replace the base link/image/emphasis parser with the GFM-only extension list. The parser is bounded to 256 KiB of UTF-8 source, 10,000 AST nodes, 32 AST/indent nesting levels, 16 nested details blocks, 20 table columns and 100 table rows.

## Syntax matrix

| Syntax | Modern baseline | Verified YRNotes source compatibility | Unsupported / safe fallback |
|---|---|---|---|
| Paragraphs and line breaks | Supported | Supported | Raw HTML line breaks outside the allowlist remain literal |
| ATX headings 1–6 | Supported | Source renderer explicitly styles 1–4; 5–6 fell back to h4 | No heading-ID/anchor extension |
| Bold / italic / strikethrough | Supported | `**`, `__`, `*`, `_`, `~~` observed | Malformed delimiters remain text |
| Inline and fenced code | Supported | Backticks and fenced blocks observed; code copy affordance observed | Code is inert text; no syntax execution |
| Ordered / unordered / nested lists | Supported | Ordered and unordered line lists observed | Nonstandard indentation beyond limits safely degrades |
| Task lists | Supported | Interactive `- [ ]`, `- [x]`, and ordered checkbox source observed | Viewer checkbox is display-only; source editing changes task markers |
| Blockquotes / horizontal rules | Supported | Both observed | Unsupported raw block HTML remains literal |
| Tables | Supported | Pipe tables observed | Tables above 20 columns or 100 rows are rejected to a source-preserving fallback |
| Links | Supported as styled text | Markdown links observed | Only http, https and mailto destinations validate; no automatic launch in this phase |
| Images | Supported as alt-text placeholder | Markdown images observed | External images are never fetched; local/data/file images are not loaded |
| `<details>` / `<summary>` | Not part of the modern baseline | Exact block form observed in the legacy renderer | Malformed blocks or attributes remain literal |
| `<kbd>`, `<ins>`, `<del>`, `<br>` | Not part of the modern baseline | These exact inline tags observed | Attributes and unrecognized variants remain literal |
| Colored `<span>` | Not part of the modern baseline | Editor inserts `<span style="color: red">` | Only the exact red semantic token maps to the app error color; arbitrary CSS/color values are inert |
| Other HTML / SVG / CSS | Disabled | Not verified as required legacy syntax | Raw tags, attributes, scripts, handlers, iframes, objects, SVG and styles are never interpreted |

## Legacy inspection evidence

Read-only inspection of `squiraldot/YRNotes` main at tree `204c97f2587af474a42958edd9ac55d109281aba` covered `src/utils/markdown.tsx`, `src/components/NoteView.tsx`, `src/components/NoteEditor.tsx`, `src/app/page.tsx` and `README.md`. The renderer is a line-oriented regular-expression renderer, not a CommonMark parser. It explicitly recognizes fenced code, blockquotes, pipe tables, details/summary, task checkboxes, headings, horizontal rules, ordered/unordered list lines and the inline syntax listed above. The editor inserts `<kbd>`, `<details>`, and red `<span>` examples.

The old repository contains no checked-in exported note fixtures or test fixtures. Its page initializes empty localStorage collections when no local data exists. Therefore no real owner-authored legacy note export was available to inspect. Tests must label source-derived compatibility examples as source-derived golden cases, not as user-data fixtures. Existing note data is never rewritten during parsing or preview.

## Version contract

- Version 1: historical plain-text body. Render as literal selectable text with line breaks. Opening or previewing does not update the row.
- Version 2: Yamintto hybrid Markdown dialect defined here.
- Unknown versions greater than 2: preserve and show raw source in a recoverable read-only state. Do not edit or overwrite them.

New Markdown editor notes are created as version 2. A version-1 note stays version 1 when only its title changes; a deliberate body change upgrades that note to version 2 in the same atomic repository write. No schema migration or mass update is required.

## Safety and privacy

- No WebView, HTML renderer, DOM, or unsanitized HTML path.
- Only the explicit AST element allowlist is converted to Flutter widgets. Unknown AST elements degrade to text; raw HTML is not parsed as executable markup.
- Link destinations are bounded and validated against http, https and mailto. Unsafe or malformed destinations render as non-interactive text. No external URL is launched automatically.
- Image source URLs are preserved in note source but never fetched; the viewer displays alt text and a local placeholder.
- No user-authored style attributes are applied. The one verified legacy red token maps to a semantic theme color.
- Never log note bodies, rendered text, link targets or image URLs.
- Parser limits and malicious-input tests are part of the Phase 03 acceptance suite.


## Implementation and verification record

Implementation files: `lib/features/notes/domain/hybrid_markdown_parser.dart` and `lib/features/notes/presentation/safe_markdown_viewer.dart`. The viewer renders a bounded AST to native Flutter widgets and uses no WebView/HTML renderer. Markdown links are visually styled but deliberately non-interactive in this phase; image nodes render an alt-text placeholder and do not fetch remote content. Parser and viewer behavior is covered by tests in `test/features/notes/hybrid_markdown_parser_test.dart` and `test/features/notes/note_editor_phase_03_test.dart`.

Implementation source SHA `e06ee5c60bacb5b8f8403a39d84457216c19e8ff`; latest PR head `84cfda21288ef4a2ae4137511796ac7b64ef7e5c` passed exact-head Flutter CI run `42333598484`, including formatting, analyzer and 120/120 unit/widget tests. The PR is not merged; owner physical-device testing remains pending. The autosave coordinator now performs a best-effort flush of a pending snapshot during unexpected disposal. Phase 03 APK artifacts remain blocked by the unchanged default-branch `main` workflow filters.
