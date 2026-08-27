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
  final VoidCallback? onTapQuote;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.isMention = false,
    this.myReactions = const {},
    this.onReact,
    this.onToggleReaction,
    this.onTapQuote,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    final surfaceColor = isDark
        ? AppColors.bgElevatedDark
        : AppColors.bgElevatedLight;
    final borderColor = isDark
        ? AppColors.borderDefaultDark
        : AppColors.borderDefaultLight;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final bgColor = isMention
        ? (isDark ? AppColors.mentionBgDark : AppColors.mentionBgLight)
        : surfaceColor;

    final mentionTextColor = isDark
        ? AppColors.mentionTextDark
        : AppColors.mentionTextLight;

    final usernameColor = ColorUtils.parseHexColor(message.senderColorHex);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing16,
        vertical: AppConstants.spacing4,
      ),
      child: InkWell(
        onLongPress: onReact,
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppConstants.radius12),
                border: Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing12,
                vertical: AppConstants.spacing8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.replyToId != null && message.replyToId! > 0)
                    _buildReplyQuote(context),
                  Text(
                    '> ${message.senderNickname}',
                    style: textTheme.titleMedium?.copyWith(
                      color: usernameColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message.content,
                    style: isMention
                        ? textTheme.bodyLarge?.copyWith(
                            color: mentionTextColor,
                            fontWeight: FontWeight.bold,
                          )
                        : textTheme.bodyLarge?.copyWith(
                            color: primaryTextColor,
                          ),
                  ),
                  if (message.reactions.isNotEmpty)
                    _buildReactionChips(context),
                ],
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: usernameColor,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(AppConstants.radius12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyQuote(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacing4),
      child: InkWell(
        onTap: onTapQuote,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacing8,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: Theme.of(context).dividerColor, width: 3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.replyToNick ?? '',
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                message.replyToText ?? '',
                style: textTheme.labelSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
