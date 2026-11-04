# ADR-0007: Independent password and recovery-key recovery

- Status: Accepted
- Date: 2026-11-04

## Context
A single forgotten password or lost device must not automatically destroy access when an independent recovery route remains.

## Decision
Provide BOTH password-based recovery and a separate high-entropy recovery-key path. Each independently restores access to the master key.

## Alternatives
Password only; recovery key only; device-bound key only.

## Consequences
Both routes must be tested independently on a clean device. Rotation must be interruption-safe. If both credentials and every valid key copy are lost, data is unrecoverable. Implementation and wrapping protocol are pending review.
