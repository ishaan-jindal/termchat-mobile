import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:termchat_app/core/models/message.dart';
import 'package:termchat_app/core/models/room_session.dart';
import 'package:termchat_app/data/cache/room_session_cache.dart';
import 'package:termchat_app/data/models/backend_user_info.dart';
import 'package:termchat_app/features/chat/bloc/chat_bloc.dart';
import 'package:termchat_app/features/chat/repositories/chat_repository.dart';
import 'package:termchat_app/features/settings/bloc/identity/identity_bloc.dart'
    as identity;
import 'package:termchat_app/features/settings/bloc/settings/settings_bloc.dart';

class MockChatRepository extends Mock implements ChatRepository {}

class MockIdentityBloc extends Mock implements identity.IdentityBloc {}

class MockSettingsBloc extends Mock implements SettingsBloc {}

class MockRoomSessionCache extends Mock implements RoomSessionCache {}

void main() {
  late ChatBloc chatBloc;
  late MockChatRepository mockRepo;
  late MockIdentityBloc mockIdentity;
  late MockSettingsBloc mockSettings;
  late MockRoomSessionCache mockSessionCache;

  late StreamController<Message> messagesController;
  late StreamController<List<Message>> batchController;
  late StreamController<List<BackendUserInfo>> usersController;
  late StreamController<ConnectionStatus> connectionStatusController;

  setUpAll(() {
    registerFallbackValue(
      RoomSession(roomId: '', roomName: '', lastAccessedAt: 0, createdAt: 0),
    );
  });

  setUp(() {
    mockRepo = MockChatRepository();
    mockIdentity = MockIdentityBloc();
    mockSettings = MockSettingsBloc();
    mockSessionCache = MockRoomSessionCache();

    when(() => mockIdentity.state).thenReturn(identity.IdentityInitial());
    when(() => mockSettings.state).thenReturn(const SettingsState());

    messagesController = StreamController<Message>.broadcast();
    batchController = StreamController<List<Message>>.broadcast();
    usersController = StreamController<List<BackendUserInfo>>.broadcast();
    connectionStatusController = StreamController<ConnectionStatus>.broadcast();

    when(() => mockRepo.messages).thenAnswer((_) => messagesController.stream);
    when(
      () => mockRepo.batchMessages,
    ).thenAnswer((_) => batchController.stream);
    when(() => mockRepo.users).thenAnswer((_) => usersController.stream);
    when(
      () => mockRepo.connectionStatus,
    ).thenAnswer((_) => connectionStatusController.stream);
    when(() => mockRepo.disconnect()).thenAnswer((_) async {});
    when(() => mockRepo.dispose()).thenAnswer((_) {});
    when(() => mockRepo.emitCachedMessages(any())).thenAnswer((_) async {});
    when(
      () => mockSessionCache.incrementUnread(any()),
    ).thenAnswer((_) async {});
    when(() => mockSessionCache.save(any())).thenAnswer((_) async {});

    chatBloc = ChatBloc(mockRepo, mockIdentity, mockSettings, mockSessionCache);
  });

  tearDown(() async {
    await chatBloc.close();
    await messagesController.close();
    await batchController.close();
    await usersController.close();
    await connectionStatusController.close();
  });

  /// Helper: triggers the connect flow so stream subscriptions are active.
  Future<void> connectToRoom() async {
    when(
      () =>
          mockRepo.connect('room1', 'Alice', password: any(named: 'password')),
    ).thenAnswer((_) async {});

    chatBloc.add(
      const ConnectChat(roomCode: 'room1', nick: 'Alice', colorHex: ''),
    );
    // Wait for the async handler to complete and emit the connected state.
    await Future(() {});
    await Future(() {});
  }

  group('ChatBloc', () {
    test('initial state is correct', () {
      expect(chatBloc.state, const ChatState());
    });

    group('ConnectChat', () {
      test('connects successfully', () async {
        when(
          () => mockRepo.connect(
            'room1',
            'Alice',
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async {});

        chatBloc.add(
          const ConnectChat(roomCode: 'room1', nick: 'Alice', colorHex: ''),
        );

        // Wait for async connect handler to complete
        await Future(() {});
        await Future(() {});

        expect(chatBloc.state.isConnected, isTrue);
        expect(chatBloc.state.isLoading, isFalse);
        expect(chatBloc.state.roomCode, 'room1');
      });

      test('emits error on connection failure', () async {
        when(
          () => mockRepo.connect(
            'room1',
            'Alice',
            password: any(named: 'password'),
          ),
        ).thenThrow(Exception('Connection failed'));

        chatBloc.add(
          const ConnectChat(roomCode: 'room1', nick: 'Alice', colorHex: ''),
        );

        await Future(() {});
        await Future(() {});

        expect(chatBloc.state.error, 'Exception: Connection failed');
        expect(chatBloc.state.isLoading, isFalse);
      });

      test('sends color command when colorHex is provided', () async {
        when(
          () => mockRepo.connect(
            'room1',
            'Alice',
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async {});
        when(() => mockRepo.updateColor('#FF0000')).thenAnswer((_) async {});

        chatBloc.add(
          const ConnectChat(
            roomCode: 'room1',
            nick: 'Alice',
            colorHex: '#FF0000',
          ),
        );

        await Future(() {});
        await Future(() {});

        verify(() => mockRepo.updateColor('#FF0000')).called(1);
      });
    });

    group('SendMessage', () {
      test('sends regular messages', () async {
        when(() => mockRepo.sendMessage('Hello')).thenAnswer((_) async {});

        chatBloc.add(const SendMessage('Hello'));

        await Future(() {});
        verify(() => mockRepo.sendMessage('Hello')).called(1);
      });

      test('handles /nick command', () async {
        when(() => mockRepo.updateNickname('NewName')).thenAnswer((_) async {});

        chatBloc.add(const SendMessage('/nick NewName'));

        await Future(() {});
        verify(() => mockRepo.updateNickname('NewName')).called(1);
      });

      test('handles /color command', () async {
        when(() => mockRepo.updateColor('#FF0000')).thenAnswer((_) async {});

        chatBloc.add(const SendMessage('/color #FF0000'));

        await Future(() {});
        verify(() => mockRepo.updateColor('#FF0000')).called(1);
      });

      test('handles /password command', () async {
        when(() => mockRepo.setPassword('secret')).thenAnswer((_) async {});

        chatBloc.add(const SendMessage('/password secret'));

        await Future(() {});
        verify(() => mockRepo.setPassword('secret')).called(1);
      });

      test('handles /password command with no password', () async {
        when(() => mockRepo.setPassword('')).thenAnswer((_) async {});

        chatBloc.add(const SendMessage('/password'));

        await Future(() {});
        verify(() => mockRepo.setPassword('')).called(1);
      });

      test('handles /help command', () async {
        chatBloc.add(const SendMessage('/help'));

        await Future(() {});

        expect(chatBloc.state.messages, hasLength(1));
        expect(chatBloc.state.messages.first.content, startsWith('Commands:'));
      });

      test('handles /clear command', () async {
        final existingMsg = Message(
          id: 'm1',
          roomId: 'r1',
          senderId: 'u1',
          senderNickname: 'A',
          senderColorHex: '#000',
          content: 'test',
          timestamp: DateTime.now(),
        );
        chatBloc.emit(ChatState(messages: [existingMsg]));

        chatBloc.add(const SendMessage('/clear'));

        await Future(() {});
        expect(chatBloc.state.messages, isEmpty);
      });

      test('handles unknown command as regular message', () async {
        when(
          () => mockRepo.sendMessage('/unknown foo'),
        ).thenAnswer((_) async {});

        chatBloc.add(const SendMessage('/unknown foo'));

        await Future(() {});
        verify(() => mockRepo.sendMessage('/unknown foo')).called(1);
      });
    });

    group('DisconnectChat', () {
      test('disconnects and resets state', () async {
        chatBloc.emit(const ChatState(isConnected: true, roomCode: 'room1'));

        chatBloc.add(DisconnectChat());

        await Future(() {});

        verify(() => mockRepo.disconnect()).called(1);
        expect(chatBloc.state, const ChatState());
      });
    });

    group('stream-based events (after connect)', () {
      setUp(() async {
        await connectToRoom();
      });

      test('message received adds message to state', () async {
        final msg = Message(
          id: 'm1',
          roomId: 'r1',
          senderId: 'u1',
          senderNickname: 'Alice',
          senderColorHex: '#FF0000',
          content: 'Hello',
          timestamp: DateTime.now(),
        );

        messagesController.add(msg);

        await Future(() {});

        expect(chatBloc.state.messages, hasLength(1));
        expect(chatBloc.state.messages.first.id, 'm1');
      });

      test('users updated sets users in state', () async {
        final users = [
          BackendUserInfo(
            nick: 'Alice',
            color: '#FF0000',
            joinedAt: 0,
            typing: false,
            isHost: true,
          ),
        ];

        usersController.add(users);

        await Future(() {});

        expect(chatBloc.state.users, users);
      });

      test('disconnected status updates state', () async {
        connectionStatusController.add(ConnectionStatus.disconnected);

        await Future(() {});

        expect(chatBloc.state.isConnected, isFalse);
        expect(chatBloc.state.connectionStatus, ConnectionStatus.disconnected);
      });

      test('connected status updates state', () async {
        connectionStatusController.add(ConnectionStatus.connected);

        await Future(() {});

        expect(chatBloc.state.isConnected, isTrue);
        expect(chatBloc.state.isLoading, isFalse);
        expect(chatBloc.state.connectionStatus, ConnectionStatus.connected);
      });

      test('connecting status updates state', () async {
        connectionStatusController.add(ConnectionStatus.connecting);

        await Future(() {});

        expect(chatBloc.state.isLoading, isTrue);
        expect(chatBloc.state.connectionStatus, ConnectionStatus.connecting);
      });

      test('stream error sets error and disconnects', () async {
        messagesController.addError('Stream error');

        await Future(() {});

        expect(chatBloc.state.error, 'Stream error');
        expect(chatBloc.state.isConnected, isFalse);
      });
    });
  });
}
