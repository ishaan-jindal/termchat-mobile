import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:termchat_app/core/constants/app_constants.dart';

void main() {
  group('AppConstants.appVersion', () {
    test('matches pubspec.yaml (without build metadata)', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final match = RegExp(
        r'^version:\s*([^\s+]+)',
        multiLine: true,
      ).firstMatch(pubspec);

      expect(match, isNotNull, reason: 'pubspec.yaml must declare a version');
      expect(AppConstants.appVersion, match![1]);
    });
  });
}
