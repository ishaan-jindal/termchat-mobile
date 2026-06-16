import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../settings/bloc/identity/identity_bloc.dart';
import '../../chat/bloc/chat_bloc.dart';
import '../../chat/managers/active_chats_manager.dart';
import '../../../di/injection.dart';

class RoomActionCard extends StatefulWidget {
  const RoomActionCard({super.key});

  @override
  State<RoomActionCard> createState() => _RoomActionCardState();
}

class _RoomActionCardState extends State<RoomActionCard> {
  final _controller = TextEditingController();

  String _getNick() {
    final identityState = context.read<IdentityBloc>().state;
    if (identityState is IdentityLoaded) {
      return identityState.user.nickname;
    }
    return 'anonymous';
  }

  String _getColor() {
    final identityState = context.read<IdentityBloc>().state;
    if (identityState is IdentityLoaded) {
      return identityState.user.colorHex;
    }
    return '';
  }

  void _handleJoin() {
    final roomCode = _controller.text.trim();
    if (roomCode.isNotEmpty) {
      final chatBloc = getIt<ActiveChatsManager>().getOrCreate(roomCode);
      if (!chatBloc.state.isConnected && !chatBloc.state.isLoading) {
        chatBloc.add(
          ConnectChat(
            roomCode: roomCode,
            nick: _getNick(),
            colorHex: _getColor(),
          ),
        );
      }
      context.go('/chat/$roomCode');
    }
  }

  void _handleCreate() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final newCode = String.fromCharCodes(
      Iterable.generate(
        4,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );

    final chatBloc = getIt<ActiveChatsManager>().getOrCreate(newCode);
    if (!chatBloc.state.isConnected && !chatBloc.state.isLoading) {
      chatBloc.add(
        ConnectChat(roomCode: newCode, nick: _getNick(), colorHex: _getColor()),
      );
    }
    context.go('/chat/$newCode');
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
            decoration: const InputDecoration(hintText: '> e.g. FROG'),
            style: textTheme.bodyLarge,
            textCapitalization: TextCapitalization.characters,
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
