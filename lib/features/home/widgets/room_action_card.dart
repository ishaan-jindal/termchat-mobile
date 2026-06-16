import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/password_prompt_modal.dart';
import '../../settings/bloc/identity/identity_bloc.dart';
import '../../chat/bloc/chat_bloc.dart';

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

  void _handleJoin() {
    final roomCode = _controller.text.trim();
    if (roomCode.isNotEmpty) {
      context.read<ChatBloc>().add(
        ConnectChat(roomCode: roomCode, nick: _getNick()),
      );
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

    context.read<ChatBloc>().add(
      ConnectChat(roomCode: newCode, nick: _getNick()),
    );
    context.go('/chat/$newCode');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (previous, current) =>
          previous.error != current.error && current.error != null,
      listener: (context, state) {
        if (state.error == 'invalid_password') {
          // If we tried to join from home and need a password
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (bottomSheetContext) => PasswordPromptModal(
              roomCode: _controller.text.trim(),
              onJoin: (password) {
                context.read<ChatBloc>().add(
                  ConnectChat(
                    roomCode: _controller.text.trim(),
                    nick: _getNick(),
                    password: password,
                  ),
                );
                // We are already on /chat page since we navigated earlier,
                // but if not, we can navigate here.
              },
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
        }
      },
      child: Container(
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
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
