# Documentation and implementation status

Snapshot: 2026-11-06 (Phase 02 accepted; Phase 03 implementation in PR); branch: `phase-03/markdown-autosave`; current PR head: `29bb4628cfcf01a47e8022ec3c861401aaa67657`; Phase 03 implementation source SHA: `1cb2558e408a4253ca36abc8a77aeccd9c183e25`; Phase 01 evidence baseline: `76ba10c04f0ec421f54e5d6252dd6745058611f9`; Phase 02 owner baseline: `92dcadd7ed2bd2ee9b49ca8893843b13a689bb7e`; Phase 02 source implementation commit: `36a27212dadda99fbb7bb333a93a3568c967869d`; this status snapshot is a documentation-only reconciliation.

## Phase 01 — Foundation

**Status: Source implementation present; automated CI and both Debug APK builds verified; Android real-device test owner-reported successful; detailed device evidence is not attached. iOS verification is unavailable and is not a phase-progression blocker.**

### Implemented in source
- Flutter package/project identity: `yamintto`; app name: Yamintto; beta version `0.1.0-beta.1+1`.
- Bootstrap initializes Flutter and starts `ProviderScope(child: YaminttoApp())`.
- Android application ID and namespace: `com.merrmist.yamintto`.
- iOS bundle identifier: `com.merrmist.yamintto`.
- Centralized provisional color, typography, spacing, sizing and radius tokens.
- Material 3 light, dark and true-black AMOLED themes.
- Reusable button, card, text-field, dialog and modal-sheet primitives.
- GoRouter splash route -> root folder browser; `/appearance` retains the foundation theme preview; unknown-route recovery.
- In-memory system/light/dark/AMOLED preview. Theme preference persistence remains Phase 09.
- Configuration, theme, splash/navigation, unknown-route and reusable-widget tests.
- Android app-shell integration smoke test source retained in `integration_test/app_smoke_test.dart`; source presence is not evidence that the test was executed.

### Configured
- Flutter 3.47.9 CI toolchain. pubspec declares Dart >=3.13.0 and Flutter >=3.38.4; only Flutter 3.47.9 is verified.
- Android and iOS host projects and identity metadata.
- Exactly three protected workflows:
  1. `.github/workflows/flutter-ci.yml` — host-only dependency, format, analyzer and unit/widget test validation.
  2. `.github/workflows/yamintto-debug-apk.yml` — universal Android Debug APK build and artifact upload.
  3. `.github/workflows/yamintto-arm64-debug-apk.yml` — ARM64-only Android Debug APK build and artifact upload.
- Both APK workflows trigger after successful Flutter CI on main/dev, check out the exact CI-tested SHA and upload artifacts. Neither performs device testing.

## Phase 01 baseline GitHub Actions evidence

These historical Phase 01 baseline runs target commit `76ba10c04f0ec421f54e5d6252dd6745058611f9` on `main`; current Phase 02 evidence is recorded separately below.

| Check | Run ID | Result | Verified steps |
|---|---:|---|---|
| Flutter CI | `41981911424` | Success | Dependency install, formatting, analyzer, unit/widget tests |
| Universal Debug APK | `41982079883` | Success | Exact tested SHA checkout, Debug APK build, artifact upload |
| ARM64 Debug APK | `41982079971` | Success | Exact tested SHA checkout, ARM64 Debug APK build, artifact upload |

- Flutter CI executed its formatting, analyzer and test steps successfully; the audited run baseline reports **15/15 Flutter tests passed**.
- Universal artifact: `yamintto-debug-76ba10c04f0ec421f54e5d6252dd6745058611f9`; uploaded successfully. GitHub artifact archive size: 78,923,986 bytes.
- ARM64 artifact: `yamintto-arm64-debug-76ba10c04f0ec421f54e5d6252dd6745058611f9`; uploaded successfully. GitHub artifact archive size: 50,633,031 bytes.
- The sizes above are GitHub artifact archive sizes, not extracted APK file sizes.
- These results are current evidence for the audited SHA, not historical baseline runs.

## Platform verification state

