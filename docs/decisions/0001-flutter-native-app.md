# ADR -flu: Flutter native application

- Status: Accepted
- Date: 2026-11-04

## Context
Yamintto is a new mobile product independent of YRNotes.

## Decision
Use Flutter/Dart for native Android/iOS; keep YRNotes separate.

## Alternatives
WebView wrapper; convert old web app; two native codebases.

## Consequences
Shared UI/logic with isolated native hosts. Scaffold exists; features do not.

This ADR is a decision record, not evidence that the capability is implemented.
