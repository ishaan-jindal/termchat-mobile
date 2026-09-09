import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:termchat_app/core/models/user.dart';
import 'package:termchat_app/core/widgets/password_prompt_modal.dart';
import 'package:termchat_app/features/settings/bloc/identity/identity_bloc.dart';

class MockIdentityBloc extends Mock implements IdentityBloc {}

void main() {
  late MockIdentityBloc identityBloc;

  setUp(() {
    identityBloc = MockIdentityBloc();
    when(() => identityBloc.state).thenReturn(
      const IdentityLoaded(
        User(id: 'u1', nickname: 'Alice', colorHex: '#FF0000'),
      ),
    );
    when(() => identityBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Future<String?> pumpModal(WidgetTester tester) {
    return showModalBottomSheet<String>(
      context: tester.element(find.byType(Scaffold)),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PasswordPromptModal(roomCode: 'ABCD'),
    );
  }

  /// Dismisses the keyboard before settling: popping a sheet with a focused
  /// autofocus field trips a framework focus-scope assertion in tests.
  Future<void> settle(WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  }

  Future<void> pumpHarness(WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider<IdentityBloc>.value(
        value: identityBloc,
        child: const MaterialApp(home: Scaffold(body: SizedBox())),
      ),
    );
    await settle(tester);
  }

  group('PasswordPromptModal', () {
    testWidgets('join returns the typed password', (tester) async {
      await pumpHarness(tester);
      final future = pumpModal(tester);
      await settle(tester);

      await tester.enterText(find.byType(TextField), 'secret');
      await tester.tap(find.text('join room'));
      await settle(tester);

      expect(await future, 'secret');
    });

    testWidgets('empty password does nothing', (tester) async {
      await pumpHarness(tester);
      unawaited(pumpModal(tester));
      await settle(tester);

      await tester.tap(find.text('join room'));
      await settle(tester);

      expect(find.text('room is locked'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('show password toggles obscure text', (tester) async {
      await pumpHarness(tester);
      unawaited(pumpModal(tester));
      await settle(tester);

      await tester.enterText(find.byType(TextField), 'secret');
      await tester.tap(find.text('show password'));
      await settle(tester);

      expect(find.text('hide password'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('cancel pops with null', (tester) async {
      await pumpHarness(tester);
      final future = pumpModal(tester);
      await settle(tester);

      await tester.tap(find.text('cancel'));
      await settle(tester);

      expect(await future, isNull);
    });
  });
}
