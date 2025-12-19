import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teamtasks/router_ani.dart';
import 'package:teamtasks/screens/auth/auth_screen.dart';
import 'package:teamtasks/screens/auth/home_screen.dart';
import 'package:teamtasks/auth/auth_prov.dart';

final routerProvider = Provider.autoDispose<GoRouter>((ref) {
  final authState = ref.read(authRepoProvider).authStateChanges();

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authState),
    redirect: (context, state) {
      final isLoggedIn = ref.read(authRepoProvider).currentUser != null;
      final isLoggingIn = state.uri.toString() == '/';

      if (isLoggedIn && isLoggingIn) {
        return '/home';
      }

      if (!isLoggedIn && !isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const AuthScreen(),
          dir: TextDirection.ltr,
        ),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const HomeScreen(),
          dir: TextDirection.rtl,
        ),
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
