# Integration testing

## Current Phase 01 coverage

- `integration_test/app_smoke_test.dart` launches the real Yamintto app widget tree.
- Verifies splash is the first route, startup transitions to the foundation placeholder, and the AMOLED preview applies a dark theme with true-black surfaces.
- The test is retained for owner-run validation on a connected physical Android device; it is not run in GitHub Actions.
- This is app-shell smoke coverage only. It does not validate physical-device installation, OEM behavior, iOS native compilation, persistence, or product workflows.

## Device/end-to-end scenarios by phase
1. Phase 01: cold app launch -> splash -> foundation route -> theme preview; owner physical-device run. Physical Android and iOS smoke remain pending.
2. Fresh launch -> create folder/note -> edit -> autosave -> force stop/relaunch -> content intact.
3. Rapid consecutive edits/background/foreground/process kill -> latest acknowledged revision survives.
4. Search results update on create/edit/move/trash/restore; pin order survives restart.
5. Trash restore preserves relationships; permanent deletion cleans revisions/tags/attachments according to approved policy.
6. Markdown source/viewer round-trip on both platforms.
7. Revision restore creates a new current revision.
8. Phase 05 attachment import/open/export/delete; interruption/storage-full cleanup. Until Phase 06, bytes are plaintext beta files; test must not imply production confidentiality.
9. Phase 06 migration: encrypt notes/revisions/attachments; kill at each migration stage; restart/resume/rollback; inspect DB/FTS/files/temp/previews/logs/backups for plaintext.
10. Phase 06 password recovery on clean install; separately recovery-key recovery; wrong credential and interrupted rotation.
11. Search unlocked transient index; lock clears it; content search blocked while locked; unlock rebuilds results without persisted plaintext index.
12. Phase 07 app lock vs vault lock; biometric cancellation, unavailable, lockout, enrollment change and device migration.
13. Phase 08 encrypted backup round-trip; corrupt/truncated/unknown version; interrupted restore leaves prior DB usable.
14. Phase 08 legacy ZIP golden fixtures; malformed/path traversal/decompression bomb; imported/skipped report.
15. Phase 09 settings/theme/font persistence after restart; OS theme changes and system text scaling.

Use isolated DB/files and deterministic fixtures. Run on owner-provided physical Android and iOS devices. Biometric/secure-storage assertions require real supported devices; no virtual-device fallback.

## Owner-run physical-device execution
The owner connects and authorizes a real physical Android/iOS device. Run flutter devices, identify the physical device ID, then run:

    flutter test integration_test -d <physical-device-id>

Record device model, OS version, app/build SHA, command and actual result. Do not use an emulator or simulator as a fallback. If no physical device is available, mark the test pending and ask the owner to run it. AI agents must not create/configure virtual devices, add emulator-runner/KVM steps, or change CI to use virtual devices.
