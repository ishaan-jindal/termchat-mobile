import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'audio_pipeline.dart';
import 'media_frame.dart';

/// Events surfaced from a [VoiceSession] to its owner.
sealed class VoiceSessionEvent {}

class VoiceSessionEnded extends VoiceSessionEvent {}

class VoiceSessionError extends VoiceSessionEvent {
  final String message;
  VoiceSessionError(this.message);
}

/// Client side of the binary /media WebSocket. Bundles the socket with the
/// streaming recorder (transmit) and player (receive) pipelines.
class VoiceSession {
  final WebSocketChannel _channel;
  final FlutterSoundPlayer _player;
  final FlutterSoundRecorder _recorder;
  final PcmChunkAssembler _assembler;
  final VoiceMixer _mixer;
  final StreamController<VoiceSessionEvent> _eventsController;
  StreamSubscription<dynamic>? _inboundSub;
  Future<void>? _playoutFuture;
  StreamController<Uint8List>? _captureController;
  final Completer<void> _handshake = Completer<void>();
  final Uint8List _silence = Uint8List(audioChunkBytes);

  bool _transmitting = false;
  bool _disposed = false;
  bool _playerOpened = false;
  bool _playerStarted = false;
  bool _recorderOpened = false;
  bool _channelClosed = false;
  bool _captureInProgress = false;

  final ValueNotifier<bool> _receiving = ValueNotifier(false);

  VoiceSession._(this._channel)
    : _player = FlutterSoundPlayer(),
      _recorder = FlutterSoundRecorder(),
      _assembler = PcmChunkAssembler(),
      _mixer = VoiceMixer(),
      _eventsController = StreamController<VoiceSessionEvent>.broadcast();

  bool get transmitting => _transmitting;

  /// True while an inbound chunk louder than the speech threshold arrives.
  ValueListenable<bool> get receiving => _receiving;

  Stream<VoiceSessionEvent> get events => _eventsController.stream;

  /// Dials the media endpoint, performs the token handshake, and starts both
  /// pipelines. Connection failures throw before any audio object is created.
  static Future<VoiceSession> connect({
    required String mediaUrl,
    required String room,
    required String token,
  }) async {
    final socket = await WebSocket.connect(
      mediaEndpointUri(mediaUrl).toString(),
    );
    final channel = IOWebSocketChannel(socket);
    final session = VoiceSession._(channel);

    try {
      channel.sink.add(
        jsonEncode({'type': 'join', 'room': room, 'token': token}),
      );

      session._inboundSub = channel.stream.listen(
        session._onInbound,
        onError: session._onSocketError,
        onDone: session._onSocketDone,
      );

      await session._handshake.future.timeout(const Duration(seconds: 10));
      await session._startPlayback().timeout(const Duration(seconds: 5));
      await session._openRecorder().timeout(const Duration(seconds: 5));

      session._playoutFuture = session._runPlayout();

      return session;
    } catch (_) {
      await session.dispose();

      rethrow;
    }
  }

  void _onInbound(dynamic data) {
    if (!_handshake.isCompleted) {
      _resolveHandshake(data);

      return;
    }

    if (data is! Uint8List && data is! List<int>) {
      return;
    }

    final frame = parseMediaFrame(Uint8List.fromList(data));

    if (frame == null ||
        frame.kind != mediaKindAudio ||
        frame.codec != mediaCodecPcm16 ||
        frame.voiceId == 0 ||
        frame.payload.length.isOdd) {
      return;
    }

    _mixer.push(frame.voiceId, frame.payload);
  }

  void _resolveHandshake(dynamic data) {
    if (data is! String) {
      _failHandshake('unexpected binary frame before handshake');

      return;
    }

    final Map<String, dynamic> json;

    try {
      json = jsonDecode(data) as Map<String, dynamic>;
    } catch (_) {
      _failHandshake('invalid handshake reply');

      return;
    }

    if (json['type'] == 'error') {
      _failHandshake(json['text'] as String? ?? 'voice join rejected');
    } else if (json['type'] == 'ok') {
      _handshake.complete();
    } else {
      _failHandshake('unexpected voice reply');
    }
  }

