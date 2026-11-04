# Platform architecture

## Verified hosts
Android: MainActivity extends FlutterActivity; namespace/application ID `com.merrmist.yamintto`; AGP 8.11.1, Kotlin 2.2.20, Gradle 8.14.3, Java 17. Flutter supplies compile/min/target SDK and NDK defaults. Manifest label Yamintto.
iOS: Swift FlutterAppDelegate, Runner Xcode project/shared scheme, bundle ID `com.merrmist.yamintto`, iOS deployment target 13.0 in Podfile/project. **No macOS/Xcode build verified; iOS native build validation pending.**

## Planned adapters
Shared Dart interfaces for secure key storage, biometric authorization, file/document access and lifecycle. Android: Keystore/BiometricPrompt and Storage Access Framework/content URIs. iOS: Keychain/LocalAuthentication and document provider. Exact flags, access groups, accessibility classes, invalidation and fallback guarantees require platform-version review. Plugin API does not prove hardware-backed storage.
Keep native APIs out of domain/widgets. Use opaque app-owned file references, not assumed cross-platform paths. Validate on physical devices; simulator is supplementary. Android CI does not prove iOS build.
