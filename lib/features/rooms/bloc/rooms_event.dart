part of 'rooms_bloc.dart';

abstract class RoomsEvent extends Equatable {
  const RoomsEvent();

  @override
  List<Object?> get props => [];
}

class LoadActiveSessions extends RoomsEvent {}

/// Starts the periodic background refresh. Driven by [RoomsPage] lifecycle
/// so we don't poll when the page was never opened.
class StartPolling extends RoomsEvent {}

/// Stops the periodic background refresh.
class StopPolling extends RoomsEvent {}
