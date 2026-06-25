import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

class ShellLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ShellLayout({super.key, required this.navigationShell});

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: theme.dividerColor)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing24,
              vertical: AppConstants.spacing12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavItem(
                  label: 'chat',
                  isSelected: navigationShell.currentIndex == 0,
                  onTap: () => _goBranch(0),
                ),
                _NavItem(
                  label: 'rooms',
                  isSelected: navigationShell.currentIndex == 1,
                  onTap: () => _goBranch(1),
                ),
                _NavItem(
                  label: 'settings',
                  isSelected: navigationShell.currentIndex == 2,
                  onTap: () => _goBranch(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    final color = isSelected
        ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
        : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 2,
            width: 24,
            color: isSelected ? color : Colors.transparent,
            margin: const EdgeInsets.only(bottom: AppConstants.spacing4),
          ),
          Text(label, style: textTheme.bodySmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}
