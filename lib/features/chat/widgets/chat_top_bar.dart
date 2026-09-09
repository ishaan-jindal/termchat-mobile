import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../repositories/chat_repository.dart';

class ChatTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String roomName;
  final int usersCount;
  final ConnectionStatus connectionStatus;
  final VoidCallback onOpenDrawer;
  final bool voiceActive;
  final VoidCallback? onToggleVoice;

  const ChatTopBar({
    super.key,
    required this.roomName,
    required this.usersCount,
    this.connectionStatus = ConnectionStatus.connected,
    required this.onOpenDrawer,
    this.voiceActive = false,
    this.onToggleVoice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final statusLabel = switch (connectionStatus) {
      ConnectionStatus.connected => 'connected',
      ConnectionStatus.connecting => 'connecting...',
      ConnectionStatus.reconnecting => 'reconnecting...',
      ConnectionStatus.disconnected => 'disconnected',
    };

    return AppBar(
      titleSpacing: AppConstants.spacing24,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            roomName,
            style: textTheme.headlineMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppConstants.spacing4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacing8),
              Text(statusLabel, style: textTheme.bodySmall),
            ],
          ),
        ],
      ),
      actions: [
        if (onToggleVoice != null)
          Semantics(
            selected: voiceActive,
            child: IconButton(
              onPressed: onToggleVoice,
              tooltip: voiceActive ? 'Leave voice' : 'Join voice',
              icon: Icon(voiceActive ? Icons.mic : Icons.mic_none),
              color: voiceActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        TextButton(
          onPressed: onOpenDrawer,
          style: TextButton.styleFrom(
            minimumSize: const Size(48, 48),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            '$usersCount users ›',
            style: textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppConstants.spacing8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
