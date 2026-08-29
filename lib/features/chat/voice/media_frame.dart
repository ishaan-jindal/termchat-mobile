import 'dart:typed_data';

/// Binary media frame kinds carried on the /media WebSocket.
const int mediaKindAudio = 0x01;
const int mediaKindVideo = 0x02;

/// Media audio codecs.
const int mediaCodecPcm16 = 0x00;

/// Frame header size: kind, codec, voice ID.
const int mediaHeaderLen = 6;

const int audioSampleRate = 16000;
const int audioChannels = 1;
const int audioChunkSamples = 640; // 40 ms at audioSampleRate
const int audioChunkBytes = audioChunkSamples * 2;

/// A parsed media frame.
class MediaFrame {
  final int kind;
  final int codec;
  final int voiceId;
  final Uint8List payload;

  const MediaFrame({
    required this.kind,
    required this.codec,
    required this.voiceId,
    required this.payload,
  });
}

/// Encodes an audio frame with a zero voice ID; the server stamps the real
/// voice ID over the header before relaying.
Uint8List encodeAudioFrame(Uint8List payload) {
  final frame = Uint8List(mediaHeaderLen + payload.length);
  final data = ByteData.view(frame.buffer);
  data.setUint8(0, mediaKindAudio);
  data.setUint8(1, mediaCodecPcm16);
  data.setUint32(2, 0, Endian.big);
  frame.setRange(mediaHeaderLen, mediaHeaderLen + payload.length, payload);
  return frame;
}

/// Parses a media endpoint URL, trimming any trailing slash so concatenation
/// never produces a doubled path segment.
Uri mediaEndpointUri(String mediaUrl) {
  final trimmed = mediaUrl.endsWith('/')
      ? mediaUrl.substring(0, mediaUrl.length - 1)
      : mediaUrl;
  return Uri.parse(trimmed);
}

/// Splits a media frame, rejecting short frames and unknown kinds.
MediaFrame? parseMediaFrame(Uint8List frame) {
  if (frame.length < mediaHeaderLen) return null;

  final data = ByteData.view(frame.buffer);
  final kind = data.getUint8(0);

  if (kind != mediaKindAudio && kind != mediaKindVideo) return null;

  return MediaFrame(
    kind: kind,
    codec: data.getUint8(1),
    voiceId: data.getUint32(2, Endian.big),
    payload: Uint8List.sublistView(frame, mediaHeaderLen, frame.length),
  );
}
