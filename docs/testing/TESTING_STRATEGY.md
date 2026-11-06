# Testing strategy and execution matrix

## Phase 02 source coverage

- Unicode 17.0 NFC conformance: all official `NormalizationTest.txt` rows; explicit NFKC_CF mapping rows; Unicode `White_Space` boundary trimming; code-point length and Dart/SQLite canonicalization parity.
- Database: exactly two domain tables, schema CHECK/index execution with registered deterministic functions, foreign-key enforcement and RESTRICT behavior, UUID v4, reopening/function registration and fail-closed newer-version behavior.
- Folders: root/nested CRUD, Unicode sibling uniqueness, case/normalization equivalents, soft-deleted name reservation, rename/move, depth 32/33, subtree depth validation, cycle prevention and empty-only soft-delete.
- Notes: create/read/list/update/move/root placement/soft-delete, active-list filtering, data/order retention, deleted-operation rejection and title boundaries.
- Presentation source: root/nested folder listing and navigation; folder create/rename/move/empty-only delete; active root/folder note lists; hybrid Markdown editor/preview; v1 plain-text compatibility; autosave status/retry; pending-edit flush before navigation and lifecycle backgrounding; note move/soft-delete; loading/empty/error/retry states.
- Physical-device integration source: `integration_test/phase_02_data_smoke_test.dart`; it creates a real SQLite file, creates folder/note rows, closes/reopens the database, verifies persistence, soft-deletes a note, checks active-list exclusion and verifies retained folder/body/order fields. It is owner-run only and has not been executed by CI.

## Current evidence
Source implementation revision `745b8f589afceb783a9b39bafcd03c123e50c395` passed Flutter CI run `42097059083` using Flutter 3.47.9: locked dependency resolution, repository-wide format, `flutter analyze --fatal-infos` and `flutter test` all succeeded; **69 tests passed**, including 19 Phase 02 screen widget tests, including dismissal-as-cancel regression coverage for both folder and note moves. The test log contained no Drift multiple-database warnings or widget hit-test warnings. Universal and ARM64-only Debug APK artifacts for that same source revision uploaded successfully on runs `42097260846` and `42097260894`. The final documentation-only revision is checked separately on its exact SHA by all three protected workflows; exact final run IDs and artifact names are recorded in the final execution report.

Flutter CI is host-only and does not provision emulators or simulators. The two APK artifact workflows compile and upload universal and ARM64-only Debug APKs after successful Flutter CI; they are build/artifact jobs, not device-test jobs. Integration and E2E tests are run by the owner on real physical devices. `integration_test/phase_02_data_smoke_test.dart` covers database creation, folder/note creation, close/reopen persistence, soft-delete, active-list exclusion and retained-row verification; it has not been executed by CI or this agent.

## Test layers
| Layer | Purpose | Environment | CI expectation |
|---|---|---|---|
| Unit | Domain rules, repositories, mapping, parser, KDF/crypto wrappers, migrations | host VM, fakes, in-memory DB | run on every CI |
| Widget | UI state, navigation, validation, accessibility semantics | Flutter test binding, provider overrides | run on every CI |
| Integration | Real DB/files/lifecycle/import/restore end-to-end | owner-provided physical Android/iOS device | owner-run physical-device smoke only; no virtual-device CI |
| Physical-device | Keystore/Keychain, biometrics, lifecycle, file provider, OS behavior | real supported Android and iOS hardware | manual/release gate; not inferred from host CI |
| Security review | Protocol, dependencies, threat model and leakage review | independent reviewer + test evidence | mandatory before security/production claim |

## Feature matrix
| Area | Unit | Widget | Integration / device |
|---|---|---|---|
| DB and migrations | schema, FK, indexes, version upgrades, rollback | migration/empty/error states | fresh install, old-version upgrade, interruption, restart |
| Folders/notes | CRUD, hierarchy, validation, repository mapping | list/detail/dialog/error | create/edit/move/delete, restart, airplane mode |
| Markdown/autosave | parser round-trip, stale-write/race/cancel | editor/preview/save status | rapid edits, background/kill/restart, data-loss simulation |
| Search | normalization, ranking, index mutation | query/loading/empty/results/locked | update/restart; Phase 06 migration removes plaintext index; lock clears memory |
| Trash/history | restore/cascade/retention/revision ordering | confirmation, restore, history | restore conflicts, permanent delete, revision restore |
| Attachments | validation, paths, limits, orphan cleanup | picker/progress/open/error | Phase 05 file round-trip/storage full; Phase 06 encrypted migration/tamper/plaintext scan |
| Encryption | selected implementation vectors, nonce strategy, KDF/wrap, tamper | setup/recovery/locked UX | migration, interruption, DB/file/temp/index/log scan |
| Recovery | wrong credential, independent paths, rotation | recovery-key reveal/confirmation | clean-device password path and separate recovery-key path |
| Biometrics | policy state machine | prompt/fallback/lock states | physical-device enrollment change, lockout, invalidation, app-vault separation |
| Backup/restore | archive parser, integrity, version, rollback | preview/progress/confirmation | encrypted round-trip, corruption, interrupted restore, cross-device |
| Legacy ZIP | golden fixtures, malformed archive, traversal/limits | import preview/report | actual Android/iOS document picker and fixtures |
| Settings/themes/fonts | validation, bounds, migration | settings/theme/font matrix | persistence after restart, OS theme and text scaling |
| Accessibility/performance | pure metric/format logic | semantics/layout/text scale | TalkBack/VoiceOver, profiler, low-memory/large-data devices |

