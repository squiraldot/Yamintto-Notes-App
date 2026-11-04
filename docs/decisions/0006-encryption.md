# ADR -enc: AES-256-GCM and key requirements

- Status: Accepted
- Date: 2026-11-04

## Context
Need confidentiality and integrity.

## Decision
Require AES-256-GCM, unique nonce, random 256-bit master key, Argon2id, secure wrapping, Android Keystore/iOS Keychain; validate exact protocol/parameters before coding.

## Alternatives
Custom unreviewed crypto; unauthenticated encryption; plaintext storage.

## Consequences
Security review, envelope version, nonce/KDF design, vectors and rotation required. Not implemented.

This ADR is a decision record, not evidence that the capability is implemented.
