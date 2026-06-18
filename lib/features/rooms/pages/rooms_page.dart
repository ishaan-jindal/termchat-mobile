import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/room_join_helper.dart';
import '../../settings/bloc/identity/identity_bloc.dart';
import '../../chat/bloc/chat_bloc.dart';
import '../../chat/managers/active_chats_manager.dart';
import '../../../di/injection.dart';
import '../widgets/active_session_card.dart';
import '../widgets/join_another_room_form.dart';

class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});

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

                            final identityState = context
                                .read<IdentityBloc>()
                                .state;
                            final myNick = identityState is IdentityLoaded
                                ? identityState.user.nickname
                                : '';
                            final isMeHost = chatState.users.any(
                              (u) => u.nick == myNick && u.isHost,
                            );

                            return ActiveSessionCard(
                              roomName: roomId,
                              usersCount: chatState.users.length,
                              unreadCount: 0,
                              isHost: isMeHost,
                              isViewing: false,
                              lastMessageText: lastMsg,
                              onTap: () => RoomJoinHelper.joinRoom(
                                context,
                                roomId,
                                false,
                              ),
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
                    RoomJoinHelper.joinRoom(context, roomCode, false);
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
