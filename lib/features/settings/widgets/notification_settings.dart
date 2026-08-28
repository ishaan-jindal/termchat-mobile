import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/notification_helper.dart';
import '../bloc/settings/settings_bloc.dart';
import 'settings_section_header.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings>
    with WidgetsBindingObserver {
  bool? _permissionGranted;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermission();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _refreshPermission() async {
    final granted = await NotificationHelper.hasNotificationPermission();

    if (mounted) {
      setState(() => _permissionGranted = granted);
    }
  }

  Future<void> _handleNotificationsToggle(bool enabled) async {
    if (!enabled) {
      context.read<SettingsBloc>().add(const ToggleMessageNotifications(false));

      return;
    }

    final status = await Permission.notification.request();
    final granted = status.isGranted;

    if (!mounted) return;

    if (granted) {
      context.read<SettingsBloc>().add(const ToggleMessageNotifications(true));
    } else {
      context.read<SettingsBloc>().add(const ToggleMessageNotifications(false));

      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text(
              'Notification permission denied - mentions will not notify you.',
            ),
            action: status.isPermanentlyDenied
                ? SnackBarAction(
                    label: 'Open settings',
                    onPressed: () => openAppSettings(),
                  )
                : null,
          ),
        );
    }

    setState(() => _permissionGranted = granted);
  }

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
              (enabled) => _handleNotificationsToggle(enabled),
              subtitle: _permissionSubtitle(),
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

  String? _permissionSubtitle() {
    if (_permissionGranted == null) return null;

    return _permissionGranted!
        ? 'permission granted'
        : 'permission not granted · tap the switch to allow';
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
