import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:termchat_app/core/models/user.dart';
import 'package:termchat_app/features/settings/bloc/identity/identity_bloc.dart';
import 'package:termchat_app/features/settings/widgets/identity_settings.dart';

class MockIdentityBloc extends Mock implements IdentityBloc {}

void main() {
  late MockIdentityBloc identityBloc;

  setUpAll(() {
    registerFallbackValue(const UpdateNickname('fallback'));
  });

  setUp(() {
    identityBloc = MockIdentityBloc();
    when(() => identityBloc.state).thenReturn(
      const IdentityLoaded(
        User(id: 'u1', nickname: 'Alice', colorHex: '#FF0000'),
      ),
    );
    when(() => identityBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    reset(identityBloc);
  });

  Future<void> pumpSettings(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<IdentityBloc>.value(
          value: identityBloc,
          child: const Scaffold(body: IdentitySettings()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('IdentitySettings edit sheets', () {
    testWidgets('saving a nickname dispatches and closes without error', (
      tester,
    ) async {
      await pumpSettings(tester);

      await tester.tap(find.text('/nick Alice ›'));
      await tester.pumpAndSettle();
      expect(find.text('edit nickname'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Bob');
      await tester.tap(find.text('save'));
      await tester.pumpAndSettle();

      verify(() => identityBloc.add(const UpdateNickname('Bob'))).called(1);
      expect(find.text('edit nickname'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('cancelling the color sheet closes without error', (
      tester,
    ) async {
      await pumpSettings(tester);

      await tester.tap(find.text('color'));
      await tester.pumpAndSettle();
      expect(find.text('edit color'), findsOneWidget);

      await tester.tap(find.text('cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => identityBloc.add(any()));
      expect(find.text('edit color'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty save keeps the sheet closed without dispatching', (
      tester,
    ) async {
      await pumpSettings(tester);

      await tester.tap(find.text('/nick Alice ›'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.text('save'));
      await tester.pumpAndSettle();

      verifyNever(() => identityBloc.add(any()));
      expect(tester.takeException(), isNull);
    });
  });
}
