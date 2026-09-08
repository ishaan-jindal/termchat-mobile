import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:termchat_app/core/models/message.dart';
import 'package:termchat_app/core/models/user.dart';
import 'package:termchat_app/core/utils/room_join_helper.dart';
import 'package:termchat_app/data/models/backend_user_info.dart';
import 'package:termchat_app/features/chat/bloc/chat_bloc.dart';
import 'package:termchat_app/features/chat/managers/active_chats_manager.dart';
import 'package:termchat_app/features/chat/models/reaction_update.dart';
import 'package:termchat_app/features/chat/repositories/chat_repository.dart';
import 'package:termchat_app/features/settings/bloc/identity/identity_bloc.dart'
    as identity;
import 'package:termchat_app/features/settings/bloc/settings/settings_bloc.dart';

class MockChatRepository extends Mock implements ChatRepository {}

class MockIdentityBloc extends Mock implements identity.IdentityBloc {}

class MockSettingsBloc extends Mock implements SettingsBloc {}

ChatBloc createChatBloc(
  MockChatRepository repo,
  MockIdentityBloc identityBloc,
  MockSettingsBloc settingsBloc,
) {
  return ChatBloc(repo, identityBloc, settingsBloc);
}

void main() {
  late MockChatRepository repo;
  late MockIdentityBloc identityBloc;
  late MockSettingsBloc settingsBloc;
  late StreamController<ConnectionStatus> statusController;
  late StreamController<Message> messagesController;
  late StreamController<List<BackendUserInfo>> usersController;
  late StreamController<ReactionUpdate> reactionsController;
  late StreamController<bool> voiceActiveController;
  late StreamController<String> voiceErrorsController;

  late ActiveChatsManager manager;
  late GoRouter router;

  setUp(() {
    repo = MockChatRepository();
    identityBloc = MockIdentityBloc();
    settingsBloc = MockSettingsBloc();

    statusController = StreamController<ConnectionStatus>.broadcast();
    messagesController = StreamController<Message>.broadcast();
    usersController = StreamController<List<BackendUserInfo>>.broadcast();
    reactionsController = StreamController<ReactionUpdate>.broadcast();
    voiceActiveController = StreamController<bool>.broadcast();
    voiceErrorsController = StreamController<String>.broadcast();

    when(() => repo.messages).thenAnswer((_) => messagesController.stream);
    when(() => repo.users).thenAnswer((_) => usersController.stream);
    when(() => repo.connectionStatus)
        .thenAnswer((_) => statusController.stream);
    when(() => repo.reactionUpdates)
        .thenAnswer((_) => reactionsController.stream);
    when(() => repo.voiceActive)
        .thenAnswer((_) => voiceActiveController.stream);
    when(() => repo.voiceErrors)
        .thenAnswer((_) => voiceErrorsController.stream);
    when(() => repo.disconnect()).thenAnswer((_) async {});
    when(() => repo.dispose()).thenAnswer((_) {});

    when(() => identityBloc.state).thenReturn(
      identity.IdentityLoaded(
        const User(id: 'u1', nickname: 'Alice', colorHex: '#FF0000'),
      ),
    );
    when(() => identityBloc.stream).thenAnswer((_) => const Stream.empty());

    manager = ActiveChatsManager(
      () => createChatBloc(repo, identityBloc, settingsBloc),
    );

    router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Scaffold()),
        GoRoute(path: '/chat/:roomId', builder: (_, _) => const Scaffold()),
      ],
    );
  });

  tearDown(() async {
    await statusController.close();
    await messagesController.close();
    await usersController.close();
    await reactionsController.close();
    await voiceActiveController.close();
    await voiceErrorsController.close();
    manager.dispose();
  });

  Future<void> pumpHarness(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<identity.IdentityBloc>.value(value: identityBloc),
          RepositoryProvider<ActiveChatsManager>.value(value: manager),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
  }

  group('RoomJoinHelper.joinRoom', () {
    testWidgets('joins an unlocked room and navigates on connect', (
      tester,
    ) async {
      await pumpHarness(tester);

      when(() => repo.connect(any(), any(), password: any(named: 'password')))
          .thenAnswer((_) async {
            statusController.add(ConnectionStatus.connected);
          });

      final context = tester.element(find.byType(Scaffold).first);
      final future = RoomJoinHelper.joinRoom(context, 'ABCD', false);

      await tester.pump();
      await tester.pump();

      expect(await future, isTrue);
      expect(router.state.uri.path, '/chat/ABCD');
      expect(manager.activeRooms, ['ABCD']);
    });

    testWidgets('prompts for password on a locked room then joins', (
      tester,
    ) async {
      await pumpHarness(tester);

      when(() => repo.connect('LOCK', any(), password: any(named: 'password')))
          .thenAnswer((_) async {
            statusController.add(ConnectionStatus.connected);
          });

      final context = tester.element(find.byType(Scaffold).first);
      final future = RoomJoinHelper.joinRoom(context, 'LOCK', true);

      await tester.pumpAndSettle();

      expect(find.text('room is locked'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'secret');
      await tester.tap(find.text('join room'));
      await tester.pumpAndSettle();

      expect(await future, isTrue);
      expect(router.state.uri.path, '/chat/LOCK');
      verify(() => repo.connect('LOCK', 'Alice', password: 'secret')).called(1);
    });

    testWidgets('shows wrong-password snackbar on invalid_password', (
      tester,
    ) async {
      await pumpHarness(tester);

      when(() => repo.connect('BADP', any(), password: any(named: 'password')))
          .thenAnswer((_) {
            messagesController.addError('invalid_password');
            // Real repo: the connection aborts and never reaches connected.
            return Completer<void>().future;
          });

      final context = tester.element(find.byType(Scaffold).first);
      final future = RoomJoinHelper.joinRoom(context, 'BADP', false);

      await tester.pump();
      await tester.pump();

      expect(await future, isFalse);
      expect(find.text('Wrong password'), findsOneWidget);
      expect(router.state.uri.path, '/');
    });

    testWidgets('re-navigates without reconnecting when already joined', (
      tester,
    ) async {
      await pumpHarness(tester);

      when(() => repo.connect(any(), any(), password: any(named: 'password')))
          .thenAnswer((_) async {
            statusController.add(ConnectionStatus.connected);
          });

      final context = tester.element(find.byType(Scaffold).first);

      final first = await RoomJoinHelper.joinRoom(context, 'ABCD', false);
      expect(first, isTrue);

      final second = await RoomJoinHelper.joinRoom(context, 'ABCD', false);
      expect(second, isTrue);

      verify(
        () => repo.connect('ABCD', 'Alice', password: any(named: 'password')),
      ).called(1);
    });
  });
}
