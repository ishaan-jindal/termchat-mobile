import 'package:flutter_test/flutter_test.dart';
import 'package:termchat_app/core/models/room.dart';

void main() {
  group('Room', () {
    const room = Room(
      id: 'r1',
      name: 'General',
      usersCount: 5,
      unreadCount: 2,
      isLocked: true,
      isViewing: true,
      lastMessagePreview: 'Hello!',
    );

    test('props are correct', () {
      expect(room.props, [
        room.id,
        room.name,
        room.usersCount,
        room.unreadCount,
        room.isLocked,
        room.isViewing,
        room.lastMessagePreview,
        room.activeUsers,
      ]);
    });

    test('equality works', () {
      const same = Room(
        id: 'r1',
        name: 'General',
        usersCount: 5,
        unreadCount: 2,
        isLocked: true,
        isViewing: true,
        lastMessagePreview: 'Hello!',
      );
      const different = Room(id: 'r2', name: 'Random');

      expect(room, equals(same));
      expect(room, isNot(equals(different)));
    });

    test('defaults are correct', () {
      const defaultRoom = Room(id: 'r1', name: 'Test');

      expect(defaultRoom.usersCount, 1);
      expect(defaultRoom.unreadCount, 0);
      expect(defaultRoom.isLocked, isFalse);
      expect(defaultRoom.isViewing, isFalse);
      expect(defaultRoom.lastMessagePreview, isNull);
      expect(defaultRoom.activeUsers, isEmpty);
    });
  });
}
