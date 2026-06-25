import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:termchat_app/features/settings/repositories/identity_repository.dart';

void main() {
  group('IdentityRepositoryImpl', () {
    late IdentityRepositoryImpl repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repository = IdentityRepositoryImpl();
    });

    group('getCurrentUser', () {
      test('creates new user when no prefs exist', () async {
        final user = await repository.getCurrentUser();

        expect(user.id, startsWith('user_'));
        expect(user.nickname, startsWith('anon_'));
        expect(user.colorHex, '');
      });

      test('loads existing user from prefs', () async {
        SharedPreferences.setMockInitialValues({
          'user_id': 'u1',
          'user_nickname': 'Alice',
          'user_color': '#FF0000',
        });
        repository = IdentityRepositoryImpl();

        final user = await repository.getCurrentUser();

        expect(user.id, 'u1');
        expect(user.nickname, 'Alice');
        expect(user.colorHex, '#FF0000');
      });
    });

    group('updateNickname', () {
      test('persists nickname', () async {
        await repository.updateNickname('Bob');

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('user_nickname'), 'Bob');
      });
    });

    group('updateColor', () {
      test('persists color', () async {
        await repository.updateColor('#00FF00');

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('user_color'), '#00FF00');
      });
    });
  });
}
