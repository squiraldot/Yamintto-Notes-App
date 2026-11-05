# PLATFORM_SUPPORT

Android host: Kotlin MainActivity/FlutterActivity, namespace/application ID com.merrmist.yamintto, AGP 8.11.1, Kotlin 2.2.20, Gradle 8.14.3, Java 17; Flutter supplies SDK defaults. Phase 01 keeps this identity and native host configuration unchanged. Owner-reported; detailed evidence not attached. The owner reports successful real-device Android testing. This is owner-reported evidence, separate from host CI and APK artifact builds.

iOS host: Swift FlutterAppDelegate, bundle ID com.merrmist.yamintto, Podfile and Xcode Runner project, iOS deployment target 13.0. Phase 01 keeps the bundle identity and host configuration unchanged. No macOS/Xcode build or device verification has been verified. Status: Not Verified — Environment Unavailable. Continue iOS implementation/configuration alongside shared Flutter development in applicable phases; this verification gap does not block Android-focused phase progression.

The splash route is rendered by Flutter after native engine startup; the existing native launch screen remains the platform handoff. Do not claim native launch-screen/device behavior without platform builds and physical-device evidence. Keep shared Dart logic platform-neutral and native secure storage/biometrics/file access behind adapters.
