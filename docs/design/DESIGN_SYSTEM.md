# Design system

## Phase 01 app-shell foundation

The approved provisional tokens are starter defaults only; they are not the final Yamintto brand system.

- Color: semantic light/dark seed colors retain the existing indigo values (#5267D8 / #9AA8FF). Light surfaces use a soft neutral; dark surfaces use a deep neutral; AMOLED surfaces use true black.
- Typography: platform-native font family with centralized Material text roles and explicit size/weight/line-height tokens. No unapproved brand typeface is bundled.
- Spacing: shared four-point scale (2, 4, 8, 16, 24, 32, 48).
- Radius: shared 8, 12, 16, 24 and pill tokens.
- Themes: Material 3 light, dark and true-black AMOLED.
- Components: reusable filled action button, card, text field, dialog and modal bottom-sheet entry point.

Implementation: lib/core/theme/ and lib/core/widgets/.

The foundation screen includes an in-memory theme preview solely to verify the three variants. Theme preference persistence belongs to Phase 09. Do not treat this placeholder as an approved complete screen design.

## Future design work

Phase 09 owns final UI/UX polish, selectable theme/font preferences and persistence. Final brand palette, iconography, elevations, motion, responsive patterns and detailed product-screen layouts require separate approval. Validate semantic contrast, accessibility, Markdown readability and platform system bars.
