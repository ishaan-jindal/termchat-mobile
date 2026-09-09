import 'dart:async';

import 'package:flutter/foundation.dart';

import '../bloc/chat_bloc.dart';

/// ChatBloc factory (keeps the manager mockable).
typedef ChatBlocFactory = ChatBloc Function();

/// Tracks blocs by room; registered manually (function type).
class ActiveChatsManager {
  ActiveChatsManager(this._blocFactory);

  final ChatBlocFactory _blocFactory;
  final Map<String, ChatBloc> _activeRooms = {};
  final _activeRoomsNotifier = ValueNotifier<List<String>>([]);

  ValueListenable<List<String>> get activeRoomsListenable =>
      _activeRoomsNotifier;

  List<String> get activeRooms => List.unmodifiable(_activeRoomsNotifier.value);

  ChatBloc getOrCreate(String roomId) {
    if (!_activeRooms.containsKey(roomId)) {
      _activeRooms[roomId] = _blocFactory();
      _updateNotifier();
    }
    return _activeRooms[roomId]!;
  }

  void remove(String roomId) {
    final bloc = _take(roomId);
    if (bloc != null) {
      // Close on a later turn so in-flight events settle first.
      bloc.add(DisconnectChat());
      unawaited(_closeAfterDelay(bloc));
    }
  }

  /// Awaits teardown; prefer when the caller stays alive.
  Future<void> leaveRoom(String roomId) async {
    final bloc = _take(roomId);
    if (bloc == null) return;
    bloc.add(DisconnectChat());
    await _closeAfterDelay(bloc);
  }

  /// Removes the bloc from tracking and notifies listeners. Returns null
  /// when the room was already gone.
  ChatBloc? _take(String roomId) {
    final bloc = _activeRooms.remove(roomId);
    if (bloc != null) _updateNotifier();
    return bloc;
  }

  Future<void> _closeAfterDelay(ChatBloc bloc) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!bloc.isClosed) {
      await bloc.close();
    }
  }

  void _updateNotifier() {
    _activeRoomsNotifier.value = _activeRooms.keys.toList();
  }

  ChatBloc? get(String roomId) {
    return _activeRooms[roomId];
  }

  Future<void> dispose() async {
    final blocs = _activeRooms.values.toList();
    _activeRooms.clear();
    _updateNotifier();
    for (final bloc in blocs) {
      if (!bloc.isClosed) {
        try {
          await bloc.close();
        } catch (_) {}
      }
    }
    _activeRoomsNotifier.dispose();
  }
}
