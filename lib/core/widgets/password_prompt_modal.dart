import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/settings/bloc/identity/identity_bloc.dart';
import '../constants/app_constants.dart';

class PasswordPromptModal extends StatefulWidget {
  final String roomCode;

  const PasswordPromptModal({super.key, required this.roomCode});

  @override
  State<PasswordPromptModal> createState() => _PasswordPromptModalState();
}

class _PasswordPromptModalState extends State<PasswordPromptModal> {
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  void _handleJoin() {
    final password = _passwordController.text.trim();
    if (password.isNotEmpty) {
      Navigator.pop(context, password);
    }
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('room is locked', style: textTheme.bodySmall),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'locked',
                    style: textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              '${widget.roomCode} requires a password',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: AppConstants.spacing16),
            BlocBuilder<IdentityBloc, IdentityState>(
              builder: (context, state) {
                String nick = 'anonymous';
                Color color = theme.colorScheme.primary;
                if (state is IdentityLoaded) {
                  nick = state.user.nickname;
                  final hex = state.user.colorHex.replaceAll('#', '');
                  if (hex.length == 6) {
                    final parsed = int.tryParse('FF$hex', radix: 16);
                    if (parsed != null) {
                      color = Color(parsed);
                    }
                  }
                }
                return Row(
                  children: [
                    Text('joining as: ', style: textTheme.labelSmall),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        nick,
                        style: textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppConstants.spacing24),
            Text('password', style: textTheme.labelSmall),
            const SizedBox(height: AppConstants.spacing8),
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: const InputDecoration(hintText: '> ********'),
              style: textTheme.bodyLarge,
              onSubmitted: (_) => _handleJoin(),
            ),
            const SizedBox(height: AppConstants.spacing8),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: Text(
                  _obscureText ? 'show password' : 'hide password',
                  style: textTheme.labelSmall,
                ),
              ),
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
                    onPressed: _handleJoin,
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.onSurface,
                      foregroundColor: theme.colorScheme.surface,
                    ),
                    child: const Text('join room'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
