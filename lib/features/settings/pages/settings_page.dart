import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../widgets/appearance_settings.dart';
import '../widgets/identity_settings.dart';
import '../widgets/notification_settings.dart';
import '../widgets/about_settings.dart';
import '../widgets/data_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.spacing24),
              children: [
                const SizedBox(height: AppConstants.spacing16),
                Text('settings', style: textTheme.headlineMedium),
                Text('\$ termchat --config', style: textTheme.labelSmall),
                const SizedBox(height: AppConstants.spacing32),
                const AppearanceSettings(),
                const SizedBox(height: AppConstants.spacing32),
                const IdentitySettings(),
                const SizedBox(height: AppConstants.spacing32),
                const NotificationSettings(),
                const SizedBox(height: AppConstants.spacing32),
                const AboutSettings(),
                const SizedBox(height: AppConstants.spacing32),
                const DataSettings(),
                const SizedBox(height: AppConstants.spacing48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