### Android
- **Owner-reported; detailed evidence not attached. Owner reports successful physical-device Android testing.**
- Do not invent device model, OS version, command output, date, tested scenarios or test logs.
- Automated host CI and successful APK artifact builds are separate evidence and do not themselves prove device behavior.
- Future device-specific, biometric and secure-storage acceptance must be recorded against actual physical-device evidence.

### iOS
- iOS bundle identity and native project configuration are present.
- **Native iOS build/device verification: Not Verified — Environment Unavailable (macOS/Xcode verification not available).**
- Do not mark iOS build or device tests passed, and do not infer success from shared Flutter CI.
- Continue iOS source/configuration/native integration alongside shared Flutter development in each applicable phase. Missing iOS verification must not block Android-focused phase progression.

## Integration testing policy

- No Android emulator in GitHub Actions.
- No iOS simulator in GitHub Actions.
- No KVM, virtual-device runner, emulator boot or simulator CI setup.
- No AI-created or AI-operated emulator/simulator testing.
- Flutter CI is host-only: locked dependency resolution, formatting, analyzer and `flutter test` (unit/widget tests).
- Integration test source remains under `integration_test/`; owner runs it on real physical devices only after coordination.
- APK workflows build and upload APK artifacts only; they do not run device tests.
- The owner-reported Android test result is recorded separately from automated Actions evidence.

## Initial Phase 02 UI implementation evidence (historical source revision 36a2721)

This historical section records the first complete presentation implementation and its original CI/APK evidence. The later regression fix and current source-SHA evidence are recorded above.

## Latest Phase 02 follow-up fix and exact-SHA verification

- Latest source revision: `745b8f589afceb783a9b39bafcd03c123e50c395`.
- Move-dialog dismissal fix: Android Back/barrier dismissal is cancellation, never an implicit Root destination.
- Regression tests: folder move-dialog dismissal and note move-dialog dismissal both preserve the original parent/folder; Phase 02 screen widget coverage is now **19 tests**.
- Flutter CI run `42097059083` — **success** on Flutter 3.47.9; locked dependency resolution, repository-wide formatting, analyzer and **69/69 tests** passed. The test log contains no Drift multiple-database warnings.
- Universal Debug APK run `42097260846` — **success**; artifact `yamintto-debug-745b8f589afceb783a9b39bafcd03c123e50c395`; archive 80,051,472 bytes; SHA-256 `e0c35176a80c4c4e88c7f23c6704b9e87fceee01c0d8782c4b561cb2f3a06153`.
- ARM64 Debug APK run `42097260894` — **success**; artifact `yamintto-arm64-debug-745b8f589afceb783a9b39bafcd03c123e50c395`; archive 51,759,502 bytes; SHA-256 `36cb8e9a1790c55468313dd956abb1dbc30ee7a66b372ed2784babe0cda94e6f`.
- The APK sizes above are GitHub artifact ZIP archive sizes, not extracted APK file sizes.
- The documentation-only final revision is validated separately on its own exact SHA by all three protected workflows; its run IDs and artifact metadata are recorded in the final execution report.

## Initial Phase 02 implementation evidence

- Source implementation revision: `36a27212dadda99fbb7bb333a93a3568c967869d`.
- Flutter CI run: `42040473461` — success on Flutter 3.47.9; locked dependencies, format, analyzer and **67/67 tests**.
- Initial Phase 02 screen widget coverage on this historical source revision: 17 tests in `test/features/phase_02_screens_test.dart`.
- Universal Debug APK run: `42040771830` — success; artifact `yamintto-debug-36a27212dadda99fbb7bb333a93a3568c967869d`; archive 80,051,369 bytes; SHA-256 `4e2544d8b6df7086fdb4ef1300fd8d0e0b78e2f97ee94597985dfbb71d186865`.
- ARM64 Debug APK run: `42040772056` — success; artifact `yamintto-arm64-debug-36a27212dadda99fbb7bb333a93a3568c967869d`; archive 51,759,376 bytes; SHA-256 `2b635ecafb2a04a256a92fe4f58d10dac8346fd639d6f263f9ddb36d03f4ee15`.
- Drift lifecycle: tests now close the in-memory fixture before opening file-backed DB instances; the latest source-revision CI log contains zero Drift multiple-database warnings.
- Unicode 17.0 canonicalization and Dart/SQLite parity remain covered by the existing conformance tests.
- The final documentation-only revision is separately checked on its exact SHA by all three protected workflows; see the final execution report for those run IDs.
- Owner device acceptance: **OWNER-REPORTED — PHASE 02 ANDROID PHYSICAL-DEVICE SMOKE TEST PASSED**. The separate integration-test source has not been executed by CI or this agent; execution is not claimed.

