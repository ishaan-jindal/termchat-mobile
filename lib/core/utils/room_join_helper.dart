import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../di/injection.dart';
import '../../features/chat/bloc/chat_bloc.dart';
import '../../features/chat/managers/active_chats_manager.dart';
import '../../features/settings/bloc/identity/identity_bloc.dart';
import '../widgets/password_prompt_modal.dart';

class RoomJoinHelper {
  RoomJoinHelper._();

  static void joinRoom(BuildContext context, String roomCode, bool isLocked) {
    final identityState = context.read<IdentityBloc>().state;
    String nick = 'anonymous';
    String colorHex = '';
    if (identityState is IdentityLoaded) {
      nick = identityState.user.nickname;
      colorHex = identityState.user.colorHex;
    }

    final chatBloc = getIt<ActiveChatsManager>().getOrCreate(roomCode);
    final isConnected = chatBloc.state.isConnected || chatBloc.state.isLoading;

    if (isLocked && !isConnected) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (bottomSheetContext) => PasswordPromptModal(
          roomCode: roomCode,
          onJoin: (password, nick, colorHex) {
            chatBloc.add(
              ConnectChat(
                roomCode: roomCode,
                nick: nick,
                colorHex: colorHex,
                password: password,
              ),
            );
            context.go('/chat/$roomCode');
          },
        ),
      );
    } else {
      if (!isConnected) {
        chatBloc.add(
          ConnectChat(roomCode: roomCode, nick: nick, colorHex: colorHex),
        );
      }
      context.go('/chat/$roomCode');
    }
  }
}
