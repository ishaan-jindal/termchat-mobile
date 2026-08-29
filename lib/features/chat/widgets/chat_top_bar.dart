import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

class ChatTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String roomName;
  final int usersCount;
  final VoidCallback onOpenDrawer;
  final bool voiceActive;
  final VoidCallback? onToggleVoice;

  const ChatTopBar({
    super.key,
    required this.roomName,
    required this.usersCount,
    required this.onOpenDrawer,
    this.voiceActive = false,
    this.onToggleVoice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing24,
        vertical: AppConstants.spacing16,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(roomName, style: textTheme.headlineMedium),
                const SizedBox(height: AppConstants.spacing4),
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onToggleVoice != null)
                  IconButton(
                    onPressed: onToggleVoice,
                    tooltip: voiceActive ? 'Leave voice' : 'Join voice',
                    icon: Icon(voiceActive ? Icons.mic : Icons.mic_none),
                    color: voiceActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                const SizedBox(width: AppConstants.spacing8),
                GestureDetector(
                  onTap: onOpenDrawer,
                  child: Text(
                    '$usersCount users ›',
                    style: textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 40);
}
