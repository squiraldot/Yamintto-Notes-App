# Routing and navigation

Current: `lib/app/router/app_router.dart` has one named `/` route to FoundationScreen. No product routes, auth guards, nested routes or deep links exist.

Planned:
- Centralize paths/names and typed route parameters in app router; builders compose screens only.
- Guards derive from observable auth/lock state. Never put secrets or note content in URLs/route extras.
- App lock and vault lock are distinct gates. Restore deep-link destination only after required unlock.
- Domain logic stays out of builders. Controllers coordinate navigation at presentation boundary.
- Define unknown route, back stack, unsaved editor, modal and process restoration behavior.
Tests: initial/unknown route, parameter validation, back/restore, deep link while locked, app vs vault lock, unsaved draft navigation. Verify Android system back and iOS navigation conventions.
