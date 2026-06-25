import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:termchat_app/core/models/user.dart';
import 'package:termchat_app/features/settings/bloc/identity/identity_bloc.dart';
import 'package:termchat_app/features/settings/repositories/identity_repository.dart';

class MockIdentityRepository extends Mock implements IdentityRepository {}

void main() {
  late IdentityBloc identityBloc;
  late MockIdentityRepository mockRepository;

  setUp(() {
    mockRepository = MockIdentityRepository();
    identityBloc = IdentityBloc(mockRepository);
  });

  tearDown(() {
    identityBloc.close();
  });

  group('IdentityBloc', () {
    test('initial state is IdentityInitial', () {
      expect(identityBloc.state, isA<IdentityInitial>());
    });

    group('LoadIdentity', () {
      test('emits loading then loaded on success', () async {
        final user = User(id: 'u1', nickname: 'Alice', colorHex: '#FF0000');
        when(
          () => mockRepository.getCurrentUser(),
        ).thenAnswer((_) async => user);

        final expected = [
          isA<IdentityLoading>(),
          isA<IdentityLoaded>().having((s) => s.user, 'user', user),
        ];

        expectLater(identityBloc.stream, emitsInOrder(expected));

        identityBloc.add(LoadIdentity());
      });

      test('emits loading then error on failure', () async {
        when(
          () => mockRepository.getCurrentUser(),
        ).thenThrow(Exception('Failed to load'));

        final expected = [
          isA<IdentityLoading>(),
          isA<IdentityError>().having(
            (s) => s.message,
            'message',
            'Exception: Failed to load',
          ),
        ];

        expectLater(identityBloc.stream, emitsInOrder(expected));

        identityBloc.add(LoadIdentity());
      });
    });

    group('UpdateNickname', () {
      test('updates nickname when state is IdentityLoaded', () async {
        final user = User(id: 'u1', nickname: 'Alice', colorHex: '#FF0000');
        when(
          () => mockRepository.getCurrentUser(),
        ).thenAnswer((_) async => user);

        identityBloc.emit(IdentityLoaded(user));

        when(
          () => mockRepository.updateNickname('Bob'),
        ).thenAnswer((_) async {});

        final expected = [
          isA<IdentityLoaded>().having(
            (s) => s.user.nickname,
            'nickname',
            'Bob',
          ),
        ];

        expectLater(identityBloc.stream, emitsInOrder(expected));

        identityBloc.add(const UpdateNickname('Bob'));
      });

      test('does nothing when state is not IdentityLoaded', () async {
        identityBloc.add(const UpdateNickname('Bob'));

        // No event should be emitted
        expect(identityBloc.state, isA<IdentityInitial>());
      });

      test('emits error on repository failure', () async {
        final user = User(id: 'u1', nickname: 'Alice', colorHex: '#FF0000');
        identityBloc.emit(IdentityLoaded(user));

        when(
          () => mockRepository.updateNickname('Bob'),
        ).thenThrow(Exception('Save failed'));

        final expected = [
          isA<IdentityError>().having(
            (s) => s.message,
            'message',
            'Exception: Save failed',
          ),
        ];

        expectLater(identityBloc.stream, emitsInOrder(expected));

        identityBloc.add(const UpdateNickname('Bob'));
      });
    });

    group('UpdateColor', () {
      test('updates color when state is IdentityLoaded', () async {
        final user = User(id: 'u1', nickname: 'Alice', colorHex: '#FF0000');
        identityBloc.emit(IdentityLoaded(user));

        when(
          () => mockRepository.updateColor('#00FF00'),
        ).thenAnswer((_) async {});

        final expected = [
          isA<IdentityLoaded>().having(
            (s) => s.user.colorHex,
            'colorHex',
            '#00FF00',
          ),
        ];

        expectLater(identityBloc.stream, emitsInOrder(expected));

        identityBloc.add(const UpdateColor('#00FF00'));
      });

      test('does nothing when state is not IdentityLoaded', () async {
        identityBloc.add(const UpdateColor('#00FF00'));

        expect(identityBloc.state, isA<IdentityInitial>());
      });

      test('emits error on repository failure', () async {
        final user = User(id: 'u1', nickname: 'Alice', colorHex: '#FF0000');
        identityBloc.emit(IdentityLoaded(user));

        when(
          () => mockRepository.updateColor('#00FF00'),
        ).thenThrow(Exception('Save failed'));

        final expected = [
          isA<IdentityError>().having(
            (s) => s.message,
            'message',
            'Exception: Save failed',
          ),
        ];

        expectLater(identityBloc.stream, emitsInOrder(expected));

        identityBloc.add(const UpdateColor('#00FF00'));
      });
    });
  });
}
