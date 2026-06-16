import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

class JoinAnotherRoomForm extends StatelessWidget {
  final VoidCallback onJoin;

  const JoinAnotherRoomForm({super.key, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('join another', style: textTheme.labelSmall),
        const SizedBox(height: AppConstants.spacing12),
        TextField(
          decoration: const InputDecoration(hintText: '> room code'),
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: AppConstants.spacing16),
        FilledButton(
          onPressed: onJoin,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.onSurface,
            foregroundColor: theme.colorScheme.surface,
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.spacing12,
            ),
          ),
          child: const Text('join room'),
        ),
      ],
    );
  }
}
