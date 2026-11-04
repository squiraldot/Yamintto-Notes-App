# Theming

## Current Phase 01 implementation

- Material 3 light and dark ThemeData are centralized in AppTheme.
- AMOLED uses a dark ColorScheme with true-black scaffold and surface containers.
- YaminttoThemeMode supports system, light, dark and AMOLED.
- The temporary foundation screen exposes an in-memory preview selector.
- Theme changes update the existing app/router instance; selection is not persisted.

## Ownership

Phase 01 establishes initial tokens and app-shell theme foundation. Phase 09 implements user-selectable system/light/dark/AMOLED preference and persistence through settings, plus font-size preferences. Final palette and detailed UI polish remain subject to approval.

Test contrast, focus, disabled, selected, error/destructive states, system bars, accessibility scaling and (in Phase 09) restart persistence.
