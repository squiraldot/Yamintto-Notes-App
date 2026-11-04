# SYSTEM_ARCHITECTURE

Current flow: main.dart -> bootstrap -> ProviderScope -> YaminttoApp -> MaterialApp.router -> GoRouter '/' -> FoundationScreen. Target flow: presentation -> Riverpod controller -> domain use case/repository interface -> data repository -> Drift/SQLite/files/native adapters. Feature-first Clean Architecture is intended, not fully implemented. Keep UI free of SQL/native details; domain free of Flutter dependencies; native services behind Dart interfaces. No network dependency for core offline notes.
