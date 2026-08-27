import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A swipe-right gesture that reveals a [background] affordance and triggers
/// [onReply] once the drag crosses [triggerOffset]. The item snaps back on
/// release, so it never actually dismisses.
class SwipeToReply extends StatefulWidget {
  final Widget child;
  final Widget background;
  final VoidCallback onReply;
  final double triggerOffset;
  final double maxDrag;

  const SwipeToReply({
    super.key,
    required this.child,
    required this.background,
    required this.onReply,
    this.triggerOffset = 64,
    this.maxDrag = 100,
  });

  @override
  State<SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<SwipeToReply>
    with SingleTickerProviderStateMixin {
  late final AnimationController _snapController;
  double _offset = 0;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(vsync: this);
  }

  void _onDragStart(DragStartDetails details) {
    _snapController.stop();
    _triggered = false;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _offset = (_offset + details.delta.dx).clamp(0.0, widget.maxDrag);
    if (_offset >= widget.triggerOffset && !_triggered) {
      _triggered = true;
      HapticFeedback.mediumImpact();
      widget.onReply();
    }
    setState(() {});
  }

  void _onDragEnd(DragEndDetails details) {
    final begin = _offset;
    if (begin <= 0) return;
    final animation = Tween<double>(
      begin: begin,
      end: 0,
    ).animate(CurvedAnimation(parent: _snapController, curve: Curves.easeOut));
    animation.addListener(() {
      _offset = animation.value;
      setState(() {});
    });
    _snapController
      ..duration = const Duration(milliseconds: 220)
      ..forward(from: 0);
    _triggered = false;
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_offset / widget.maxDrag).clamp(0.0, 1.0);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Opacity(
              opacity: progress,
              child: Transform.scale(
                scale: 0.6 + 0.4 * progress,
                child: widget.background,
              ),
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: _onDragStart,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: Transform.translate(
            offset: Offset(_offset, 0),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
