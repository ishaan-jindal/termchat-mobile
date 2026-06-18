part of 'rooms_bloc.dart';

abstract class RoomsEvent extends Equatable {
  const RoomsEvent();

  @override
  List<Object?> get props => [];
}

class LoadActiveSessions extends RoomsEvent {}

class LeaveRoom extends RoomsEvent {
  final String roomId;

  const LeaveRoom(this.roomId);

  @override
  List<Object?> get props => [roomId];
}
