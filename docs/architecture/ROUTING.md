# Routing and navigation

## Current Phase 01 implementation

- GoRouter is owned by the root app and created once per app state.
- Initial location is /splash; SplashScreen displays the app identity and navigates to / after a short startup interval.
- / maps to the temporary FoundationScreen placeholder.
- Unknown locations use a recoverable not-found page with a home action.
- Theme preview state is exposed to the foundation route through a ValueListenable; route state is not recreated when the theme changes.
- There are no product routes, auth guards, nested routes or deep links.

## Planned

- Centralize paths/names and typed route parameters in app router; builders compose screens only.
- Guards derive from observable auth/lock state. Never put secrets or note content in URLs/route extras.
- App lock and vault lock are distinct gates. Restore deep-link destination only after required unlock.
- Domain logic stays out of builders. Controllers coordinate navigation at presentation boundary.
- Define back stack, unsaved editor, modal and process restoration behavior.

Tests: initial/splash route, splash-to-home navigation, unknown route recovery. Future tests cover parameter validation, back/restore, deep link while locked, app vs vault lock and unsaved draft navigation. Verify Android system back and iOS navigation conventions on devices.
