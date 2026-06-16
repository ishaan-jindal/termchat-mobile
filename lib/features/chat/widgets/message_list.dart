import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import 'chat_message_bubble.dart';

class MessageList extends StatelessWidget {
  const MessageList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing24),
      children: [
        _buildSystemMessage(context, 'Ishaan joined the room'),
        const SizedBox(height: AppConstants.spacing28),
        const ChatMessageBubble(
          username: 'Ishaan',
          usernameColor: Color(0xFFFF6B6B), // dynamic color from server
          message: 'hey @Zack',
        ),
        const SizedBox(height: AppConstants.spacing14),
        const ChatMessageBubble(
          username: 'Zack',
          usernameColor: Color(0xFF51CF66), // dynamic color from server
          message: '@Ishaan hey\nsup, how u doing',
          isMention: true,
        ),
        const SizedBox(height: AppConstants.spacing28),
        _buildSystemMessage(context, 'Alex left the room'),
        const SizedBox(height: AppConstants.spacing28),
        const ChatMessageBubble(
          username: 'Ishaan',
          usernameColor: Color(0xFFFF6B6B),
          message: 'great wby?\nI heard about the app launch idea',
        ),
        const SizedBox(height: AppConstants.spacing14),
        const ChatMessageBubble(
          username: 'Zack',
          usernameColor: Color(0xFF51CF66),
          message: 'i think its okay\nyeah lets ship it',
        ),
      ],
    );
  }

  Widget _buildSystemMessage(BuildContext context, String text) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '· $text ·',
              style: textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
