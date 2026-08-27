import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termchat_app/features/chat/widgets/swipe_to_reply.dart';

void main() {
  testWidgets('triggers onReply once when swiped past threshold', (
    tester,
  ) async {
    var replyCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SwipeToReply(
            onReply: () => replyCalls++,
            background: const Icon(Icons.reply),
            child: const SizedBox(width: 100, height: 40),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(SwipeToReply), const Offset(120, 0));
    await tester.pumpAndSettle();

    expect(replyCalls, 1);
  });

  testWidgets('does not trigger onReply for a sub-threshold swipe', (
    tester,
  ) async {
    var replyCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SwipeToReply(
            onReply: () => replyCalls++,
            background: const Icon(Icons.reply),
            child: const SizedBox(width: 100, height: 40),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(SwipeToReply), const Offset(20, 0));
    await tester.pumpAndSettle();

    expect(replyCalls, 0);
  });
}
