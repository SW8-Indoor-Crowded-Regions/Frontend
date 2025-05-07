import 'package:flutter/material.dart';

/// Utility class for color-related operations
class ColorUtils {
  /// Parse a color string into a Color object
  static Color parseColorString(String colorString) {
    try {
      // Handle hex colors with # prefix
      if (colorString.startsWith('#')) {
        String hex = colorString.substring(1);
        if (hex.length == 6) {
          return Color(int.parse(hex, radix: 16) | 0xFF000000);
        }
      }

      // Use a hash-based color for other strings
      return Color((colorString.hashCode & 0xFFFFFF) | 0xFF000000);
    } catch (e) {
      // Default fallback color -- No idea on what we should do in this case, so lets hope it never happens
      return Colors.grey;
    }
  }
}
