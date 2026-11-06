import 'package:flutter/material.dart';

/// Fixed opaque ARGB palette persisted as SQLite INTEGER values.
abstract final class FolderColorPalette {
  static const List<int> values = <int>[
    0xFFF44336, 0xFFE91E63, 0xFFFF9800, 0xFFFFEB3B, 0xFF4CAF50,
    0xFF009688, 0xFF3F51B5, 0xFF673AB7, 0xFF03A9F4, 0xFFFFC107,
  ];

  static Color color(int? argb, Color fallback) =>
      argb == null ? fallback : Color(argb);

  static Color foreground(int argb) =>
      ThemeData.estimateBrightnessForColor(Color(argb)) == Brightness.dark
          ? Colors.white
          : Colors.black;
}
