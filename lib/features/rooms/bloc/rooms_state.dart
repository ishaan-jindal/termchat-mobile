part of 'rooms_bloc.dart';

class RoomsState extends Equatable {
  final List<Room> activeSessions;
  final bool isLoading;
  final bool isJoining;
  final String? error;
  final bool passwordRequired;

  const RoomsState({
    this.activeSessions = const [],
    this.isLoading = false,
    this.isJoining = false,
    this.error,
    this.passwordRequired = false,
  });

  RoomsState copyWith({
    List<Room>? activeSessions,
    bool? isLoading,
    bool? isJoining,
    String? error,
    bool? passwordRequired,
  }) {
    return RoomsState(
      activeSessions: activeSessions ?? this.activeSessions,
      isLoading: isLoading ?? this.isLoading,
      isJoining: isJoining ?? this.isJoining,
      error: error,
      passwordRequired: passwordRequired ?? this.passwordRequired,
    );
  }

  @override
  List<Object?> get props => [
    activeSessions,
    isLoading,
    isJoining,
    error,
    passwordRequired,
  ];
}
