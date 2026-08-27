import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/message.dart';
import '../../../core/models/reaction.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/color_utils.dart';

class ChatMessageBubble extends StatelessWidget {
  final Message message;
  final bool isMention;
  final Set<String> myReactions;
  final VoidCallback? onReact;
  final void Function(String name)? onToggleReaction;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.isMention = false,
    this.myReactions = const {},
    this.onReact,
    this.onToggleReaction,
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

    final usernameColor = ColorUtils.parseHexColor(message.senderColorHex);

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing24,
        vertical: AppConstants.spacing4,
      ),
      child: InkWell(
        onLongPress: onReact,
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
                message.senderNickname.substring(0, 1).toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacing8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: textTheme.bodyLarge,
                      children: [
                        TextSpan(
                          text: '${message.senderNickname}\n',
                          style: textTheme.titleMedium?.copyWith(
                            color: usernameColor,
                          ),
                        ),
                        TextSpan(
                          text: message.content,
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
                  if (message.reactions.isNotEmpty)
                    _buildReactionChips(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionChips(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spacing4),
      child: Wrap(
        spacing: AppConstants.spacing4,
        runSpacing: AppConstants.spacing4,
        children: message.reactions.map((reaction) {
          final isMine = myReactions.contains('${message.id}:${reaction.name}');
          return InkWell(
            onTap: onToggleReaction == null
                ? null
                : () => onToggleReaction!(reaction.name),
            borderRadius: BorderRadius.circular(AppConstants.spacing14),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isMine
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).dividerColor,
                ),
                borderRadius: BorderRadius.circular(AppConstants.spacing14),
              ),
              child: Text(
                '${reactionGlyph(reaction.name)} ${reaction.count}',
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: isMine ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
