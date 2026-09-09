import 'package:flutter_test/flutter_test.dart';
import 'package:termchat_app/features/chat/voice/voice_session.dart';

void main() {
  group('voiceHandshakeFailure', () {
    test('returns null for ok', () {
      expect(voiceHandshakeFailure({'type': 'ok'}), isNull);
    });

    test('returns the server text for errors', () {
      expect(
        voiceHandshakeFailure({'type': 'error', 'text': 'nick-taken'}),
        'nick-taken',
      );
    });

    test('defaults a missing text', () {
      expect(voiceHandshakeFailure({'type': 'error'}), 'voice join rejected');
    });

    test('coerces non-string text instead of throwing', () {
      expect(voiceHandshakeFailure({'type': 'error', 'text': 123}), '123');
      expect(
        voiceHandshakeFailure(const {'type': 'error', 'text': null}),
        'voice join rejected',
      );
    });

    test('rejects unexpected types', () {
      expect(
        voiceHandshakeFailure({'type': 'hello'}),
        'unexpected voice reply',
      );
      expect(voiceHandshakeFailure({}), 'unexpected voice reply');
    });
  });
}
