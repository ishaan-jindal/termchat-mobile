import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:termchat_app/core/models/room.dart';
import 'package:termchat_app/features/rooms/bloc/rooms_bloc.dart';
import 'package:termchat_app/features/rooms/repositories/room_repository.dart';

class MockRoomRepository extends Mock implements RoomRepository {}

void main() {
  late RoomsBloc roomsBloc;
  late MockRoomRepository mockRepository;

  setUp(() {
    mockRepository = MockRoomRepository();
    roomsBloc = RoomsBloc(mockRepository);
  });

  tearDown(() {
    roomsBloc.close();
  });

  group('RoomsBloc', () {
    test('initial state is correct', () {
      expect(roomsBloc.state, const RoomsState());
    });

    group('LoadActiveSessions', () {
      final sessions = [
        Room(id: 'r1', name: 'Room 1'),
        Room(id: 'r2', name: 'Room 2'),
      ];

      test('emits loading then loaded on success', () async {
        when(
          () => mockRepository.getActiveSessions(),
        ).thenAnswer((_) async => sessions);

        final expected = [
          const RoomsState(isLoading: true),
          RoomsState(activeSessions: sessions, isLoading: false),
        ];

        expectLater(roomsBloc.stream, emitsInOrder(expected));

        roomsBloc.add(LoadActiveSessions());
      });

      test('emits loading then error on failure', () async {
        when(
          () => mockRepository.getActiveSessions(),
        ).thenThrow(Exception('Network error'));

        final expected = [
          const RoomsState(isLoading: true),
          const RoomsState(isLoading: false, error: 'Exception: Network error'),
        ];

        expectLater(roomsBloc.stream, emitsInOrder(expected));

        roomsBloc.add(LoadActiveSessions());
      });
    });
  });
}
