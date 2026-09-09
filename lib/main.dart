import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'di/injection.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_lifecycle_tracker.dart';
import 'core/utils/notification_helper.dart';
import 'features/settings/bloc/identity/identity_bloc.dart';
import 'features/settings/bloc/settings/settings_bloc.dart';
import 'features/rooms/bloc/rooms_bloc.dart';
import 'features/chat/managers/active_chats_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();

  final packageInfo = await PackageInfo.fromPlatform();
  AppConstants.appVersion = packageInfo.version;

  AppLifecycleTracker.instance.init();
  await NotificationHelper.initialize();

  final identityBloc = getIt<IdentityBloc>()..add(LoadIdentity());
  final settingsBloc = getIt<SettingsBloc>()..add(LoadSettings());
  final roomsBloc = getIt<RoomsBloc>()..add(LoadActiveSessions());
  final appRouter = AppRouter(getIt<ActiveChatsManager>());

  runApp(
    TermchatApp(
      identityBloc: identityBloc,
      settingsBloc: settingsBloc,
      roomsBloc: roomsBloc,
      appRouter: appRouter,
    ),
  );

  // Defer the permission prompt until after the first frame.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    NotificationHelper.requestNotificationPermissionIfNeeded();
  });
}

class TermchatApp extends StatelessWidget {
  final IdentityBloc identityBloc;
  final SettingsBloc settingsBloc;
  final RoomsBloc roomsBloc;
  final AppRouter appRouter;

  const TermchatApp({
    super.key,
    required this.identityBloc,
    required this.settingsBloc,
    required this.roomsBloc,
    required this.appRouter,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>.value(value: settingsBloc),
        BlocProvider<IdentityBloc>.value(value: identityBloc),
        // GetIt-owned; never closed by the provider.
        BlocProvider<RoomsBloc>.value(value: roomsBloc),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) =>
            previous.themeMode != current.themeMode ||
            previous.fontSize != current.fontSize,
        builder: (context, settingsState) {
          final themeMode = settingsState.themeMode == 'light'
              ? ThemeMode.light
              : settingsState.themeMode == 'system'
              ? ThemeMode.system
              : ThemeMode.dark;

          return MaterialApp.router(
            title: 'Termchat',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: AppTheme.light(fontSize: settingsState.fontSize),
            darkTheme: AppTheme.dark(fontSize: settingsState.fontSize),
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}
