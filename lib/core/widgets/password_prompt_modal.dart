import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class PasswordPromptModal extends StatefulWidget {
  final String roomCode;
  final ValueChanged<String> onJoin;
  final VoidCallback? onCancel;

  const PasswordPromptModal({
    super.key,
    required this.roomCode,
    required this.onJoin,
    this.onCancel,
  });

  @override
  State<PasswordPromptModal> createState() => _PasswordPromptModalState();
}

class _PasswordPromptModalState extends State<PasswordPromptModal> {
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  void _handleJoin() {
    final password = _passwordController.text.trim();
    if (password.isNotEmpty) {
      widget.onJoin(password);
      Navigator.pop(context);
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
                    onPressed: widget.onCancel ?? () => Navigator.pop(context),
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
