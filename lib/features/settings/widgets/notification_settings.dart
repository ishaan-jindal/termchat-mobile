import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../bloc/settings/settings_bloc.dart';
import 'settings_section_header.dart';

class NotificationSettings extends StatelessWidget {
  const NotificationSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SettingsSectionHeader(title: 'notifications'),
            _buildSwitchRow(
              context,
              'message notifications',
              state.messageNotificationsEnabled,
              (enabled) {
                context.read<SettingsBloc>().add(
                  ToggleMessageNotifications(enabled),
                );
              },
            ),
            _buildSwitchRow(
              context,
              'mention sound',
              state.mentionSoundEnabled,
              (enabled) {
                context.read<SettingsBloc>().add(ToggleMentionSound(enabled));
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSwitchRow(
    BuildContext context,
    String title,
    bool value,
    ValueChanged<bool>? onChanged, {
    String? subtitle,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodySmall?.copyWith(
                    color: onChanged == null ? theme.disabledColor : null,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: textTheme.labelSmall?.copyWith(
                      color: theme.disabledColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            height: 20,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: theme.colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}
