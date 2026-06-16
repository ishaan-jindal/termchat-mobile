import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class RoomActionCard extends StatelessWidget {
  const RoomActionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('room code', style: textTheme.bodySmall),
          const SizedBox(height: AppConstants.spacing12),
          TextField(
            decoration: const InputDecoration(hintText: '> e.g. FROG'),
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: AppConstants.spacing16),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.onSurface,
              foregroundColor: colorScheme.surface,
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacing12,
              ),
            ),
            child: const Text('join room'),
          ),
          const SizedBox(height: AppConstants.spacing24),
          Row(
            children: [
              Expanded(child: Divider(color: theme.dividerColor)),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing16,
                ),
                child: Text('or', style: textTheme.labelSmall),
              ),
              Expanded(child: Divider(color: theme.dividerColor)),
            ],
          ),
          const SizedBox(height: AppConstants.spacing24),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacing12,
              ),
            ),
            child: const Text('+ create a new room'),
          ),
        ],
      ),
    );
  }
}
