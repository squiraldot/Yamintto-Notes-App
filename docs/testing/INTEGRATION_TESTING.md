# Integration testing

## Current Phase 01 coverage

- `integration_test/app_smoke_test.dart` launches the real Yamintto app widget tree.
- It verifies splash as the initial route, startup transition to the foundation placeholder, and AMOLED preview with true-black surfaces.
- This test source is retained for owner-run physical-device execution. It is **not** run in GitHub Actions.
- Source presence does not prove execution. The owner reports successful real-device Android testing; detailed device evidence is not attached.
- This app-shell smoke test does not establish iOS native compilation or validate future product workflows.

## CI policy — fixed

- No Android emulator in GitHub Actions.
- No iOS simulator in GitHub Actions.
- No KVM, virtual-device runner, emulator boot or simulator provisioning.
- No AI-created or AI-operated virtual-device testing.
- Flutter CI runs host-only dependency resolution, formatting, analyzer and unit/widget tests.
- The universal and ARM64 APK workflows compile and upload artifacts only; they do not run device tests.
- Preserve integration test source; do not delete it to reflect the CI policy.

## Device/end-to-end scenarios by phase

1. Phase 01: cold launch -> splash -> foundation route -> theme preview; owner physical Android test. Detailed evidence is not attached. iOS build/device verification is environment-unavailable and non-gating.
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

Use isolated DB/files and deterministic fixtures. Run applicable integration scenarios on owner-provided physical devices only. Biometric/secure-storage assertions require real supported hardware; no virtual-device fallback.

## Owner-run physical-device execution

The owner connects and authorizes a real physical device. Run:

```sh
flutter devices
flutter test integration_test -d <physical-device-id>
```

Record device model, OS version, app/build SHA, command, tested scenarios and actual result when available. Never use an emulator or simulator as a fallback. If a physical device is unavailable, leave that particular test pending and ask the owner to run it. AI agents must not create/configure virtual devices, add emulator-runner/KVM steps, or change CI to use virtual devices.

## iOS verification

Continue implementing iOS-compatible shared/native code and configuration throughout applicable phases. Native iOS build/device verification is labelled **Not Verified — Environment Unavailable** when macOS/Xcode is unavailable. Do not claim success or make this unavailable verification a blocker for Android-focused phase progression.


## Phase 02 owner acceptance record

**OWNER-REPORTED — PHASE 02 ANDROID PHYSICAL-DEVICE SMOKE TEST PASSED.** Source: explicit owner confirmation in the current project conversation. This is manual owner-reported smoke testing, not an independently verified device log. No device model, Android version, test date, command output, screenshots or logs are asserted. The file `integration_test/phase_02_data_smoke_test.dart` exists; execution of that automated integration-test source is not evidenced and is not claimed. Phase 02 acceptance does not depend on claiming that source was executed.
