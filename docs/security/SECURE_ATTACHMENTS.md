# SECURE_ATTACHMENTS

No attachment feature exists. Import through platform document providers; validate size/type/name; encrypt bytes before persistence; unique nonce; persist encrypted blob and only approved metadata; avoid plaintext temp files; transactional association and safe orphan cleanup; backup includes ciphertext/integrity data. Test tampering, interrupted import, duplicate names, cleanup, storage full and platform pickers.
