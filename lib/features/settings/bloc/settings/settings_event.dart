part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateThemeMode extends SettingsEvent {
  final String themeMode;
  const UpdateThemeMode(this.themeMode);
  @override
  List<Object?> get props => [themeMode];
}

class UpdateFontSize extends SettingsEvent {
  final String fontSize;
  const UpdateFontSize(this.fontSize);
  @override
  List<Object?> get props => [fontSize];
}

class ToggleMessageNotifications extends SettingsEvent {
  final bool enabled;
  const ToggleMessageNotifications(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class ToggleMentionSound extends SettingsEvent {
  final bool enabled;
  const ToggleMentionSound(this.enabled);
  @override
  List<Object?> get props => [enabled];
}
