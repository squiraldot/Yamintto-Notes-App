# DEBUG_APK_GUIDE

Local: `flutter pub get --enforce-lockfile` then `flutter build apk --debug`; expected `build/app/outputs/flutter-apk/app-debug.apk`. GitHub: Actions -> Yamintto Debug APK -> successful run -> Artifacts -> download `yamintto-debug-<sha>`; retention 14 days. Workflow builds exact CI-tested SHA with Flutter 3.47.9 after successful CI on main/dev. Beta only debug APK; no release APK/AAB/signing/publishing. Test on physical device separately.
