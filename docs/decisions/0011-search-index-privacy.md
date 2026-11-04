# ADR-0011: Search index privacy lifecycle

- Status: Accepted
- Date: 2026-11-04

## Context
Phase 04 search precedes Phase 06 encryption. A persistent plaintext full-text index could retain note content after note bodies are encrypted.

## Decision
Allow the Phase 04 index only as a pre-encryption implementation detail, subject to verified SQLite engine support. Phase 06 migration must remove persistent plaintext FTS/token/snippet/cache structures. After encryption, content search is available only while unlocked through a transient in-memory index built from decrypted records; clear it on lock. Locked search is unavailable. No encrypted-search protocol is approved.

## Alternatives
Keep plaintext FTS after encryption; invent encrypted-search protocol; disable content search permanently.

## Consequences
Phase 06 includes index migration, storage scans and lock/unlock tests. Large note collections may require batched decryption and have startup/search latency and memory cost; benchmark on low-memory devices. This decision does not claim implementation.