## Data-loss scenarios
Test process kill during autosave; simultaneous edits; disk full; SQLite busy/corrupt; migration interrupted before/after staged file; attachment copy interrupted; deletion cleanup interrupted; restore invalid archive; backup interrupted; device storage permission revoked; app upgrade while locked; key rotation interrupted. Original data must remain usable or failure must be explicit and recoverable.

## CI interpretation
A successful Flutter CI run proves only its executed steps. Host-side CI does not prove integration or physical-device behavior. Both Android debug artifact workflows are separate builds, not test coverage. iOS requires macOS/Xcode and physical-device validation; Linux CI does not prove it.

## Physical-device testing policy
GitHub Actions is deliberately host-only and runs locked dependency resolution, formatting, analyzer and unit/widget tests. It must not provision Android emulators, iOS simulators, KVM or virtual-device runners. AI agents must not create/use virtual devices. Integration/E2E tests are run by the owner on real physical devices only. After the owner connects a device, identify it with `flutter devices` and run:

    flutter test integration_test -d <physical-device-id>

Record owner-reported device results separately from automated CI; do not invent device details or treat artifact builds as device tests. **OWNER-REPORTED — PHASE 02 ANDROID PHYSICAL-DEVICE SMOKE TEST PASSED.** The owner explicitly confirmed successful testing in the current project conversation. No device details, logs, screenshots, command output or test date are asserted. iOS source/configuration work continues phase-by-phase; native build/device verification is `Not Verified — Environment Unavailable` when macOS/Xcode is unavailable and is non-blocking for Android-focused phase progression.


## Phase 02 implementation evidence notes

The current Drift warning investigation traced the multiple-database debug messages to database unit tests that retained their group-level in-memory fixture while opening an additional file-backed database for reopen/fail-closed cases. The fixture is now explicitly closed before those file-backed instances are constructed. Each uses a distinct executor; the warning did not demonstrate that production Riverpod creates duplicate app databases. Exact-HEAD CI must still verify that the revised teardown is warning-free and that tests pass.


## Phase 02 reopened repair — required test coverage

The historical 69-test CI run did not test note tags or folder colors. Before Phase 02 acceptance:
- Test tag create/list/rename/delete according to approved semantics; multiple tag assignment/removal; duplicate/normalization policy; referential integrity; soft-deleted-note behavior; and prove tag operations never mutate note body/title.
- Test folder color null/default, valid/invalid values, persistence after restart, nested rendering, theme fallback and contrast; color must not alter IDs, hierarchy, names or sort order.
- Migrate a populated schema-v1 fixture and verify every existing folder/note ID, content, relationship, order, timestamp and deleted_at value is unchanged. Test migration rollback/fail-closed behavior.
- Add tag-management/assignment and folder-color widget tests.
- Re-run locked dependency resolution, format, analyzer, full unit/widget tests and all three protected workflows on the exact repair SHA. Owner repeats the physical Android smoke test.

## Phase 03 hybrid Markdown/autosave coverage

- Parser/serializer tests for the documented modern syntax and verified legacy YRNotes golden fixtures; no silent source rewriting.
- Security tests for raw HTML/script/event handlers, dangerous URL schemes, malformed/nested tags, external images, oversized input and deeply nested documents. Only explicitly allowlisted legacy tags may render as safe widgets.
- Viewer/editor tests for syntax matrix, unknown constructs, accessibility semantics, keyboard/focus, selection and text scaling.
- Autosave tests for debounce, immediate flush, same-note serialization/revision guards, stale completions, note switching, navigation, background/resume, failure/retry and dirty-state retention.
- Process kill cannot guarantee a pending debounce was flushed; document the durability boundary and test restart after a completed flush.


## Phase 02 repair verification — executed

Repair source SHA: `fa8f4ad469786a6a7199360a3d6813d22fac75e6`.

