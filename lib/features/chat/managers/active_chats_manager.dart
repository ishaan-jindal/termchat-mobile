import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../di/injection.dart';
import '../bloc/chat_bloc.dart';

@lazySingleton
class ActiveChatsManager {
  final Map<String, ChatBloc> _activeRooms = {};
  final _activeRoomsNotifier = ValueNotifier<List<String>>([]);

  ValueListenable<List<String>> get activeRoomsListenable =>
      _activeRoomsNotifier;

  List<String> get activeRooms => List.unmodifiable(_activeRoomsNotifier.value);

  ChatBloc getOrCreate(String roomId) {
    if (!_activeRooms.containsKey(roomId)) {
      final bloc = getIt<ChatBloc>();
      _activeRooms[roomId] = bloc;
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
      _updateNotifier();
    }
  }

  void _updateNotifier() {
    _activeRoomsNotifier.value = _activeRooms.keys.toList();
  }

  ChatBloc? get(String roomId) {
    return _activeRooms[roomId];
  }
}
