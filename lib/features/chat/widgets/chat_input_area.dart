import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

class ChatInputArea extends StatefulWidget {
  final ValueChanged<String> onSend;
  final VoidCallback? onTyping;

  const ChatInputArea({super.key, required this.onSend, this.onTyping});

  @override
  State<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<ChatInputArea> {
  final _controller = TextEditingController();
  DateTime? _lastTypingTime;

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  void _handleTyping() {
    if (widget.onTyping == null) return;

    final now = DateTime.now();
    if (_lastTypingTime == null ||
        now.difference(_lastTypingTime!) > const Duration(seconds: 1)) {
      _lastTypingTime = now;
      widget.onTyping!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing24,
        vertical: AppConstants.spacing16,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: '> Type a message or /command',
                ),
                style: textTheme.bodyLarge,
                onSubmitted: (_) => _handleSend(),
                onChanged: (text) {
                  if (text.isNotEmpty) {
                    _handleTyping();
                  }
                },
              ),
            ),
            const SizedBox(width: AppConstants.spacing16),
            FilledButton(
              onPressed: _handleSend,
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.onSurface,
                foregroundColor: theme.colorScheme.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing24,
                  vertical: AppConstants.spacing12,
                ),
              ),
              child: const Text('send'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
