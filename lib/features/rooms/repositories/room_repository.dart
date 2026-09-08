import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/api_exceptions.dart';
import '../../../data/models/backend_room_info.dart';
import '../../../core/models/room.dart';

abstract class RoomRepository {
  Future<List<Room>> getActiveSessions();
}

@LazySingleton(as: RoomRepository)
class RoomRepositoryImpl implements RoomRepository {
  RoomRepositoryImpl(this._client);

  final http.Client _client;

  @override
  Future<List<Room>> getActiveSessions() async {
    final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.discoverPath}'),
          )
          .timeout(AppConstants.httpTimeout);
    } on TimeoutException {
      throw const ApiNetworkException('Timed out discovering rooms');
    } on http.ClientException catch (e) {
      throw ApiNetworkException('Network error discovering rooms', e);
    } on IOException catch (e) {
      throw ApiNetworkException('Network error discovering rooms', e);
    }

    if (response.statusCode != 200) {
      throw ApiServerException(response.statusCode);
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const ApiParseException('Malformed room list from server');
    }

    if (decoded is! List) {
      throw const ApiParseException('Unexpected room list shape');
    }

    final rooms = <Room>[];
    for (final entry in decoded) {
      if (entry is! Map<String, dynamic>) continue;
      try {
        final backendRoom = BackendRoomInfo.fromJson(entry);
        rooms.add(
          Room(
            id: backendRoom.id,
            name: backendRoom.id,
            usersCount: backendRoom.userCount,
            isLocked: backendRoom.hasPassword,
          ),
        );
      } on FormatException {
        // Skip a single malformed room instead of failing the whole list.
        continue;
      }
    }
    return rooms;
  }
}
