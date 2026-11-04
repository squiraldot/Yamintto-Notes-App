# Testing strategy and execution matrix

## Current evidence
Flutter CI runs locked dependency resolution, repository-wide format, analyzer, `flutter test`, and the Phase 01 integration smoke test on an Android API 35 emulator. The emulator suite is app-shell coverage only. Physical Android/iOS device evidence and iOS native compilation remain separate gates.

## Test layers
| Layer | Purpose | Environment | CI expectation |
|---|---|---|---|
| Unit | Domain rules, repositories, mapping, parser, KDF/crypto wrappers, migrations | host VM, fakes, in-memory DB | run on every CI |
| Widget | UI state, navigation, validation, accessibility semantics | Flutter test binding, provider overrides | run on every CI |
| Integration | Real DB/files/lifecycle/import/restore end-to-end | Android emulator in CI; simulator or attached device for platform-specific runs | Phase 01 app-shell smoke runs on Android emulator; extend by feature phase |
| Physical-device | Keystore/Keychain, biometrics, lifecycle, file provider, OS behavior | real supported Android and iOS hardware | manual/release gate; not inferred from emulator CI |
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
A successful Flutter CI run proves only its executed steps. Android emulator smoke coverage proves the app-shell integration scenario on the configured API level, not physical OEM/device behavior. Android debug artifact workflow is a separate build, not test coverage. iOS requires macOS/Xcode and physical-device validation; Linux CI does not prove it.
