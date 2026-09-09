import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termchat_app/features/rooms/widgets/join_another_room_form.dart';

void main() {
  Future<void> pumpForm(
    WidgetTester tester,
    Future<bool> Function(String) onJoin,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: JoinAnotherRoomForm(onJoin: onJoin)),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('JoinAnotherRoomForm', () {
    testWidgets('rejects codes that are not 4 letters or numbers', (
      tester,
    ) async {
      String? joinedWith;
      await pumpForm(tester, (code) async {
        joinedWith = code;
        return true;
      });

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.tap(find.text('join room'));
      await tester.pumpAndSettle();

      expect(
        find.text('Room code must be 4 letters or numbers'),
        findsOneWidget,
      );
      expect(joinedWith, isNull);
    });

    testWidgets('uppercases and joins valid codes, clears on success', (
      tester,
    ) async {
      String? joinedWith;
      await pumpForm(tester, (code) async {
        joinedWith = code;
        return true;
      });

      await tester.enterText(find.byType(TextField), 'frog');
      await tester.tap(find.text('join room'));
      await tester.pumpAndSettle();

      expect(joinedWith, 'FROG');
      expect(find.text('frog'), findsNothing);
    });

    testWidgets('keeps text when join fails', (tester) async {
      await pumpForm(tester, (_) async => false);

      await tester.enterText(find.byType(TextField), 'FROG');
      await tester.tap(find.text('join room'));
      await tester.pumpAndSettle();

      expect(find.text('FROG'), findsOneWidget);
    });
  });
}