**Phase 02 — ACCEPTED.** Implementation, automated validation, and owner-reported Android physical-device smoke testing are complete. The integration-test source remains unexecuted unless separately evidenced. Phase 03 has not started and is not authorized.

## Phase 01 acceptance checklist

- [x] Flutter bootstrap and root Riverpod ProviderScope.
- [x] App/package identity and Android application ID.
- [x] iOS bundle identifier configured (native build verification remains unavailable).
- [x] Material 3 light/dark/AMOLED themes and centralized base tokens.
- [x] Reusable app-shell UI primitives.
- [x] Splash, GoRouter navigation and unknown-route recovery.
- [x] Configuration, theme, navigation and widget test source.
- [x] Android integration smoke test source retained.
- [x] Latest host-only Flutter CI run succeeded on audited SHA.
- [x] Universal Debug APK built and artifact uploaded on audited SHA.
- [x] ARM64 Debug APK built and artifact uploaded on audited SHA.
- [x] Owner-reported successful physical Android testing (detailed evidence not attached; not independently verified from repository logs).
- [ ] iOS native build/device verification — environment unavailable; explicitly non-blocking for Android-focused phase progression.

**Phase 01 acceptance is recorded as an owner-reported Android pass, not an independent QA/device-log verification.** The owner has reported successful real-device testing, so no Android device-test failure is currently outstanding. iOS verification is not a gate. Do not describe the owner-reported result as independently verified.

## Phase 02 — Final acceptance

**PHASE 02 — ACCEPTED**

- Architecture: owner-approved frozen Phase 02 architecture (baseline `92dcadd7ed2bd2ee9b49ca8893843b13a689bb7e`).
- Implementation: complete on source revision `745b8f589afceb783a9b39bafcd03c123e50c395`.
- Automated host validation: Flutter CI run `42097059083` passed on Flutter 3.47.9; 69/69 unit/widget tests passed, including 19 Phase 02 screen widget tests.
- APK builds/artifacts: universal run `42097260846` and ARM64 run `42097260894` succeeded and uploaded artifacts for the same source SHA.
- Owner device acceptance: **OWNER-REPORTED — PHASE 02 ANDROID PHYSICAL-DEVICE SMOKE TEST PASSED**. Source: explicit owner confirmation in the current project conversation. No device model, OS version, date, command, screenshots or logs are asserted.
- Integration-test distinction: `integration_test/phase_02_data_smoke_test.dart` exists. Its execution is not independently evidenced and is not claimed as executed.
- iOS: **NOT VERIFIED — ENVIRONMENT UNAVAILABLE**; non-blocking for Android-focused Phase 02 acceptance.
- Previous documentation validation revision: `c32a954d49b60b64abbab3347fad5b998bf6dc90`. The final documentation revision and its exact-SHA workflow evidence are recorded in the subsequent closure commit/report.

**PHASE 03 — NOT AUTHORIZED.** Separate explicit owner approval is required. No Phase 03 work may begin.

## Workflow policy

Exactly three protected workflows must remain. ADR-0012 supersedes ADR-0009's original two-workflow decision. Preserve all three files; do not delete, rename, disable, modify, merge or add workflows without explicit owner authorization.

## Beta and production status

Beta policy remains Debug APK only: no release APK/AAB, release signing or publishing. Production readiness has not been achieved. Security, encryption, recovery, biometric, backup and data workflows remain future-phase requirements, not implemented functionality.


## Phase 02 — Owner-approved architecture decision freeze (2026-11-05)

