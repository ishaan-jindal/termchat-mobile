import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class RoomCard extends StatelessWidget {
  final String name;
  final int users;
  final bool isLocked;
  final VoidCallback? onJoin;

  const RoomCard({
    super.key,
    required this.name,
    required this.users,
    this.isLocked = false,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      padding: const .all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: .circular(AppConstants.radiusMd),
        border: .all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Column(
            crossAxisAlignment: .start,
            children: [
              Text(name, style: textTheme.titleMedium),
              const SizedBox(height: AppConstants.spacingXs),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.successDark,
                      shape: .circle,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  Text(
                    '$users user${users != 1 ? 's' : ''}${isLocked ? ' · locked' : ''}',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          OutlinedButton(
            onPressed: onJoin ?? () {},
            style: OutlinedButton.styleFrom(
              padding: const .symmetric(
                horizontal: AppConstants.spacingMd,
                vertical: AppConstants.spacingSm,
              ),
              minimumSize: .zero,
            ),
            child: const Text('join →'),
          ),
        ],
      ),
    );
  }
}
