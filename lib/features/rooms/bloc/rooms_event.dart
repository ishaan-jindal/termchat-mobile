part of 'rooms_bloc.dart';

abstract class RoomsEvent extends Equatable {
  const RoomsEvent();

  @override
  List<Object?> get props => [];
}

class LoadActiveSessions extends RoomsEvent {}

/// Starts background refresh (driven by RoomsPage lifecycle).
class StartPolling extends RoomsEvent {}

class StopPolling extends RoomsEvent {}
