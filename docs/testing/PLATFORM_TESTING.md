# Platform testing matrix

## CI versus device evidence
Flutter CI runs on Ubuntu with Flutter 3.47.9: locked dependency resolution, Dart format, analyzer, Flutter unit/widget tests only. Integration/E2E and hardware-specific checks are owner-run on real physical devices. Host CI does not validate physical OEM behavior, iOS native compilation or hardware security. Debug APK workflow builds the Android debug artifact after CI; build success is not device validation.

## Android
| Area | Required evidence |
|---|---|
| Build/install | Debug APK build, install, cold launch, upgrade and uninstall/reinstall |
| UI/lifecycle | back, keyboard/insets, rotation, background/foreground, process death, large text |
| Storage | SQLite persistence, SAF/content URI, revoked permissions, low storage |
| Security | Keystore availability/hardware backing, BiometricPrompt fallback, enrollment invalidation, app/vault lock separation |
| Regression | DB migration, encryption, search lock lifecycle, attachment, backup restore |

CI covers only host-runnable unit/widget checks. Test representative supported API levels and OEMs on physical hardware before platform acceptance. Do not promise StrongBox/TEE universally.

## iOS
**Native build validation is pending: no macOS/Xcode build has been verified.** After macOS/Xcode is available, the owner should verify Flutter iOS Debug build, CocoaPods, Runner scheme, then install/launch on a physical iPhone/iPad.
| Area | Required evidence |
|---|---|
| Build/install | Xcode/Flutter Debug build and install on physical device |
| UI/lifecycle | scene/app lifecycle, navigation, keyboard, rotation, large text |
| Storage | SQLite, document picker, sandbox/file protection |
| Security | Keychain accessibility, LocalAuthentication, biometric-set invalidation, passcode/device migration |
| Regression | migrations, encryption, search, attachments, backup/restore |

## Cross-platform gate
Run identical product scenarios on physical Android and iOS devices; document native exceptions. Physical-device biometrics/secure storage are mandatory. Record device model, OS version, build SHA, steps and outcome without logging sensitive values.

## Physical-device-only validation
GitHub Actions must remain host-only and must not provision or run Android emulators or iOS simulators. The owner performs platform integration/E2E testing on real physical devices. For Android integration tests, connect the device, run flutter devices, then flutter test integration_test -d <physical-device-id>. AI agents must not create/use virtual devices or add KVM/emulator-runner steps. If a physical device is unavailable, report testing as pending.
