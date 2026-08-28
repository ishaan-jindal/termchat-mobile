import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:termchat_app/features/chat/voice/audio_pipeline.dart';
import 'package:termchat_app/features/chat/voice/media_frame.dart';

Uint8List pcmBytes(List<int> samples) {
  final bytes = Uint8List(samples.length * 2);
  final data = ByteData.view(bytes.buffer);

  for (var i = 0; i < samples.length; i++) {
    data.setInt16(i * 2, samples[i], Endian.little);
  }

  return bytes;
}

/// Builds a chunk the way the receive path does: a view over a media frame
/// buffer, offset past the 6-byte header, with a nonzero voice ID.
Uint8List framedChunk(List<int> samples, {int voiceId = 0x11223344}) {
  final payload = pcmBytes(samples);
  final frame = Uint8List(mediaHeaderLen + payload.length);
  frame[0] = mediaKindAudio;
  frame[1] = mediaCodecPcm16;
  ByteData.view(frame.buffer).setUint32(2, voiceId, Endian.big);
  frame.setRange(mediaHeaderLen, mediaHeaderLen + payload.length, payload);
  return Uint8List.sublistView(frame, mediaHeaderLen);
}

List<int> pcmSamples(Uint8List bytes) {
  final data = ByteData.view(bytes.buffer);
  final samples = <int>[];

  for (var i = 0; i < bytes.length; i += 2) {
    samples.add(data.getInt16(i, Endian.little));
  }

  return samples;
}

void main() {
  group('PcmChunkAssembler', () {
    test('emits complete chunks and buffers the remainder', () {
      final assembler = PcmChunkAssembler(chunkSize: 4);

      expect(assembler.add([1, 2, 3, 4, 5]), hasLength(1));
      expect(assembler.add([6, 7]), isEmpty);
      expect(assembler.add([8]), hasLength(1));
    });

    test('emits multiple chunks from a large buffer', () {
      final assembler = PcmChunkAssembler(chunkSize: 4);
      final frames = assembler.add(List<int>.generate(10, (i) => i));

      expect(frames, hasLength(2));
      expect(frames.first, [0, 1, 2, 3]);
      expect(frames.last, [4, 5, 6, 7]);
    });

    test('exact multiple produces all chunks with no remainder', () {
      final assembler = PcmChunkAssembler(chunkSize: 4);
      final frames = assembler.add([1, 2, 3, 4, 5, 6, 7, 8]);

      expect(frames, hasLength(2));
    });
  });

  group('ChunkRing', () {
    test('drops the oldest chunk beyond capacity', () {
      final ring = ChunkRing(capacity: 2);
      ring.push(Uint8List.fromList([1]));
      ring.push(Uint8List.fromList([2]));
      ring.push(Uint8List.fromList([3]));

      expect(ring.pop(), [2]);
      expect(ring.pop(), [3]);
      expect(ring.pop(), isNull);
    });

    test('is stale after the threshold', () {
      final ring = ChunkRing(capacity: 2);
      ring.push(Uint8List.fromList([1]));

      final now = DateTime.now();

      expect(ring.isStale(now, const Duration(seconds: 2)), isFalse);
      expect(
        ring.isStale(
          now.add(const Duration(seconds: 3)),
          const Duration(seconds: 2),
        ),
        isTrue,
      );
    });
  });

  group('VoiceMixer', () {
    test('returns null before any frame arrives', () {
      final mixer = VoiceMixer(chunkSize: 4);
      expect(mixer.mix(DateTime.now()), isNull);
    });

    test('mixes two speakers with saturation', () {
      final mixer = VoiceMixer(chunkSize: 4);

      mixer.push(1, pcmBytes([30000, -30000]));
      mixer.push(2, pcmBytes([30000, 5000]));

      final mixed = mixer.mix(DateTime.now());

      expect(mixed, isNotNull);
      final samples = pcmSamples(mixed!);
      expect(samples[0], 32767); // 60000 saturates
      expect(samples[1], -25000);
    });

    test('mixes linearly within range', () {
      final mixer = VoiceMixer(chunkSize: 4);

      mixer.push(1, pcmBytes([1000, -1000]));
      mixer.push(2, pcmBytes([2000, -3000]));

      final samples = pcmSamples(mixer.mix(DateTime.now())!);
      expect(samples[0], 3000);
      expect(samples[1], -4000);
    });

    test('drops stale speakers', () {
      final mixer = VoiceMixer(chunkSize: 4);
      mixer.push(1, pcmBytes([100, 200]));

      final later = DateTime.now().add(const Duration(seconds: 3));
      final mixed = mixer.mix(later);

      expect(mixed, isNotNull);
      expect(pcmSamples(mixed!), [0, 0]);
      expect(mixer.speakerCount, 0);
    });

    test('keeps feeding silence after first frame', () {
      final mixer = VoiceMixer(chunkSize: 4);
      mixer.push(1, pcmBytes([100, 200]));

      expect(mixer.mix(DateTime.now()), isNotNull);
      expect(mixer.mix(DateTime.now()), isNotNull);
    });

    test('mixes chunks that are views with a nonzero byte offset', () {
      final mixer = VoiceMixer(chunkSize: 8);
      mixer.push(1, framedChunk([1000, -2000, 3000, -4000]));

      final samples = pcmSamples(mixer.mix(DateTime.now())!);
      expect(samples, [1000, -2000, 3000, -4000]);
    });

    test('mixes two offset-view chunks without header leakage', () {
      final mixer = VoiceMixer(chunkSize: 4);
      mixer.push(1, framedChunk([5000, 5000]));
      mixer.push(2, framedChunk([-1000, -1000], voiceId: 0xdeadbeef));

      final samples = pcmSamples(mixer.mix(DateTime.now())!);
      expect(samples, [4000, 4000]);
    });
  });

  group('chunkPeak', () {
    test('returns the largest sample magnitude', () {
      expect(chunkPeak(pcmBytes([100, -5000, 300, 1])), 5000);
      expect(chunkPeak(pcmBytes([0, 0])), 0);
    });

    test('respects the byte offset of view chunks', () {
      expect(chunkPeak(framedChunk([100, -5000, 300, 1])), 5000);
      expect(chunkPeak(framedChunk([0, 0])), 0);
    });

    test('treats loud chunks above the speech threshold', () {
      expect(chunkPeak(pcmBytes([100])), lessThan(voicePeakThreshold));
      expect(
        chunkPeak(pcmBytes([10000])),
        greaterThanOrEqualTo(voicePeakThreshold),
      );
    });
  });
}
