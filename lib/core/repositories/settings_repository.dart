import 'package:injectable/injectable.dart';

abstract class SettingsRepository {
  Future<String> getThemeMode();
  Future<void> setThemeMode(String mode); // dark, light, system

  Future<String> getFontSize();
  Future<void> setFontSize(String size); // sm, md, lg

  Future<bool> getMessageNotifications();
  Future<void> setMessageNotifications(bool enabled);

  Future<bool> getMentionSound();
  Future<void> setMentionSound(bool enabled);

  Future<bool> getJoinLeaveAlerts();
  Future<void> setJoinLeaveAlerts(bool enabled);
}

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  @override
  Future<String> getThemeMode() async {
    // TODO: Implement SharedPreferences
    return 'dark';
  }

  @override
  Future<void> setThemeMode(String mode) async {
    // TODO: Implement SharedPreferences
  }

  @override
  Future<String> getFontSize() async {
    // TODO: Implement SharedPreferences
    return 'sm';
  }

  @override
  Future<void> setFontSize(String size) async {
    // TODO: Implement SharedPreferences
  }

  @override
  Future<bool> getMessageNotifications() async {
    // TODO: Implement SharedPreferences
    return true;
  }

  @override
  Future<void> setMessageNotifications(bool enabled) async {
    // TODO: Implement SharedPreferences
  }

  @override
  Future<bool> getMentionSound() async {
    // TODO: Implement SharedPreferences
    return true;
  }

  @override
  Future<void> setMentionSound(bool enabled) async {
    // TODO: Implement SharedPreferences
  }

  @override
  Future<bool> getJoinLeaveAlerts() async {
    // TODO: Implement SharedPreferences
    return false;
  }

  @override
  Future<void> setJoinLeaveAlerts(bool enabled) async {
    // TODO: Implement SharedPreferences
  }
}
