import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:termchat_app/core/models/message.dart';
import 'package:termchat_app/core/models/reaction.dart';
import 'package:termchat_app/data/models/backend_user_info.dart';
import 'package:termchat_app/features/chat/bloc/chat_bloc.dart';
import 'package:termchat_app/features/chat/models/reaction_update.dart';
import 'package:termchat_app/features/chat/repositories/chat_repository.dart';
import 'package:termchat_app/features/settings/bloc/identity/identity_bloc.dart'
    as identity;
import 'package:termchat_app/features/settings/bloc/settings/settings_bloc.dart';

class MockChatRepository extends Mock implements ChatRepository {}

class MockIdentityBloc extends Mock implements identity.IdentityBloc {}

class MockSettingsBloc extends Mock implements SettingsBloc {}

Future<void> waitForState(ChatBloc bloc, bool Function(ChatState) predicate) {
  final completer = Completer<void>();
  late final StreamSubscription<ChatState> sub;
  sub = bloc.stream.listen((s) {
    if (predicate(s)) {
      sub.cancel();
      completer.complete();
    }
  });
  return completer.future;
}

void main() {
  late ChatBloc chatBloc;
  late MockChatRepository mockRepo;
  late MockIdentityBloc mockIdentity;
  late MockSettingsBloc mockSettings;

  late StreamController<Message> messagesController;
  late StreamController<List<BackendUserInfo>> usersController;
  late StreamController<ConnectionStatus> connectionStatusController;
  late StreamController<ReactionUpdate> reactionUpdatesController;
  late StreamController<bool> voiceActiveController;
  late StreamController<String> voiceErrorsController;

  setUp(() {
    mockRepo = MockChatRepository();
    mockIdentity = MockIdentityBloc();
    mockSettings = MockSettingsBloc();

    when(() => mockIdentity.state).thenReturn(identity.IdentityInitial());

    messagesController = StreamController<Message>.broadcast();
    usersController = StreamController<List<BackendUserInfo>>.broadcast();
    connectionStatusController = StreamController<ConnectionStatus>.broadcast();
    reactionUpdatesController = StreamController<ReactionUpdate>.broadcast();
    voiceActiveController = StreamController<bool>.broadcast();
    voiceErrorsController = StreamController<String>.broadcast();

    when(() => mockRepo.messages).thenAnswer((_) => messagesController.stream);
    when(() => mockRepo.users).thenAnswer((_) => usersController.stream);
    when(() => mockRepo.connectionStatus)
        .thenAnswer((_) => connectionStatusController.stream);
    when(() => mockRepo.reactionUpdates)
        .thenAnswer((_) => reactionUpdatesController.stream);
    when(() => mockRepo.voiceActive)
        .thenAnswer((_) => voiceActiveController.stream);
    when(() => mockRepo.voiceErrors)
        .thenAnswer((_) => voiceErrorsController.stream);
    when(() => mockRepo.disconnect()).thenAnswer((_) async {});
    when(() => mockRepo.dispose()).thenAnswer((_) {});

    chatBloc = ChatBloc(mockRepo, mockIdentity, mockSettings);
  });

  tearDown(() async {
    await chatBloc.close();
    await messagesController.close();
    await usersController.close();
    await connectionStatusController.close();
    await reactionUpdatesController.close();
    await voiceActiveController.close();
    await voiceErrorsController.close();
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
        await waitForState(chatBloc, (s) => s.isConnected);

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
        await waitForState(chatBloc, (s) => s.error != null);

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

        await untilCalled(() => mockRepo.updateColor('#FF0000'));

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
        when(() => mockRepo.sendMessage('/unknown foo'))
            .thenAnswer((_) async {});

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

    group('ReplyTarget', () {
      final msg = Message(
        id: 'm1',
        roomId: 'r1',
        senderId: 'u1',
        senderNickname: 'Alice',
        senderColorHex: '#FF0000',
        content: 'Hello',
        timestamp: DateTime.now(),
      );

      test('SetReplyTarget sets replyingTo', () async {
        chatBloc.add(SetReplyTarget(msg));
        await waitForState(chatBloc, (s) => s.replyingTo == msg);
        expect(chatBloc.state.replyingTo, msg);
      });

      test('ClearReplyTarget clears replyingTo', () async {
        chatBloc.add(SetReplyTarget(msg));
        await waitForState(chatBloc, (s) => s.replyingTo == msg);

        chatBloc.add(ClearReplyTarget());
        await waitForState(chatBloc, (s) => s.replyingTo == null);
        expect(chatBloc.state.replyingTo, isNull);
      });

      test('SendMessage with replyToId clears replyingTo', () async {
        when(
          () => mockRepo.sendMessage(any(), replyToId: any(named: 'replyToId')),
        ).thenAnswer((_) async {});

        chatBloc.add(SetReplyTarget(msg));
        await waitForState(chatBloc, (s) => s.replyingTo == msg);

        chatBloc.add(SendMessage('hi', 123));
        await waitForState(chatBloc, (s) => s.replyingTo == null);

        verify(() => mockRepo.sendMessage('hi', replyToId: 123)).called(1);
        expect(chatBloc.state.replyingTo, isNull);
      });
    });

    group('Reactions', () {
      final msg = Message(
        id: 'm1',
        roomId: 'r1',
        senderId: 'u1',
        senderNickname: 'Alice',
        senderColorHex: '#FF0000',
        content: 'Hello',
        timestamp: DateTime.now(),
        reactions: const [Reaction(name: '+1', count: 1)],
      );

      setUp(() async {
        await connectToRoom();
      });

      test('toggles myReactions on add then remove', () async {
        when(() => mockRepo.sendReaction(any(), any()))
            .thenAnswer((_) async {});

        chatBloc.add(SendReaction(123, '+1'));
        await waitForState(chatBloc, (s) => s.myReactions.contains('123:+1'));

        chatBloc.add(SendReaction(123, '+1'));
        await waitForState(chatBloc, (s) => !s.myReactions.contains('123:+1'));

        expect(chatBloc.state.myReactions.contains('123:+1'), isFalse);
      });

      test('empty reaction update clears message reactions', () async {
        chatBloc.emit(ChatState(messages: [msg]));

        final cleared = waitForState(
          chatBloc,
          (s) => s.messages.isNotEmpty && s.messages.first.reactions.isEmpty,
        );
        reactionUpdatesController.add(
          ReactionUpdate(messageId: 'm1', reactions: []),
        );
        await cleared;

        expect(chatBloc.state.messages.first.reactions, isEmpty);
      });
    });

    group('Voice', () {
      setUp(() async {
        await connectToRoom();
      });

      test('StartVoice joins the voice session', () async {
        when(() => mockRepo.joinVoice()).thenAnswer((_) async {});

        chatBloc.add(StartVoice());

        await untilCalled(() => mockRepo.joinVoice());
        verify(() => mockRepo.joinVoice()).called(1);
      });

      test('StartVoice surfaces errors into voiceError', () async {
        when(() => mockRepo.joinVoice()).thenThrow(Exception('no mic'));

        chatBloc.add(StartVoice());
        await waitForState(chatBloc, (s) => s.voiceError != null);

        expect(chatBloc.state.voiceError, 'Exception: no mic');
      });

      test('StopVoice leaves the voice session', () async {
        when(() => mockRepo.leaveVoice()).thenAnswer((_) async {});

        chatBloc.add(StopVoice());

        await untilCalled(() => mockRepo.leaveVoice());
        verify(() => mockRepo.leaveVoice()).called(1);
      });

      test('SetVoiceTransmit toggles transmitting state', () async {
        when(() => mockRepo.setVoiceTransmit(true)).thenAnswer((_) async {});

        chatBloc.add(const SetVoiceTransmit(true));

        await waitForState(chatBloc, (s) => s.isVoiceTransmitting);
        verify(() => mockRepo.setVoiceTransmit(true)).called(1);
      });

      test('voiceActive stream mirrors into state', () async {
        voiceActiveController.add(true);
        await waitForState(chatBloc, (s) => s.isVoiceActive);

        voiceActiveController.add(false);
        await waitForState(chatBloc, (s) => !s.isVoiceActive);

        expect(chatBloc.state.isVoiceTransmitting, isFalse);
      });

      test('voiceErrors stream surfaces as voiceError', () async {
        voiceErrorsController.add('voice dropped');
        await waitForState(chatBloc, (s) => s.voiceError == 'voice dropped');
      });
    });
  });
}
