import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:termchat_app/core/models/message.dart';
import 'package:termchat_app/data/models/backend_user_info.dart';
import 'package:termchat_app/features/chat/repositories/chat_repository.dart';
import 'package:termchat_app/features/chat/voice/voice_session.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// In-memory WebSocketChannel that records what the client sends and lets the
/// test push frames as if they came from the server.
class FakeWebSocketChannel extends StreamChannelMixin<dynamic>
    implements WebSocketChannel {
  FakeWebSocketChannel() : controller = StreamController<dynamic>.broadcast();

  final StreamController<dynamic> controller;
  final List<Object?> sent = [];
  bool closed = false;

  /// When true, sink.add throws to simulate a dead socket mid-flush.
  bool throwOnSend = false;

  @override
  String? get protocol => null;

  @override
  int? get closeCode => null;

  @override
  String? get closeReason => null;

  @override
  Future<void> get ready => Future<void>.value();

  @override
  Stream<dynamic> get stream => controller.stream;

  @override
  WebSocketSink get sink => _FakeSink(this);

  void serverSend(Object message) {
    controller.add(message);
  }

  void serverDone() {
    controller.close();
  }
}

class _FakeSink implements WebSocketSink {
  _FakeSink(this._channel);

  final FakeWebSocketChannel _channel;

  @override
  Future<void> get done => _channel.controller.done;

