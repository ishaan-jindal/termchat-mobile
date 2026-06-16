import 'package:flutter/material.dart';

import '../widgets/chat_top_bar.dart';
import '../widgets/message_list.dart';
import '../widgets/chat_input_area.dart';
import '../widgets/room_users_drawer.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  void _openUsersDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RoomUsersDrawer(roomName: 'ALTH'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatTopBar(
        roomName: 'ALTH',
        usersCount: 3,
        onOpenDrawer: () => _openUsersDrawer(context),
      ),
      body: const Column(
        children: [
          Expanded(child: MessageList()),
          ChatInputArea(onSend: _dummySend),
        ],
      ),
    );
  }
}

void _dummySend() {}
