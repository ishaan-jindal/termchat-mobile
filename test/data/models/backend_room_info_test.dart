import 'package:flutter_test/flutter_test.dart';
import 'package:termchat_app/data/models/backend_room_info.dart';

void main() {
  group('BackendRoomInfo', () {
    group('fromJson', () {
      test('parses valid JSON', () {
        final json = {
          'id': 'room1',
          'user_count': 42,
          'has_password': true,
          'host_nick': 'Alice',
        };

        final info = BackendRoomInfo.fromJson(json);

        expect(info.id, 'room1');
        expect(info.userCount, 42);
        expect(info.hasPassword, isTrue);
        expect(info.hostNick, 'Alice');
      });

      test('uses defaults for missing fields', () {
        final json = {'id': 'room2'};

        final info = BackendRoomInfo.fromJson(json);

        expect(info.userCount, 0);
        expect(info.hasPassword, isFalse);
        expect(info.hostNick, '');
      });
    });

    group('toJson', () {
      test('produces correct map', () {
        final info = BackendRoomInfo(
          id: 'room1',
          userCount: 42,
          hasPassword: true,
          hostNick: 'Alice',
        );

        expect(info.toJson(), {
          'id': 'room1',
          'user_count': 42,
          'has_password': true,
          'host_nick': 'Alice',
        });
      });
    });

    test('round-trip preserves values', () {
      final original = BackendRoomInfo(
        id: 'test-room',
        userCount: 7,
        hasPassword: false,
        hostNick: 'Bob',
      );

      final json = original.toJson();
      final reconstructed = BackendRoomInfo.fromJson(json);

      expect(reconstructed.id, original.id);
      expect(reconstructed.userCount, original.userCount);
      expect(reconstructed.hasPassword, original.hasPassword);
      expect(reconstructed.hostNick, original.hostNick);
    });
  });
}
