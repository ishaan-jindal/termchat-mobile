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
      padding: const EdgeInsets.all(AppConstants.spacing20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: textTheme.titleMedium),
              const SizedBox(height: AppConstants.spacing4),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.successDark,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing8),
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
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing16,
                vertical: AppConstants.spacing12,
              ),
              minimumSize: Size.zero,
            ),
            child: const Text('join →'),
          ),
        ],
      ),
    );
  }
}
