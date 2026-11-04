import 'package:flutter/material.dart';

/// Reusable primary action for the Yamintto app shell.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label);

    final button = icon != null && !isLoading
        ? FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: child,
          )
        : FilledButton(onPressed: onPressed, child: child);

    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
