import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../repositories/settings_repository.dart';

part 'settings_state.dart';
part 'settings_event.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repository;

  SettingsBloc(this._repository) : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateThemeMode>(_onUpdateThemeMode);
    on<UpdateFontSize>(_onUpdateFontSize);
    on<ToggleMessageNotifications>(_onToggleMessageNotifications);
    on<ToggleMentionSound>(_onToggleMentionSound);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final theme = await _repository.getThemeMode();
      final font = await _repository.getFontSize();
      final msgNotif = await _repository.getMessageNotifications();
      final mention = await _repository.getMentionSound();

      emit(
        state.copyWith(
          themeMode: theme,
          fontSize: font,
          messageNotificationsEnabled: msgNotif,
          mentionSoundEnabled: mention,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdateThemeMode(
    UpdateThemeMode event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _repository.setThemeMode(event.themeMode);
      emit(state.copyWith(themeMode: event.themeMode));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onUpdateFontSize(
    UpdateFontSize event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _repository.setFontSize(event.fontSize);
      emit(state.copyWith(fontSize: event.fontSize));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onToggleMessageNotifications(
    ToggleMessageNotifications event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _repository.setMessageNotifications(event.enabled);
      emit(state.copyWith(messageNotificationsEnabled: event.enabled));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onToggleMentionSound(
    ToggleMentionSound event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _repository.setMentionSound(event.enabled);
      emit(state.copyWith(mentionSoundEnabled: event.enabled));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
