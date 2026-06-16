import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/password_prompt_modal.dart';
import '../../settings/bloc/identity/identity_bloc.dart';
import '../../chat/bloc/chat_bloc.dart';
import '../bloc/rooms_bloc.dart';
import '../widgets/active_session_card.dart';
import '../widgets/join_another_room_form.dart';

class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});

  void _handleJoinRoom(BuildContext context, String roomCode, bool isLocked) {
    final identityState = context.read<IdentityBloc>().state;
    String nick = 'anonymous';
    if (identityState is IdentityLoaded) {
      nick = identityState.user.nickname;
    }

    if (isLocked) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (bottomSheetContext) => PasswordPromptModal(
          roomCode: roomCode,
          onJoin: (password) {
            context.read<ChatBloc>().add(
              ConnectChat(roomCode: roomCode, nick: nick, password: password),
            );
            context.go('/chat/$roomCode');
          },
        ),
      );
    } else {
      context.read<ChatBloc>().add(ConnectChat(roomCode: roomCode, nick: nick));
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
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<RoomsBloc>().add(LoadActiveSessions());
              },
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
                      BlocBuilder<ChatBloc, ChatState>(
                        builder: (context, chatState) {
                          return Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: chatState.isConnected
                                      ? theme.colorScheme.tertiary
                                      : theme.disabledColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppConstants.spacing8),
                              Text(
                                chatState.isConnected
                                    ? 'connected'
                                    : 'disconnected',
                                style: textTheme.bodySmall,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacing16),
                  BlocBuilder<RoomsBloc, RoomsState>(
                    builder: (context, state) {
                      if (state.isLoading && state.activeSessions.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (state.activeSessions.isEmpty) {
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
                        children: state.activeSessions.map((room) {
                          return ActiveSessionCard(
                            roomName: room.name,
                            usersCount: room.usersCount,
                            unreadCount: room.unreadCount,
                            isHost: false, // Could derive from ChatBloc users
                            isViewing: false, // Could map from connected state
                            lastMessageText:
                                room.lastMessagePreview ??
                                (room.isLocked
                                    ? '[locked room]'
                                    : 'No recent messages'),
                            onTap: () => _handleJoinRoom(
                              context,
                              room.id,
                              room.isLocked,
                            ),
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
      ),
    );
  }
}
