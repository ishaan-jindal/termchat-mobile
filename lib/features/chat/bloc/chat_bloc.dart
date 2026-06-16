import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/models/message.dart';
import '../../../core/models/backend_message.dart';
import '../../../core/repositories/chat_repository.dart';

part 'chat_state.dart';
part 'chat_event.dart';

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  StreamSubscription<Message>? _messageSubscription;
  StreamSubscription<List<BackendUserInfo>>? _usersSubscription;

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
  }

  Future<void> _onConnectChat(
    ConnectChat event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _repository.connect(
        event.roomCode,
        event.nick,
        password: event.password,
      );

      // Cancel previous subscriptions if any
      await _messageSubscription?.cancel();
      await _usersSubscription?.cancel();

      // Listen to streams
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
    _messageSubscription = null;
    _usersSubscription = null;
    await _repository.disconnect();
    emit(const ChatState()); // Reset state
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _usersSubscription?.cancel();
    _repository.disconnect();
    return super.close();
  }
}
