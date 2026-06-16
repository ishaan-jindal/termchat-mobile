import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class ChatMessageBubble extends StatelessWidget {
  final String username;
  final Color usernameColor;
  final String message;
  final bool isMention;

  const ChatMessageBubble({
    super.key,
    required this.username,
    required this.usernameColor,
    required this.message,
    this.isMention = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isMention
        ? (isDark ? AppColors.mentionBgDark : AppColors.mentionBgLight)
        : Colors.transparent;

    final mentionTextColor = isDark
        ? AppColors.mentionTextDark
        : AppColors.mentionTextLight;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing24,
        vertical: AppConstants.spacing4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: usernameColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              username.substring(0, 1).toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacing8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: textTheme.bodyLarge,
                children: [
                  TextSpan(
                    text: '$username\n',
                    style: textTheme.titleMedium?.copyWith(
                      color: usernameColor,
                    ),
                  ),
                  TextSpan(
                    text: message,
                    style: isMention
                        ? textTheme.bodyLarge?.copyWith(
                            color: mentionTextColor,
                            fontWeight: FontWeight.bold,
                          )
                        : textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
