# ADR-0004: Riverpod

- Status: Accepted
- Date: 2026-11-04

## Context
The app needs testable state management and dependency injection.

## Decision
Use Riverpod/flutter_riverpod.

## Alternatives
Bloc; Provider; GetX; ad hoc local state.

## Consequences
Root ProviderScope exists. Feature providers/controllers do not yet exist. Generator strategy remains undecided.