**Architecture decision freeze: COMPLETE. Implementation authorization: GRANTED by owner on 2026-11-05. Initial Phase 02 UI source implementation and automated validation completed on source revision `36a27212dadda99fbb7bb333a93a3568c967869d` (Flutter CI run `42040473461`, 67/67 tests); both initial source-revision Debug APK artifacts uploaded successfully. The later move-dialog dismissal fix and updated 69-test evidence are recorded in the latest follow-up section above. The documentation-only final revision is checked separately on its exact SHA. owner-reported Android physical-device smoke testing passed; Phase 02 final acceptance is recorded. Phase 03 has not started and is not authorized.**

- Owner reviewed the Phase 02 decision register, ADR-0013, schema, migration policy and retention policy, then approved the baseline with amendments.
- Accepted amendments: maximum folder depth 32 (virtual root level 0); folder names max 255 Unicode code points; note titles max 255 Unicode code points; case-insensitive sibling folder-name uniqueness using a Unicode NFKC_Casefold canonicalizer and root-aware DB unique constraint; unique names remain reserved while folders are soft-deleted.
- Folder deletion: empty-folder-only; reject if any child folder or any note including soft-deleted notes exists; soft-delete only.
- Notes soft-delete from schema v1 and retain folder/order. Active lists/default search exclude deleted notes; edit/move requires restore.
- Phase 04 Trash must include both deleted notes and folders, support restore and explicit permanent deletion. Note restore uses original folder/order or root with explicit conflict result if unavailable.
- Soft-deleted records are retained indefinitely initially. No automatic expiry or cleanup. Permanent deletion is future-phase work and is NOT a Phase 02 blocker; Phase 05 adds revision/attachment dependent cleanup.
- Phase 02 schema v1 is limited to folders and notes. Drift/SQLite, UUID v4, UTC Unix milliseconds, 32-level hierarchy, transactional moves, FK RESTRICT, explicit ordering and forward-only fail-closed migrations are accepted.
- Updated authoritative documents: decision register, ADR-0013, database schema, migration policy, data retention, product requirements, feature catalog and phase roadmap.
- Existing Phase 02 source on `main` includes the Drift `GeneratedDatabase` wrapper and schema v1 SQL, app-scoped lazy Riverpod database provider, Unicode 17.0 canonicalizer and generated data, folder and notes repositories/domain models, repository providers, unit tests and a physical-device integration smoke-test source.
- Unicode data provenance and generation are present under `tool/unicode/17.0.0/` and `tool/unicode/generate_unicode_17_data.py`; the schema uses the same deterministic Unicode functions for Dart validation and SQLite checks.
- The owner subsequently authorized implementation on `main`, starting from `92dcadd7ed2bd2ee9b49ca8893843b13a689bb7e`. The branch already contained implementation commits after that baseline; work continued from the newer branch head without resetting history.
- Intermediate validation history: earlier runs on implementation commits failed the format gate, so analyzer/tests were skipped on those intermediate SHAs and dependent APK workflows were skipped. Those failures were corrected; source revision `36a27212dadda99fbb7bb333a93a3568c967869d` passed Flutter CI (67/67 tests) and both Debug APK workflows uploaded artifacts for that same SHA. The documentation-only final revision is validated separately by the three protected workflows on its exact SHA. No Phase 02 physical-device integration run is verified.
- **Historical acceptance reconciliation:** the earlier pending statement is superseded by the final acceptance record above. Phase 03 has not started and is not authorized.



## Owner decision reconciliation — 2026-11-06

- **Workflows:** retain exactly the three existing protected workflows: `.github/workflows/flutter-ci.yml`, `.github/workflows/yamintto-debug-apk.yml`, and `.github/workflows/yamintto-arm64-debug-apk.yml`. No consolidation, deletion, rename, disablement or addition is authorized.
- **Markdown:** Phase 03 uses the owner-selected **hybrid** dialect: a documented modern Markdown baseline plus explicitly verified legacy YRNotes compatibility.
- **Tags and folder colors:** the owner selected **REPAIR**, not defer. The previous Phase 02 acceptance is superseded for phase progression. Phase 02 is **REOPENED — REPAIR REQUIRED** because note tags and persisted folder colors are absent from the current source.
- Historical Phase 02 CI/APK evidence (69/69 tests and both APK artifacts) remains valid for the exact tested folders/notes baseline only. It does not prove tags or folder colors. The earlier owner-reported physical-device result likewise applies only to the baseline tested at that time.

