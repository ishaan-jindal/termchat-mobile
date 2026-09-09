import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/chat/bloc/chat_bloc.dart';
import '../../features/chat/managers/active_chats_manager.dart';
import '../../features/chat/repositories/chat_repository.dart';
import '../../features/settings/bloc/identity/identity_bloc.dart';
import '../constants/app_constants.dart';
import '../widgets/password_prompt_modal.dart';

class RoomJoinHelper {
  RoomJoinHelper._();

  static Future<bool> joinRoom(
    BuildContext context,
    String roomCode,
    bool isLocked,
  ) async {
    final identityState = context.read<IdentityBloc>().state;
    String nick = 'anonymous';
    String colorHex = '';
    if (identityState is IdentityLoaded) {
      nick = identityState.user.nickname;
      colorHex = identityState.user.colorHex;
    }

    final chatBloc = context.read<ActiveChatsManager>().getOrCreate(roomCode);
    final blocState = chatBloc.state;
    // Connected, loading, or backing off: a join is already in flight, so
    // navigate and let it settle instead of firing a second ConnectChat.
    final joinInFlight =
        blocState.isConnected ||
        blocState.isLoading ||
        blocState.connectionStatus == ConnectionStatus.reconnecting;

    if (isLocked && !joinInFlight) {
      final password = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (bottomSheetContext) =>
            PasswordPromptModal(roomCode: roomCode),
      );
      if (password == null || !context.mounted) return false;
      chatBloc.add(
        ConnectChat(
          roomCode: roomCode,
          nick: nick,
          colorHex: colorHex,
          password: password,
        ),
      );
    } else if (!joinInFlight) {
      chatBloc.add(
        ConnectChat(roomCode: roomCode, nick: nick, colorHex: colorHex),
      );
    } else {
      context.go('/chat/$roomCode');
      return true;
    }

    try {
      final result = await chatBloc.stream
          .firstWhere((s) => s.isConnected || s.error != null)
          .timeout(AppConstants.roomJoinTimeout);

      if (!context.mounted) return false;

      if (result.isConnected) {
        context.go('/chat/$roomCode');
        return true;
      } else if (result.error == 'invalid_password') {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Wrong password')));
        return false;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error ?? 'Invalid room code')),
        );
        return false;
      }
    } on TimeoutException {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not join room: Connection timed out'),
        ),
      );
      return false;
    }
  }
}
