import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/models/user.dart';
import '../../../../core/repositories/identity_repository.dart';

part 'identity_state.dart';
part 'identity_event.dart';

@injectable
class IdentityBloc extends Bloc<IdentityEvent, IdentityState> {
  final IdentityRepository _repository;

  IdentityBloc(this._repository) : super(IdentityInitial()) {
    on<LoadIdentity>(_onLoadIdentity);
    on<UpdateNickname>(_onUpdateNickname);
    on<UpdateColor>(_onUpdateColor);
  }

  Future<void> _onLoadIdentity(
    LoadIdentity event,
    Emitter<IdentityState> emit,
  ) async {
    emit(IdentityLoading());
    try {
      final user = await _repository.getCurrentUser();
      emit(IdentityLoaded(user));
    } catch (e) {
      emit(IdentityError(e.toString()));
    }
  }

  Future<void> _onUpdateNickname(
    UpdateNickname event,
    Emitter<IdentityState> emit,
  ) async {
    if (state is IdentityLoaded) {
      final currentUser = (state as IdentityLoaded).user;
      try {
        await _repository.updateNickname(event.nickname);
        emit(
          IdentityLoaded(
            User(
              id: currentUser.id,
              nickname: event.nickname,
              colorHex: currentUser.colorHex,
              isHost: currentUser.isHost,
            ),
          ),
        );
      } catch (e) {
        emit(IdentityError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateColor(
    UpdateColor event,
    Emitter<IdentityState> emit,
  ) async {
    if (state is IdentityLoaded) {
      final currentUser = (state as IdentityLoaded).user;
      try {
        await _repository.updateColor(event.colorHex);
        emit(
          IdentityLoaded(
            User(
              id: currentUser.id,
              nickname: currentUser.nickname,
              colorHex: event.colorHex,
              isHost: currentUser.isHost,
            ),
          ),
        );
      } catch (e) {
        emit(IdentityError(e.toString()));
      }
    }
  }
}
