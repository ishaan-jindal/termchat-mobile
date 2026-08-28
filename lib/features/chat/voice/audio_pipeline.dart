import 'dart:typed_data';

import 'media_frame.dart';

/// Minimum sample magnitude treated as speech for activity lights; open-mic
/// room tone stays below it.
const int voicePeakThreshold = 700;

/// Accumulates variable-size raw PCM chunks from the recorder and splits
/// them into fixed-size protocol frames, keeping any remainder buffered.
class PcmChunkAssembler {
  final int chunkSize;
  final BytesBuilder _builder = BytesBuilder();

  PcmChunkAssembler({this.chunkSize = audioChunkBytes});

  /// Appends raw PCM bytes and returns any complete chunks.
  List<Uint8List> add(List<int> data) {
    _builder.add(data);
    final bytes = _builder.takeBytes();
    final frames = <Uint8List>[];
    var offset = 0;

    while (bytes.length - offset >= chunkSize) {
      frames.add(Uint8List.sublistView(bytes, offset, offset + chunkSize));
      offset += chunkSize;
    }

    if (offset < bytes.length) {
      _builder.add(Uint8List.sublistView(bytes, offset));
    }

    return frames;
  }
}

/// Buffers one speaker's audio chunks in arrival order.
class ChunkRing {
  final int capacity;
  final List<Uint8List> _chunks = [];
  late DateTime _lastSeen;

  ChunkRing({this.capacity = 8}) : _lastSeen = DateTime.now();

  void push(Uint8List chunk) {
    if (_chunks.length >= capacity) {
      _chunks.removeAt(0);
    }
    _chunks.add(chunk);
    _lastSeen = DateTime.now();
  }

  Uint8List? pop() {
    if (_chunks.isEmpty) return null;
    return _chunks.removeAt(0);
  }

  bool isStale(DateTime now, Duration staleAfter) {
    return now.difference(_lastSeen) > staleAfter;
  }
}

/// Mixes one chunk per active speaker into a single saturated PCM chunk.
class VoiceMixer {
  final int chunkSize;
  final int ringCapacity;
  final Duration staleAfter;
  final Map<int, ChunkRing> _rings = {};
  bool _started = false;

  VoiceMixer({
    this.chunkSize = audioChunkBytes,
    this.ringCapacity = 8,
    this.staleAfter = const Duration(seconds: 2),
  });

  void push(int voiceId, Uint8List chunk) {
    final ring = _rings.putIfAbsent(
      voiceId,
      () => ChunkRing(capacity: ringCapacity),
    );
    ring.push(chunk);
    _started = true;
  }

  int get speakerCount => _rings.length;

  /// Mixes one chunk per non-stale ring into a single chunk. Returns null
  /// while nothing has ever been received so the player stays silent until
  /// the first frame arrives; after that it always feeds (silence when idle)
  /// to keep the stream player from underflowing.
  Uint8List? mix(DateTime now) {
    if (!_started) return null;

    final mix = Uint8List(chunkSize);
    final mixData = ByteData.view(mix.buffer, mix.offsetInBytes, mix.length);

    _rings.removeWhere((id, ring) => ring.isStale(now, staleAfter));

    for (final ring in _rings.values) {
      final chunk = ring.pop();
      if (chunk == null) continue;

      final data = ByteData.view(
        chunk.buffer,
        chunk.offsetInBytes,
        chunk.length,
      );
      for (var i = 0; i < chunkSize; i += 2) {
        final sum =
            mixData.getInt16(i, Endian.little) +
            data.getInt16(i, Endian.little);
        mixData.setInt16(i, sum.clamp(-32768, 32767), Endian.little);
      }
    }

    return mix;
  }

  void clear() {
    _rings.clear();
    _started = false;
  }
}

/// Largest sample magnitude in a PCM chunk; used for TX/RX activity lights.
int chunkPeak(Uint8List chunk) {
  final data = ByteData.view(chunk.buffer, chunk.offsetInBytes, chunk.length);
  var peak = 0;

  for (var i = 0; i + 2 <= chunk.length; i += 2) {
    final v = data.getInt16(i, Endian.little).abs();
    if (v > peak) peak = v;
  }

  return peak;
}
