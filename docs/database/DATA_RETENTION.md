# Data retention and deletion

Retention is not implemented; exact periods/limits require product approval.

Decide trash expiry; revision count/age; attachment size/type and orphan cleanup; backup temp cleanup; migration staging cleanup; transient search-index lifetime; old key metadata retirement. Do not silently expire user data.
Soft delete retains enough metadata to restore original folder/order. Permanent delete removes dependent rows and blobs safely; references prevent deleting shared data. Use DB transactions plus staged file cleanup; on failure keep recoverable cleanup marker.
After Phase 06 remove ciphertext and any plaintext temp/cache copies. Secure overwrite on flash storage cannot be guaranteed; never promise forensic erasure. Clear in-memory decrypted content/search on lock; Dart zeroization guarantees require review. No secrets in ordinary settings. Test retention boundaries, restore conflicts, crash cleanup and attachment references.
