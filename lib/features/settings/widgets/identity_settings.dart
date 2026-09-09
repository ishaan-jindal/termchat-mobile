import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_utils.dart';
import '../../chat/bloc/chat_bloc.dart' as chat_bloc;
import '../bloc/identity/identity_bloc.dart';
import 'settings_section_header.dart';

class IdentitySettings extends StatelessWidget {
  const IdentitySettings({super.key});

  void _showEditNicknameModal(BuildContext context, String currentNick) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditTextSheet(
        title: 'edit nickname',
        hintText: '> /nick name',
        initialText: currentNick,
        onSave: (value) {
          context.read<IdentityBloc>().add(UpdateNickname(value));
          try {
            context.read<chat_bloc.ChatBloc>().add(
              chat_bloc.UpdateNickname(value),
            );
          } catch (_) {}
        },
      ),
    );
  }

  void _showEditColorModal(BuildContext context, String currentColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditTextSheet(
        title: 'edit color',
        hintText: '> #hex',
        initialText: currentColor,
        onSave: (value) {
          context.read<IdentityBloc>().add(UpdateColor(value));
          try {
            context.read<chat_bloc.ChatBloc>().add(
              chat_bloc.UpdateColor(value),
            );
          } catch (_) {}
        },
      ),
    );
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
              child: Semantics(
                button: true,
                label: 'Edit nickname',
                hint: 'Double-tap to edit',
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
            ),
            Material(
              color: Colors.transparent,
              child: Semantics(
                button: true,
                label: 'Edit color',
                hint: 'Double-tap to edit',
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
                                color: ColorUtils.parseHexColor(colorHex),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(
                              ' ›',
                              semanticsLabel: '',
                              style: textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ],
                    ),
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

/// Text-editing bottom sheet. Owns its [TextEditingController] in [State]
/// so pop animations and keyboard-driven rebuilds can never touch a
/// disposed controller.
class _EditTextSheet extends StatefulWidget {
  final String title;
  final String hintText;
  final String initialText;
  final ValueChanged<String> onSave;

  const _EditTextSheet({
    required this.title,
    required this.hintText,
    required this.initialText,
    required this.onSave,
  });

  @override
  State<_EditTextSheet> createState() => _EditTextSheetState();
}

class _EditTextSheetState extends State<_EditTextSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = _controller.text.trim();
    if (value.isNotEmpty) widget.onSave(value);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

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
            MediaQuery.of(context).viewInsets.bottom + AppConstants.spacing24,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: textTheme.bodySmall),
            const SizedBox(height: AppConstants.spacing24),
            TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: widget.hintText),
              style: textTheme.bodyLarge,
              autofocus: true,
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: AppConstants.spacing24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('cancel'),
                  ),
                ),
                const SizedBox(width: AppConstants.spacing16),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    style: AppTheme.inverseFilledButtonStyle(theme.colorScheme),
                    child: const Text('save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