  void _failHandshake(String message) {
    if (_handshake.isCompleted) return;

    _handshake.completeError(StateError(message));
  }

  Future<void> _startPlayback() async {
    await _player.openPlayer();
    _playerOpened = true;
    await _player.startPlayerFromStream(
      codec: Codec.pcm16,
      interleaved: true,
      numChannels: audioChannels,
      sampleRate: audioSampleRate,
      bufferSize: 2048,
    );
    _playerStarted = true;
  }

  Future<void> _openRecorder() async {
    await _recorder.openRecorder();
    _recorderOpened = true;
  }

  /// Pull-driven playout loop: feeds one mixed chunk as soon as the player
  /// accepts data, keeping the native buffer full and immune to timer jitter.
  Future<void> _runPlayout() async {
    while (!_disposed) {
      final mixed = _mixer.mix(DateTime.now()) ?? _silence;

      _receiving.value = chunkPeak(mixed) >= voicePeakThreshold;

      try {
        await _player.feedUint8FromStream(mixed);
      } catch (_) {
        if (_disposed) break;
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  /// Starts or stops microphone capture; each 40 ms chunk is framed and sent
  /// over the socket.
  Future<void> setTransmitting(bool on) async {
    if (on == _transmitting) return;
    if (_captureInProgress) return;

    _transmitting = on;
    _captureInProgress = true;

    try {
      if (on) {
        await _startCapture();
      } else {
        await _stopCapture();
      }
    } catch (_) {
      _transmitting = false;
      rethrow;
    } finally {
      _captureInProgress = false;
    }
  }

  Future<void> _startCapture() async {
    final controller = StreamController<Uint8List>();
    _captureController = controller;

    controller.stream.listen((chunk) {
      for (final frame in _assembler.add(chunk)) {
        if (_disposed || _channelClosed) return;
        _channel.sink.add(encodeAudioFrame(frame));
      }
    });

    await _recorder.startRecorder(
      toStream: controller.sink,
      codec: Codec.pcm16,
      sampleRate: audioSampleRate,
      numChannels: audioChannels,
      enableEchoCancellation: true,
      enableNoiseSuppression: true,
    );
  }

  Future<void> _stopCapture() async {
    final controller = _captureController;
    _captureController = null;

    if (_recorder.isRecording) {
      try {
        await _recorder.stopRecorder();
      } catch (_) {}
    }

    if (controller != null && !controller.isClosed) {
      await controller.close();
    }
  }

  void _onSocketDone() {
    if (_disposed) return;

    if (!_handshake.isCompleted) {
      _failHandshake('media connection closed');
    }

    _emitEnded();
  }

  void _onSocketError(Object error) {
    if (_disposed) return;

    if (!_handshake.isCompleted) {
      _failHandshake(error.toString());
    }

    _eventsController.add(VoiceSessionError(error.toString()));
    _emitEnded();
  }

  void _emitEnded() {
    if (_eventsController.isClosed) return;

    _eventsController.add(VoiceSessionEnded());
  }

  Future<void> dispose() async {
    if (_disposed) return;

    _disposed = true;

    if (_transmitting) {
      await _stopCapture();
      _transmitting = false;
    }

    if (_recorderOpened) {
      try {
        await _recorder.closeRecorder();
      } catch (_) {}
    }

    if (_playerStarted) {
      try {
        await _player.stopPlayer();
      } catch (_) {}
    }

    if (_playerOpened) {
      try {
        await _player.closePlayer();
      } catch (_) {}
    }

    final playout = _playoutFuture;
    _playoutFuture = null;

    if (playout != null) {
      try {
        await playout.timeout(
          const Duration(milliseconds: 200),
          onTimeout: () {},
        );
      } catch (_) {}
    }

    await _inboundSub?.cancel();

    _channelClosed = true;

    try {
      await _channel.sink.close();
    } catch (_) {}

    _receiving.dispose();

    if (!_eventsController.isClosed) {
      await _eventsController.close();
    }
  }
}
