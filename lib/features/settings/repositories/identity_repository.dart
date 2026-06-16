import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/user.dart';

abstract class IdentityRepository {
  Future<User> getCurrentUser();
  Future<void> updateNickname(String nickname);
  Future<void> updateColor(String colorHex);
}

@LazySingleton(as: IdentityRepository)
class IdentityRepositoryImpl implements IdentityRepository {
  @override
  Future<User> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('user_id');
    if (id == null) {
      id = 'user_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('user_id', id);
    }

    final nickname =
        prefs.getString('user_nickname') ??
        'anon_${id.substring(id.length - 4)}';
    final colorHex = prefs.getString('user_color') ?? '';

    return User(id: id, nickname: nickname, colorHex: colorHex);
  }

  @override
  Future<void> updateNickname(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_nickname', nickname);
  }

  @override
  Future<void> updateColor(String colorHex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_color', colorHex);
  }
}
