import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/main/pages/main_layout.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/chat/pages/chat_page.dart';
import '../../features/chat/managers/active_chats_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../di/injection.dart';
import '../../features/rooms/pages/rooms_page.dart';
import '../../features/settings/pages/settings_page.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              // Chat / Home Tab (Index 0)
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
              // Rooms Tab (Index 1)
              GoRoute(
                path: '/rooms',
                builder: (context, state) => const RoomsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              // Settings Tab (Index 2)
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
