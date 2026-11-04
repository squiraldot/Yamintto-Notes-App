# Integration testing

Current `integration_test/` contains README only. CI skips this suite until a `*_test.dart` file exists. Do not count the conditional skip as test success.

## Device/end-to-end scenarios
1. Fresh launch -> create folder/note -> edit -> autosave -> force stop/relaunch -> content intact.
2. Rapid consecutive edits/background/foreground/process kill -> latest acknowledged revision survives.
3. Search results update on create/edit/move/trash/restore; pin order survives restart.
4. Trash restore preserves relationships; permanent deletion cleans revisions/tags/attachments according to approved policy.
5. Markdown source/viewer round-trip on both platforms.
6. Revision restore creates a new current revision.
7. Phase 05 attachment import/open/export/delete; interruption/storage-full cleanup. Until Phase 06, bytes are plaintext beta files; test must not imply production confidentiality.
8. Phase 06 migration: encrypt notes/revisions/attachments; kill at each migration stage; restart/resume/rollback; inspect DB/FTS/files/temp/previews/logs/backups for plaintext.
9. Phase 06 password recovery on clean install; separately recovery-key recovery; wrong credential and interrupted rotation.
10. Search unlocked transient index; lock clears it; content search blocked while locked; unlock rebuilds results without persisted plaintext index.
11. Phase 07 app lock vs vault lock; biometric cancellation, unavailable, lockout, enrollment change and device migration.
12. Phase 08 encrypted backup round-trip; corrupt/truncated/unknown version; interrupted restore leaves prior DB usable.
13. Phase 08 legacy ZIP golden fixtures; malformed/path traversal/decompression bomb; imported/skipped report.
14. Phase 09 settings/theme/font persistence after restart; OS theme changes and system text scaling.

Use isolated DB/files and deterministic fixtures. Run Android emulator/physical and iOS simulator/physical suites separately. Biometric/secure-storage assertions require real supported devices; simulator is supplementary.
