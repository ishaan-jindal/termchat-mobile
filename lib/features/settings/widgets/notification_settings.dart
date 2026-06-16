import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import 'settings_section_header.dart';

class NotificationSettings extends StatelessWidget {
  const NotificationSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SettingsSectionHeader(title: 'notifications'),
        _buildSwitchRow(context, 'message notifications', true),
        _buildSwitchRow(context, 'mention sound', true),
        _buildSwitchRow(context, 'join/leave alerts', false),
      ],
    );
  }

  Widget _buildSwitchRow(BuildContext context, String title, bool value) {
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
          Text(title, style: textTheme.bodySmall),
          SizedBox(
            height: 20,
            child: Switch(
              value: value,
              onChanged: (v) {},
              activeThumbColor: theme.colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}
