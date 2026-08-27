import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termchat_app/core/models/message.dart';
import 'package:termchat_app/features/chat/widgets/chat_input_area.dart';

void main() {
  Widget buildWidget({
    required void Function(String text, int? replyToId) onSend,
    VoidCallback? onTyping,
    Message? replyTarget,
    VoidCallback? onCancelReply,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ChatInputArea(
          onSend: onSend,
          onTyping: onTyping,
          replyTarget: replyTarget,
          onCancelReply: onCancelReply,
        ),
      ),
    );
  }

  group('ChatInputArea', () {
    testWidgets('renders hint text and send button', (tester) async {
      await tester.pumpWidget(buildWidget(onSend: (_, _) {}));

      expect(find.text('> Type a message or /command'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'send'), findsOneWidget);
    });

    testWidgets(
      'typing and tapping send invokes onSend with text and null id',
      (tester) async {
        var sentText = '';
        int? sentReplyToId;

        await tester.pumpWidget(
          buildWidget(
            onSend: (text, replyToId) {
              sentText = text;
              sentReplyToId = replyToId;
            },
          ),
        );

        await tester.enterText(find.byType(TextField), 'hello world');
        await tester.tap(find.widgetWithText(FilledButton, 'send'));
        await tester.pump();

        expect(sentText, 'hello world');
        expect(sentReplyToId, isNull);
      },
    );

    testWidgets('send clears the text field', (tester) async {
      await tester.pumpWidget(buildWidget(onSend: (_, _) {}));

      await tester.enterText(find.byType(TextField), 'to be cleared');
      await tester.tap(find.widgetWithText(FilledButton, 'send'));
      await tester.pump();

      expect(find.text('to be cleared'), findsNothing);
    });

    testWidgets('sending with a replyTarget passes the parsed reply id', (
      tester,
    ) async {
      final reply = Message(
        id: '42',
        roomId: 'r1',
        senderId: 'u1',
        senderNickname: 'Bob',
        senderColorHex: '#00FF00',
        content: 'previous message',
        timestamp: DateTime.now(),
      );

      int? sentReplyToId;
      await tester.pumpWidget(
        buildWidget(
          onSend: (_, replyToId) => sentReplyToId = replyToId,
          replyTarget: reply,
        ),
      );

      await tester.enterText(find.byType(TextField), 'a reply');
      await tester.tap(find.widgetWithText(FilledButton, 'send'));
      await tester.pump();

      expect(sentReplyToId, 42);
    });

    testWidgets('onTyping fires once then is throttled within 1 second', (
      tester,
    ) async {
      var typingCalls = 0;

      await tester.pumpWidget(
        buildWidget(onSend: (_, _) {}, onTyping: () => typingCalls++),
      );

      await tester.enterText(find.byType(TextField), 'a');
      expect(typingCalls, 1);

      await tester.enterText(find.byType(TextField), 'ab');
      expect(typingCalls, 1);
    });

    testWidgets('replyTarget shows chip and cancel invokes onCancelReply', (
      tester,
    ) async {
      var cancelled = false;
      final reply = Message(
        id: '7',
        roomId: 'r1',
        senderId: 'u1',
        senderNickname: 'Carol',
        senderColorHex: '#0000FF',
        content: 'ping',
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        buildWidget(
          onSend: (_, _) {},
          replyTarget: reply,
          onCancelReply: () => cancelled = true,
        ),
      );

      expect(find.text('Replying to Carol'), findsOneWidget);

      await tester.tap(find.byTooltip('Cancel reply'));
      await tester.pump();

      expect(cancelled, isTrue);
    });
  });
}
