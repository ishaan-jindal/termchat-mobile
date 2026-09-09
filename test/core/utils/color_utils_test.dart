import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termchat_app/core/utils/color_utils.dart';

void main() {
  group('ColorUtils.parseHexColor', () {
    test('parses 7-character hex with hash', () {
      final color = ColorUtils.parseHexColor('#FF0000');
      expect(color, const Color(0xFFFF0000));
    });

    test('parses 6-character hex without hash', () {
      final color = ColorUtils.parseHexColor('00FF00');
      expect(color, const Color(0xFF00FF00));
    });

    test('parses 9-character hex with alpha', () {
      final color = ColorUtils.parseHexColor('#AAFF0000');
      expect(color, const Color(0xAAFF0000));
    });

    test('returns opaque white for empty string', () {
      final color = ColorUtils.parseHexColor('');
      expect(color, const Color(0xFFFFFFFF));
    });

    test('returns opaque white for invalid hex', () {
      final color = ColorUtils.parseHexColor('#ZZZZZZ');
      expect(color, const Color(0xFFFFFFFF));
    });

    test('expands 3-char shorthand', () {
      expect(ColorUtils.parseHexColor('#F00'), const Color(0xFFFF0000));
      expect(ColorUtils.parseHexColor('0F0'), const Color(0xFF00FF00));
    });

    test('rejects partial hex instead of misparsing', () {
      // Old code parsed 'F00' as 0xF00 (near-transparent black).
      expect(ColorUtils.parseHexColor('F00'), const Color(0xFFFF0000));
      expect(ColorUtils.parseHexColor('#12345'), const Color(0xFFFFFFFF));
    });
  });

  group('ColorUtils.tryParseHexColor', () {
    test('accepts valid colors', () {
      expect(ColorUtils.tryParseHexColor('#FF0000'), const Color(0xFFFF0000));
    });

    test('returns null for garbage', () {
      expect(ColorUtils.tryParseHexColor('nope'), isNull);
      expect(ColorUtils.tryParseHexColor(''), isNull);
    });
  });
}
