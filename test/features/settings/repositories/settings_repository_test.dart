import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:termchat_app/features/settings/repositories/settings_repository.dart';

void main() {
  group('SettingsRepositoryImpl', () {
    late SettingsRepositoryImpl repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repository = SettingsRepositoryImpl();
    });

    group('theme mode', () {
      test('getThemeMode returns default when not set', () async {
        expect(await repository.getThemeMode(), 'dark');
      });

      test('setThemeMode persists and can be read', () async {
        await repository.setThemeMode('light');
        expect(await repository.getThemeMode(), 'light');
      });
    });

    group('font size', () {
      test('getFontSize returns default when not set', () async {
        expect(await repository.getFontSize(), 'sm');
      });

      test('setFontSize persists and can be read', () async {
        await repository.setFontSize('lg');
        expect(await repository.getFontSize(), 'lg');
      });
    });

    group('message notifications', () {
      test('getMessageNotifications returns default when not set', () async {
        expect(await repository.getMessageNotifications(), isTrue);
      });

      test('setMessageNotifications persists and can be read', () async {
        await repository.setMessageNotifications(false);
        expect(await repository.getMessageNotifications(), isFalse);
      });
    });

    group('mention sound', () {
      test('getMentionSound returns default when not set', () async {
        expect(await repository.getMentionSound(), isTrue);
      });

      test('setMentionSound persists and can be read', () async {
        await repository.setMentionSound(false);
        expect(await repository.getMentionSound(), isFalse);
      });
    });
  });
}
