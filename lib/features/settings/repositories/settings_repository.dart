import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsRepository {
  Future<String> getThemeMode();
  Future<void> setThemeMode(String mode); // dark, light, system

  Future<String> getFontSize();
  Future<void> setFontSize(String size); // sm, md, lg

  Future<bool> getMessageNotifications();
  Future<void> setMessageNotifications(bool enabled);

  Future<bool> getMentionSound();
  Future<void> setMentionSound(bool enabled);
}

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  @override
  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('theme_mode') ?? 'dark';
  }

  @override
  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode);
  }

  @override
  Future<String> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('font_size') ?? 'sm';
  }

  @override
  Future<void> setFontSize(String size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('font_size', size);
  }

  @override
  Future<bool> getMessageNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('msg_notifications') ?? true;
  }

  @override
  Future<void> setMessageNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('msg_notifications', enabled);
  }

  @override
  Future<bool> getMentionSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('mention_sound') ?? true;
  }

  @override
  Future<void> setMentionSound(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mention_sound', enabled);
  }
}
