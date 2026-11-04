# ADR-0008: App and vault biometric protection

- Status: Accepted
- Date: 2026-11-04

## Context
Yamintto needs both application access control and a distinct vault authorization boundary.

## Decision
Provide APP + VAULT biometric protection. App unlock must not implicitly unlock vault.

## Alternatives
App lock only; vault lock only; password-only protection.

## Consequences
Both policies and key scopes must be separately defined. Android/iOS native invalidation and fallback require current platform review and physical-device tests. Neither integration exists yet.
