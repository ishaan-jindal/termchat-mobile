import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:termchat_app/data/api_exceptions.dart';
import 'package:termchat_app/features/rooms/repositories/room_repository.dart';

void main() {
  group('RoomRepositoryImpl', () {
    late MockClient client;
    late RoomRepositoryImpl repository;

    setUp(() {
      client = MockClient((_) async => http.Response('[]', 200));
      repository = RoomRepositoryImpl(client);
    });

    test('returns empty list on empty body', () async {
      expect(await repository.getActiveSessions(), isEmpty);
    });

    test('parses valid rooms', () async {
      client = MockClient(
        (_) async => http.Response(
          jsonEncode([
            {'id': 'r1', 'user_count': 3, 'has_password': true},
            {'id': 'r2', 'user_count': 1, 'has_password': false},
          ]),
          200,
        ),
      );
      repository = RoomRepositoryImpl(client);

      final rooms = await repository.getActiveSessions();

      expect(rooms, hasLength(2));
      expect(rooms[0].id, 'r1');
      expect(rooms[0].name, 'r1');
      expect(rooms[0].usersCount, 3);
      expect(rooms[0].isLocked, isTrue);
      expect(rooms[1].isLocked, isFalse);
    });

    test('skips malformed rooms instead of failing whole list', () async {
      client = MockClient(
        (_) async => http.Response(
          jsonEncode([
            {'id': 'r1', 'user_count': 2},
            'not-a-map',
            {'user_count': 2},
            {'id': 'r2', 'user_count': 5},
          ]),
          200,
        ),
      );
      repository = RoomRepositoryImpl(client);

      final rooms = await repository.getActiveSessions();

      expect(rooms, hasLength(2));
      expect(rooms[0].id, 'r1');
      expect(rooms[1].id, 'r2');
    });

    test('throws ApiServerException on non-200', () async {
      client = MockClient((_) async => http.Response('oops', 500));
      repository = RoomRepositoryImpl(client);

      expect(
        () => repository.getActiveSessions(),
        throwsA(isA<ApiServerException>()),
      );
    });

    test('throws ApiParseException on malformed JSON', () async {
      client = MockClient((_) async => http.Response('not json', 200));
      repository = RoomRepositoryImpl(client);

      expect(
        () => repository.getActiveSessions(),
        throwsA(isA<ApiParseException>()),
      );
    });

    test('throws ApiParseException on unexpected shape', () async {
      client = MockClient((_) async => http.Response('{"foo":1}', 200));
      repository = RoomRepositoryImpl(client);

      expect(
        () => repository.getActiveSessions(),
        throwsA(isA<ApiParseException>()),
      );
    });

    test('accepts a rooms envelope', () async {
      client = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'rooms': [
              {'id': 'r1', 'user_count': 2},
            ],
          }),
          200,
        ),
      );
      repository = RoomRepositoryImpl(client);

      final rooms = await repository.getActiveSessions();

      expect(rooms, hasLength(1));
      expect(rooms[0].id, 'r1');
    });

    test('caps huge discover lists', () async {
      client = MockClient(
        (_) async => http.Response(
          jsonEncode(List.generate(600, (i) => {'id': 'r$i'})),
          200,
        ),
      );
      repository = RoomRepositoryImpl(client);

      final rooms = await repository.getActiveSessions();

      expect(rooms, hasLength(500));
    });

    test('server error carries a truncated body snippet', () async {
      client = MockClient((_) async => http.Response('oops', 500));
      repository = RoomRepositoryImpl(client);

      Object? error;
      try {
        await repository.getActiveSessions();
        fail('expected ApiServerException');
      } catch (e) {
        error = e;
      }

      expect(error, isA<ApiServerException>());
      expect(error.toString(), contains('500'));
      expect(error.toString(), contains('oops'));
    });

    test('throws ApiNetworkException on transport failure', () async {
      client = MockClient(
        (_) async => throw http.ClientException('connection refused'),
      );
      repository = RoomRepositoryImpl(client);

      expect(
        () => repository.getActiveSessions(),
        throwsA(isA<ApiNetworkException>()),
      );
    });
  });
}
