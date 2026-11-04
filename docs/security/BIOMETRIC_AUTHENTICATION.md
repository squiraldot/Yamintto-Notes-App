# BIOMETRIC_AUTHENTICATION

Both app-level biometric protection and separate vault biometric lock are required; neither exists. Android direction: BiometricPrompt/Keystore; iOS: LocalAuthentication/Keychain. Define biometric classes, device-credential fallback, timeout, relock, lockout, enrollment changes, unavailable hardware, reinstall and device migration. Never silently expose a vault key after biometric invalidation. Test physical devices; simulator does not prove hardware-backed behavior.
