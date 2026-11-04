# ADR-0005: GoRouter

- Status: Accepted
- Date: 2026-11-04

## Context
Navigation needs centralized, testable route configuration.

## Decision
Use GoRouter.

## Alternatives
Imperative Navigator; another declarative router.

## Consequences
One foundation route exists; product routes, deep links and auth guards do not.
