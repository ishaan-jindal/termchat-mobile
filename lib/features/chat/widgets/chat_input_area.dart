import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

class ChatInputArea extends StatelessWidget {
  final VoidCallback onSend;

  const ChatInputArea({
    super.key,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing24,
        vertical: AppConstants.spacing16,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: '> Type a message or /command',
                ),
                style: textTheme.bodyLarge,
              ),
            ),
            const SizedBox(width: AppConstants.spacing16),
            FilledButton(
              onPressed: onSend,
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.onSurface,
                foregroundColor: theme.colorScheme.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing24,
                  vertical: AppConstants.spacing12,
                ),
              ),
              child: const Text('send'),
            ),
          ],
        ),
      ),
    );
  }
}
