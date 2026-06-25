import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/backend_room_info.dart';
import '../../../core/models/room.dart';

abstract class RoomRepository {
  Future<List<Room>> getActiveSessions();
}

@LazySingleton(as: RoomRepository)
class RoomRepositoryImpl implements RoomRepository {
  @override
  Future<List<Room>> getActiveSessions() async {
    try {
      final response = await http
          .get(Uri.parse('${AppConstants.apiBaseUrl}/discover'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        return jsonList.map((json) {
          final backendRoom = BackendRoomInfo.fromJson(
            json as Map<String, dynamic>,
          );
          return Room(
            id: backendRoom.id,
            name: backendRoom.id,
            usersCount: backendRoom.userCount,
            isLocked: backendRoom.hasPassword,
          );
        }).toList();
      } else {
        throw Exception(
          'Failed to load active sessions: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error while discovering rooms: $e');
    }
  }
}
