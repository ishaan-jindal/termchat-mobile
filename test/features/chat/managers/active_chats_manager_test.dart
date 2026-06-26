import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:termchat_app/core/models/room_session.dart';
import 'package:termchat_app/data/cache/room_session_cache.dart';
import 'package:termchat_app/features/chat/bloc/chat_bloc.dart';
import 'package:termchat_app/features/chat/managers/active_chats_manager.dart';
import 'package:termchat_app/features/chat/repositories/chat_repository.dart';
import 'package:termchat_app/features/settings/bloc/identity/identity_bloc.dart'
    as identity;
import 'package:termchat_app/features/settings/bloc/settings/settings_bloc.dart';

ChatBloc createTestChatBloc() {
  final repo = MockChatRepository();
  final identity = MockIdentityBloc();
  final settings = MockSettingsBloc();
  final sessionCache = MockRoomSessionCache();

  when(() => repo.messages).thenAnswer((_) => const Stream.empty());
  when(() => repo.batchMessages).thenAnswer((_) => const Stream.empty());
  when(() => repo.users).thenAnswer((_) => const Stream.empty());
  when(() => repo.connectionStatus).thenAnswer((_) => const Stream.empty());
  when(() => repo.disconnect()).thenAnswer((_) async {});
  when(() => repo.dispose()).thenAnswer((_) {});

  return ChatBloc(repo, identity, settings, sessionCache);
}

class MockChatBloc extends Mock implements ChatBloc {}

class MockChatRepository extends Mock implements ChatRepository {}

class MockIdentityBloc extends Mock implements identity.IdentityBloc {}

class MockSettingsBloc extends Mock implements SettingsBloc {}

class MockRoomSessionCache extends Mock implements RoomSessionCache {}

void main() {
  late ActiveChatsManager manager;
  late MockRoomSessionCache mockSessionCache;

  setUpAll(() {
    registerFallbackValue(
      RoomSession(roomId: '', roomName: '', lastAccessedAt: 0, createdAt: 0),
    );
  });

  setUp(() {
    mockSessionCache = MockRoomSessionCache();
    when(() => mockSessionCache.save(any())).thenAnswer((_) async {});
    when(() => mockSessionCache.delete(any())).thenAnswer((_) async {});
    GetIt.instance.registerFactory<ChatBloc>(createTestChatBloc);
    manager = ActiveChatsManager(mockSessionCache);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  group('ActiveChatsManager', () {
    test('starts with no active rooms', () {
      expect(manager.activeRooms, isEmpty);
    });

    group('getOrCreate', () {
      test('creates a new ChatBloc for unknown room', () {
        final bloc = manager.getOrCreate('room1');
        expect(bloc, isA<ChatBloc>());
      });

      test('returns existing ChatBloc for known room', () {
        final first = manager.getOrCreate('room1');
        final second = manager.getOrCreate('room1');

        expect(second, same(first));
      });

      test('updates activeRooms after creation', () {
        manager.getOrCreate('room1');
        expect(manager.activeRooms, ['room1']);
      });

      test('tracks multiple rooms', () {
        manager.getOrCreate('room1');
        manager.getOrCreate('room2');
        manager.getOrCreate('room3');

        expect(manager.activeRooms, hasLength(3));
        expect(manager.activeRooms, containsAll(['room1', 'room2', 'room3']));
      });
    });

    group('get', () {
      test('returns null for unknown room', () {
        expect(manager.get('room1'), isNull);
      });

      test('returns ChatBloc for known room', () {
        final created = manager.getOrCreate('room1');
        final retrieved = manager.get('room1');

        expect(retrieved, same(created));
      });
    });

    group('remove', () {
      test('removes room and disconnects', () {
        manager.getOrCreate('room1');

        manager.remove('room1');

        expect(manager.activeRooms, isEmpty);
      });

      test('does nothing for unknown room', () {
        manager.remove('unknown');
        expect(manager.activeRooms, isEmpty);
      });
    });

    group('activeRoomsListenable', () {
      test('notifies listeners on changes', () {
        final values = <List<String>>[];
        manager.activeRoomsListenable.addListener(() {
          values.add(List.from(manager.activeRoomsListenable.value));
        });

        manager.getOrCreate('room1');
        manager.getOrCreate('room2');

        expect(values, [
          ['room1'],
          ['room1', 'room2'],
        ]);
      });
    });
  });
}
