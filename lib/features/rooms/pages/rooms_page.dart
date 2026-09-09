import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/room_join_helper.dart';
import '../../settings/bloc/identity/identity_bloc.dart';
import '../../chat/bloc/chat_bloc.dart';
import '../../chat/managers/active_chats_manager.dart';
import '../bloc/rooms_bloc.dart';
import '../widgets/active_session_card.dart';
import '../widgets/join_another_room_form.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  @override
  void initState() {
    super.initState();
    context.read<RoomsBloc>().add(StartPolling());
  }

  @override
  void dispose() {
    // Bloc is app-scoped; only stop our polling, don't close it.
    try {
      context.read<RoomsBloc>().add(StopPolling());
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final activeChatsManager = context.read<ActiveChatsManager>();

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
                  valueListenable: activeChatsManager.activeRoomsListenable,
                  builder: (context, roomIds, child) {
                    if (roomIds.isEmpty) {
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

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: roomIds.length,
                      itemBuilder: (context, index) {
                        final roomId = roomIds[index];
                        final chatBloc = activeChatsManager.get(roomId);
                        if (chatBloc == null) return const SizedBox.shrink();

                        return BlocBuilder<ChatBloc, ChatState>(
                          key: ValueKey(roomId),
                          bloc: chatBloc,
                          buildWhen: (prev, curr) =>
                              prev.messages.length != curr.messages.length ||
                              prev.users != curr.users,
                          builder: (context, chatState) {
                            final lastMsg = chatState.messages.isNotEmpty
                                ? chatState.messages.last.content
                                : 'No messages yet';

                            final myNick = context.select<IdentityBloc, String>(
                              (bloc) {
                                final s = bloc.state;
                                return s is IdentityLoaded
                                    ? s.user.nickname
                                    : '';
                              },
                            );
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
                              onTap: () {
                                RoomJoinHelper.joinRoom(context, roomId, false);
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: AppConstants.spacing48),
                JoinAnotherRoomForm(
                  onJoin: (roomCode) async {
                    return await RoomJoinHelper.joinRoom(
                      context,
                      roomCode,
                      false,
                    );
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
