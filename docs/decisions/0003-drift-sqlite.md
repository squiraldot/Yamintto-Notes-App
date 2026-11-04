# ADR -dri: Drift and SQLite

- Status: Accepted
- Date: 2026-11-04

## Context
Need relational local persistence, transactions and migrations.

## Decision
Use Drift over SQLite.

## Alternatives
Raw SQLite; alternative ORM; remote DB.

## Consequences
Dependencies configured; no schema/DAOs/migrations exist.

This ADR is a decision record, not evidence that the capability is implemented.
