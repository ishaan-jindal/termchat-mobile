import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/chat_top_bar.dart';
import '../widgets/message_list.dart';
import '../widgets/chat_input_area.dart';
import '../widgets/room_users_drawer.dart';
import '../bloc/chat_bloc.dart';
import '../repositories/chat_repository.dart';
import 'package:go_router/go_router.dart';
import '../managers/active_chats_manager.dart';
import '../../settings/bloc/identity/identity_bloc.dart' as identity;
import '../../../core/widgets/password_prompt_modal.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  void _openUsersDrawer(BuildContext context, String roomName) {
    final chatBloc = context.read<ChatBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: chatBloc,
        child: RoomUsersDrawer(roomName: roomName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listenWhen: (previous, current) =>
          previous.error != current.error && current.error != null,
      listener: (context, state) async {
        if (state.error == 'invalid_password') {
          final password = await showModalBottomSheet<String>(
            context: context,
            isScrollControlled: true,
            isDismissible: false,
            backgroundColor: Colors.transparent,
            builder: (bottomSheetContext) =>
                PasswordPromptModal(roomCode: state.roomCode ?? ''),
          );
          if (password != null && context.mounted) {
            final identityState = context.read<identity.IdentityBloc>().state;
            String nick = 'anonymous';
            String colorHex = '';
            if (identityState is identity.IdentityLoaded) {
              nick = identityState.user.nickname;
              colorHex = identityState.user.colorHex;
            }
            context.read<ChatBloc>().add(
              ConnectChat(
                roomCode: state.roomCode ?? '',
                nick: nick,
                colorHex: colorHex,
                password: password,
              ),
            );
          }
        } else if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
          if (!state.isConnected) {
            context.go('/');
          }
        }
      },
      builder: (context, state) {
        final roomName = state.roomCode ?? 'Loading...';
        final usersCount = state.users.length;

        return Scaffold(
          appBar: ChatTopBar(
            roomName: roomName,
            usersCount: usersCount,
            onOpenDrawer: () => _openUsersDrawer(context, roomName),
          ),
          body: Column(
            children: [
              if (state.isLoading) const LinearProgressIndicator(),
              if (state.connectionStatus == ConnectionStatus.reconnecting)
                Container(
                  color: Colors.orange.withValues(alpha: 0.1),
                  padding: const EdgeInsets.all(8.0),
                  child: const Center(
                    child: Text(
                      'Reconnecting...',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                )
              else if (!state.isConnected && !state.isLoading)
                Container(
                  color: Colors.red.withValues(alpha: 0.1),
                  padding: const EdgeInsets.all(8.0),
                  child: const Center(
                    child: Text(
                      'Disconnected',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              const Expanded(child: MessageList()),
              ChatInputArea(
                onSend: (text) {
                  final trimmed = text.trim();
                  if (trimmed == '/quit') {
                    final roomCode =
                        context.read<ChatBloc>().state.roomCode ?? '';
                    if (roomCode.isNotEmpty) {
                      context.read<ActiveChatsManager>().remove(roomCode);
                    }
                    context.go('/');
                    return;
                  }
                  context.read<ChatBloc>().add(SendMessage(text));
                },
                onTyping: () {
                  context.read<ChatBloc>().add(SendTyping());
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
