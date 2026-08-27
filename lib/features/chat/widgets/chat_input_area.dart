import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/message.dart';

class ChatInputArea extends StatefulWidget {
  final void Function(String text, int? replyToId) onSend;
  final VoidCallback? onTyping;
  final Message? replyTarget;
  final VoidCallback? onCancelReply;

  const ChatInputArea({
    super.key,
    required this.onSend,
    this.onTyping,
    this.replyTarget,
    this.onCancelReply,
  });

  @override
  State<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<ChatInputArea> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  DateTime? _lastTypingTime;

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final replyToId = widget.replyTarget != null
          ? int.tryParse(widget.replyTarget!.id)
          : null;
      widget.onSend(text, replyToId);
      _controller.clear();
      _focusNode.requestFocus();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.replyTarget != null) _buildReplyChip(context),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.send,
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
          ],
        ),
      ),
    );
  }

  Widget _buildReplyChip(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacing8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppConstants.spacing8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Replying to ${widget.replyTarget!.senderNickname}',
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.replyTarget!.content,
                    style: textTheme.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (widget.onCancelReply != null)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onCancelReply,
                tooltip: 'Cancel reply',
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
