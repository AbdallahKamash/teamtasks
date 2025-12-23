import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teamtasks/router/router_ani.dart';
import 'package:teamtasks/screens/auth/auth_screen.dart';
import 'package:teamtasks/screens/auth/forgot_password_screen.dart';
import 'package:teamtasks/screens/auth/launch_screen.dart';
import 'package:teamtasks/screens/auth/verify_email_screen.dart';
import 'package:teamtasks/screens/home/main_page.dart';
import 'package:teamtasks/screens/settings/settings_screen.dart';
import 'package:teamtasks/screens/settings/edit_profile_screen.dart';
import 'package:teamtasks/screens/workspace/add_workspace_screen.dart';
import 'package:teamtasks/screens/workspace/edit_workspace_screen.dart';
import 'package:teamtasks/screens/workspace/edit_workspace_scheme_screen.dart';
import 'package:teamtasks/screens/workspace/workspace_users_screen.dart';
import 'package:teamtasks/models/workspace_model.dart';
import 'package:teamtasks/auth/auth_prov.dart';

final routerProvider = Provider.autoDispose<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
      ref.watch(fbAuthProvider).authStateChanges(),
    ),
    redirect: (context, state) async {
      final user = ref.read(fbAuthProvider).currentUser;
      final isLoggedIn = user != null;
      final verified = user?.emailVerified ?? false;
      final isLoggingIn = state.uri.toString() == '/';
      final isAuth = state.uri.toString() == '/auth';

      if (isLoggedIn) {
        if (!verified) {
          if (state.uri.toString() != '/verify') return '/verify';
        } else if (isLoggingIn || isAuth) {
          return '/home';
        }
      } else {
        if (!isLoggingIn &&
            !isAuth &&
            state.uri.toString() != '/forgot-password') {
          return '/auth';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const LaunchScreen(),
          dir: TextDirection.ltr,
        ),
      ),
      GoRoute(
        path: '/auth',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const AuthScreen(),
          dir: TextDirection.rtl,
        ),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const MainPage(),
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
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const SettingsScreen(),
          dir: TextDirection.rtl,
        ),
      ),
      GoRoute(
        path: '/edit-profile',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const EditProfileScreen(),
          dir: TextDirection.rtl,
        ),
      ),
      GoRoute(
        path: '/add-workspace',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const AddWorkspaceScreen(),
          dir: TextDirection.rtl,
        ),
      ),
      GoRoute(
        path: '/edit-workspace',
        pageBuilder: (context, state) {
          final workspace = state.extra as WorkspaceModel;
          return buildPageWithTransition(
            context: context,
            state: state,
            child: EditWorkspaceScreen(workspace: workspace),
            dir: TextDirection.rtl,
          );
        },
      ),
      GoRoute(
        path: '/edit-workspace-scheme',
        pageBuilder: (context, state) {
          final workspace = state.extra as WorkspaceModel;
          return buildPageWithTransition(
            context: context,
            state: state,
            child: EditWorkspaceSchemeScreen(workspace: workspace),
            dir: TextDirection.rtl,
          );
        },
      ),
      GoRoute(
        path: '/workspace-users',
        pageBuilder: (context, state) {
          final workspaceId = state.extra as String;
          return buildPageWithTransition(
            context: context,
            state: state,
            child: WorkspaceUsersScreen(workspaceId: workspaceId),
            dir: TextDirection.rtl,
          );
        },
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
