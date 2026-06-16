import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/models/room.dart';
import '../repositories/room_repository.dart';

part 'rooms_state.dart';
part 'rooms_event.dart';

@injectable
class RoomsBloc extends Bloc<RoomsEvent, RoomsState> {
  final RoomRepository _repository;

  RoomsBloc(this._repository) : super(const RoomsState()) {
    on<LoadActiveSessions>(_onLoadActiveSessions);
    on<JoinRoom>(_onJoinRoom);
    on<LeaveRoom>(_onLeaveRoom);
  }

  Future<void> _onLoadActiveSessions(
    LoadActiveSessions event,
    Emitter<RoomsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final sessions = await _repository.getActiveSessions();
      emit(state.copyWith(activeSessions: sessions, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onJoinRoom(JoinRoom event, Emitter<RoomsState> emit) async {
    emit(state.copyWith(isJoining: true, error: null, passwordRequired: false));
    try {
      final room = await _repository.joinRoom(
        event.roomCode,
        password: event.password,
      );

      // If successful, add to active sessions
      final updatedSessions = List<Room>.from(state.activeSessions);
      if (!updatedSessions.any((r) => r.id == room.id)) {
        updatedSessions.add(room);
      }

      emit(state.copyWith(activeSessions: updatedSessions, isJoining: false));
    } catch (e) {
      // Mocking password required error for UI testing
      if (e.toString().contains('password required') ||
          e.toString().contains('locked')) {
        emit(state.copyWith(isJoining: false, passwordRequired: true));
      } else {
        emit(state.copyWith(isJoining: false, error: e.toString()));
      }
    }
  }

  Future<void> _onLeaveRoom(LeaveRoom event, Emitter<RoomsState> emit) async {
    try {
      await _repository.leaveRoom(event.roomId);
      final updatedSessions = state.activeSessions
          .where((r) => r.id != event.roomId)
          .toList();
      emit(state.copyWith(activeSessions: updatedSessions));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
