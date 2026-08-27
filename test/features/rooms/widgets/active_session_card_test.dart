import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termchat_app/core/theme/app_colors.dart';
import 'package:termchat_app/features/rooms/widgets/active_session_card.dart';

void main() {
  Widget buildWidget({
    required String roomName,
    bool isHost = false,
    bool isViewing = false,
    required int usersCount,
    int unreadCount = 0,
    required String lastMessageText,
    VoidCallback? onTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ActiveSessionCard(
          roomName: roomName,
          isHost: isHost,
          isViewing: isViewing,
          usersCount: usersCount,
          unreadCount: unreadCount,
          lastMessageText: lastMessageText,
          onTap: onTap ?? () {},
        ),
      ),
    );
  }

  group('ActiveSessionCard', () {
    testWidgets('shows room name, users count and last message', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(
          roomName: 'general',
          usersCount: 3,
          lastMessageText: 'see you later',
        ),
      );

      expect(find.text('general'), findsOneWidget);
      expect(find.text('3 users'), findsOneWidget);
      expect(find.text('see you later'), findsOneWidget);
    });

    testWidgets('singular user label for one user', (tester) async {
      await tester.pumpWidget(
        buildWidget(roomName: 'room', usersCount: 1, lastMessageText: 'hi'),
      );

      expect(find.text('1 user'), findsOneWidget);
    });

    testWidgets('host label shown only when isHost', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          roomName: 'room',
          isHost: true,
          usersCount: 2,
          lastMessageText: 'hi',
        ),
      );

      expect(find.text('host'), findsOneWidget);

      await tester.pumpWidget(
        buildWidget(
          roomName: 'room',
          isHost: false,
          usersCount: 2,
          lastMessageText: 'hi',
        ),
      );

      expect(find.text('host'), findsNothing);
    });

    testWidgets('unread badge shown when unreadCount > 0', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          roomName: 'room',
          usersCount: 2,
          unreadCount: 4,
          lastMessageText: 'hi',
        ),
      );

      expect(find.text('4'), findsOneWidget);
      final badge = find.ancestor(
        of: find.text('4'),
        matching: find.byType(Container),
      );
      final decoration =
          tester.widget<Container>(badge.first).decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.color, AppColors.errorDark);
    });

    testWidgets('no unread badge when unreadCount is zero', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          roomName: 'room',
          usersCount: 2,
          unreadCount: 0,
          lastMessageText: 'hi',
        ),
      );

      expect(find.text('0'), findsNothing);
    });

    testWidgets('tapping the card invokes onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildWidget(
          roomName: 'room',
          usersCount: 2,
          lastMessageText: 'hi',
          onTap: () => tapped = true,
        ),
      );

      await tester.tap(find.byType(ActiveSessionCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('viewing label shown when isViewing', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          roomName: 'room',
          isViewing: true,
          usersCount: 2,
          lastMessageText: 'hi',
        ),
      );

      expect(find.text('viewing'), findsOneWidget);
      expect(find.text('switch →'), findsNothing);

      await tester.pumpWidget(
        buildWidget(
          roomName: 'room',
          isViewing: false,
          usersCount: 2,
          lastMessageText: 'hi',
        ),
      );

      expect(find.text('viewing'), findsNothing);
      expect(find.text('switch →'), findsOneWidget);
    });
  });
}
