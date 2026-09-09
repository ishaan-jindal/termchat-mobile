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

      test('missing type defaults to unknown instead of throwing', () {
        final msg = BackendMessage.fromJson({'nick': 'Alice'});

        expect(msg.type, 'unknown');
      });

      test('skips malformed entries instead of aborting batch', () {
        final json = {
          'type': 'history',
          'messages': [
            {'type': 'chat', 'nick': 'Alice', 'text': 'Hi'},
            {'type': 'chat', 'nick': 'Bob', 'text': 'Hey'},
            'not-a-map',
            {'type': 'chat', 'nick': 'Cara', 'text': 'Yo'},
          ],
        };

        final msg = BackendMessage.fromJson(json);

        expect(msg.messages, hasLength(3));
      });

      test('skips users with missing nick/color', () {
        final json = {
          'type': 'users_list',
          'users': [
            {'nick': 'Alice', 'color': '#FF0000'},
            {'nick': '', 'color': '#00FF00'},
            {'color': '#0000FF'},
            {'nick': 'Bob', 'color': '#00FF00'},
          ],
        };

        final msg = BackendMessage.fromJson(json);

        expect(msg.users, hasLength(2));
        expect(msg.users![0].nick, 'Alice');
        expect(msg.users![1].nick, 'Bob');
      });

      test('coerces string numbers and bools', () {
        final json = {
          'type': 'chat',
          'id': '7',
          'timestamp': '1700000000000',
          'reply_to_id': '3',
          'users': [
            {
              'nick': 'Alice',
              'color': '#FF0000',
              'joined_at': '1700000000',
              'typing': 1,
              'is_host': 'true',
              'voice_id': '9',
            },
          ],
        };

        final msg = BackendMessage.fromJson(json);

        expect(msg.id, 7);
        expect(msg.timestamp, 1700000000000);
        expect(msg.replyToId, 3);
        expect(msg.users![0].joinedAt, 1700000000);
        expect(msg.users![0].typing, isTrue);
        expect(msg.users![0].isHost, isTrue);
        expect(msg.users![0].voiceId, 9);
      });

      test('caps pathological batches', () {
        final json = {
          'type': 'history',
          'messages': List.generate(
            BackendMessage.maxBatchItems + 500,
            (i) => {'type': 'chat', 'nick': 'A', 'text': 'm$i'},
          ),
        };

        final msg = BackendMessage.fromJson(json);

        expect(msg.messages, hasLength(BackendMessage.maxBatchItems));
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
