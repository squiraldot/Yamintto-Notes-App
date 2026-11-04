# Biometric authentication

Requirement: **APP + VAULT**, two distinct authorization scopes. Neither is implemented.

## App lock
Gates entry to Yamintto UI. Define inactivity timeout, background relock, device credential fallback, cancellation, lockout, unavailable hardware and app restart behavior. App lock alone is not encryption and must not be represented as protecting ciphertext if key access remains available.

## Vault lock
Separate gate for vault content/key. Unlocking app must not automatically unlock vault. Use separately scoped platform authorization/key reference and policy; exact key separation and wrapping require security review. If vault biometric key is invalidated, vault stays locked until a valid password/recovery route restores access.

## Android
Investigate BiometricPrompt authenticators, device credential fallback, Keystore auth-bound key flags, invalidation on enrollment changes, API-level differences and OEM behavior. Hardware-backed key storage is not universal; do not promise StrongBox/TEE.

## iOS
Investigate LocalAuthentication policy, Keychain access control, biometric-set invalidation, passcode requirement, accessibility class and device migration. Secure Enclave availability is not universal.

## Test matrix
Success, no enrolled biometric, unsupported hardware, cancellation, lockout, device credential fallback, biometric enrollment add/remove, passcode removal/change, app reinstall, device migration, OS upgrade and app/vault independence. Unit/widget tests cover policy and UX; **physical Android and iOS devices are mandatory** for native key/invalidation evidence. Simulator tests are supplementary.
