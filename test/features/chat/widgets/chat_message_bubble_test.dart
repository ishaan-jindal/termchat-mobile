import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termchat_app/core/models/message.dart';
import 'package:termchat_app/core/models/reaction.dart';
import 'package:termchat_app/core/theme/app_colors.dart';
import 'package:termchat_app/core/utils/color_utils.dart';
import 'package:termchat_app/features/chat/widgets/chat_message_bubble.dart';

void main() {
  Message buildMessage({
    String id = 'm1',
    String senderNickname = 'Alice',
    String senderColorHex = '#FF0000',
    String content = 'Hello there',
    int? replyToId,
    String? replyToNick,
    String? replyToText,
    List<Reaction> reactions = const [],
  }) {
    return Message(
      id: id,
      roomId: 'r1',
      senderId: 'u1',
      senderNickname: senderNickname,
      senderColorHex: senderColorHex,
      content: content,
      timestamp: DateTime.now(),
      replyToId: replyToId,
      replyToNick: replyToNick,
      replyToText: replyToText,
      reactions: reactions,
    );
  }

  Widget buildWidget({
    required Message message,
    bool isMention = false,
    Set<String> myReactions = const {},
    VoidCallback? onReact,
    void Function(String name)? onToggleReaction,
    VoidCallback? onTapQuote,
    ThemeData? theme,
  }) {
    return MaterialApp(
      theme: theme ?? ThemeData.light(),
      home: Scaffold(
        body: ChatMessageBubble(
          message: message,
          isMention: isMention,
          myReactions: myReactions,
          onReact: onReact,
          onToggleReaction: onToggleReaction,
          onTapQuote: onTapQuote,
        ),
      ),
    );
  }

  group('ChatMessageBubble', () {
    testWidgets('shows sender nickname and message content', (tester) async {
      await tester.pumpWidget(buildWidget(message: buildMessage()));

      expect(find.text('> Alice'), findsOneWidget);
      expect(find.text('Hello there'), findsOneWidget);
    });

    testWidgets('parses sender color from hex', (tester) async {
      await tester.pumpWidget(
        buildWidget(message: buildMessage(senderColorHex: '#FF0000')),
      );

      final username = tester.widget<Text>(find.text('> Alice'));
      expect(username.style?.color, ColorUtils.parseHexColor('#FF0000'));
    });

    testWidgets('mention highlight applies bold weight and mention color', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(
          message: buildMessage(content: 'look at me'),
          isMention: true,
          theme: ThemeData.dark(),
        ),
      );

      final content = tester.widget<Text>(find.text('look at me'));
      expect(content.style?.fontWeight, FontWeight.bold);
      expect(content.style?.color, AppColors.mentionTextDark);
    });

    testWidgets('non-mention content is not bold', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          message: buildMessage(content: 'plain message'),
          isMention: false,
        ),
      );

      final content = tester.widget<Text>(find.text('plain message'));
      expect(content.style?.fontWeight, isNot(FontWeight.bold));
    });

    testWidgets('long press triggers onReact', (tester) async {
      var reacted = false;
      await tester.pumpWidget(
        buildWidget(message: buildMessage(), onReact: () => reacted = true),
      );

      await tester.longPress(find.byType(ChatMessageBubble));
      await tester.pump();

      expect(reacted, isTrue);
    });

    testWidgets('reply quote shows when replyToId > 0 and taps quote', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        buildWidget(
          message: buildMessage(
            replyToId: 5,
            replyToNick: 'Dave',
            replyToText: 'original',
          ),
          onTapQuote: () => tapped = true,
        ),
      );

      expect(find.text('Dave'), findsOneWidget);
      expect(find.text('original'), findsOneWidget);

      await tester.tap(find.text('original'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('reaction chips call onToggleReaction with name', (
      tester,
    ) async {
      const reaction = Reaction(name: 'heart', count: 2);
      String? toggled;
      await tester.pumpWidget(
        buildWidget(
          message: buildMessage(reactions: const [reaction]),
          onToggleReaction: (name) => toggled = name,
        ),
      );

      expect(find.text('❤️ 2'), findsOneWidget);

      await tester.tap(find.text('❤️ 2'));
      await tester.pump();

      expect(toggled, 'heart');
    });
  });
}