### Phase 02 — Reopened repair scope

Required missing capabilities:
1. **Note tags:** create/manage reusable tags and assign/remove multiple tags on notes, with persistent local relationships.
2. **Folder colors:** persist and display an optional validated color for each folder, including nested folders.

The repair must inspect the original Phase 02 prompt and actual Drift migration/source state before freezing tag normalization, duplicate/deletion semantics, color palette/serialization and fallback behavior. Preserve schema v1 as an immutable baseline; implement any extension through a forward-only, data-preserving migration. Preserve existing IDs, content, relationships, ordering, timestamps, soft-delete semantics, Unicode folder-name rules and depth constraints.

Phase 02 can close only after implementation, migration tests, tag/color unit and widget tests, full Flutter validation, all three protected workflows on the exact repair SHA, owner-run Android physical-device retest, documentation reconciliation and explicit owner acceptance.

**Phase 03 remains NOT STARTED and NOT AUTHORIZED.** The prepared [Phase 03 implementation prompt](development/PHASE_03_IMPLEMENTATION_PROMPT.md) is gated and must not be executed until Phase 02 repair is accepted and the owner separately authorizes Phase 03.


## Phase 02 reopened repair — implementation evidence (2026-11-06)

**Current status: IMPLEMENTATION COMPLETE — OWNER DEVICE ACCEPTANCE PENDING. Phase 02 is not yet ACCEPTED.**

- Starting source HEAD: `7882bbdd5b751980bc1f14502e5e4bacc452f2d5`.
- Repair implementation source SHA: `fa8f4ad469786a6a7199360a3d6813d22fac75e6` on `main`.
- Database: immutable schema v1 upgraded forward to v2. Existing v1 records are retained; migrated folder colors default to NULL; existing notes receive no tags.
- Note tags: reusable global definitions, multiple note assignments, Unicode 17.0 normalization, transactional assignment/deletion, retained links for soft-deleted notes.
- Folder colors: fixed ten-color opaque ARGB palette, nullable default, root/nested persistence. Color-only edits do not alter timestamps.
- Dependencies: no package added; pubspec and pubspec.lock unchanged.
- Flutter CI run `42177776797`: success on the exact repair SHA with Flutter 3.47.9; locked dependency installation, formatting, analyzer and **85/85 tests passed** (16 unit, 11 database/migration, 29 repository, 29 widget).


### Exact-SHA Android Debug APK evidence

Both protected APK workflows succeeded on repair source SHA `fa8f4ad469786a6a7199360a3d6813d22fac75e6`:

| Workflow | Run | Artifact | Artifact ID | Archive bytes | SHA-256 |
|---|---:|---|---:|---:|---|
| Universal Debug APK | `42177872597` | `yamintto-debug-fa8f4ad469786a6a7199360a3d6813d22fac75e6` | `13483409802` | 80,077,640 | `ec417ad611bbdbc64ffa402af433cfc96cb70958871aee56b5a70192626c34e2` |
| ARM64 Debug APK | `42177872567` | `yamintto-arm64-debug-fa8f4ad469786a6a7199360a3d6813d22fac75e6` | `13484082037` | 51,786,455 | `f53c2e1caadd41b52dfaf3a657ad0bf95ad82bf36be6a51a532f16c680308837` |

Sizes are GitHub artifact ZIP archive sizes, not extracted APK sizes. Both artifacts were uploaded successfully and were unexpired when inspected; their recorded expiry is 2026-11-20.


- Physical-device integration source covers tag and folder-color persistence across a database close/reopen. It has **not** been executed by this agent or CI. Owner retest is pending.
- The prior owner-reported device result applies to the earlier folders/notes baseline only; it does not accept the repaired features.
- Phase 03 remains unauthorized and has not started.

This section supersedes historical Phase 02 ACCEPTED / schema-v1-only / repair-required statements earlier in this file. Those statements remain historical records, not current status.


