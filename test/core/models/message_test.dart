import 'package:flutter_test/flutter_test.dart';
import 'package:termchat_app/core/models/message.dart';

void main() {
  group('Message', () {
    final now = DateTime.now();
    final message = Message(
      id: 'm1',
      roomId: 'room1',
      senderId: 'u1',
      senderNickname: 'Alice',
      senderColorHex: '#FF0000',
      content: 'Hello',
      timestamp: now,
      isSystemMessage: false,
    );

    test('props are correct', () {
      expect(message.props, [
        message.id,
        message.roomId,
        message.senderId,
        message.senderNickname,
        message.senderColorHex,
        message.content,
        message.timestamp,
        message.isSystemMessage,
      ]);
    });

    test('equality works', () {
      final same = Message(
        id: 'm1',
        roomId: 'room1',
        senderId: 'u1',
        senderNickname: 'Alice',
        senderColorHex: '#FF0000',
        content: 'Hello',
        timestamp: now,
      );

      expect(message, equals(same));
    });

    test('isSystemMessage defaults to false', () {
      final msg = Message(
        id: 'm2',
        roomId: 'room1',
        senderId: 'u1',
        senderNickname: 'Alice',
        senderColorHex: '#000',
        content: 'Hi',
        timestamp: DateTime.now(),
      );
      expect(msg.isSystemMessage, isFalse);
    });
  });
}
