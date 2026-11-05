# Widget testing matrix

Use Riverpod provider overrides and deterministic fakes. Every screen tests loading, empty, populated, validation, error/retry and destructive confirmation where applicable.

| UI area | Required widget checks |
|---|---|
| Phase 01 startup/navigation | splash is initial route, splash advances to the root folder browser, unknown route recovery, theme preview changes between system/light/dark/AMOLED |
| Phase 01 theme foundation | Material 3 light/dark variants, AMOLED true-black surface, shared token values |
| Shared components | button enabled/loading/disabled, card tap behavior, text-field validation/obscure/multiline, dialog and sheet presentation |
| Phase 02 folders | root and nested lists/navigation, create/rename/move, root destination, empty-folder soft-delete, non-empty deletion rejection, loading/empty/error/retry |
| Phase 02 plain-text note editor | title/body input, explicit create/update save, validation, cancel/back, unsaved-change confirmation, retained draft on save failure |
| Phase 02 active notes | root/folder listing, open, root/folder note creation, move between folder/root, soft-delete, active-list exclusion |
| Search | query input, no results, result list, trashed filter, locked message, unlock transition |
| Pin/trash/history | pin state/order, permanent delete confirmation, restore conflict, revision preview/restore |
| Attachments | picker cancel/permission failure, progress, invalid type/size, open/export/remove |
| Encryption/recovery | setup state, password failure, recovery-key one-time reveal/confirmation, locked/unlocked states |
| Biometrics | unavailable/cancel/lockout/fallback, app lock separate from vault lock |
| Backup/restore | preview, unsupported version, progress, cancel, rollback error |
| Phase 09 settings | settings controls, persisted theme modes, AMOLED contrast, font size bounds and system scaling |

Current Phase 02 UI coverage is in `test/features/phase_02_screens_test.dart` (19 widget tests): root empty state; nested folder navigation; folder create/rename/move/delete; move-to-root; descendant destination exclusion; empty-folder deletion; rejection when soft-deleted notes remain; root/folder note creation; note edit/save; cancel and unsaved-change protection; note movement to/from root; soft-delete retention and active-list exclusion; and missing-folder error recovery. These checks are included in the 69-test source-revision Flutter CI run `42097059083`.

Also test semantics labels/order, keyboard focus, screen-reader actions, large text, narrow/wide layouts, light/dark/AMOLED and reduced motion. Golden tests supplement behavior assertions; they do not replace semantics and interaction tests.
