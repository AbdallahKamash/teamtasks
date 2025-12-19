import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teamtasks/router_ani.dart';
import 'package:teamtasks/screens/auth/auth_screen.dart';
import 'package:teamtasks/screens/auth/forgot_password_screen.dart';
import 'package:teamtasks/screens/auth/verify_email_screen.dart';
import 'package:teamtasks/screens/auth/home_screen.dart';
import 'package:teamtasks/auth/auth_prov.dart';

final routerProvider = Provider.autoDispose<GoRouter>((ref) {
  final authState = ref.read(authRepoProvider).authStateChanges();

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authState),
    redirect: (context, state) async {
      final isLoggedIn = ref.read(authRepoProvider).currentUser != null;
      final verified =
          ref.read(authRepoProvider).currentUser?.emailVerified ?? false;
      final isLoggingIn = state.uri.toString() == '/';
      print(verified.toString());
      if (isLoggedIn && isLoggingIn && verified) {
        return '/home';
      } else if (isLoggedIn && isLoggingIn && !verified) {
        return '/verify';
      }

      if (!isLoggedIn &&
          !isLoggingIn &&
          state.uri.toString() != '/forgot-password') {
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
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const ForgotPasswordScreen(),
          dir: TextDirection.rtl,
        ),
      ),
      GoRoute(
        path: '/verify',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const VerifyEmailScreen(),
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
