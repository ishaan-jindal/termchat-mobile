import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

class RoomUsersDrawer extends StatelessWidget {
  final String roomName;

  const RoomUsersDrawer({super.key, required this.roomName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radius16),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing24,
        vertical: AppConstants.spacing24,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('users in $roomName', style: textTheme.bodySmall),
                Text('3 online', style: textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: AppConstants.spacing20),
            _buildUserRow(
              context: context,
              username: 'Ishaan',
              color: const Color(0xFFFF6B6B),
              isHost: true,
              metaText: '· joined 2m ago',
            ),
            const SizedBox(height: AppConstants.spacing16),
            _buildUserRow(
              context: context,
              username: 'Zack',
              color: const Color(0xFF51CF66),
              isTyping: true,
              metaText: '· joined 1m ago',
            ),
            const SizedBox(height: AppConstants.spacing16),
            _buildUserRow(
              context: context,
              username: 'Alex',
              color: const Color(0xFF1F6FEB),
              metaText: '· joined 45s ago',
            ),
            const SizedBox(height: AppConstants.spacing32),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.dividerColor),
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacing12,
                ),
              ),
              child: const Text('/quit · leave room'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRow({
    required BuildContext context,
    required String username,
    required Color color,
    bool isHost = false,
    bool isTyping = false,
    required String metaText,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            username.substring(0, 1).toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacing12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  username,
                  style: textTheme.titleMedium?.copyWith(color: color),
                ),
                if (isHost) ...[
                  const SizedBox(width: AppConstants.spacing4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '[host]',
                      style: textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
                if (isTyping) ...[
                  const SizedBox(width: AppConstants.spacing4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'typing...',
                      style: textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(metaText, style: textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}
