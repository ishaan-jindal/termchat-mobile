import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/backend_message.dart';
import '../../../data/models/backend_user_info.dart';
import '../../../core/models/message.dart';
import '../../../core/models/reaction.dart';
import '../models/reaction_update.dart';
import '../voice/voice_session.dart';

enum ConnectionStatus { disconnected, connecting, connected, reconnecting }

/// Creates voice sessions; injected so tests can substitute fakes instead
/// of dialing real media sockets and audio hardware.
typedef VoiceSessionFactory = Future<VoiceSession> Function({
  required String mediaUrl,
  required String room,
  required String token,
});

abstract class ChatRepository {
  Future<void> connect(String roomCode, String nick, {String? password});
  Future<void> disconnect();
  Future<void> sendMessage(String content, {int? replyToId});
  Future<void> updateNickname(String nick);
  Future<void> updateColor(String color);
  Future<void> setPassword(String password);
  Future<void> sendTyping();
  Future<void> sendReaction(int messageId, String name);
  Future<void> joinVoice();
  Future<void> leaveVoice();
  Future<void> setVoiceTransmit(bool on);
  void dispose();

  Stream<Message> get messages;
  Stream<List<BackendUserInfo>> get users;
  Stream<ConnectionStatus> get connectionStatus;
  Stream<ReactionUpdate> get reactionUpdates;
  Stream<bool> get voiceActive;
  Stream<String> get voiceErrors;
}

