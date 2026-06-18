import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/color_utils.dart';
import '../bloc/chat_bloc.dart';
import '../managers/active_chats_manager.dart';
import '../../../di/injection.dart';

class RoomUsersDrawer extends StatelessWidget {
  final String roomName;

  const RoomUsersDrawer({super.key, required this.roomName});

  String _formatJoinTime(int timestampSecs) {
    if (timestampSecs == 0) return 'recently';
    final joinedAt = DateTime.fromMillisecondsSinceEpoch(timestampSecs * 1000);
    final diff = DateTime.now().difference(joinedAt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
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
                    Text(
                      '${state.users.length} online',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing20),
                if (state.users.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No users loaded',
                        style: textTheme.bodySmall,
                      ),
                    ),
                  ),
                ...state.users.map((user) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppConstants.spacing16,
                    ),
                    child: _buildUserRow(
                      context: context,
                      username: user.nick,
                      color: ColorUtils.parseHexColor(user.color),
                      isHost: user.isHost,
                      isTyping: user.typing,
                      metaText: '· joined ${_formatJoinTime(user.joinedAt)}',
                    ),
                  );
                }),
                const SizedBox(height: AppConstants.spacing16),
                OutlinedButton(
                  onPressed: () {
                    final roomCode =
                        context.read<ChatBloc>().state.roomCode ?? '';
                    if (roomCode.isNotEmpty) {
                      getIt<ActiveChatsManager>().remove(roomCode);
                    }
                    Navigator.pop(context); // close bottom sheet
                    context.go('/'); // Go back to home
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
      },
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
            username.isNotEmpty ? username.substring(0, 1).toUpperCase() : '?',
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
