import 'dart:async';

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
  Timer? _refreshTimer;

  RoomsBloc(this._repository) : super(const RoomsState()) {
    on<LoadActiveSessions>(_onLoadActiveSessions);
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      add(LoadActiveSessions());
    });
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

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
