# DEBUG_APK_GUIDE

## Local builds
Universal debug APK:

```sh
flutter pub get --enforce-lockfile
flutter build apk --debug
```

ARM64-only debug APK:

```sh
flutter pub get --enforce-lockfile
flutter build apk --debug --target-platform android-arm64
```

Both commands write `build/app/outputs/flutter-apk/app-debug.apk`; use separate output directories or copy/rename the local outputs if building both locally so one does not overwrite the other.

## GitHub Actions artifacts
Exactly three protected workflows exist. One is host-only Flutter CI; the other two protected artifact workflows run automatically after successful **Flutter CI** completion on `main` or `dev`. Both artifact workflows check out the exact CI-tested SHA, use Flutter 3.47.9 and retain artifacts for 14 days:
- **Yamintto Debug APK**: universal multi-ABI APK. Artifact: `yamintto-debug-<sha>`.
- **ARM64-only Debug APK**: `android-arm64` APK for compatible 64-bit Android devices. Artifact: `yamintto-arm64-debug-<sha>`.

Open GitHub Actions, select the relevant workflow and successful run, then download its artifact. Keep both workflows; do not delete, rename, disable, merge or replace either without explicit owner authorization. The universal workflow remains unchanged.

Beta policy: Debug APK only. No release APK/AAB, release signing or publishing. Neither artifact workflow runs emulator/simulator tests; test on a real physical device separately.
