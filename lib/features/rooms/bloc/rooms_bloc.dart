import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/models/room.dart';
import '../repositories/room_repository.dart';

part 'rooms_state.dart';
part 'rooms_event.dart';

@lazySingleton
class RoomsBloc extends Bloc<RoomsEvent, RoomsState> {
  static const Duration pollInterval = Duration(seconds: 30);

  final RoomRepository _repository;
  Timer? _refreshTimer;

  RoomsBloc(this._repository) : super(const RoomsState()) {
    on<LoadActiveSessions>(_onLoadActiveSessions);
    on<StartPolling>(_onStartPolling);
    on<StopPolling>(_onStopPolling);
  }

  void _onStartPolling(StartPolling event, Emitter<RoomsState> emit) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(pollInterval, (_) {
      add(LoadActiveSessions());
    });
  }

  void _onStopPolling(StopPolling event, Emitter<RoomsState> emit) {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> _onLoadActiveSessions(
    LoadActiveSessions event,
    Emitter<RoomsState> emit,
  ) async {
    // Silent refresh after the initial load to avoid flicker.
    final isInitialLoad = state.activeSessions.isEmpty && state.error == null;
    if (isInitialLoad) {
      emit(state.copyWith(isLoading: true, clearError: true));
    }
    try {
      final sessions = await _repository.getActiveSessions();
      emit(
        state.copyWith(
          activeSessions: sessions,
          isLoading: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
