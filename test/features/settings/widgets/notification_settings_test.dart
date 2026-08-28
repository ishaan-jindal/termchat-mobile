import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:termchat_app/features/settings/bloc/settings/settings_bloc.dart';
import 'package:termchat_app/features/settings/repositories/settings_repository.dart';
import 'package:termchat_app/features/settings/widgets/notification_settings.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

class FakePermissionHandlerPlatform extends PermissionHandlerPlatform {
  PermissionStatus status;
  PermissionStatus? requestResult;
  final List<Permission> requested = [];
  bool openAppSettingsCalled = false;

  FakePermissionHandlerPlatform(this.status);

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    return status;
  }

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) async {
    requested.addAll(permissions);

    return {
      for (final permission in permissions) permission: requestResult ?? status,
    };
  }

  @override
  Future<bool> openAppSettings() async {
    openAppSettingsCalled = true;

    return true;
  }

  @override
  Future<bool> shouldShowRequestPermissionRationale(
    Permission permission,
  ) async {
    return false;
  }
}

void main() {
  late SettingsBloc settingsBloc;
  late MockSettingsRepository mockRepository;
  late FakePermissionHandlerPlatform fakePermissions;
  late PermissionHandlerPlatform originalInstance;

  setUp(() {
    originalInstance = PermissionHandlerPlatform.instance;
    mockRepository = MockSettingsRepository();
    settingsBloc = SettingsBloc(mockRepository);

    when(() => mockRepository.setMessageNotifications(any()))
        .thenAnswer((_) async {});
    when(() => mockRepository.setMentionSound(any())).thenAnswer((_) async {});

    fakePermissions = FakePermissionHandlerPlatform(PermissionStatus.granted);
    PermissionHandlerPlatform.instance = fakePermissions;
  });

  tearDown(() {
    settingsBloc.close();
    PermissionHandlerPlatform.instance = originalInstance;
  });

  Widget buildWidget() {
    return MaterialApp(
      home: BlocProvider.value(
        value: settingsBloc,
        child: const Scaffold(body: NotificationSettings()),
      ),
    );
  }

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();
  }

  Switch messageSwitch(WidgetTester tester) =>
      tester.widget<Switch>(find.byType(Switch).first);

  group('NotificationSettings', () {
    testWidgets('shows granted subtitle when permission is granted', (
      tester,
    ) async {
      fakePermissions.status = PermissionStatus.granted;
      await pump(tester);

      expect(find.text('permission granted'), findsOneWidget);
    });

    testWidgets('shows not-granted subtitle when permission is denied', (
      tester,
    ) async {
      fakePermissions.status = PermissionStatus.denied;
      await pump(tester);

      expect(
        find.text('permission not granted · tap the switch to allow'),
        findsOneWidget,
      );
    });

    testWidgets(
      'toggling on when request is denied keeps notifications off and '
      'shows a snackbar',
      (tester) async {
        fakePermissions.status = PermissionStatus.denied;
        settingsBloc.emit(
          const SettingsState(messageNotificationsEnabled: false),
        );

        await pump(tester);
        await tester.tap(find.byType(Switch).first);
        await tester.pumpAndSettle();

        expect(messageSwitch(tester).value, isFalse);
        verify(() => mockRepository.setMessageNotifications(false)).called(1);
        expect(
          find.text(
            'Notification permission denied - mentions will not notify you.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'permanently denied shows an open-settings action in the snackbar',
      (tester) async {
        fakePermissions.status = PermissionStatus.permanentlyDenied;
        settingsBloc.emit(
          const SettingsState(messageNotificationsEnabled: false),
        );

        await pump(tester);
        await tester.tap(find.byType(Switch).first);
        await tester.pumpAndSettle();

        expect(find.text('Open settings'), findsOneWidget);

        await tester.tap(find.text('Open settings'));
        await tester.pump();

        expect(fakePermissions.openAppSettingsCalled, isTrue);
      },
    );
  });
}
