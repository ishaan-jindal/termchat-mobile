part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ConnectChat extends ChatEvent {
  final String roomCode;
  final String nick;
  final String colorHex;
  final String? password;

  const ConnectChat({
    required this.roomCode,
    required this.nick,
    required this.colorHex,
    this.password,
  });

  @override
  List<Object?> get props => [roomCode, nick, colorHex, password];
}

class SendMessage extends ChatEvent {
  final String content;
  const SendMessage(this.content);
  @override
  List<Object?> get props => [content];
}

class UpdateNickname extends ChatEvent {
  final String nickname;
  const UpdateNickname(this.nickname);
  @override
  List<Object?> get props => [nickname];
}

class UpdateColor extends ChatEvent {
  final String colorHex;
  const UpdateColor(this.colorHex);
  @override
  List<Object?> get props => [colorHex];
}

class SetRoomPassword extends ChatEvent {
  final String password;
  const SetRoomPassword(this.password);
  @override
  List<Object?> get props => [password];
}

class SendTyping extends ChatEvent {}

class _MessageReceived extends ChatEvent {
  final Message message;
  const _MessageReceived(this.message);
  @override
  List<Object?> get props => [message];
}

class _UsersUpdated extends ChatEvent {
  final List<BackendUserInfo> users;
  const _UsersUpdated(this.users);
  @override
  List<Object?> get props => [users];
}

class _ChatError extends ChatEvent {
  final String error;
  const _ChatError(this.error);
  @override
  List<Object?> get props => [error];
}

class DisconnectChat extends ChatEvent {}

class _ConnectionStatusChanged extends ChatEvent {
  final ConnectionStatus status;
  const _ConnectionStatusChanged(this.status);
  @override
  List<Object?> get props => [status];
}
