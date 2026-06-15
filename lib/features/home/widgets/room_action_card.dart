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
      padding: const .all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: .circular(AppConstants.radiusLg),
        border: .all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Text('room code', style: textTheme.bodySmall),
          const SizedBox(height: AppConstants.spacingMd),
          TextField(
            decoration: const InputDecoration(hintText: '> e.g. FROG'),
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.onSurface,
              foregroundColor: colorScheme.surface,
              padding: const .symmetric(vertical: AppConstants.spacingMd),
            ),
            child: const Text('join room'),
          ),
          const SizedBox(height: AppConstants.spacingLg),
          Row(
            children: [
              Expanded(child: Divider(color: theme.dividerColor)),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingMd,
                ),
                child: Text('or', style: textTheme.labelSmall),
              ),
              Expanded(child: Divider(color: theme.dividerColor)),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLg),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingMd,
              ),
            ),
            child: const Text('+ create a new room'),
          ),
        ],
      ),
    );
  }
}
