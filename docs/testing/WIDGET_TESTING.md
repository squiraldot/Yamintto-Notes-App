# Widget testing matrix

Use Riverpod provider overrides and deterministic fakes. Every screen tests loading, empty, populated, validation, error/retry and destructive confirmation where applicable.

| UI area | Required widget checks |
|---|---|
| Phase 01 startup/navigation | splash is initial route, splash advances to foundation, unknown route recovery, theme preview changes between system/light/dark/AMOLED |
| Phase 01 theme foundation | Material 3 light/dark variants, AMOLED true-black surface, shared token values |
| Shared components | button enabled/loading/disabled, card tap behavior, text-field validation/obscure/multiline, dialog and sheet presentation |
| Folders/notes | create/rename/move/delete dialogs, empty list, selection, error state |
| Editor/viewer | Markdown preview, selection, keyboard insets, unsaved state, save/saved/error indicators |
| Search | query input, no results, result list, trashed filter, locked message, unlock transition |
| Pin/trash/history | pin state/order, permanent delete confirmation, restore conflict, revision preview/restore |
| Attachments | picker cancel/permission failure, progress, invalid type/size, open/export/remove |
| Encryption/recovery | setup state, password failure, recovery-key one-time reveal/confirmation, locked/unlocked states |
| Biometrics | unavailable/cancel/lockout/fallback, app lock separate from vault lock |
| Backup/restore | preview, unsupported version, progress, cancel, rollback error |
| Phase 09 settings | settings controls, persisted theme modes, AMOLED contrast, font size bounds and system scaling |

Also test semantics labels/order, keyboard focus, screen-reader actions, large text, narrow/wide layouts, light/dark/AMOLED and reduced motion. Golden tests supplement behavior assertions; they do not replace semantics and interaction tests.
