import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/message.dart';
import '../models/backend_message.dart';

abstract class ChatRepository {
  Future<void> connect(String roomCode, String nick, {String? password});
  Future<void> disconnect();
  Future<void> sendMessage(String content);
  Future<void> updateNickname(String nick);
  Future<void> updateColor(String color);
  Future<void> setPassword(String password);
  Future<void> sendTyping();

  Stream<Message> get messages;
  Stream<List<BackendUserInfo>> get users;
}

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  WebSocketChannel? _channel;
  final _messagesController = StreamController<Message>.broadcast();
  final _usersController = StreamController<List<BackendUserInfo>>.broadcast();

  @override
  Stream<Message> get messages => _messagesController.stream;

  @override
  Stream<List<BackendUserInfo>> get users => _usersController.stream;

  @override
  Future<void> connect(String roomCode, String nick, {String? password}) async {
    final uri = Uri.parse('wss://termchat.sacred99.online/ws');
    _channel = WebSocketChannel.connect(uri);

    // Send join message immediately
    final joinMsg = BackendMessage(
      type: 'join',
      room: roomCode,
      nick: nick,
      password: password,
    );
    _channel!.sink.add(jsonEncode(joinMsg.toJson()));

    // Listen to incoming messages
    _channel!.stream.listen(
      (data) {
        final Map<String, dynamic> json = jsonDecode(data as String);
        final msg = BackendMessage.fromJson(json);

        if (msg.type == 'error' && msg.text == 'invalid_password') {
          _messagesController.addError('invalid_password');
          disconnect();
          return;
        }

        if (msg.type == 'history') {
          // Add all historical messages
          if (msg.messages != null) {
            for (var m in msg.messages!) {
              _handleIncomingMessage(m, roomCode);
            }
          }
        } else if (msg.type == 'users') {
          if (msg.users != null) {
            _usersController.add(msg.users!);
          }
        } else {
          _handleIncomingMessage(msg, roomCode);
        }
      },
      onError: (error) {
        _messagesController.addError(error);
      },
      onDone: () {
        // Handle disconnect if needed
      },
    );
  }

  void _handleIncomingMessage(BackendMessage backendMsg, String roomCode) {
    // Both 'chat' and 'message' are parsed for safety
    if (backendMsg.type == 'chat' ||
        backendMsg.type == 'message' ||
        backendMsg.type == 'system') {
      final msg = Message(
        id: DateTime.now().millisecondsSinceEpoch
            .toString(), // Temporary ID since backend doesn't provide one
        roomId: roomCode,
        senderId: backendMsg.nick ?? 'system',
        senderNickname: backendMsg.nick ?? 'system',
        senderColorHex: backendMsg.color ?? '#FFFFFF',
        content: backendMsg.text ?? '',
        timestamp: DateTime.now(), // backend should ideally provide timestamp
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
    await _channel?.sink.close();
    _channel = null;
  }
}
