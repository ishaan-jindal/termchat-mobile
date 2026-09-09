import 'package:flutter/material.dart';

class ColorUtils {
  ColorUtils._();

  static final RegExp _hex6 = RegExp(r'^[0-9a-fA-F]{6}$');
  static final RegExp _hex8 = RegExp(r'^[0-9a-fA-F]{8}$');
  static final RegExp _hex3 = RegExp(r'^[0-9a-fA-F]{3}$');

  /// Parses hex; returns white instead of throwing on bad input.
  static Color parseHexColor(String hex) {
    final cleanHex = hex.replaceAll('#', '');
    if (_hex3.hasMatch(cleanHex)) {
      final expanded = cleanHex.split('').map((c) => '$c$c').join();
      return Color(int.parse('FF$expanded', radix: 16));
    }
    if (_hex6.hasMatch(cleanHex)) {
      return Color(int.parse('FF$cleanHex', radix: 16));
    }
    if (_hex8.hasMatch(cleanHex)) {
      return Color(int.parse(cleanHex, radix: 16));
    }
    return const Color(0xFFFFFFFF);
  }

  /// Strict parse for user input; null when invalid.
  static Color? tryParseHexColor(String hex) {
    final cleanHex = hex.replaceAll('#', '');
    if (!_hex3.hasMatch(cleanHex) &&
        !_hex6.hasMatch(cleanHex) &&
        !_hex8.hasMatch(cleanHex)) {
      return null;
    }
    return parseHexColor(hex);
  }
}
