import 'package:flutter/material.dart';

/// Reusable Material form field with app-wide decoration defaults.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    this.label,
    this.hint,
    this.validator,
    this.onChanged,
    this.obscureText = false,
    this.maxLines = 1,
    this.keyboardType,
    super.key,
  }) : assert(maxLines > 0);

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: validator,
      onChanged: onChanged,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      keyboardType: keyboardType,
    );
  }
}
