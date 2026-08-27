import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/reaction.dart';

void showReactionPicker(
  BuildContext context,
  Set<String> myReactions,
  String messageId,
  void Function(String name) onToggle,
) {
  showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spacing14,
          horizontal: AppConstants.spacing24,
        ),
        child: Wrap(
          spacing: AppConstants.spacing8,
          runSpacing: AppConstants.spacing8,
          alignment: WrapAlignment.center,
          children: reactionNames.map((name) {
            final isMine = myReactions.contains('$messageId:$name');
            return InkWell(
              onTap: () {
                onToggle(name);
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(AppConstants.spacing14),
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spacing8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isMine
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.spacing14),
                ),
                child: Text(
                  reactionGlyph(name),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            );
          }).toList(),
        ),
      );
    },
  );
}
