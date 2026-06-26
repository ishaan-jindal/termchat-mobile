import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../layout/shell_layout.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/chat/pages/chat_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../di/injection.dart';
import '../../features/rooms/pages/rooms_page.dart';
import '../../features/settings/pages/settings_page.dart';
import '../../features/chat/managers/active_chats_manager.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return RepositoryProvider.value(
            value: getIt<ActiveChatsManager>(),
            child: ShellLayout(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'chat/:roomId',
                    builder: (context, state) {
                      final roomId = state.pathParameters['roomId']!;
                      final chatBloc = getIt<ActiveChatsManager>().getOrCreate(
                        roomId,
                      );
                      return BlocProvider.value(
                        value: chatBloc,
                        child: const ChatPage(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/rooms',
                builder: (context, state) => const RoomsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
