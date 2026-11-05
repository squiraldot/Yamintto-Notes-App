# Documentation and implementation status

Snapshot: 2026-11-06; branch: `main`; Phase 01 evidence baseline: `76ba10c04f0ec421f54e5d6252dd6745058611f9`; Phase 02 owner baseline: `92dcadd7ed2bd2ee9b49ca8893843b13a689bb7e`; Phase 02 source implementation commit: `36a27212dadda99fbb7bb333a93a3568c967869d`; this status snapshot is a documentation-only reconciliation.

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

