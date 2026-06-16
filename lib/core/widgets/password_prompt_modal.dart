import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class PasswordPromptModal extends StatelessWidget {
  final String roomName;
  final VoidCallback onCancel;
  final VoidCallback onJoin;

  const PasswordPromptModal({
    super.key,
    required this.roomName,
    required this.onCancel,
    required this.onJoin,
  });

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
      padding: EdgeInsets.only(
        left: AppConstants.spacing24,
        right: AppConstants.spacing24,
        top: AppConstants.spacing24,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + AppConstants.spacing24,
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
                Text('room is locked', style: textTheme.bodySmall),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'locked',
                    style: textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text('$roomName requires a password', style: textTheme.bodySmall),
            const SizedBox(height: AppConstants.spacing24),
            Text('password', style: textTheme.labelSmall),
            const SizedBox(height: AppConstants.spacing8),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(hintText: '> ********'),
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: AppConstants.spacing8),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {},
                child: Text('show password', style: textTheme.labelSmall),
              ),
            ),
            const SizedBox(height: AppConstants.spacing24),
            // Example error state:
            // Text(
            //   '• incorrect password',
            //   style: textTheme.bodySmall?.copyWith(color: AppColors.errorDark),
            // ),
            // const SizedBox(height: AppConstants.spacing16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    child: const Text('cancel'),
                  ),
                ),
                const SizedBox(width: AppConstants.spacing16),
                Expanded(
                  child: FilledButton(
                    onPressed: onJoin,
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.onSurface,
                      foregroundColor: theme.colorScheme.surface,
                    ),
                    child: const Text('join room'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