@Injectable(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  static const int maxReconnectAttempts = 10;
  static const int maxQueuedMessages = 50;
  static const int maxVoiceRejoinAttempts = 5;
  static const Duration voiceRejoinDelay = Duration(seconds: 1);

  ChatRepositoryImpl()
    : _channelFactory = WebSocketChannel.connect,
      _voiceFactory = VoiceSession.connect;

  /// Test seam: inject a fake channel factory to avoid real sockets.
  @visibleForTesting
  ChatRepositoryImpl.forTest({
    required WebSocketChannel Function(Uri uri) channelFactory,
    VoiceSessionFactory? voiceFactory,
    // ignore: prefer_initializing_formals, named for readability at call sites.
  }) : _channelFactory = channelFactory,
       _voiceFactory = voiceFactory ?? VoiceSession.connect;

  final WebSocketChannel Function(Uri uri) _channelFactory;
  final VoiceSessionFactory _voiceFactory;

  WebSocketChannel? _channel;
  final _messagesController = StreamController<Message>.broadcast();
  final _usersController = StreamController<List<BackendUserInfo>>.broadcast();
  final _connectionStatusController =
      StreamController<ConnectionStatus>.broadcast();
  final _reactionUpdatesController =
      StreamController<ReactionUpdate>.broadcast();
  final _voiceActiveController = StreamController<bool>.broadcast();
  final _voiceErrorsController = StreamController<String>.broadcast();

  String? _roomCode;
  String? _nick;
  String? _password;

  VoiceSession? _voice;
  StreamSubscription<VoiceSessionEvent>? _voiceEventSub;
  bool _voiceWanted = false;
  bool _voiceRejoinPending = false;
  int _voiceRejoinAttempts = 0;
  Completer<String>? _mediaTokenCompleter;
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  bool _isDisposed = false;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  Timer? _voiceRejoinTimer;
  StreamSubscription<dynamic>? _channelSub;
  final List<BackendMessage> _pendingSends = [];
  final _random = Random();

  @override
  Stream<Message> get messages => _messagesController.stream;

  @override
  Stream<List<BackendUserInfo>> get users => _usersController.stream;

  @override
  Stream<ReactionUpdate> get reactionUpdates =>
      _reactionUpdatesController.stream;

  @override
  Stream<bool> get voiceActive => _voiceActiveController.stream;

  @override
  Stream<String> get voiceErrors => _voiceErrorsController.stream;

  @override
  Stream<ConnectionStatus> get connectionStatus =>
      _connectionStatusController.stream;

  @override
  Future<void> connect(String roomCode, String nick, {String? password}) async {
    _roomCode = roomCode;
    _nick = nick;
    _password = password;
    _reconnectAttempts = 0;
    _pendingSends.clear();
    _isDisposed = false;

    _updateStatus(ConnectionStatus.connecting);
    try {
      await _establishConnection();
    } catch (e) {
      _updateStatus(ConnectionStatus.disconnected);
      rethrow;
    }
  }

  Future<void> _establishConnection() async {
    if (_isDisposed) return;

    // Drop any previous socket/subscription before dialing a new one so
    // reconnects never leak the old channel.
    await _channelSub?.cancel();
    _channelSub = null;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;

    final uri = Uri.parse(AppConstants.wsBaseUrl);
    _channel = _channelFactory(uri);

    final completer = Completer<void>();

    final joinMsg = BackendMessage(
      type: 'join',
      room: _roomCode,
      nick: _nick,
      password: _password,
    );
    _channel!.sink.add(jsonEncode(joinMsg.toJson()));

    _channelSub = _channel!.stream.listen(
      (data) {
        if (_isDisposed) return;
        final BackendMessage msg;
        try {
          if (data is! String) return;
          final decoded = jsonDecode(data);
          if (decoded is! Map<String, dynamic>) return;
          msg = BackendMessage.fromJson(decoded);
        } catch (_) {
          return;
        }

        if (msg.type == 'media_token') {
          final pending = _mediaTokenCompleter;
          _mediaTokenCompleter = null;

          if (pending != null && !pending.isCompleted) {
            if (msg.token != null && msg.token!.isNotEmpty) {
              pending.complete(msg.token!);
            } else {
              pending.completeError(StateError('empty media token'));
            }
          }

          return;
        }

        if (msg.type == 'error') {
          // Any server rejection fails the handshake; only a clean first
          // frame marks the room connected. After the handshake, only a
          // session-invalidating password error tears down; transient
          // errors (e.g. rate limits) are non-fatal.
          final code = msg.text ?? 'server_error';
          if (!completer.isCompleted) {
            completer.completeError(code);
            unawaited(disconnect());
          } else if (code == 'invalid_password') {
            if (!_messagesController.isClosed) {
              _messagesController.addError(code);
            }
            unawaited(disconnect());
          }
          return;
        }

        if (!completer.isCompleted) {
          completer.complete();
          _updateStatus(ConnectionStatus.connected);
          _reconnectAttempts = 0;
          _flushQueue();
        }

        if (msg.type == 'history') {
          if (msg.messages != null) {
            for (var m in msg.messages!) {
              _handleIncomingMessage(m, _roomCode ?? '');
            }
          }
        } else if (msg.type == 'users_list') {
          if (msg.users != null && !_usersController.isClosed) {
            _usersController.add(msg.users!);
          }
        } else if (msg.type == 'reaction') {
          if (msg.id != null && !_reactionUpdatesController.isClosed) {
            _reactionUpdatesController.add(
              ReactionUpdate(
                messageId: msg.id.toString(),
                reactions:
                    msg.reactions
                        ?.map((r) => Reaction(name: r.name, count: r.count))
                        .toList() ??
                    const [],
              ),
            );
          }
        } else {
          _handleIncomingMessage(msg, _roomCode ?? '');
        }
      },
      onError: (Object error) {
        if (_isDisposed) return;
        if (!completer.isCompleted) {
          completer.completeError(error);
        } else {
          _handleDisconnectOrError(error);
        }
      },
      onDone: () {
        if (_isDisposed) return;
        if (!completer.isCompleted) {
          completer.completeError('Disconnected before joining');
        } else {
          _handleDisconnectOrError('Connection closed');
        }
      },
    );

    return completer.future.timeout(
      AppConstants.wsJoinTimeout,
      onTimeout: () {
        _channelSub?.cancel();
        _channelSub = null;
        try {
          _channel?.sink.close();
        } catch (_) {}
        _channel = null;
        throw TimeoutException('Connection timed out');
      },
    );
  }

  void _handleDisconnectOrError(Object error) {
    if (_isDisposed ||
        _connectionStatus == ConnectionStatus.reconnecting ||
        _connectionStatus == ConnectionStatus.connecting) {
      return;
    }

    _closeVoiceSession();

    _updateStatus(ConnectionStatus.reconnecting);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    if (_isDisposed) return;

    if (_reconnectAttempts >= maxReconnectAttempts) {
      _pendingSends.clear();
      _updateStatus(ConnectionStatus.disconnected);
      return;
    }

    final backoffSeconds = (1 << _reconnectAttempts).clamp(1, 30);
    final jitterMs = _random.nextInt(1000);
    _reconnectAttempts++;

    _reconnectTimer = Timer(
      Duration(seconds: backoffSeconds, milliseconds: jitterMs),
      () async {
        if (_isDisposed || _connectionStatus != ConnectionStatus.reconnecting) {
          return;
        }

        try {
          await _establishConnection();
          await _maybeRejoinVoice();
        } catch (_) {
          _scheduleReconnect();
        }
      },
    );
  }

  /// Sends immediately when connected, otherwise queues (bounded) for flush
  /// on reconnect. Typing is ephemeral and dropped while offline.
  void _sendOrQueue(BackendMessage msg, {bool dropWhenOffline = false}) {
    if (_isDisposed) return;
    final channel = _channel;
    if (channel != null && _connectionStatus == ConnectionStatus.connected) {
      try {
        channel.sink.add(jsonEncode(msg.toJson()));
        return;
      } catch (_) {
        // Fall through to queue so the message is not silently lost.
      }
    }
    if (dropWhenOffline) return;
    if (_pendingSends.length >= maxQueuedMessages) {
      _pendingSends.removeAt(0);
    }
    _pendingSends.add(msg);
  }

  void _flushQueue() {
    if (_pendingSends.isEmpty) return;
    final pending = List<BackendMessage>.from(_pendingSends);
    _pendingSends.clear();
    for (var i = 0; i < pending.length; i++) {
      try {
        _channel?.sink.add(jsonEncode(pending[i].toJson()));
      } catch (_) {
        // Re-queue the failed message AND everything after it to preserve
        // order; nothing is dropped.
        _pendingSends.insertAll(0, pending.sublist(i));
        break;
      }
    }
  }

  void _handleIncomingMessage(BackendMessage backendMsg, String roomCode) {
    if (backendMsg.type == 'chat' ||
        backendMsg.type == 'message' ||
        backendMsg.type == 'system') {
      if (_messagesController.isClosed) return;
      final ts = backendMsg.timestamp;
      final timestamp = ts != null
          ? DateTime.fromMillisecondsSinceEpoch(ts)
          : DateTime.now();
      final nick = backendMsg.nick ?? 'system';
      final id =
          backendMsg.id?.toString() ??
          (ts != null
              ? '${ts}_$nick'
              : '${timestamp.millisecondsSinceEpoch}_$nick');
      final msg = Message(
        id: id,
        roomId: roomCode,
        senderId: nick,
        senderNickname: nick,
        senderColorHex: backendMsg.color ?? '#FFFFFF',
        content: backendMsg.text ?? '',
        timestamp: timestamp,
        isSystemMessage: backendMsg.type == 'system',
        reactions:
            backendMsg.reactions
                ?.map((r) => Reaction(name: r.name, count: r.count))
                .toList() ??
            const [],
        replyToId: backendMsg.replyToId,
        replyToNick: backendMsg.replyToNick,
        replyToText: backendMsg.replyToText,
      );
      _messagesController.add(msg);
    }
  }

  @override
  Future<void> sendMessage(String content, {int? replyToId}) async {
    _sendOrQueue(
      BackendMessage(type: 'message', text: content, replyToId: replyToId),
    );
  }

  @override
  Future<void> updateNickname(String nick) async {
    _sendOrQueue(BackendMessage(type: 'nick', newNick: nick));
  }

  @override
  Future<void> updateColor(String color) async {
    _sendOrQueue(BackendMessage(type: 'color', color: color));
  }

  @override
  Future<void> setPassword(String password) async {
    _sendOrQueue(BackendMessage(type: 'set_password', password: password));
  }

  @override
  Future<void> sendTyping() async {
    _sendOrQueue(BackendMessage(type: 'typing'), dropWhenOffline: true);
  }

  @override
  Future<void> sendReaction(int messageId, String name) async {
    _sendOrQueue(BackendMessage(type: 'reaction', id: messageId, text: name));
  }

  @override
  Future<void> joinVoice() async {
    if (_voice != null) return;

    if (_channel == null ||
        _connectionStatus != ConnectionStatus.connected ||
        _roomCode == null) {
      throw StateError('not connected');
    }

    _voiceWanted = true;
    _voiceRejoinAttempts = 0;

    try {
      await _establishVoice();
    } catch (_) {
      _voiceWanted = false;

      rethrow;
    }
  }

  /// Dials the media session without touching the want/retry bookkeeping,
  /// so rejoin attempts don't clear the user's intent on transient failure.
  Future<void> _establishVoice() async {
    final token = await _requestMediaToken();
    final session = await _voiceFactory(
      mediaUrl: AppConstants.mediaWsBaseUrl,
      room: _roomCode!,
      token: token,
    );

    if (_isDisposed) {
      await session.dispose();

      return;
    }

    _voice = session;
    _voiceEventSub = session.events.listen(_onVoiceEvent);
    _emitVoiceActive(true);
  }

  @override
  Future<void> leaveVoice() async {
    _voiceWanted = false;
    _voiceRejoinPending = false;
    _voiceRejoinAttempts = 0;
    _voiceRejoinTimer?.cancel();
    _voiceRejoinTimer = null;
    await _closeVoiceSession();
  }

  @override
  Future<void> setVoiceTransmit(bool on) async {
    await _voice?.setTransmitting(on);
  }

  Future<String> _requestMediaToken() async {
    final channel = _channel;
    if (channel == null || _connectionStatus != ConnectionStatus.connected) {
      throw StateError('not connected');
    }
    // Fail any superseded request instead of leaving it hanging forever.
    final stale = _mediaTokenCompleter;
    if (stale != null && !stale.isCompleted) {
      stale.completeError(StateError('media token request superseded'));
    }
    final completer = Completer<String>();
    _mediaTokenCompleter = completer;

    channel.sink.add(jsonEncode(BackendMessage(type: 'media_token').toJson()));

    final token = await completer.future.timeout(
      AppConstants.mediaTokenTimeout,
      onTimeout: () {
        // Only clear our own completer; a newer request may own the field.
        if (identical(_mediaTokenCompleter, completer)) {
          _mediaTokenCompleter = null;
        }
        throw TimeoutException('media token request timed out');
      },
    );

    return token;
  }

  /// Completes a pending media-token request with an error instead of
  /// dropping it (a dropped completer hangs the awaiting joinVoice forever).
  void _failPendingMediaToken(Object error) {
    final pending = _mediaTokenCompleter;
    _mediaTokenCompleter = null;
    if (pending != null && !pending.isCompleted) {
      pending.completeError(error);
    }
  }

  Future<void> _closeVoiceSession() async {
    final session = _voice;
    _voice = null;

    await _voiceEventSub?.cancel();
    _voiceEventSub = null;

    if (session != null) {
      await session.dispose();
      _emitVoiceActive(false);
    }
  }

  void _onVoiceEvent(VoiceSessionEvent event) {
    if (event is VoiceSessionError) {
      if (!_voiceErrorsController.isClosed) {
        _voiceErrorsController.add(event.message);
      }
    }

    if (event is VoiceSessionEnded) {
      final wasActive = _voice != null;
      _voice = null;
      _emitVoiceActive(false);

      // Keep the rejoin intent even while reconnecting: _maybeRejoinVoice
      // retries once the socket is back instead of dropping voice silently.
      if (wasActive && _voiceWanted && !_voiceRejoinPending) {
        _voiceRejoinPending = true;
        _scheduleVoiceRejoin();
      }
    }
  }

  void _scheduleVoiceRejoin() {
    _voiceRejoinTimer?.cancel();
    if (_isDisposed) return;
    _voiceRejoinTimer = Timer(voiceRejoinDelay, () {
      _voiceRejoinPending = false;
      unawaited(_maybeRejoinVoice());
    });
  }

  Future<void> _maybeRejoinVoice() async {
    if (_isDisposed || !_voiceWanted || _voice != null) return;

    if (_connectionStatus != ConnectionStatus.connected) {
      // Offline: stay pending; the reconnect completion path retries.
      _voiceRejoinPending = true;
      return;
    }

    try {
      await _establishVoice();
      _voiceRejoinPending = false;
      _voiceRejoinAttempts = 0;
    } catch (e) {
      _voiceRejoinAttempts++;
      if (!_voiceErrorsController.isClosed) {
        _voiceErrorsController.add(e.toString());
      }
      if (_voiceRejoinAttempts >= maxVoiceRejoinAttempts) {
        // Bounded retries: give up instead of draining the battery in a
        // 1s loop against a permanent failure (e.g. revoked mic).
        _voiceWanted = false;
        _voiceRejoinPending = false;
        _voiceRejoinAttempts = 0;
      } else {
        _voiceRejoinPending = true;
        _scheduleVoiceRejoin();
      }
    }
  }

  void _emitVoiceActive(bool active) {
    if (!_voiceActiveController.isClosed) {
      _voiceActiveController.add(active);
    }
  }

  @override
  Future<void> disconnect() async {
    _voiceWanted = false;
    _voiceRejoinTimer?.cancel();
    _voiceRejoinTimer = null;
    _voiceRejoinPending = false;
    _voiceRejoinAttempts = 0;
    _pendingSends.clear();
    await _closeVoiceSession();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _failPendingMediaToken(StateError('disconnected'));
    _updateStatus(ConnectionStatus.disconnected);
    await _channelSub?.cancel();
    _channelSub = null;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    _voiceRejoinTimer?.cancel();
    _channelSub?.cancel();
    _voiceEventSub?.cancel();
    _failPendingMediaToken(StateError('disposed'));
    // Best-effort close; controllers guarded by isClosed on every add.
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _messagesController.close();
    _usersController.close();
    _connectionStatusController.close();
    _reactionUpdatesController.close();
    _voiceActiveController.close();
    _voiceErrorsController.close();
  }

  void _updateStatus(ConnectionStatus status) {
    _connectionStatus = status;
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.add(status);
    }
  }
}