  @override
  void add(Object? event) {
    if (_channel.throwOnSend) {
      throw StateError('sink closed');
    }
    // Record only: a real socket never echoes client sends back inbound.
    _channel.sent.add(event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _channel.controller.addError(error, stackTrace);
  }

  @override
  Future<void> addStream(Stream<dynamic> stream) =>
      _channel.controller.addStream(stream);

  @override
  Future<void> close([int? closeCode, String? closeReason]) {
    _channel.closed = true;
    return _channel.controller.close();
  }
}

void main() {
  late ChatRepositoryImpl repo;
  late List<FakeWebSocketChannel> channels;

  FakeWebSocketChannel channel() => channels.last;

  setUp(() {
    channels = [];
    repo = ChatRepositoryImpl.forTest(
      channelFactory: (_) {
        final c = FakeWebSocketChannel();
        channels.add(c);
        return c;
      },
    );
  });

  tearDown(() {
    repo.dispose();
  });

  /// Flushes pending microtasks/timers so async broadcast deliveries land.
  Future<void> pump() => Future<void>.delayed(Duration.zero);

  Future<void> connectAndHandshake() async {
    final future = repo.connect('ROOM', 'Alice');
    // Let _establishConnection reach the stream.listen call before replying.
    await pump();
    // Server replies with the join ack.
    channel().serverSend(jsonEncode({'type': 'ok'}));
    await future;
    await pump();
  }

  group('connect', () {
    test('completes and reports connected after handshake', () async {
      final statuses = <ConnectionStatus>[];
      final sub = repo.connectionStatus.listen(statuses.add);

      final connect = repo.connect('ROOM', 'Alice');
      await pump();
      channel().serverSend(jsonEncode({'type': 'ok'}));
      await connect;
      await pump();

      expect(statuses, contains(ConnectionStatus.connected));
      expect(channel().sent, isNotEmpty);
      await sub.cancel();
    });

    test('throws invalid_password when server rejects', () async {
      final connect = repo.connect('ROOM', 'Alice', password: 'wrong');
      await pump();
      channel().serverSend(
        jsonEncode({'type': 'error', 'text': 'invalid_password'}),
      );

      await expectLater(connect, throwsA('invalid_password'));
      await pump();
    });

    test(
      'fails the handshake on any server error, not just password',
      () async {
        final connect = repo.connect('ROOM', 'Alice');
        await pump();
        channel().serverSend(
          jsonEncode({'type': 'error', 'text': 'nick-taken'}),
        );

        await expectLater(connect, throwsA('nick-taken'));
        await pump();
      },
    );

    test('ignores transient post-join errors without disconnecting', () async {
      await connectAndHandshake();

      final statuses = <ConnectionStatus>[];
      final sub = repo.connectionStatus.listen(statuses.add);
      final messages = <Message>[];
      final msgSub = repo.messages.listen(messages.add);

      channel().serverSend(
        jsonEncode({'type': 'error', 'text': 'rate_limited'}),
      );
      await pump();

      expect(statuses, isNot(contains(ConnectionStatus.disconnected)));

      channel().serverSend(
        jsonEncode({'type': 'chat', 'nick': 'Bob', 'text': 'still here'}),
      );
      await pump();
      expect(messages.map((m) => m.content), contains('still here'));

      await sub.cancel();
      await msgSub.cancel();
    });
  });

  group('inbound parsing', () {
    test('emits chat messages from history batch', () async {
      await connectAndHandshake();

      final messages = <Message>[];
      final sub = repo.messages.listen(messages.add);

      channel().serverSend(
        jsonEncode({
          'type': 'history',
          'messages': [
            {'type': 'chat', 'nick': 'Bob', 'text': 'hi', 'timestamp': 1},
            {'type': 'chat', 'nick': 'Cara', 'text': 'yo', 'timestamp': 2},
          ],
        }),
      );

      await pump();
      expect(messages, hasLength(2));
      expect(messages[0].content, 'hi');
      expect(messages[1].senderNickname, 'Cara');
      await sub.cancel();
    });

    test('emits users list', () async {
      await connectAndHandshake();

      final users = <List<BackendUserInfo>>[];
      final sub = repo.users.listen(users.add);

      channel().serverSend(
        jsonEncode({
          'type': 'users_list',
          'users': [
            {'nick': 'Bob', 'color': '#FF0000'},
          ],
        }),
      );

      await pump();
      expect(users, hasLength(1));
      expect(users.first, hasLength(1));
      await sub.cancel();
    });

    test('skips malformed frames without killing the listener', () async {
      await connectAndHandshake();

      final messages = <Message>[];
      final sub = repo.messages.listen(messages.add);

      channel().serverSend('not-json');
      channel().serverSend(
        jsonEncode({'type': 'chat', 'nick': 'Bob', 'text': 'ok'}),
      );
      channel().serverSend(<int>[1, 2, 3]); // binary frame

      await pump();
      expect(messages, hasLength(1));
      expect(messages.single.content, 'ok');
      await sub.cancel();
    });
  });

  group('reconnect', () {
    test('re-enters reconnecting on socket close and reconnects', () async {
      await connectAndHandshake();

      final statuses = <ConnectionStatus>[];
      final sub = repo.connectionStatus.listen(statuses.add);
      statuses.clear();

      channels.first.serverDone();
      await pump();
      expect(statuses, contains(ConnectionStatus.reconnecting));

      // Backoff is ~1s + jitter; let the reconnect timer fire and dial.
      await Future<void>.delayed(const Duration(milliseconds: 2500));
      await pump();
      await pump();
      expect(channels, hasLength(2));

      channels.last.serverSend(jsonEncode({'type': 'ok'}));
      await pump();
      expect(statuses, contains(ConnectionStatus.connected));

      await sub.cancel();
    });

    test('queues sends while reconnecting and flushes on reconnect', () async {
      await connectAndHandshake();

      channels.first.serverDone();
      await pump();

      await repo.sendMessage('hello');
      await repo.sendMessage('world');

      // Nothing flushed while reconnecting.
      final before = channels.last.sent.map((e) => e.toString()).join('\n');
      expect(before, isNot(contains('hello')));

      await Future<void>.delayed(const Duration(milliseconds: 2500));
      await pump();
      await pump();
      channels.last.serverSend(jsonEncode({'type': 'ok'}));
      await pump();

      final sentStrings = channels.last.sent
          .map((e) => e.toString())
          .join('\n');
      expect(sentStrings, contains('hello'));
      expect(sentStrings, contains('world'));
    });

    test('drops typing while offline', () async {
      await connectAndHandshake();

      channels.first.serverDone();
      await pump();

      await repo.sendTyping();
      await repo.sendMessage('kept');

      await Future<void>.delayed(const Duration(milliseconds: 2500));
      await pump();
      await pump();
      channels.last.serverSend(jsonEncode({'type': 'ok'}));
      await pump();

      final sentStrings = channels.last.sent
          .map((e) => e.toString())
          .join('\n');
      expect(sentStrings, isNot(contains('"typing"')));
      expect(sentStrings, contains('kept'));
    });

    test('failed flush re-queues the whole tail in order', () async {
      await connectAndHandshake();

      channels.first.serverDone();
      await pump();

      await repo.sendMessage('one');
      await repo.sendMessage('two');
      await repo.sendMessage('three');

      await Future<void>.delayed(const Duration(milliseconds: 2500));
      await pump();
      await pump();
      expect(channels, hasLength(2));

      // Kill the redialed socket before the ack so the flush fails.
      channels.last.throwOnSend = true;
      channels.last.serverSend(jsonEncode({'type': 'ok'}));
      await pump();

      // Only the join went out; nothing was lost.
      expect(channels.last.sent, hasLength(1));

      // Next reconnect flushes all three in order.
      channels.last.serverDone();
      await pump();
      await Future<void>.delayed(const Duration(milliseconds: 2500));
      await pump();
      await pump();
      channels.last.serverSend(jsonEncode({'type': 'ok'}));
      await pump();

      final sentStrings = channels.last.sent
          .map((e) => e.toString())
          .join('\n');
      final one = sentStrings.indexOf('one');
      final two = sentStrings.indexOf('two');
      final three = sentStrings.indexOf('three');
      expect(one, isNonNegative);
      expect(two, greaterThan(one));
      expect(three, greaterThan(two));
    });
  });

  group('media token', () {
    test(
      'disconnect fails a pending token request instead of hanging',
      () async {
        await connectAndHandshake();

        final join = repo.joinVoice();
        await pump();
        final expectation = expectLater(join, throwsStateError);

        await repo.disconnect();

        await expectation;
      },
    );

    test('a second token request fails the superseded first one', () async {
      await connectAndHandshake();

      final first = repo.joinVoice();
      await pump();
      final firstExpectation = expectLater(
        first,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'media token request superseded',
          ),
        ),
      );
      final second = repo.joinVoice();
      await pump();
      final secondExpectation = expectLater(second, throwsStateError);

      await repo.disconnect();

      await firstExpectation;
      await secondExpectation;
    });
  });

  group('voice rejoin', () {
    late StreamController<VoiceSessionEvent> voiceEvents;
    late MockVoiceSession voiceSession;
    late int voiceFactoryCalls;
    late bool failVoice;

    setUp(() {
      voiceEvents = StreamController<VoiceSessionEvent>.broadcast();
      voiceSession = MockVoiceSession();
      when(() => voiceSession.events).thenAnswer((_) => voiceEvents.stream);
      when(() => voiceSession.dispose()).thenAnswer((_) async {});
      voiceFactoryCalls = 0;
      failVoice = false;
      repo = ChatRepositoryImpl.forTest(
        channelFactory: (_) {
          final c = FakeWebSocketChannel();
          channels.add(c);
          return c;
        },
        voiceFactory:
            ({
              required String mediaUrl,
              required String room,
              required String token,
            }) async {
              voiceFactoryCalls++;
              if (failVoice) throw StateError('mic dead');
              return voiceSession;
            },
      );
    });

    tearDown(() async {
      await voiceEvents.close();
    });

    /// Answers the in-flight media-token request, retrying until the factory
    /// has been reached [count] times (spurious tokens with no pending
    /// request are ignored by the repo).
    Future<void> answerTokenUntil(int count) async {
      for (var i = 0; i < 30; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        channel().serverSend(
          jsonEncode({'type': 'media_token', 'token': 'tok$i'}),
        );
        await pump();
        if (voiceFactoryCalls >= count) return;
      }
      fail('timed out waiting for a media-token request');
    }

    Future<void> joinVoiceFlow() async {
      final target = voiceFactoryCalls + 1;
      final join = repo.joinVoice();
      await answerTokenUntil(target);
      await join;
      await pump();
    }

    test('Ended schedules a rejoin that reactivates voice', () async {
      await connectAndHandshake();
      await joinVoiceFlow();
      expect(voiceFactoryCalls, 1);

      final active = <bool>[];
      final sub = repo.voiceActive.listen(active.add);

      voiceEvents.add(VoiceSessionEnded());
      await pump();
      // Rejoin timer is 1s; the rejoin itself needs another token answer.
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      await pump();
      await answerTokenUntil(2);
      await pump();

      expect(voiceFactoryCalls, 2);
      expect(active, contains(true));
      await sub.cancel();
    });

    test('persistent rejoin failure surfaces errors then gives up', () async {
      await connectAndHandshake();
      await joinVoiceFlow();

      final errors = <String>[];
      final sub = repo.voiceErrors.listen(errors.add);

      failVoice = true;
      voiceEvents.add(VoiceSessionEnded());

      // 5 bounded attempts, ~1s apart; keep answering tokens so each
      // attempt reaches the (failing) factory instead of timing out.
      for (var i = 0; i < 40 && voiceFactoryCalls < 6; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        channel().serverSend(
          jsonEncode({'type': 'media_token', 'token': 't$i'}),
        );
        await pump();
      }

      expect(voiceFactoryCalls, 6); // 1 initial + 5 rejoins
      expect(errors, hasLength(5));

      // Intent cleared: no further attempts after the cap.
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      await pump();
      expect(voiceFactoryCalls, 6);

      await sub.cancel();
    });
  });
}

class MockVoiceSession extends Mock implements VoiceSession {}
