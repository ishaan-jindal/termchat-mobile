import 'package:flutter_test/flutter_test.dart';
import 'package:termchat_app/data/models/backend_message.dart';
import 'package:termchat_app/data/models/backend_user_info.dart';

void main() {
  group('BackendMessage', () {
    group('fromJson', () {
      test('parses simple message', () {
        final json = {
          'type': 'chat',
          'nick': 'Alice',
          'room': 'general',
          'text': 'Hello!',
        };

        final msg = BackendMessage.fromJson(json);

        expect(msg.type, 'chat');
        expect(msg.nick, 'Alice');
        expect(msg.room, 'general');
        expect(msg.text, 'Hello!');
        expect(msg.newNick, isNull);
        expect(msg.color, isNull);
        expect(msg.password, isNull);
        expect(msg.messages, isNull);
        expect(msg.users, isNull);
      });

      test('parses message with nested messages', () {
        final json = {
          'type': 'history',
          'messages': [
            {'type': 'chat', 'nick': 'Alice', 'text': 'Hi'},
            {'type': 'chat', 'nick': 'Bob', 'text': 'Hey'},
          ],
        };

        final msg = BackendMessage.fromJson(json);

        expect(msg.messages, hasLength(2));
        expect(msg.messages![0].text, 'Hi');
        expect(msg.messages![1].nick, 'Bob');
      });

      test('parses message with users list', () {
        final json = {
          'type': 'users_list',
          'users': [
            {'nick': 'Alice', 'color': '#FF0000'},
            {'nick': 'Bob', 'color': '#00FF00'},
          ],
        };

        final msg = BackendMessage.fromJson(json);

        expect(msg.users, hasLength(2));
        expect(msg.users![0].nick, 'Alice');
        expect(msg.users![1].color, '#00FF00');
      });

      test('parses command fields', () {
        final json = {
          'type': 'nick',
          'new_nick': 'NewName',
          'color': '#FF0000',
          'password': 'secret',
        };

        final msg = BackendMessage.fromJson(json);

        expect(msg.newNick, 'NewName');
        expect(msg.color, '#FF0000');
        expect(msg.password, 'secret');
      });
    });

    group('toJson', () {
      test('produces correct map', () {
        final msg = BackendMessage(
          type: 'message',
          nick: 'Alice',
          room: 'general',
          text: 'Hello',
        );

        expect(msg.toJson(), {
          'type': 'message',
          'nick': 'Alice',
          'room': 'general',
          'text': 'Hello',
        });
      });

      test('omits null fields', () {
        final msg = BackendMessage(type: 'ping');

        expect(msg.toJson(), {'type': 'ping'});
      });
    });

    test('round-trip preserves values', () {
      final original = BackendMessage(
        type: 'chat',
        nick: 'Charlie',
        room: 'random',
        text: 'Yo!',
        newNick: 'Chuck',
        color: '#0000FF',
        password: 'p@ss',
        users: [
          BackendUserInfo(
            nick: 'Charlie',
            color: '#0000FF',
            joinedAt: 0,
            typing: false,
            isHost: true,
          ),
        ],
      );

      final json = original.toJson();
      final reconstructed = BackendMessage.fromJson(json);

      expect(reconstructed.type, original.type);
      expect(reconstructed.nick, original.nick);
      expect(reconstructed.room, original.room);
      expect(reconstructed.text, original.text);
      expect(reconstructed.newNick, original.newNick);
      expect(reconstructed.color, original.color);
      expect(reconstructed.password, original.password);
      expect(reconstructed.users, hasLength(1));
      expect(reconstructed.users![0].nick, 'Charlie');
    });
  });
}
