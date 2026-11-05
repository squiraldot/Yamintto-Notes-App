# State management and dependency injection

## Current implementation

- `flutter_riverpod` is installed and root `ProviderScope` wraps the app.
- `databaseProvider` is a lazy, app-scoped `FutureProvider` that owns the single Drift database instance and closes it when disposed.
- `folderRepositoryProvider` and `noteRepositoryProvider` compose repositories from that shared database provider; they do not create separate database instances.
- Presentation list/detail providers live under each feature's `presentation/` directory and expose folder lists/details and active note lists/details as `AsyncValue` states.
- Screens call repository domain operations through Riverpod providers. They do not receive the raw database handle or execute SQL.
- Mutations invalidate affected list/detail providers so the active UI refreshes after create, rename, move, delete and save.
- Loading, empty, error/retry and populated states are represented in the folder browser and note editor.
- Failed note saves retain the editor controllers and show UI-safe feedback.
- The note editor owns and disposes its text controllers and guards unsaved changes on route pop.

## Constraints and follow-up

- Do not introduce another state-management framework or a second database owner.
- Repositories remain the data boundary; raw Drift handles and transaction objects must never reach presentation.
- Future controllers/use cases may be introduced only where they materially improve orchestration; do not create duplicate repository/provider layers.
- Test provider overrides, invalidation, disposal, async races and cancellation. Integration tests remain owner-run on real physical devices.
