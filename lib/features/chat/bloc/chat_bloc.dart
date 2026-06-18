import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/models/message.dart';
import '../../../core/models/backend_message.dart';
import '../repositories/chat_repository.dart';

part 'chat_state.dart';
part 'chat_event.dart';

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  StreamSubscription<Message>? _messageSubscription;
  StreamSubscription<List<BackendUserInfo>>? _usersSubscription;
  StreamSubscription<ConnectionStatus>? _connectionStatusSubscription;

  ChatBloc(this._repository) : super(const ChatState()) {
    on<ConnectChat>(_onConnectChat);
    on<SendMessage>(_onSendMessage);
    on<UpdateNickname>(_onUpdateNickname);
    on<UpdateColor>(_onUpdateColor);
    on<SetRoomPassword>(_onSetRoomPassword);
    on<SendTyping>(_onSendTyping);
    on<_MessageReceived>(_onMessageReceived);
    on<_UsersUpdated>(_onUsersUpdated);
    on<_ChatError>(_onChatError);
    on<DisconnectChat>(_onDisconnectChat);
    on<_ConnectionStatusChanged>(_onConnectionStatusChanged);
  }

  Future<void> _onConnectChat(
    ConnectChat event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _connectionStatusSubscription?.cancel();
      _connectionStatusSubscription = _repository.connectionStatus.listen(
        (status) => add(_ConnectionStatusChanged(status)),
      );

      await _repository.connect(
        event.roomCode,
        event.nick,
        password: event.password,
      );

      await _messageSubscription?.cancel();
      await _usersSubscription?.cancel();

      _messageSubscription = _repository.messages.listen(
        (message) => add(_MessageReceived(message)),
        onError: (error) => add(_ChatError(error.toString())),
      );

      _usersSubscription = _repository.users.listen(
        (users) => add(_UsersUpdated(users)),
        onError: (error) {},
      );

      emit(
        state.copyWith(
          isLoading: false,
          isConnected: true,
          roomCode: event.roomCode,
        ),
      );

      if (event.colorHex.isNotEmpty) {
        add(SendMessage('/color ${event.colorHex}'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final content = event.content;
      if (content.startsWith('/')) {
        final parts = content.split(' ');
        final cmd = parts[0].toLowerCase();

        if (cmd == '/nick' && parts.length > 1) {
          final newNick = parts.sublist(1).join(' ');
          add(UpdateNickname(newNick));
          return;
        } else if (cmd == '/color' && parts.length > 1) {
          add(UpdateColor(parts[1]));
          return;
        } else if (cmd == '/password') {
          final newPass = parts.length > 1 ? parts.sublist(1).join(' ') : '';
          add(SetRoomPassword(newPass));
          return;
        } else if (cmd == '/help') {
          final helpMsg = Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            roomId: state.roomCode ?? '',
            senderId: 'system',
            senderNickname: 'system',
            senderColorHex: '#888888',
            content: 'Commands: /help /clear /nick /color /password /quit',
            timestamp: DateTime.now(),
            isSystemMessage: true,
          );
          emit(
            state.copyWith(messages: List.from(state.messages)..add(helpMsg)),
          );
          return;
        } else if (cmd == '/clear') {
          emit(state.copyWith(messages: []));
          return;
        }
      }

      await _repository.sendMessage(content);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onUpdateNickname(
    UpdateNickname event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _repository.updateNickname(event.nickname);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onUpdateColor(
    UpdateColor event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _repository.updateColor(event.colorHex);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onSetRoomPassword(
    SetRoomPassword event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _repository.setPassword(event.password);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onSendTyping(SendTyping event, Emitter<ChatState> emit) async {
    try {
      await _repository.sendTyping();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onMessageReceived(_MessageReceived event, Emitter<ChatState> emit) {
    final updatedMessages = List<Message>.from(state.messages)
      ..add(event.message);
    emit(state.copyWith(messages: updatedMessages));
  }

  void _onUsersUpdated(_UsersUpdated event, Emitter<ChatState> emit) {
    emit(state.copyWith(users: event.users));
  }

  void _onChatError(_ChatError event, Emitter<ChatState> emit) {
    emit(state.copyWith(error: event.error, isConnected: false));
  }

  Future<void> _onDisconnectChat(
    DisconnectChat event,
    Emitter<ChatState> emit,
  ) async {
    await _messageSubscription?.cancel();
    await _usersSubscription?.cancel();
    await _connectionStatusSubscription?.cancel();
    _messageSubscription = null;
    _usersSubscription = null;
    _connectionStatusSubscription = null;
    await _repository.disconnect();
    emit(const ChatState());
  }

  void _onConnectionStatusChanged(
    _ConnectionStatusChanged event,
    Emitter<ChatState> emit,
  ) {
    switch (event.status) {
      case ConnectionStatus.disconnected:
        emit(
          state.copyWith(
            isConnected: false,
            isLoading: false,
            connectionStatus: event.status,
          ),
        );
        break;
      case ConnectionStatus.connecting:
        emit(state.copyWith(isLoading: true, connectionStatus: event.status));
        break;
      case ConnectionStatus.connected:
        emit(
          state.copyWith(
            isConnected: true,
            isLoading: false,
            clearError: true,
            connectionStatus: event.status,
          ),
        );
        break;
      case ConnectionStatus.reconnecting:
        emit(
          state.copyWith(
            isConnected: false,
            isLoading: false,
            connectionStatus: event.status,
          ),
        );
        break;
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _usersSubscription?.cancel();
    _connectionStatusSubscription?.cancel();
    _repository.dispose();
    return super.close();
  }
}
