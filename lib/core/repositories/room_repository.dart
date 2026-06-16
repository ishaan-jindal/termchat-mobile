import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../models/room.dart';
import '../models/backend_message.dart';

abstract class RoomRepository {
  Future<List<Room>> getActiveSessions();
  Future<Room> joinRoom(String roomCode, {String? password});
  Future<void> leaveRoom(String roomId);
}

@LazySingleton(as: RoomRepository)
class RoomRepositoryImpl implements RoomRepository {
  @override
  Future<List<Room>> getActiveSessions() async {
    try {
      final response = await http.get(
        Uri.parse('https://termchat.sacred99.online/discover'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        return jsonList.map((json) {
          final backendRoom = BackendRoomInfo.fromJson(
            json as Map<String, dynamic>,
          );
          return Room(
            id: backendRoom.id,
            name: backendRoom
                .id, // Using ID as name since backend doesn't differentiate
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

  @override
  Future<Room> joinRoom(String roomCode, {String? password}) async {
    // Joining is now handled by ChatRepository via WebSocket.
    // RoomsBloc will just return a mocked Room object so it appears in the active sessions list.
    // The actual authentication failure will be caught by ChatRepository throwing an error.
    return Room(id: roomCode, name: roomCode);
  }

  @override
  Future<void> leaveRoom(String roomId) async {
    // Handled locally or by closing WebSocket via ChatRepository
  }
}
