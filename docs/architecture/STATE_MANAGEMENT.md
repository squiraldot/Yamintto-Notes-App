# State management and dependency injection

Current: flutter_riverpod is a dependency and root ProviderScope wraps app. No feature providers/controllers exist.

Planned:
- Root providers compose config, database, repositories and platform interfaces in `lib/app/providers`.
- Feature providers expose controllers/notifiers; widgets use `ref.watch` for state and `ref.read` for commands.
- State distinguishes loading, data, empty and failure; failed saves retain editable drafts.
- Domain entities/use cases remain Flutter-independent. Controllers orchestrate use cases and map failures to UI-safe state.
- Provider lifetime matches resource lifetime. Dispose streams, subscriptions, DB handles and transient decrypted search index. Do not retain decrypted content beyond unlock session.
- Tests override providers with deterministic fakes; use in-memory Drift for DAO/repository behavior. Test disposal, overlapping commands, stale async results and cancellation.
No Riverpod generator/codegen pattern is implemented; choose/document it before adoption.
