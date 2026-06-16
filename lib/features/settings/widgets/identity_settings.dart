import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../bloc/identity/identity_bloc.dart';
import '../../chat/bloc/chat_bloc.dart' as chat_bloc;
import 'settings_section_header.dart';

class IdentitySettings extends StatelessWidget {
  const IdentitySettings({super.key});

  void _showEditNicknameModal(BuildContext context, String currentNick) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final controller = TextEditingController(text: currentNick);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
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
                MediaQuery.of(bottomSheetContext).viewInsets.bottom +
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
                  controller: controller,
                  decoration: const InputDecoration(hintText: '> /nick name'),
                  style: textTheme.bodyLarge,
                  autofocus: true,
                ),
                const SizedBox(height: AppConstants.spacing24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(bottomSheetContext),
                        child: const Text('cancel'),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (controller.text.trim().isNotEmpty) {
                            context.read<IdentityBloc>().add(
                              UpdateNickname(controller.text.trim()),
                            );
                            // Also send to ChatBloc if connected
                            context.read<chat_bloc.ChatBloc>().add(
                              chat_bloc.UpdateNickname(controller.text.trim()),
                            );
                          }
                          Navigator.pop(bottomSheetContext);
                        },
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

  void _showEditColorModal(BuildContext context, String currentColor) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final controller = TextEditingController(text: currentColor);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
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
                MediaQuery.of(bottomSheetContext).viewInsets.bottom +
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
                  controller: controller,
                  decoration: const InputDecoration(hintText: '> #hex'),
                  style: textTheme.bodyLarge,
                  autofocus: true,
                ),
                const SizedBox(height: AppConstants.spacing24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(bottomSheetContext),
                        child: const Text('cancel'),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (controller.text.trim().isNotEmpty) {
                            context.read<IdentityBloc>().add(
                              UpdateColor(controller.text.trim()),
                            );
                            // Also send to ChatBloc if connected
                            context.read<chat_bloc.ChatBloc>().add(
                              chat_bloc.UpdateColor(controller.text.trim()),
                            );
                          }
                          Navigator.pop(bottomSheetContext);
                        },
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

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.tryParse(hex, radix: 16) ?? 0xFFFFFFFF);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return BlocBuilder<IdentityBloc, IdentityState>(
      builder: (context, state) {
        String nick = 'loading...';
        String colorHex = '#ffffff';

        if (state is IdentityLoaded) {
          nick = state.user.nickname;
          colorHex = state.user.colorHex;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SettingsSectionHeader(title: 'identity'),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showEditNicknameModal(context, nick),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: theme.dividerColor),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacing14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('nickname', style: textTheme.bodySmall),
                      Text('/nick $nick ›', style: textTheme.labelSmall),
                    ],
                  ),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showEditColorModal(context, colorHex),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: theme.dividerColor),
                    ),
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
                          Text('$colorHex ', style: textTheme.labelSmall),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _parseColor(colorHex),
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
      },
    );
  }
}
