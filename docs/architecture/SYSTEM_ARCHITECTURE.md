# System architecture

## Current implementation (Phase 01)

lib/main.dart calls bootstrap(); bootstrap initializes Flutter binding and runs ProviderScope(child: YaminttoApp()). The root app creates one GoRouter instance and a ValueNotifier for an in-memory theme preview. MaterialApp.router receives Material 3 light and dark/AMOLED themes. GoRouter starts at /splash, then SplashScreen navigates to / (FoundationScreen). Unknown locations show a recoverable not-found surface.

Core theme tokens are centralized under lib/core/theme/tokens/. Reusable app-shell primitives are under lib/core/widgets/. Theme selection is not persisted; Phase 09 owns preferences. The foundation screen exists only to verify the startup/navigation/theme shell.

No DB, repository, feature controller, domain model, encryption, biometric or product workflow exists.

## Planned architecture

- Presentation calls Riverpod controllers.
- Domain owns rules/use cases/repository contracts.
- Data owns Drift DAOs, repository implementations, file storage and native adapters.
- Features do not import another feature's private data layer.
- Multi-record writes use transactions.
- Native APIs stay behind narrow platform adapters.
- Tests use fakes/in-memory DB for unit boundaries, provider overrides for widgets, integration tests for real persistence/files/router, and physical devices for hardware security.

This is target architecture, not implemented architecture.
