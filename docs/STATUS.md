# Documentation and implementation status

Snapshot: 2026-11-05; branch: `main`; Phase 01 evidence baseline: `76ba10c04f0ec421f54e5d6252dd6745058611f9`; Phase 02 audit starting HEAD: `e1c886ade7eb078049a6303ccfd2f6de72527e1b`.

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
- GoRouter splash route -> temporary foundation route; unknown-route recovery.
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

## Latest GitHub Actions evidence

All three successful runs below target the same audited commit `76ba10c04f0ec421f54e5d6252dd6745058611f9` on `main`.

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

Phase 02–09 implementation remains not started unless separately authorized. No Phase 02 feature is included in this documentation reconciliation.

## Workflow policy

Exactly three protected workflows must remain. ADR-0012 supersedes ADR-0009's original two-workflow decision. Preserve all three files; do not delete, rename, disable, modify, merge or add workflows without explicit owner authorization.

## Beta and production status

Beta policy remains Debug APK only: no release APK/AAB, release signing or publishing. Production readiness has not been achieved. Security, encryption, recovery, biometric, backup and data workflows remain future-phase requirements, not implemented functionality.


## Phase 02 — Pre-implementation architecture review (2026-11-05)

**Status: Documentation review recorded; decision freeze NOT complete; implementation NOT started. Owner approval is required before a separate Phase 02 implementation prompt.**

- Audited starting HEAD: `e1c886ade7eb078049a6303ccfd2f6de72527e1b` on `main`.
- Source includes Phase 01 bootstrap, Riverpod root scope, YaminttoApp, themes/widgets and foundation routes. `lib/core/database/README.md` is guidance only.
- pubspec and lockfile contain Drift/SQLite dependencies; there is no DB class, Drift table, DAO, generated schema, repository, schema version, executable migration or notes/folders CRUD.
- Existing three protected workflows were inspected and are unchanged.
- ADR-0002 accepts offline-first; ADR-0003 accepts Drift/SQLite; ADR-0011 defines post-encryption search privacy; ADR-0012 protects three workflows and supersedes ADR-0009.
- Previous schema draft mixed Phase 02 with future revisions, attachments, tags, trash, encryption metadata and settings. It also omitted exact nullability/defaults, FK actions, ID/time formats, ordering, schema version and folder deletion behavior.
- Proposed schema v1 now contains only folders and notes. Row-level deleted_at provides soft-delete foundation; future tables remain in their owning phases. SQLite WAL/journal/temp/index plaintext migration is explicitly called out for Phase 06.
- See [Phase 02 decision register](database/PHASE_02_DECISION_REGISTER.md). Blocking owner decisions include schema v1, UUID/timestamps, folder deletion, note soft-delete/restore, hierarchy/name rules, ordering, FK/transactions, migration policy and retention.
- No Phase 02 application implementation is complete or started. Do not mark this phase frozen or authorize implementation until owner approval.


## Phase 02 — Owner-approved architecture decision freeze (2026-11-05)

**Status: COMPLETE — all Phase 02 implementation-blocking architecture decisions have explicit owner approval. Application implementation remains NOT STARTED and requires a separate explicit authorization.**

- Owner reviewed the Phase 02 decision register, ADR-0013, schema, migration policy and retention policy, then approved the baseline with amendments.
- Accepted amendments: maximum folder depth 32 (virtual root level 0); folder names max 255 Unicode code points; note titles max 255 Unicode code points; case-insensitive sibling folder-name uniqueness using a Unicode NFKC_Casefold canonicalizer and root-aware DB unique constraint; unique names remain reserved while folders are soft-deleted.
- Folder deletion: empty-folder-only; reject if any child folder or any note including soft-deleted notes exists; soft-delete only.
- Notes soft-delete from schema v1 and retain folder/order. Active lists/default search exclude deleted notes; edit/move requires restore.
- Phase 04 Trash must include both deleted notes and folders, support restore and explicit permanent deletion. Note restore uses original folder/order or root with explicit conflict result if unavailable.
- Soft-deleted records are retained indefinitely initially. No automatic expiry or cleanup. Permanent deletion is future-phase work and is NOT a Phase 02 blocker; Phase 05 adds revision/attachment dependent cleanup.
- Phase 02 schema v1 is limited to folders and notes. Drift/SQLite, UUID v4, UTC Unix milliseconds, 32-level hierarchy, transactional moves, FK RESTRICT, explicit ordering and forward-only fail-closed migrations are accepted.
- Updated authoritative documents: decision register, ADR-0013, database schema, migration policy, data retention, product requirements, feature catalog and phase roadmap.
- **No Phase 02 implementation has been authorized or started.** The next step is a separate owner-issued implementation prompt.

