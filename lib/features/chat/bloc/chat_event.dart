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
  final int? replyToId;
  const SendMessage(this.content, [this.replyToId]);
  @override
  List<Object?> get props => [content, replyToId];
}

class SetReplyTarget extends ChatEvent {
  final Message target;
  const SetReplyTarget(this.target);
  @override
  List<Object?> get props => [target];
}

class ClearReplyTarget extends ChatEvent {}

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

class SendReaction extends ChatEvent {
  final int messageId;
  final String name;
  const SendReaction(this.messageId, this.name);
  @override
  List<Object?> get props => [messageId, name];
}

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

class _ReactionUpdated extends ChatEvent {
  final ReactionUpdate update;
  const _ReactionUpdated(this.update);
  @override
  List<Object?> get props => [update];
}

class _ChatError extends ChatEvent {
  final String error;
  const _ChatError(this.error);
  @override
  List<Object?> get props => [error];
}

class DisconnectChat extends ChatEvent {}

class StartVoice extends ChatEvent {}

class StopVoice extends ChatEvent {}

class SetVoiceTransmit extends ChatEvent {
  final bool on;
  const SetVoiceTransmit(this.on);
  @override
  List<Object?> get props => [on];
}

class _VoiceActiveChanged extends ChatEvent {
  final bool active;
  const _VoiceActiveChanged(this.active);
  @override
  List<Object?> get props => [active];
}

class _VoiceError extends ChatEvent {
  final String error;
  const _VoiceError(this.error);
  @override
  List<Object?> get props => [error];
}

class _ConnectionStatusChanged extends ChatEvent {
  final ConnectionStatus status;
  const _ConnectionStatusChanged(this.status);
  @override
  List<Object?> get props => [status];
}
