import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:termchat_app/features/settings/bloc/settings/settings_bloc.dart';
import 'package:termchat_app/features/settings/repositories/settings_repository.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late SettingsBloc settingsBloc;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    settingsBloc = SettingsBloc(mockRepository);
  });

  tearDown(() {
    settingsBloc.close();
  });

  group('SettingsBloc', () {
    test('initial state is correct', () {
      expect(settingsBloc.state, const SettingsState());
    });

    group('LoadSettings', () {
      test('loads all settings on success', () async {
        when(
          () => mockRepository.getThemeMode(),
        ).thenAnswer((_) async => 'light');
        when(() => mockRepository.getFontSize()).thenAnswer((_) async => 'lg');
        when(
          () => mockRepository.getMessageNotifications(),
        ).thenAnswer((_) async => false);
        when(
          () => mockRepository.getMentionSound(),
        ).thenAnswer((_) async => true);

        final expected = [
          const SettingsState(isLoading: true),
          const SettingsState(
            themeMode: 'light',
            fontSize: 'lg',
            messageNotificationsEnabled: false,
            mentionSoundEnabled: true,
            isLoading: false,
          ),
        ];

        expectLater(settingsBloc.stream, emitsInOrder(expected));

        settingsBloc.add(LoadSettings());
      });

      test('emits error on repository failure', () async {
        when(
          () => mockRepository.getThemeMode(),
        ).thenThrow(Exception('Load failed'));

        final expected = [
          const SettingsState(isLoading: true),
          isA<SettingsState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.error, 'error', 'Exception: Load failed'),
        ];

        expectLater(settingsBloc.stream, emitsInOrder(expected));

        settingsBloc.add(LoadSettings());
      });
    });

    group('UpdateThemeMode', () {
      test('updates theme mode on success', () async {
        when(
          () => mockRepository.setThemeMode('light'),
        ).thenAnswer((_) async {});

        final expected = [
          isA<SettingsState>().having((s) => s.themeMode, 'themeMode', 'light'),
        ];

        expectLater(settingsBloc.stream, emitsInOrder(expected));

        settingsBloc.add(const UpdateThemeMode('light'));
      });

      test('emits error on repository failure', () async {
        when(
          () => mockRepository.setThemeMode('light'),
        ).thenThrow(Exception('Save failed'));

        final expected = [
          isA<SettingsState>().having(
            (s) => s.error,
            'error',
            'Exception: Save failed',
          ),
        ];

        expectLater(settingsBloc.stream, emitsInOrder(expected));

        settingsBloc.add(const UpdateThemeMode('light'));
      });
    });

    group('UpdateFontSize', () {
      test('updates font size on success', () async {
        when(() => mockRepository.setFontSize('lg')).thenAnswer((_) async {});

        final expected = [
          isA<SettingsState>().having((s) => s.fontSize, 'fontSize', 'lg'),
        ];

        expectLater(settingsBloc.stream, emitsInOrder(expected));

        settingsBloc.add(const UpdateFontSize('lg'));
      });
    });

    group('ToggleMessageNotifications', () {
      test('disables notifications', () async {
        when(
          () => mockRepository.setMessageNotifications(false),
        ).thenAnswer((_) async {});

        final expected = [
          isA<SettingsState>().having(
            (s) => s.messageNotificationsEnabled,
            'enabled',
            false,
          ),
        ];

        expectLater(settingsBloc.stream, emitsInOrder(expected));

        settingsBloc.add(const ToggleMessageNotifications(false));
      });
    });

    group('ToggleMentionSound', () {
      test('disables mention sound', () async {
        when(
          () => mockRepository.setMentionSound(false),
        ).thenAnswer((_) async {});

        final expected = [
          isA<SettingsState>().having(
            (s) => s.mentionSoundEnabled,
            'enabled',
            false,
          ),
        ];

        expectLater(settingsBloc.stream, emitsInOrder(expected));

        settingsBloc.add(const ToggleMentionSound(false));
      });
    });
  });
}
