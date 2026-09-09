import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
  Animation<double>? _snapAnim;
  double _offset = 0;
  bool _triggered = false;
  bool _isRtl = false;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(vsync: this);
    _snapController.addListener(_onSnapTick);
  }

  void _onSnapTick() {
    final anim = _snapAnim;
    if (anim == null) return;
    _offset = anim.value;
    if (mounted) setState(() {});
  }

  void _onDragStart(DragStartDetails details) {
    _snapController.stop();
    _triggered = false;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    // Swipe toward the leading edge in both directions: right in LTR,
    // left in RTL.
    final delta = _isRtl ? -details.delta.dx : details.delta.dx;
    _offset = (_offset + delta).clamp(0.0, widget.maxDrag);
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
    _snapAnim = Tween<double>(
      begin: begin,
      end: 0,
    ).animate(CurvedAnimation(parent: _snapController, curve: Curves.easeOut));
    _snapController
      ..duration = const Duration(milliseconds: 220)
      ..forward(from: 0);
    _triggered = false;
  }

  @override
  void dispose() {
    _snapController.removeListener(_onSnapTick);
    _snapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isRtl = Directionality.of(context) == TextDirection.rtl;
    final progress = (_offset / widget.maxDrag).clamp(0.0, 1.0);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Align(
            alignment: _isRtl ? Alignment.centerRight : Alignment.centerLeft,
            child: ExcludeSemantics(
              child: Opacity(
                opacity: progress,
                child: Transform.scale(
                  scale: 0.6 + 0.4 * progress,
                  child: widget.background,
                ),
              ),
            ),
          ),
        ),
        Semantics(
          customSemanticsActions: <CustomSemanticsAction, VoidCallback>{
            CustomSemanticsAction(label: 'Reply'): widget.onReply,
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            child: Transform.translate(
              offset: Offset(_isRtl ? -_offset : _offset, 0),
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }
}
