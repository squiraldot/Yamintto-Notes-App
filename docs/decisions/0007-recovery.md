# ADR -rec: Password and recovery key

- Status: Accepted
- Date: 2026-11-04

## Context
Avoid a single credential/device being the only recovery route.

## Decision
Both password-based and independent recovery-key recovery.

## Alternatives
Password only; recovery key only; device-only.

## Consequences
Either route should independently recover master key; if both and all copies lost, recovery cannot be promised. Not implemented.

This ADR is a decision record, not evidence that the capability is implemented.