Flutter CI run `42177776797` succeeded on Flutter 3.47.9:
- Locked dependency resolution: passed.
- `dart format --output=none --set-exit-if-changed .`: passed.
- `flutter analyze --fatal-infos`: passed.
- `flutter test`: **85/85 passed**.

Test distribution from the successful runner log:
- Unit/app/theme/Unicode tests: 16.
- Database/schema/migration tests: 11.
- Folder/note/tag repository tests: 29.
- Widget tests: 29 (including 19 existing Phase 02 screen tests and 4 repair-screen tests).

Migration coverage includes a populated schema-v1 fixture, preservation of old IDs/content/relationships/order/timestamps/deleted_at, v2 tag creation and assignment, color persistence after reopen, FK/integrity checks and forced migration failure/rollback.


Exact-SHA Debug APK evidence (source `fa8f4ad469786a6a7199360a3d6813d22fac75e6`):
- Universal run `42177872597` succeeded; artifact `yamintto-debug-fa8f4ad469786a6a7199360a3d6813d22fac75e6`, ID `13483409802`, archive 80,077,640 bytes, SHA-256 `ec417ad611bbdbc64ffa402af433cfc96cb70958871aee56b5a70192626c34e2`.
- ARM64 run `42177872567` succeeded; artifact `yamintto-arm64-debug-fa8f4ad469786a6a7199360a3d6813d22fac75e6`, ID `13484082037`, archive 51,786,455 bytes, SHA-256 `f53c2e1caadd41b52dfaf3a657ad0bf95ad82bf36be6a51a532f16c680308837`.
Archive sizes are ZIP sizes, not extracted APK sizes. Both artifact records showed expiry 2026-11-20.


The physical-device integration source `integration_test/phase_02_data_smoke_test.dart` covers tag assignment and folder-color persistence across close/reopen. **Its execution is not independently evidenced and is not claimed.** The owner separately confirmed successful physical-device testing of the repaired application; see the final owner acceptance record below. No emulator/simulator/KVM/virtual device was used or added.


## Phase 02 final physical-device acceptance — 2026-11-06

The owner explicitly confirmed successful physical-device testing of the repaired application and reported that everything works as expected. Record this as **OWNER-REPORTED PHYSICAL-DEVICE PASS** for the Phase 02 Note Tags + Folder Colors repair. This closes the owner-device acceptance gate alongside the exact-repair-SHA automated evidence (Flutter CI run `42177776797`, 85/85 tests; universal APK run `42177872597`; ARM64 APK run `42177872567`).

No device model, OS version, screenshots, logs, or exact test command were supplied, so none are asserted. The source file `integration_test/phase_02_data_smoke_test.dart` remains distinct from the owner's manual device confirmation; its execution is not independently evidenced and is not claimed. iOS verification remains unavailable and separate from this Android-focused acceptance.

**Phase 02 — ACCEPTED. Phase 03 — NOT STARTED / NOT AUTHORIZED.**


## Phase 03 implementation verification — PR #2

Exact PR source SHA: `1cb2558e408a4253ca36abc8a77aeccd9c183e25`.

Flutter CI run [#42200798879](https://github.com/squiraldot/Yamintto-Notes-App/actions/runs/42200798879) succeeded on Flutter 3.47.9:
- Locked dependency resolution: passed.
- `dart format --output=none --set-exit-if-changed .`: passed.
- `flutter analyze --fatal-infos`: passed.
- `flutter test`: **114/114 passed**.

Phase 03 coverage includes:
- Hybrid Markdown parser tests for modern block/inline syntax, task lists, tables, links, images, verified legacy details/summary and inline tags, raw HTML inertness, unsafe URLs, malformed details, source preservation, byte/node/depth/table limits.
- Content format repository tests for v2 creation, v1 literal preservation on open/title-only edits, v1→v2 upgrade only on deliberate body edits, and rejection/preservation of unknown future versions.
- Autosave coordinator tests for 700 ms debounce, serialized latest-revision persistence, stale completion protection, failure/retry, atomic title/body snapshots and independent editor sessions.
- Editor/viewer widget tests for inert links/images, text scaling and selection, editor/preview source preservation, autosave timing, navigation flush, lifecycle background flush, unknown-format read-only behavior, failure/retry and v1 literal preview.
- Phase 02 screen tests were updated to assert that pending edits are flushed before navigation; the old discard-confirmation behavior is superseded by autosave-before-navigation.

This is host unit/widget evidence only. Phase 03 physical-device integration testing remains owner-run and pending. No process-kill durability guarantee is made for a debounce that has not completed a flush. The PR is not merged or owner-accepted.
