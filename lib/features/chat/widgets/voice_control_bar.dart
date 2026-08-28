import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

/// Push-to-talk control shown while a voice session is joined. Holding the
/// mic button transmits; the lock keeps transmit on hands-free.
class VoiceControlBar extends StatefulWidget {
  final bool isTransmitting;
  final int speakersCount;
  final ValueChanged<bool> onSetTransmitting;

  const VoiceControlBar({
    super.key,
    required this.isTransmitting,
    required this.speakersCount,
    required this.onSetTransmitting,
  });

  @override
  State<VoiceControlBar> createState() => _VoiceControlBarState();
}

class _VoiceControlBarState extends State<VoiceControlBar> {
  bool _locked = false;
  bool _holding = false;

  bool get _effectiveTransmitting => widget.isTransmitting || _holding;

  void _handlePointerDown(PointerDownEvent _) {
    if (_locked) {
      setState(() => _locked = false);
      widget.onSetTransmitting(false);

      return;
    }

    setState(() => _holding = true);
    widget.onSetTransmitting(true);
  }

  void _handlePointerUpOrCancel() {
    if (!_holding) return;

    setState(() => _holding = false);

    if (!_locked) {
      widget.onSetTransmitting(false);
    }
  }

  void _toggleLock() {
    setState(() => _locked = !_locked);

    if (_locked) {
      widget.onSetTransmitting(true);
    } else {
      widget.onSetTransmitting(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final transmitting = _effectiveTransmitting;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing24,
        vertical: AppConstants.spacing12,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _locked
                        ? 'voice locked on - tap mic to stop'
                        : 'hold the mic to talk',
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    '${widget.speakersCount} in voice',
                    style: textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _toggleLock,
              tooltip: _locked ? 'Unlock transmit' : 'Lock transmit on',
              icon: Icon(_locked ? Icons.lock : Icons.lock_open),
              color: _locked
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppConstants.spacing8),
            Listener(
              key: const Key('voice_ptt_button'),
              onPointerDown: _handlePointerDown,
              onPointerUp: (_) => _handlePointerUpOrCancel(),
              onPointerCancel: (_) => _handlePointerUpOrCancel(),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: transmitting
                      ? theme.colorScheme.error
                      : theme.colorScheme.surfaceContainerHighest,
                ),
                child: Icon(
                  transmitting ? Icons.mic : Icons.mic_none,
                  size: 32,
                  color: transmitting
                      ? theme.colorScheme.onError
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
