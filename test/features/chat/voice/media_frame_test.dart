import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:termchat_app/features/chat/voice/media_frame.dart';

Uint8List pcmBytes(List<int> samples) {
  final bytes = Uint8List(samples.length * 2);
  final data = ByteData.view(bytes.buffer);

  for (var i = 0; i < samples.length; i++) {
    data.setInt16(i * 2, samples[i], Endian.little);
  }

  return bytes;
}

void main() {
  group('encodeAudioFrame', () {
    test('builds a 6-byte header with zero voice ID', () {
      final payload = Uint8List(4);
      final frame = encodeAudioFrame(payload);

      expect(frame.length, mediaHeaderLen + 4);
      expect(frame[0], mediaKindAudio);
      expect(frame[1], mediaCodecPcm16);

      final data = ByteData.view(frame.buffer);
      expect(data.getUint32(2, Endian.big), 0);
    });

    test('appends payload after the header', () {
      final payload = pcmBytes([100, -200]);
      final frame = encodeAudioFrame(payload);

      expect(Uint8List.sublistView(frame, mediaHeaderLen), payload);
    });
  });

  group('parseMediaFrame', () {
    test('rejects frames shorter than the header', () {
      expect(parseMediaFrame(Uint8List(mediaHeaderLen - 1)), isNull);
    });

    test('rejects unknown kinds', () {
      final frame = Uint8List(mediaHeaderLen);
      frame[0] = 0x7f;

      expect(parseMediaFrame(frame), isNull);
    });

    test('parses header and payload round trip', () {
      final payload = pcmBytes([1, 2, 3, 4]);
      final frame = encodeAudioFrame(payload);

      // Simulate the server stamping a voice ID over the header.
      final data = ByteData.view(frame.buffer);
      data.setUint32(2, 42, Endian.big);

      final parsed = parseMediaFrame(frame);

      expect(parsed, isNotNull);
      expect(parsed!.kind, mediaKindAudio);
      expect(parsed.codec, mediaCodecPcm16);
      expect(parsed.voiceId, 42);
      expect(parsed.payload, payload);
    });

    test('reads the voice ID as big endian', () {
      final frame = Uint8List(mediaHeaderLen);
      frame[0] = mediaKindAudio;
      frame[1] = mediaCodecPcm16;
      frame[2] = 0x01;
      frame[3] = 0x02;
      frame[4] = 0x03;
      frame[5] = 0x04;

      final parsed = parseMediaFrame(frame);

      expect(parsed!.voiceId, 0x01020304);
    });
  });

  group('mediaEndpointUri', () {
    test('keeps the media path exactly once', () {
      expect(
        mediaEndpointUri('wss://termchat.sacred99.online/media').path,
        '/media',
      );
    });

    test('trims a trailing slash without doubling the segment', () {
      expect(
        mediaEndpointUri('wss://termchat.sacred99.online/media/').path,
        '/media',
      );
    });

    test('keeps scheme and host', () {
      final uri = mediaEndpointUri('wss://termchat.sacred99.online/media');

      expect(uri.scheme, 'wss');
      expect(uri.host, 'termchat.sacred99.online');
    });
  });
}
