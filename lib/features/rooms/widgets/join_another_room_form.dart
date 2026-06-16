import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

class JoinAnotherRoomForm extends StatefulWidget {
  final ValueChanged<String> onJoin;

  const JoinAnotherRoomForm({super.key, required this.onJoin});

  @override
  State<JoinAnotherRoomForm> createState() => _JoinAnotherRoomFormState();
}

class _JoinAnotherRoomFormState extends State<JoinAnotherRoomForm> {
  final _controller = TextEditingController();

  void _handleJoin() {
    final roomCode = _controller.text.trim();
    if (roomCode.isNotEmpty) {
      widget.onJoin(roomCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('join another', style: textTheme.labelSmall),
        const SizedBox(height: AppConstants.spacing12),
        TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: '> room code'),
          style: textTheme.bodyLarge,
          textCapitalization: TextCapitalization.characters,
          onSubmitted: (_) => _handleJoin(),
        ),
        const SizedBox(height: AppConstants.spacing16),
        FilledButton(
          onPressed: _handleJoin,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.onSurface,
            foregroundColor: theme.colorScheme.surface,
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.spacing12,
            ),
          ),
          child: const Text('join room'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
