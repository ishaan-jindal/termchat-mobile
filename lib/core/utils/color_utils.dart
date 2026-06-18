import 'package:flutter/material.dart';

class ColorUtils {
  ColorUtils._();

  /// Parses a hex color string (e.g. "#FF0000" or "FF0000" or "#AAFF0000") into a Flutter [Color].
  static Color parseHexColor(String hex) {
    String cleanHex = hex.replaceAll('#', '');
    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    }
    return Color(int.tryParse(cleanHex, radix: 16) ?? 0xFFFFFFFF);
  }
}
