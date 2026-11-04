# ADR-0002: Offline-first architecture

- Status: Accepted
- Date: 2026-11-04

## Context
Core note creation, reading, editing and organization must work without network connectivity.

## Decision
Local-first persistence; no mandatory network dependency for core workflows.

## Alternatives
Cloud-first or mandatory account/network for core notes.

## Consequences
Local integrity, migration, encryption and user-controlled backup are critical. Database is not yet implemented.
