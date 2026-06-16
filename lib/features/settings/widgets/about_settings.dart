import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import 'settings_section_header.dart';

class AboutSettings extends StatelessWidget {
  const AboutSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SettingsSectionHeader(title: 'about'),
        Text(
          'termchat mobile v${AppConstants.appVersion}',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: AppConstants.spacing4),
        Text(
          'instant · disposable · terminal-first',
          style: textTheme.labelSmall,
        ),
      ],
    );
  }
}
