import 'package:injectable/injectable.dart';

import '../models/user.dart';

abstract class IdentityRepository {
  Future<User> getCurrentUser();
  Future<void> updateNickname(String nickname);
  Future<void> updateColor(String colorHex);
}

@LazySingleton(as: IdentityRepository)
class IdentityRepositoryImpl implements IdentityRepository {
  @override
  Future<User> getCurrentUser() async {
    // TODO: Implement backend integration / SharedPreferences
    return const User(id: 'mock_id', nickname: 'Ishaan', colorHex: '#FF6B6B');
  }

  @override
  Future<void> updateNickname(String nickname) async {
    // TODO: Implement backend integration / SharedPreferences
  }

  @override
  Future<void> updateColor(String colorHex) async {
    // TODO: Implement backend integration / SharedPreferences
  }
}
