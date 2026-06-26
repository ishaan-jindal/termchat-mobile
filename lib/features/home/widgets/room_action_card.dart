import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/room_join_helper.dart';

class RoomActionCard extends StatefulWidget {
  const RoomActionCard({super.key});

  @override
  State<RoomActionCard> createState() => _RoomActionCardState();
}

class _RoomActionCardState extends State<RoomActionCard> {
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

    final success = await RoomJoinHelper.joinRoom(context, roomCode, false);
    if (success) _controller.clear();
  }

  Future<void> _handleCreate() async {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final newCode = String.fromCharCodes(
      Iterable.generate(
        4,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
    final success = await RoomJoinHelper.joinRoom(context, newCode, false);
    if (success) _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('room code', style: textTheme.bodySmall),
          const SizedBox(height: AppConstants.spacing12),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: '> e.g. FROG',
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
              backgroundColor: colorScheme.onSurface,
              foregroundColor: colorScheme.surface,
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacing12,
              ),
            ),
            child: const Text('join room'),
          ),
          const SizedBox(height: AppConstants.spacing24),
          Row(
            children: [
              Expanded(child: Divider(color: theme.dividerColor)),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing16,
                ),
                child: Text('or', style: textTheme.labelSmall),
              ),
              Expanded(child: Divider(color: theme.dividerColor)),
            ],
          ),
          const SizedBox(height: AppConstants.spacing24),
          OutlinedButton(
            onPressed: _handleCreate,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacing12,
              ),
            ),
            child: const Text('+ create a new room'),
          ),
        ],
      ),
    );
  }
}
