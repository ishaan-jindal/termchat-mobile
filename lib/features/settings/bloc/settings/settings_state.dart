part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final String themeMode;
  final String fontSize;
  final bool messageNotificationsEnabled;
  final bool mentionSoundEnabled;
  final bool joinLeaveAlertsEnabled;
  final bool isLoading;
  final String? error;

  const SettingsState({
    this.themeMode = 'dark',
    this.fontSize = 'sm',
    this.messageNotificationsEnabled = true,
    this.mentionSoundEnabled = true,
    this.joinLeaveAlertsEnabled = false,
    this.isLoading = false,
    this.error,
  });

  SettingsState copyWith({
    String? themeMode,
    String? fontSize,
    bool? messageNotificationsEnabled,
    bool? mentionSoundEnabled,
    bool? joinLeaveAlertsEnabled,
    bool? isLoading,
    String? error,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      messageNotificationsEnabled:
          messageNotificationsEnabled ?? this.messageNotificationsEnabled,
      mentionSoundEnabled: mentionSoundEnabled ?? this.mentionSoundEnabled,
      joinLeaveAlertsEnabled:
          joinLeaveAlertsEnabled ?? this.joinLeaveAlertsEnabled,
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
    joinLeaveAlertsEnabled,
    isLoading,
    error,
  ];
}
