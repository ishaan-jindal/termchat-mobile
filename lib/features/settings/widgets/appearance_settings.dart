import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import 'settings_section_header.dart';

class AppearanceSettings extends StatelessWidget {
  const AppearanceSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SettingsSectionHeader(title: 'appearance'),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(AppConstants.radius8),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildSegmentButton(context, 'dark', true, true, false),
              ),
              Expanded(
                child: _buildSegmentButton(
                  context,
                  'light',
                  false,
                  false,
                  false,
                ),
              ),
              Expanded(
                child: _buildSegmentButton(
                  context,
                  'system',
                  false,
                  false,
                  true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacing16),
        Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(bottom: BorderSide(color: theme.dividerColor)),
          ),
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('font size', style: textTheme.bodySmall),
              Row(
                children: [
                  Text('sm', style: textTheme.labelSmall),
                  const SizedBox(width: AppConstants.spacing12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'md',
                      style: textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Text('lg', style: textTheme.labelSmall),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentButton(
    BuildContext context,
    String label,
    bool isSelected,
    bool isFirst,
    bool isLast,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing12),
      decoration: BoxDecoration(
        color: isSelected ? theme.dividerColor : Colors.transparent,
        border: Border(
          right: isLast
              ? BorderSide.none
              : BorderSide(color: theme.dividerColor),
        ),
        borderRadius: BorderRadius.horizontal(
          left: isFirst
              ? const Radius.circular(AppConstants.radius8)
              : Radius.zero,
          right: isLast
              ? const Radius.circular(AppConstants.radius8)
              : Radius.zero,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: isSelected
                ? theme.colorScheme.onSurface
                : textTheme.bodySmall?.color,
          ),
        ),
      ),
    );
  }
}
