part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final String themeMode;
  final String fontSize;
  final bool messageNotificationsEnabled;
  final bool mentionSoundEnabled;
  final bool isLoading;
  final String? error;

  const SettingsState({
    this.themeMode = 'dark',
    this.fontSize = 'sm',
    this.messageNotificationsEnabled = true,
    this.mentionSoundEnabled = true,
    this.isLoading = false,
    this.error,
  });

  SettingsState copyWith({
    String? themeMode,
    String? fontSize,
    bool? messageNotificationsEnabled,
    bool? mentionSoundEnabled,
    bool? isLoading,
    String? error,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      messageNotificationsEnabled:
          messageNotificationsEnabled ?? this.messageNotificationsEnabled,
      mentionSoundEnabled: mentionSoundEnabled ?? this.mentionSoundEnabled,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    themeMode,
    fontSize,
    messageNotificationsEnabled,
    mentionSoundEnabled,
    isLoading,
    error,
  ];
}
