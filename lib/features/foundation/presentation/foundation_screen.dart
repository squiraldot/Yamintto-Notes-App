import 'package:flutter/material.dart';
import 'package:yamintto/core/theme/app_theme.dart';
import 'package:yamintto/core/theme/tokens/app_spacing.dart';

/// Temporary app-shell screen used to verify Phase 01 navigation and themes.
class FoundationScreen extends StatelessWidget {
  const FoundationScreen({
    required this.themeMode,
    required this.onThemeModeChanged,
    super.key,
  });

  final YaminttoThemeMode themeMode;
  final ValueChanged<YaminttoThemeMode> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Yamintto')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(
                  Icons.notes_rounded,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Application foundation is ready.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Phase 01 navigation and theme preview.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xl),
                DropdownButtonFormField<YaminttoThemeMode>(
                  key: const ValueKey('theme-mode-selector'),
                  value: themeMode,
                  decoration: const InputDecoration(labelText: 'Theme preview'),
                  items: const <DropdownMenuItem<YaminttoThemeMode>>[
                    DropdownMenuItem(
                      value: YaminttoThemeMode.system,
                      child: Text('System'),
                    ),
                    DropdownMenuItem(
                      value: YaminttoThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: YaminttoThemeMode.dark,
                      child: Text('Dark'),
                    ),
                    DropdownMenuItem(
                      value: YaminttoThemeMode.amoled,
                      child: Text('AMOLED'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) onThemeModeChanged(value);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
