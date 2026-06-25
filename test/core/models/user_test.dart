import 'package:flutter_test/flutter_test.dart';
import 'package:termchat_app/core/models/user.dart';

void main() {
  group('User', () {
    const user = User(id: 'u1', nickname: 'Alice', colorHex: '#FF0000');

    test('props are correct', () {
      expect(user.props, [user.id, user.nickname, user.colorHex]);
    });

    test('equality works', () {
      const same = User(id: 'u1', nickname: 'Alice', colorHex: '#FF0000');
      const different = User(id: 'u2', nickname: 'Bob', colorHex: '#00FF00');

      expect(user, equals(same));
      expect(user, isNot(equals(different)));
    });

    test('toString contains fields', () {
      expect(user.toString(), contains('Alice'));
    });
  });
}
