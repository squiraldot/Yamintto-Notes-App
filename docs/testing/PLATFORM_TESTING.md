# Platform testing matrix

## CI versus device evidence
Flutter CI runs on Ubuntu with Flutter 3.47.9: locked dependency resolution, Dart format, analyzer, Flutter unit/widget tests; integration test command runs only if test files exist. This does not test iOS native compilation or hardware security. Debug APK workflow builds the Android debug artifact after CI; build success is not device validation.

## Android
| Area | Required evidence |
|---|---|
| Build/install | Debug APK build, install, cold launch, upgrade and uninstall/reinstall |
| UI/lifecycle | back, keyboard/insets, rotation, background/foreground, process death, large text |
| Storage | SQLite persistence, SAF/content URI, revoked permissions, low storage |
| Security | Keystore availability/hardware backing, BiometricPrompt fallback, enrollment invalidation, app/vault lock separation |
| Regression | DB migration, encryption, search lock lifecycle, attachment, backup restore |

Test representative supported API levels and OEMs. Do not promise StrongBox/TEE universally.

## iOS
**Native build validation is pending: no macOS/Xcode build has been verified.** After macOS runner is available, verify Flutter iOS Debug build, CocoaPods, Runner scheme, simulator launch, then physical iPhone/iPad.
| Area | Required evidence |
|---|---|
| Build/install | Xcode/Flutter Debug build and install on simulator/device |
| UI/lifecycle | scene/app lifecycle, navigation, keyboard, rotation, large text |
| Storage | SQLite, document picker, sandbox/file protection |
| Security | Keychain accessibility, LocalAuthentication, biometric-set invalidation, passcode/device migration |
| Regression | migrations, encryption, search, attachments, backup/restore |

## Cross-platform gate
Run identical product scenarios on both OSes; document native exceptions. Physical-device biometrics/secure storage are mandatory. Simulator evidence does not substitute for hardware. Record device model, OS version, build SHA, steps and outcome without logging sensitive values.
