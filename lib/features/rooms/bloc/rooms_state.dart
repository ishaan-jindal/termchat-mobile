part of 'rooms_bloc.dart';

class RoomsState extends Equatable {
  final List<Room> activeSessions;
  final bool isLoading;
  final String? error;

  const RoomsState({
    this.activeSessions = const [],
    this.isLoading = false,
    this.error,
  });

  RoomsState copyWith({
    List<Room>? activeSessions,
    bool? isLoading,
    String? error,
  }) {
    return RoomsState(
      activeSessions: activeSessions ?? this.activeSessions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [activeSessions, isLoading, error];
}
