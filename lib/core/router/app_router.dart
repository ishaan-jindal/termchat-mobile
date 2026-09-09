import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/chat/managers/active_chats_manager.dart';
import '../../features/chat/pages/chat_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/rooms/pages/rooms_page.dart';
import '../../features/settings/pages/settings_page.dart';
import '../layout/shell_layout.dart';

class AppRouter {
  AppRouter(this._activeChatsManager);

  final ActiveChatsManager _activeChatsManager;

  final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'root',
  );

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return RepositoryProvider<ActiveChatsManager>.value(
            value: _activeChatsManager,
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
                    redirect: (context, state) {
                      final roomId = state.pathParameters['roomId'] ?? '';
                      if (!RegExp(r'^[A-Za-z0-9]{4}$').hasMatch(roomId)) {
                        return '/';
                      }
                      final upper = roomId.toUpperCase();
                      if (upper != roomId) return '/chat/$upper';
                      return null;
                    },
                    builder: (context, state) {
                      final roomId = state.pathParameters['roomId']!;
                      final chatBloc = _activeChatsManager.getOrCreate(roomId);
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
