import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teamtasks/router_ani.dart';
import 'package:teamtasks/screens/auth/auth_screen.dart';
import 'package:teamtasks/screens/auth/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  /*-Text Direction-*/
  final dir = TextDirection.rtl;
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const AuthScreen(),
          dir: dir,
        ),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const HomeScreen(),
          dir: dir,
        ),
      ),
    ],
  );
});
