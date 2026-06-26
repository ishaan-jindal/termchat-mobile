import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../di/injection.dart';
import '../../chat/managers/active_chats_manager.dart';
import '../../../data/cache/room_session_cache.dart';
import '../../../data/cache/message_cache.dart';
import 'settings_section_header.dart';

class DataSettings extends StatelessWidget {
  const DataSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SettingsSectionHeader(title: 'data'),
        Text(
          'cached rooms and messages are stored locally on device',
          style: textTheme.labelSmall,
        ),
        const SizedBox(height: AppConstants.spacing16),
        OutlinedButton.icon(
          onPressed: () => _confirmClear(context),
          icon: const Icon(Icons.delete_outline),
          label: const Text('delete local cache'),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            side: BorderSide(
              color: theme.colorScheme.error.withValues(alpha: 0.4),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.spacing12,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear local cache?'),
        content: const Text(
          'This will remove all saved rooms and messages. '
          'Active connections will be disconnected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _executeClear(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _executeClear(BuildContext context) async {
    final activeChatsManager = getIt<ActiveChatsManager>();
    await activeChatsManager.removeAll();
    await getIt<RoomSessionCache>().clearAll();
    await getIt<MessageCache>().clearAll();

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Local cache cleared')));
    }
  }
}