## Phase 02 final owner acceptance — 2026-11-06

**PHASE 02 — ACCEPTED.** The owner explicitly confirmed in the project conversation that physical-device testing of the repaired application was successful and that everything works as expected. This closes the remaining owner-device acceptance gate for the Note Tags + Folder Colors repair.

- Repair source SHA: `fa8f4ad469786a6a7199360a3d6813d22fac75e6`.
- Final documentation baseline before this acceptance record: `19a40823507207187a850997c955131aef53b0e0`.
- Automated Flutter CI on repair source: run `42177776797`, success; 85/85 tests passed.
- Universal Debug APK: run `42177872597`, success.
- ARM64 Debug APK: run `42177872567`, success.
- Owner physical-device result: **PASS — owner-reported**. No device model, OS version, individual test log, screenshots, or exact test command are asserted because they were not supplied.
- The integration-test source exists, but its execution is not independently evidenced; this does not override the owner's successful manual physical-device acceptance.
- iOS native build/device verification remains **NOT VERIFIED — ENVIRONMENT UNAVAILABLE** and is not a blocker for this Android-focused Phase 02 acceptance.

The earlier “OWNER DEVICE ACCEPTANCE PENDING” statements in the repair implementation history are historical snapshots and are superseded by this final owner acceptance. Exactly three protected workflows remain; no workflow changes are authorized or included in this closure.

**PHASE 03 — NOT STARTED / NOT AUTHORIZED.** A separate explicit owner authorization is still required before any Phase 03 work.


## Current Phase 03 implementation status — 2026-11-06

**PHASE 03 — IMPLEMENTED ON PR BRANCH; OWNER ACCEPTANCE AND MERGE PENDING.**

- Owner authorization: the owner submitted the complete Phase 03 implementation prompt and explicitly authorized execution on 2026-11-06.
- Repository: `squiraldot/Yamintto-Notes-App`; branch: `phase-03/markdown-autosave`; pull request: [#2](https://github.com/squiraldot/Yamintto-Notes-App/pull/2).
- Current PR head at this status snapshot: `29bb4628cfcf01a47e8022ec3c861401aaa67657`. Phase 03 implementation source SHA (last non-documentation code commit): `1cb2558e408a4253ca36abc8a77aeccd9c183e25`.
- Implemented: documented hybrid Markdown dialect; Dart AST parser; safe native Flutter renderer; editor/preview UI; version-aware plain-text/Markdown behavior; future-format read-only preservation; 700 ms debounced autosave; serialized revision-aware writes; explicit/navigation/lifecycle flush; save error and retry states.
- Data: no SQLite schema migration. Existing v1 plain-text rows remain literal on open/preview/title-only edits. New editor notes use content format v2. A deliberate body edit upgrades only that v1 note to v2. Unknown versions cannot be overwritten.
- Safety: raw HTML is not rendered; only exact legacy inline constructs are allowlisted; link schemes are validated and links are inert; images are alt-text placeholders and are never fetched; source remains the persisted data.
- Exact-SHA Flutter CI run [#42200798879](https://github.com/squiraldot/Yamintto-Notes-App/actions/runs/42200798879): **success** on source SHA `1cb2558e408a4253ca36abc8a77aeccd9c183e25`; locked dependencies, Dart formatting, analyzer and **114/114 unit/widget tests** passed.
- The earlier formatting, analyzer and widget-test failures occurred on intermediate commits and were corrected. They are historical iteration evidence, not the current PR-head result.
- PR #2 is not merged. No APK build or artifact workflow is claimed for this PR SHA. Owner physical-device testing for Phase 03 is pending. iOS native build/device verification remains unavailable and is not inferred from host CI.
- The temporary formatter helper workflow used during correction was removed. The final branch retains exactly the three protected workflows: Flutter CI, universal Debug APK and ARM64 Debug APK.
- Phase 02 remains **ACCEPTED** with its separate owner-reported physical-device PASS. Phase 04–09 remain planned and are not authorized.

This current section supersedes all earlier pre-authorization statements in this historical status record that Phase 03 had not started or was not authorized. It does not mark Phase 03 owner-accepted or merged.
