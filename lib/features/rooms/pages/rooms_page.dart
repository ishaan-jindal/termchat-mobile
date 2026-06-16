import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
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
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacing8),
                        Text('connected', style: textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing16),
                ActiveSessionCard(
                  roomName: 'ALTH',
                  isHost: true,
                  isViewing: true,
                  usersCount: 3,
                  lastMessageText: 'Zack: yeah lets ship it',
                  onTap: () {},
                ),
                ActiveSessionCard(
                  roomName: 'FROG',
                  usersCount: 5,
                  unreadCount: 4,
                  lastMessageText: 'Alex: anyone here tried the new build?',
                  onTap: () {},
                ),
                ActiveSessionCard(
                  roomName: 'BETA',
                  usersCount: 1,
                  lastMessageText: 'no recent messages',
                  onTap: () {},
                ),
                const SizedBox(height: AppConstants.spacing48),
                JoinAnotherRoomForm(onJoin: () {}),
                const SizedBox(height: AppConstants.spacing48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
