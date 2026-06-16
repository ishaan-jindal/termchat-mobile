import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/chat_top_bar.dart';
import '../widgets/message_list.dart';
import '../widgets/chat_input_area.dart';
import '../widgets/room_users_drawer.dart';
import '../bloc/chat_bloc.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  void _openUsersDrawer(BuildContext context, String roomName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RoomUsersDrawer(roomName: roomName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listenWhen: (previous, current) =>
          previous.error != current.error && current.error != null,
      listener: (context, state) {
        // Only show error if we're not dealing with invalid_password, which is handled
        // by the home page / rooms page password prompts.
        if (state.error != 'invalid_password') {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
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
              if (!state.isConnected && !state.isLoading)
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
