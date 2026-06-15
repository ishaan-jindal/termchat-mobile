import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/pages/home_page.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [GoRoute(path: '/', builder: (context, state) => const HomePage())],
  );
}
