import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:termchat_app/core/models/user.dart';
import 'package:termchat_app/features/chat/bloc/chat_bloc.dart';
import 'package:termchat_app/features/chat/managers/active_chats_manager.dart';
import 'package:termchat_app/features/chat/pages/chat_page.dart';
import 'package:termchat_app/features/settings/bloc/identity/identity_bloc.dart'
    as identity;

class MockChatBloc extends Mock implements ChatBloc {}

class MockIdentityBloc extends Mock implements identity.IdentityBloc {}

class MockActiveChatsManager extends Mock implements ActiveChatsManager {}

void main() {
  late MockChatBloc chatBloc;
  late MockIdentityBloc identityBloc;
  late MockActiveChatsManager manager;
  late GoRouter router;

  setUp(() {
    chatBloc = MockChatBloc();
    identityBloc = MockIdentityBloc();
    manager = MockActiveChatsManager();

    when(() => chatBloc.state)
        .thenReturn(const ChatState(roomCode: 'ABCD', isConnected: true));
    when(() => chatBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => identityBloc.state).thenReturn(
      const identity.IdentityLoaded(
        User(id: 'u1', nickname: 'Alice', colorHex: '#FF0000'),
      ),
    );
    when(() => identityBloc.stream).thenAnswer((_) => const Stream.empty());

    router = GoRouter(
      initialLocation: '/chat/ABCD',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Scaffold()),
        GoRoute(path: '/chat/:roomId', builder: (_, _) => const ChatPage()),
      ],
    );
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ChatBloc>.value(value: chatBloc),
          BlocProvider<identity.IdentityBloc>.value(value: identityBloc),
          RepositoryProvider<ActiveChatsManager>.value(value: manager),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('ChatPage', () {
    testWidgets('/quit leaves the room and navigates home', (tester) async {
      await pumpPage(tester);
      expect(find.byType(ChatPage), findsOneWidget);

      await tester.enterText(find.byType(TextField), '/quit');
      await tester.tap(find.text('send'));
      await tester.pumpAndSettle();

      verify(() => manager.remove('ABCD')).called(1);
      expect(router.state.uri.path, '/');
      expect(tester.takeException(), isNull);
    });
  });
}
