import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/backend_message.dart';
import '../../../data/models/backend_user_info.dart';
import '../../../core/models/message.dart';

enum ConnectionStatus { disconnected, connecting, connected, reconnecting }

abstract class ChatRepository {
  Future<void> connect(String roomCode, String nick, {String? password});
  Future<void> disconnect();
  Future<void> sendMessage(String content);
  Future<void> updateNickname(String nick);
  Future<void> updateColor(String color);
  Future<void> setPassword(String password);
  Future<void> sendTyping();
  void dispose();

  Stream<Message> get messages;
  Stream<List<BackendUserInfo>> get users;
  Stream<ConnectionStatus> get connectionStatus;
}

@Injectable(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  WebSocketChannel? _channel;
  final _messagesController = StreamController<Message>.broadcast();
  final _usersController = StreamController<List<BackendUserInfo>>.broadcast();
  final _connectionStatusController =
      StreamController<ConnectionStatus>.broadcast();

  String? _roomCode;
  String? _nick;
  String? _password;

  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  bool _isDisposed = false;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;

  @override
  Stream<Message> get messages => _messagesController.stream;

  @override
  Stream<List<BackendUserInfo>> get users => _usersController.stream;

  @override
  Stream<ConnectionStatus> get connectionStatus =>
      _connectionStatusController.stream;

  @override
  Future<void> connect(String roomCode, String nick, {String? password}) async {
    _roomCode = roomCode;
    _nick = nick;
    _password = password;
    _reconnectAttempts = 0;
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

    final uri = Uri.parse(AppConstants.wsBaseUrl);
    _channel = WebSocketChannel.connect(uri);

    final completer = Completer<void>();

    final joinMsg = BackendMessage(
      type: 'join',
      room: _roomCode,
      nick: _nick,
      password: _password,
    );
    _channel!.sink.add(jsonEncode(joinMsg.toJson()));

    _channel!.stream.listen(
      (data) {
        if (_isDisposed) return;
        final Map<String, dynamic> json = jsonDecode(data as String);
        final msg = BackendMessage.fromJson(json);

        if (msg.type == 'error' && msg.text == 'invalid_password') {
          if (!completer.isCompleted) {
            completer.completeError('invalid_password');
          } else {
            _messagesController.addError('invalid_password');
          }
          disconnect();
          return;
        }

        if (!completer.isCompleted) {
          completer.complete();
          _updateStatus(ConnectionStatus.connected);
          _reconnectAttempts = 0;
        }

        if (msg.type == 'history') {
          if (msg.messages != null) {
            for (var m in msg.messages!) {
              _handleIncomingMessage(m, _roomCode ?? '');
            }
          }
        } else if (msg.type == 'users_list') {
          if (msg.users != null) {
            _usersController.add(msg.users!);
          }
        } else {
          _handleIncomingMessage(msg, _roomCode ?? '');
        }
      },
      onError: (error) {
        if (_isDisposed) return;
        if (!completer.isCompleted) {
          completer.completeError(error);
        } else {
          _messagesController.addError(error);
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
      const Duration(seconds: 10),
      onTimeout: () {
        _channel?.sink.close();
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

    _updateStatus(ConnectionStatus.reconnecting);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    if (_isDisposed) return;

    final delaySeconds = (1 << _reconnectAttempts).clamp(1, 30);
    _reconnectAttempts++;

    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () async {
      if (_isDisposed || _connectionStatus != ConnectionStatus.reconnecting) {
        return;
      }

      try {
        await _establishConnection();
      } catch (e) {
        _scheduleReconnect();
      }
    });
  }

  void _handleIncomingMessage(BackendMessage backendMsg, String roomCode) {
    if (backendMsg.type == 'chat' ||
        backendMsg.type == 'message' ||
        backendMsg.type == 'system') {
      final msg = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        roomId: roomCode,
        senderId: backendMsg.nick ?? 'system',
        senderNickname: backendMsg.nick ?? 'system',
        senderColorHex: backendMsg.color ?? '#FFFFFF',
        content: backendMsg.text ?? '',
        timestamp: DateTime.now(),
        isSystemMessage: backendMsg.type == 'system',
      );
      _messagesController.add(msg);
    }
  }

  @override
  Future<void> sendMessage(String content) async {
    if (_channel != null) {
      final msg = BackendMessage(type: 'message', text: content);
      _channel!.sink.add(jsonEncode(msg.toJson()));
    }
  }

  @override
  Future<void> updateNickname(String nick) async {
    if (_channel != null) {
      final msg = BackendMessage(type: 'nick', newNick: nick);
      _channel!.sink.add(jsonEncode(msg.toJson()));
    }
  }

  @override
  Future<void> updateColor(String color) async {
    if (_channel != null) {
      final msg = BackendMessage(type: 'color', color: color);
      _channel!.sink.add(jsonEncode(msg.toJson()));
    }
  }

  @override
  Future<void> setPassword(String password) async {
    if (_channel != null) {
      final msg = BackendMessage(type: 'set_password', password: password);
      _channel!.sink.add(jsonEncode(msg.toJson()));
    }
  }

  @override
  Future<void> sendTyping() async {
    if (_channel != null) {
      final msg = BackendMessage(type: 'typing');
      _channel!.sink.add(jsonEncode(msg.toJson()));
    }
  }

  @override
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _updateStatus(ConnectionStatus.disconnected);
    await _channel?.sink.close();
    _channel = null;
  }

  @override
  void dispose() {
    _isDisposed = true;
    disconnect();
    _messagesController.close();
    _usersController.close();
    _connectionStatusController.close();
  }

  void _updateStatus(ConnectionStatus status) {
    _connectionStatus = status;
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.add(status);
    }
  }
}
