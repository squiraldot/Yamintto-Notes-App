# ADR-0003: Drift and SQLite

- Status: Accepted
- Date: 2026-11-04

## Context
The app requires relational local persistence, transactions and schema migrations.

## Decision
Use Drift over SQLite for typed local data access and migration support.

## Alternatives
Raw SQLite; another ORM; remote database as primary store.

## Consequences
Drift/SQLite packages are configured. No schema, DAOs, generated code or migrations currently exist. Proposed schema is in [DATABASE_SCHEMA](../database/DATABASE_SCHEMA.md).
