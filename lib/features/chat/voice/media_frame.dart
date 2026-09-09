import 'dart:typed_data';

const int mediaKindAudio = 0x01;
const int mediaKindVideo = 0x02;

const int mediaCodecPcm16 = 0x00;

/// Header: kind, codec, voice ID.
const int mediaHeaderLen = 6;

const int audioSampleRate = 16000;
const int audioChannels = 1;
const int audioChunkSamples = 640; // 40 ms at audioSampleRate
const int audioChunkBytes = audioChunkSamples * 2;

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

/// Server stamps the real voice ID before relaying.
Uint8List encodeAudioFrame(Uint8List payload) {
  final frame = Uint8List(mediaHeaderLen + payload.length);
  final data = ByteData.view(frame.buffer);
  data.setUint8(0, mediaKindAudio);
  data.setUint8(1, mediaCodecPcm16);
  data.setUint32(2, 0, Endian.big);
  frame.setRange(mediaHeaderLen, mediaHeaderLen + payload.length, payload);
  return frame;
}

/// Trims trailing slash so concatenation never doubles the path.
Uri mediaEndpointUri(String mediaUrl) {
  final trimmed = mediaUrl.endsWith('/')
      ? mediaUrl.substring(0, mediaUrl.length - 1)
      : mediaUrl;
  return Uri.parse(trimmed);
}

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

/// Whether a parsed frame is safe to push into the mixer. Exact payload
/// size is required: the mixer indexes a full chunk, so short frames would
/// throw RangeError and long ones would silently truncate.
bool isPlayableAudioFrame(MediaFrame? frame) =>
    frame != null &&
    frame.kind == mediaKindAudio &&
    frame.codec == mediaCodecPcm16 &&
    frame.voiceId != 0 &&
    frame.payload.length == audioChunkBytes;
