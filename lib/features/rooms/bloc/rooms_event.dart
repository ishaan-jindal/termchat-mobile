part of 'rooms_bloc.dart';

abstract class RoomsEvent extends Equatable {
  const RoomsEvent();

  @override
  List<Object?> get props => [];
}

class LoadActiveSessions extends RoomsEvent {}

class JoinRoom extends RoomsEvent {
  final String roomCode;
  final String? password;

  const JoinRoom({required this.roomCode, this.password});

  @override
  List<Object?> get props => [roomCode, password];
}

class LeaveRoom extends RoomsEvent {
  final String roomId;

  const LeaveRoom(this.roomId);

  @override
  List<Object?> get props => [roomId];
}
