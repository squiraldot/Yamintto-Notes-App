# ADR-0012: Three protected workflows with an ARM64-only Debug APK artifact

- Status: Accepted
- Date: 2026-11-05
- Supersedes: The two-workflow limit in ADR-0009

## Context
The project owner tests beta builds on a Redmi Note 10S running Android 13 / MIUI 14 with a 64-bit ARM processor. The existing universal Debug APK workflow must remain unchanged for broad Android ABI compatibility, while an additional smaller ARM64-targeted artifact is useful for this physical test device. The owner explicitly authorized adding a third workflow and documenting it as protected.

## Decision
Maintain exactly these three protected GitHub Actions workflows:

1. `.github/workflows/flutter-ci.yml` — host-only dependency, formatting, analysis and unit/widget validation.
2. `.github/workflows/yamintto-debug-apk.yml` — existing universal Android Debug APK artifact; do not modify as part of this addition.
3. `.github/workflows/yamintto-arm64-debug-apk.yml` — ARM64-only Android Debug APK artifact.

The two APK workflows trigger automatically when the named Flutter CI workflow completes successfully on `main` or `dev`. Each checks out the exact commit SHA tested by Flutter CI, uses Flutter 3.47.9, resolves locked dependencies, builds only a Debug APK and uploads an artifact with 14-day retention.

The ARM64 build command is `flutter build apk --debug --target-platform android-arm64`. Its artifact is named `yamintto-arm64-debug-<sha>`. The universal workflow remains unchanged and continues to produce `yamintto-debug-<sha>`.

All three workflows are protected project infrastructure. AI agents must not delete, rename, disable, merge, replace or omit them from project documentation without explicit owner authorization. No additional workflow may be introduced without explicit owner authorization.

## Alternatives
- Replace the universal workflow with an ARM64-only workflow: rejected because it would remove broad ABI coverage.
- Build every ABI separately in multiple extra workflows: rejected as unnecessary workflow complexity.
- Add emulator/simulator jobs: rejected; all integration and E2E testing remains owner-run on real physical devices.
- Change the existing universal workflow: rejected; it remains untouched.

## Consequences
The repository has three workflows. A successful Flutter CI run on `main` or `dev` should automatically trigger both APK artifact workflows. The ARM64 artifact excludes x86_64 and ARMv7 native libraries, but its actual final size and installation/runtime behavior still require verification on the owner's physical Redmi Note 10S. The workflow does not run device tests and does not establish physical-device acceptance. Beta remains Debug APK only; no release APK/AAB, signing or publishing is allowed.
