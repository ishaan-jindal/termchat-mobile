import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const TermchatApp());
}

class TermchatApp extends StatelessWidget {
  const TermchatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'Termchat',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
