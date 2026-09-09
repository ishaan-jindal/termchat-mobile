import 'dart:async';

import 'package:flutter/foundation.dart';

import '../bloc/chat_bloc.dart';

/// Factory for chat BLoCs so [ActiveChatsManager] doesn't reach into the
/// service locator and stays mockable.
typedef ChatBlocFactory = ChatBloc Function();

/// Tracks active chat BLoCs keyed by room code. Registered manually in
/// [configureDependencies] because the injected factory is a function type.
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
    final bloc = _activeRooms.remove(roomId);
    if (bloc != null) {
      _updateNotifier();
      // Disconnect immediately, then close on a later turn so in-flight
      // events settle and nothing can `add()` after `close()`.
      bloc.add(DisconnectChat());
      unawaited(_closeAfterDelay(bloc));
    }
  }

  /// Removes the room and awaits full teardown. Prefer over [remove] when
  /// the caller stays alive (e.g. before navigating away) so no orphan
  /// disconnect/close is left racing a rejoin.
  Future<void> leaveRoom(String roomId) async {
    final bloc = _activeRooms.remove(roomId);
    if (bloc == null) return;
    _updateNotifier();
    bloc.add(DisconnectChat());
    await _closeAfterDelay(bloc);
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

  /// Closes every tracked bloc (disconnecting sockets) and releases the
  /// notifier. Only called when the manager itself is torn down.
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
