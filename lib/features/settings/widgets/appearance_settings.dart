import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../bloc/settings/settings_bloc.dart';
import 'settings_section_header.dart';

class AppearanceSettings extends StatelessWidget {
  const AppearanceSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
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
                    child: _buildSegmentButton(
                      context,
                      'dark',
                      state.themeMode == 'dark',
                      true,
                      false,
                      () => context.read<SettingsBloc>().add(
                        const UpdateThemeMode('dark'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildSegmentButton(
                      context,
                      'light',
                      state.themeMode == 'light',
                      false,
                      false,
                      () => context.read<SettingsBloc>().add(
                        const UpdateThemeMode('light'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildSegmentButton(
                      context,
                      'system',
                      state.themeMode == 'system',
                      false,
                      true,
                      () => context.read<SettingsBloc>().add(
                        const UpdateThemeMode('system'),
                      ),
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
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacing14,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('font size', style: textTheme.bodySmall),
                  Row(
                    children: [
                      _buildFontSizeOption(
                        context,
                        'sm',
                        state.fontSize == 'sm',
                      ),
                      const SizedBox(width: AppConstants.spacing12),
                      _buildFontSizeOption(
                        context,
                        'md',
                        state.fontSize == 'md',
                      ),
                      const SizedBox(width: AppConstants.spacing12),
                      _buildFontSizeOption(
                        context,
                        'lg',
                        state.fontSize == 'lg',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFontSizeOption(
    BuildContext context,
    String size,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: () => context.read<SettingsBloc>().add(UpdateFontSize(size)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? theme.dividerColor : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          size,
          style: textTheme.labelSmall?.copyWith(
            color: isSelected
                ? theme.colorScheme.onSurface
                : textTheme.labelSmall?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentButton(
    BuildContext context,
    String label,
    bool isSelected,
    bool isFirst,
    bool isLast,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.horizontal(
          left: isFirst
              ? const Radius.circular(AppConstants.radius8)
              : Radius.zero,
          right: isLast
              ? const Radius.circular(AppConstants.radius8)
              : Radius.zero,
        ),
        child: Container(
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
        ),
      ),
    );
  }
}
