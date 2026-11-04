# ADR-0001: Flutter native application

- Status: Accepted
- Date: 2026-11-04

## Context
Yamintto is a new mobile application and is independent of the existing YRNotes web app.

## Decision
Use Flutter/Dart for native Android and iOS application development. Keep YRNotes separate and untouched.

## Alternatives
WebView wrapper; conversion of the existing web app; separate native codebases.

## Consequences
Shared Dart UI/business logic with isolated native hosts. Host scaffolding exists; product features do not. iOS build remains pending macOS/Xcode verification.
