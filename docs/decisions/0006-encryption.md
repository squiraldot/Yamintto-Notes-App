# ADR-0006: Encryption and key requirements

- Status: Accepted as requirements; protocol pending security review
- Date: 2026-11-04

## Context
Local notes, revisions, attachments and backups require confidentiality and integrity.

## Decision
Require AES-256-GCM, a fresh unique nonce for each encryption operation, a random 256-bit master key, Argon2id password KDF, secure key wrapping and Android Keystore/iOS Keychain integration. No plaintext note/attachment content or persistent plaintext full-text index may remain after Phase 06 migration.

## Alternatives
Custom unreviewed cryptography; unauthenticated encryption; plaintext persistent content; retaining plaintext FTS after encryption.

## Consequences
No implementation exists. Exact cipher package, nonce strategy, AAD, KDF parameters, wrapping protocol, envelope version, key rotation and native access flags require independent security review. See [encryption specification](../security/ENCRYPTION_SPECIFICATION.md) and [key management](../security/KEY_MANAGEMENT.md).
