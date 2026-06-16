import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class ActiveSessionCard extends StatelessWidget {
  final String roomName;
  final bool isHost;
  final bool isViewing;
  final int usersCount;
  final int unreadCount;
  final String lastMessageText;
  final VoidCallback onTap;

  const ActiveSessionCard({
    super.key,
    required this.roomName,
    this.isHost = false,
    this.isViewing = false,
    required this.usersCount,
    this.unreadCount = 0,
    required this.lastMessageText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radius12),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacing20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(roomName, style: textTheme.titleMedium),
                        if (isHost) ...[
                          const SizedBox(width: AppConstants.spacing8),
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
                              'host',
                              style: textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                        if (unreadCount > 0) ...[
                          const SizedBox(width: AppConstants.spacing8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.errorDark, // Red unread badge
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              unreadCount.toString(),
                              style: textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (isViewing)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'viewing',
                          style: textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.surface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Text(
                        'switch →',
                        style: textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing8),
                Text(
                  '$usersCount user${usersCount == 1 ? '' : 's'}',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: AppConstants.spacing12),
                Text(
                  lastMessageText,
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
