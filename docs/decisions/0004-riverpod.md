# ADR -riv: Riverpod

- Status: Accepted
- Date: 2026-11-04

## Context
Need explicit state and dependency wiring.

## Decision
Use Riverpod/flutter_riverpod.

## Alternatives
Bloc; Provider; GetX; local-only state.

## Consequences
Root ProviderScope exists; feature providers do not.

This ADR is a decision record, not evidence that the capability is implemented.
