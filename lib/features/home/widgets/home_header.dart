import 'package:flutter/material.dart';
import 'package:termchat_app/core/constants/app_constants.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$ ',
              style: textTheme.displayLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 28,
              ),
            ),
            Text(
              AppConstants.appName,
              style: textTheme.displayLarge?.copyWith(
                color: colorScheme.onSurface,
                fontSize: 28,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Text(
          AppConstants.appDescription,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
