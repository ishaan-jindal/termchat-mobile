import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/password_prompt_modal.dart';
import '../../settings/bloc/identity/identity_bloc.dart';
import '../../chat/bloc/chat_bloc.dart';
import '../../chat/managers/active_chats_manager.dart';
import '../../../di/injection.dart';
import '../widgets/active_session_card.dart';
import '../widgets/join_another_room_form.dart';

class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});

  void _handleJoinRoom(BuildContext context, String roomCode, bool isLocked) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.spacing24),
              children: [
                const SizedBox(height: AppConstants.spacing16),
                Text('rooms', style: textTheme.headlineMedium),
                const SizedBox(height: AppConstants.spacing32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('active sessions', style: textTheme.labelSmall),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing16),
                ValueListenableBuilder<List<String>>(
                  valueListenable:
                      getIt<ActiveChatsManager>().activeRoomsListenable,
                  builder: (context, activeRooms, child) {
                    if (activeRooms.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'No active sessions found.',
                            style: textTheme.bodySmall,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: activeRooms.map((roomId) {
                        final chatBloc = getIt<ActiveChatsManager>().get(
                          roomId,
                        );
                        if (chatBloc == null) return const SizedBox.shrink();

                        return BlocBuilder<ChatBloc, ChatState>(
                          bloc: chatBloc,
                          builder: (context, chatState) {
                            final lastMsg = chatState.messages.isNotEmpty
                                ? chatState.messages.last.content
                                : 'No messages yet';

                            return ActiveSessionCard(
                              roomName: roomId,
                              usersCount: chatState.users.length,
                              unreadCount:
                                  0, // Could implement unread count logic in state if needed
                              isHost: false, // Could derive from state
                              isViewing: false, // Could check current route
                              lastMessageText: lastMsg,
                              onTap: () =>
                                  _handleJoinRoom(context, roomId, false),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: AppConstants.spacing48),
                JoinAnotherRoomForm(
                  onJoin: (roomCode) {
                    _handleJoinRoom(context, roomCode, false);
                  },
                ),
                const SizedBox(height: AppConstants.spacing48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
