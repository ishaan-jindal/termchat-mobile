import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_lifecycle_tracker.dart';
import 'core/utils/notification_helper.dart';
import 'data/database/app_database.dart';
import 'data/cache/room_session_cache.dart';
import 'data/cache/message_cache.dart';
import 'features/settings/bloc/identity/identity_bloc.dart';
import 'features/settings/bloc/settings/settings_bloc.dart';
import 'features/rooms/bloc/rooms_bloc.dart';
import 'features/chat/managers/active_chats_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();

  AppLifecycleTracker.instance.init();

  // Initialize database and cache services
  final database = await AppDatabase.create();
  getIt.registerLazySingleton<AppDatabase>(() => database);
  getIt.registerLazySingleton<RoomSessionCache>(
    () => RoomSessionCache(database),
  );
  getIt.registerLazySingleton<MessageCache>(() => MessageCache(database));

  await NotificationHelper.initialize();

  final identityBloc = getIt<IdentityBloc>()..add(LoadIdentity());
  final settingsBloc = getIt<SettingsBloc>()..add(LoadSettings());

  // Wait for identity before auto-connecting saved rooms
  if (identityBloc.state is! IdentityLoaded) {
    await identityBloc.stream.firstWhere((s) => s is IdentityLoaded);
  }

  // Load and auto-connect saved room sessions
  final activeChatsManager = getIt<ActiveChatsManager>();
  await activeChatsManager.loadSavedSessions();

  runApp(TermchatApp(identityBloc: identityBloc, settingsBloc: settingsBloc));
}

class TermchatApp extends StatelessWidget {
  final IdentityBloc identityBloc;
  final SettingsBloc settingsBloc;

  const TermchatApp({
    super.key,
    required this.identityBloc,
    required this.settingsBloc,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>.value(value: settingsBloc),
        BlocProvider<IdentityBloc>.value(value: identityBloc),
        BlocProvider<RoomsBloc>(
          create: (_) => getIt<RoomsBloc>()..add(LoadActiveSessions()),
        ),
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
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
