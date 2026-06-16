import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import 'settings_section_header.dart';

class IdentitySettings extends StatelessWidget {
  const IdentitySettings({super.key});

  void _showEditNicknameModal(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.radius16),
            ),
          ),
          padding: EdgeInsets.only(
            left: AppConstants.spacing24,
            right: AppConstants.spacing24,
            top: AppConstants.spacing24,
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                AppConstants.spacing24,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('edit nickname', style: textTheme.bodySmall),
                const SizedBox(height: AppConstants.spacing24),
                TextField(
                  decoration: const InputDecoration(hintText: '> /nick name'),
                  style: textTheme.bodyLarge,
                  autofocus: true,
                ),
                const SizedBox(height: AppConstants.spacing24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('cancel'),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.onSurface,
                          foregroundColor: theme.colorScheme.surface,
                        ),
                        child: const Text('save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditColorModal(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.radius16),
            ),
          ),
          padding: EdgeInsets.only(
            left: AppConstants.spacing24,
            right: AppConstants.spacing24,
            top: AppConstants.spacing24,
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                AppConstants.spacing24,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('edit color', style: textTheme.bodySmall),
                const SizedBox(height: AppConstants.spacing24),
                TextField(
                  decoration: const InputDecoration(hintText: '> #hex'),
                  style: textTheme.bodyLarge,
                  autofocus: true,
                ),
                const SizedBox(height: AppConstants.spacing24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('cancel'),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.onSurface,
                          foregroundColor: theme.colorScheme.surface,
                        ),
                        child: const Text('save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SettingsSectionHeader(title: 'identity'),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showEditNicknameModal(context),
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.dividerColor)),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacing14,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('nickname', style: textTheme.bodySmall),
                  Text('/nick Ishaan ›', style: textTheme.labelSmall),
                ],
              ),
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showEditColorModal(context),
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.dividerColor)),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacing14,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('color', style: textTheme.bodySmall),
                  Row(
                    children: [
                      Text('#ff6b6b ', style: textTheme.labelSmall),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B6B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(' ›', style: textTheme.labelSmall),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
