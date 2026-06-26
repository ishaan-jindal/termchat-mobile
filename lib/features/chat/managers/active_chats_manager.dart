import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../di/injection.dart';
import '../../../data/cache/room_session_cache.dart';
import '../../../core/models/room_session.dart';
import '../../settings/bloc/identity/identity_bloc.dart';
import '../bloc/chat_bloc.dart';

@lazySingleton
class ActiveChatsManager {
  final RoomSessionCache _roomSessionCache;
  final Map<String, ChatBloc> _activeRooms = {};
  final _activeRoomsNotifier = ValueNotifier<List<String>>([]);
  List<RoomSession> _cachedSessions = [];

  ActiveChatsManager(this._roomSessionCache);

  ValueListenable<List<String>> get activeRoomsListenable =>
      _activeRoomsNotifier;

  List<RoomSession> get cachedSessions => _cachedSessions;

  List<String> get activeRooms => List.unmodifiable(_activeRoomsNotifier.value);

  ChatBloc getOrCreate(String roomId) {
    if (!_activeRooms.containsKey(roomId)) {
      final bloc = getIt<ChatBloc>();
      _activeRooms[roomId] = bloc;
      final now = DateTime.now().millisecondsSinceEpoch;
      _roomSessionCache.save(
        RoomSession(
          roomId: roomId,
          roomName: roomId,
          lastAccessedAt: now,
          createdAt: now,
        ),
      );
      _updateNotifier();
    }
    return _activeRooms[roomId]!;
  }

  void remove(String roomId) {
    final bloc = _activeRooms.remove(roomId);
    if (bloc != null) {
      bloc.add(DisconnectChat());
      Future.delayed(const Duration(milliseconds: 500), () {
        bloc.close();
      });
      _roomSessionCache.delete(roomId);
      _updateNotifier();
    }
  }

  Future<void> loadSavedSessions() async {
    final sessions = await _roomSessionCache.getAll();
    _cachedSessions = sessions;
    for (final session in sessions) {
      getOrCreate(session.roomId);
      final bloc = _activeRooms[session.roomId]!;
      if (!bloc.state.isConnected &&
          !bloc.state.isLoading &&
          !session.isLocked) {
        final identityState = getIt<IdentityBloc>().state;
        if (identityState is IdentityLoaded) {
          bloc.add(
            ConnectChat(
              roomCode: session.roomId,
              nick: identityState.user.nickname,
              colorHex: identityState.user.colorHex,
            ),
          );
        }
      }
    }
    _updateNotifier();
  }

  void _updateNotifier() {
    _activeRoomsNotifier.value = _activeRooms.keys.toList();
  }

  Future<void> removeAll() async {
    for (final roomId in _activeRooms.keys.toList()) {
      remove(roomId);
    }
    await Future.delayed(const Duration(milliseconds: 600));
  }

  ChatBloc? get(String roomId) {
    return _activeRooms[roomId];
  }
}
