import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/bloc/identity/identity_bloc.dart';
import 'features/settings/bloc/settings/settings_bloc.dart';
import 'features/rooms/bloc/rooms_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const TermchatApp());
}

class TermchatApp extends StatelessWidget {
  const TermchatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>(
          create: (_) => getIt<SettingsBloc>()..add(LoadSettings()),
        ),
        BlocProvider<IdentityBloc>(
          create: (_) => getIt<IdentityBloc>()..add(LoadIdentity()),
        ),
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
