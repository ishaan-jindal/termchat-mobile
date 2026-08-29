import 'package:flutter_test/flutter_test.dart';
import 'package:termchat_app/data/models/backend_user_info.dart';

void main() {
  group('BackendUserInfo', () {
    group('fromJson', () {
      test('parses valid JSON', () {
        final json = {
          'nick': 'Alice',
          'color': '#FF0000',
          'joined_at': 12345,
          'typing': true,
          'is_host': false,
          'voice_id': 42,
        };

        final info = BackendUserInfo.fromJson(json);

        expect(info.nick, 'Alice');
        expect(info.color, '#FF0000');
        expect(info.joinedAt, 12345);
        expect(info.typing, isTrue);
        expect(info.isHost, isFalse);
        expect(info.voiceId, 42);
      });

      test('uses defaults for missing fields', () {
        final json = {'nick': 'Bob', 'color': '#00FF00'};

        final info = BackendUserInfo.fromJson(json);

        expect(info.joinedAt, 0);
        expect(info.typing, isFalse);
        expect(info.isHost, isFalse);
        expect(info.voiceId, 0);
      });
    });

    group('toJson', () {
      test('produces correct map', () {
        final info = BackendUserInfo(
          nick: 'Alice',
          color: '#FF0000',
          joinedAt: 12345,
          typing: true,
          isHost: false,
        );

        expect(info.toJson(), {
          'nick': 'Alice',
          'color': '#FF0000',
          'joined_at': 12345,
          'typing': true,
          'is_host': false,
        });
      });

      test('omits voice_id when zero and includes it otherwise', () {
        final silent = BackendUserInfo(
          nick: 'A',
          color: '#000',
          joinedAt: 0,
          typing: false,
          isHost: false,
        );

        final talking = BackendUserInfo(
          nick: 'A',
          color: '#000',
          joinedAt: 0,
          typing: false,
          isHost: false,
          voiceId: 7,
        );

        expect(silent.toJson().containsKey('voice_id'), isFalse);
        expect(talking.toJson()['voice_id'], 7);
      });
    });

    test('round-trip preserves values', () {
      final original = BackendUserInfo(
        nick: 'Charlie',
        color: '#0000FF',
        joinedAt: 999,
        typing: false,
        isHost: true,
      );

      final json = original.toJson();
      final reconstructed = BackendUserInfo.fromJson(json);

      expect(reconstructed.nick, original.nick);
      expect(reconstructed.color, original.color);
      expect(reconstructed.joinedAt, original.joinedAt);
      expect(reconstructed.typing, original.typing);
      expect(reconstructed.isHost, original.isHost);
      expect(reconstructed.voiceId, original.voiceId);
    });
  });
}
