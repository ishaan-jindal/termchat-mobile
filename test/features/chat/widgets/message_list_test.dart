import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:termchat_app/core/models/message.dart';
import 'package:termchat_app/core/models/user.dart';
import 'package:termchat_app/features/chat/bloc/chat_bloc.dart';
import 'package:termchat_app/features/chat/repositories/chat_repository.dart';
import 'package:termchat_app/features/chat/widgets/message_list.dart';
import 'package:termchat_app/features/settings/bloc/identity/identity_bloc.dart'
    as identity;
import 'package:termchat_app/features/settings/bloc/settings/settings_bloc.dart';

class MockChatRepository extends Mock implements ChatRepository {}

class MockIdentityBloc extends Mock implements identity.IdentityBloc {}

class MockSettingsBloc extends Mock implements SettingsBloc {}

Message testMessage({
  String id = '1',
  String nick = 'Bob',
  String content = 'hello',
  bool system = false,
}) {
  return Message(
    id: id,
    roomId: 'ROOM',
    senderId: nick,
    senderNickname: nick,
    senderColorHex: '#FF0000',
    content: content,
    timestamp: DateTime(2026, 9, 9),
    isSystemMessage: system,
  );
}

void main() {
  late MockChatRepository repo;
  late MockIdentityBloc identityBloc;
  late MockSettingsBloc settingsBloc;
  late ChatBloc chatBloc;

  setUp(() {
    repo = MockChatRepository();
    identityBloc = MockIdentityBloc();
    settingsBloc = MockSettingsBloc();

    when(() => repo.messages).thenAnswer((_) => const Stream.empty());
    when(() => repo.users).thenAnswer((_) => const Stream.empty());
    when(() => repo.connectionStatus).thenAnswer((_) => const Stream.empty());
    when(() => repo.reactionUpdates).thenAnswer((_) => const Stream.empty());
    when(() => repo.voiceActive).thenAnswer((_) => const Stream.empty());
    when(() => repo.voiceErrors).thenAnswer((_) => const Stream.empty());
    when(() => repo.disconnect()).thenAnswer((_) async {});
    when(() => repo.dispose()).thenAnswer((_) {});

    when(() => identityBloc.state).thenReturn(
      const identity.IdentityLoaded(
        User(id: 'u1', nickname: 'Alice', colorHex: '#00FF00'),
      ),
    );
    when(() => identityBloc.stream).thenAnswer((_) => const Stream.empty());

    chatBloc = ChatBloc(repo, identityBloc, settingsBloc);
  });

  tearDown(() async {
    await chatBloc.close();
  });

  Future<void> pumpList(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<ChatBloc>.value(value: chatBloc),
            BlocProvider<identity.IdentityBloc>.value(value: identityBloc),
          ],
          child: const Scaffold(body: MessageList()),
        ),
      ),
    );
    await tester.pump();
  }

  group('MessageList', () {
    testWidgets('shows connecting hint when empty and offline', (tester) async {
      await pumpList(tester);

      expect(find.text('Connecting...'), findsOneWidget);
    });

    testWidgets('shows empty hint when connected with no messages', (
      tester,
    ) async {
      await pumpList(tester);
      chatBloc.emit(const ChatState(isConnected: true));
      await tester.pumpAndSettle();

      expect(find.text('No messages yet.'), findsOneWidget);
    });

    testWidgets('renders chat and system messages', (tester) async {
      await pumpList(tester);
      chatBloc.emit(
        ChatState(
          isConnected: true,
          messages: [
            testMessage(),
            testMessage(id: '2', content: 'bye', system: true),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('hello'), findsOneWidget);
      expect(find.text('· bye ·'), findsOneWidget);
    });

    testWidgets('numeric ids allow reacting, synthesized ids do not', (
      tester,
    ) async {
      await pumpList(tester);
      chatBloc.emit(
        ChatState(
          isConnected: true,
          messages: [
            testMessage(id: '123'),
            testMessage(id: '1_Bob'),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Both bubbles render; only the numeric one wires long-press react.
      expect(find.text('hello'), findsNWidgets(2));
    });
  });
}
