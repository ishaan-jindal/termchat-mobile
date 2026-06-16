import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../bloc/chat_bloc.dart';
import '../../settings/bloc/identity/identity_bloc.dart';
import 'chat_message_bubble.dart';

class MessageList extends StatefulWidget {
  const MessageList({super.key});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.tryParse(hex, radix: 16) ?? 0xFFFFFFFF);
  }

  @override
  Widget build(BuildContext context) {
    final identityState = context.watch<IdentityBloc>().state;
    String myNick = '';
    if (identityState is IdentityLoaded) {
      myNick = identityState.user.nickname;
    }

    return BlocConsumer<ChatBloc, ChatState>(
      listenWhen: (previous, current) =>
          previous.messages.length != current.messages.length,
      listener: (context, state) {
        Future.delayed(const Duration(milliseconds: 50), _scrollToBottom);
      },
      builder: (context, state) {
        if (state.messages.isEmpty) {
          return Center(
            child: Text(
              state.isConnected ? 'No messages yet.' : 'Connecting...',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }

        return ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing24),
          itemCount: state.messages.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppConstants.spacing14),
          itemBuilder: (context, index) {
            final msg = state.messages[index];

            if (msg.isSystemMessage) {
              return _buildSystemMessage(context, msg.content);
            }

            final isMention =
                myNick.isNotEmpty && msg.content.contains('@$myNick');

            return ChatMessageBubble(
              username: msg.senderNickname,
              usernameColor: _parseColor(msg.senderColorHex),
              message: msg.content,
              isMention: isMention,
            );
          },
        );
      },
    );
  }

  Widget _buildSystemMessage(BuildContext context, String text) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing24,
        vertical: AppConstants.spacing8,
      ),
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
