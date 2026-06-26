import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';

class JoinAnotherRoomForm extends StatefulWidget {
  final Future<bool> Function(String) onJoin;

  const JoinAnotherRoomForm({super.key, required this.onJoin});

  @override
  State<JoinAnotherRoomForm> createState() => _JoinAnotherRoomFormState();
}

class _JoinAnotherRoomFormState extends State<JoinAnotherRoomForm> {
  final _controller = TextEditingController();
  String? _errorText;

  void _onChanged(String value) {
    if (_errorText != null) {
      setState(() => _errorText = null);
    }
  }

  Future<void> _handleJoin() async {
    final roomCode = _controller.text.trim().toUpperCase();
    if (roomCode.isEmpty) return;

    if (!RegExp(r'^[A-Z0-9]{4}$').hasMatch(roomCode)) {
      setState(() => _errorText = 'Room code must be 4 letters or numbers');
      return;
    }

    final success = await widget.onJoin(roomCode);
    if (success) _controller.clear();
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
          decoration: InputDecoration(
            hintText: '> room code',
            errorText: _errorText,
          ),
          style: textTheme.bodyLarge,
          textCapitalization: TextCapitalization.characters,
          maxLength: 4,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
          ],
          onChanged: _onChanged,
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
