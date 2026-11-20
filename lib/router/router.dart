import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:teamtasks/router/app_pages.dart';
import 'package:teamtasks/router/auth_transition.dart';
import 'package:teamtasks/router/motion.dart';
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
import 'package:teamtasks/screens/home/notifications_screen.dart';
import 'package:teamtasks/screens/home/notification_detail_screen.dart';
import 'package:teamtasks/screens/tasks/add_task_screen.dart';
import 'package:teamtasks/screens/tasks/task_detail_screen.dart';
import 'package:teamtasks/models/workspace_model.dart';
import 'package:teamtasks/models/pending_assignment_model.dart';
import 'package:teamtasks/models/task_model.dart';
import 'package:teamtasks/auth/auth_prov.dart';

/// Locations a signed-out user may visit.
const kPublicPaths = <String>{'/', '/auth', '/forgot-password'};

/// The single source of truth for auth-based routing.
///
/// RULE: UI code never calls `go('/')` / `go('/home')` for auth. Only this
/// table and [AuthTransition] decide where an auth change lands.
String? authRedirect({
  required String location,
  required bool signedIn,
  required bool verified,
  required bool signingOut,
  required bool holdingLogin,
}) {
  final bool isPublic = kPublicPaths.contains(location);
  if (signingOut) return location == '/' ? null : '/';
  if (!signedIn) return isPublic ? null : '/';
  if (holdingLogin && isPublic) return null; // credential call in flight
  if (!verified) return location == '/verify' ? null : '/verify';
  if (isPublic || location == '/verify') return '/home';
  return null;
}

final routerProvider = Provider.autoDispose<GoRouter>((ref) {
  final refresh = GoRouterRefreshStream(
    ref.watch(fbAuthProvider).authStateChanges(),
  );
  final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refresh,
    // Synchronous on purpose: refresh()/go() then update the location in the
    // same call, which AuthTransition relies on.
    redirect: (context, state) {
      final user = ref.read(fbAuthProvider).currentUser;
      final flow = ref.read(authTransitionProvider);
      return authRedirect(
        location: state.matchedLocation,
        signedIn: user != null,
        verified: user?.emailVerified ?? false,
        signingOut: flow.isSigningOut,
        holdingLogin: flow.holdsAuthRedirect,
      );
    },
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => rootPage(
          context,
          state,
          const LaunchScreen(),
          entrance: RootEntrance.backward,
        ),
      ),
      GoRoute(
        path: '/auth',
        pageBuilder: (context, state) =>
            pushPage(context, state, const AuthScreen()),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => rootPage(
          context,
          state,
          const MainPage(),
          entrance: RootEntrance.forward,
          backdrop: AppMotion.homeSurface,
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) =>
            pushPage(context, state, const ForgotPasswordScreen()),
      ),
      GoRoute(
        path: '/verify',
        pageBuilder: (context, state) => rootPage(
          context,
          state,
          const VerifyEmailScreen(),
          entrance: RootEntrance.forward,
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) =>
            pushPage(context, state, const SettingsScreen()),
      ),
      GoRoute(
        path: '/edit-profile',
        pageBuilder: (context, state) =>
            pushPage(context, state, const EditProfileScreen()),
      ),
      GoRoute(
        path: '/add-workspace',
        pageBuilder: (context, state) =>
            pushPage(context, state, const AddWorkspaceScreen()),
      ),
      GoRoute(
        path: '/edit-workspace',
        pageBuilder: (context, state) {
          final workspace = state.extra as WorkspaceModel;
          return pushPage(
            context,
            state,
            EditWorkspaceScreen(workspace: workspace),
          );
        },
      ),
      GoRoute(
        path: '/edit-workspace-scheme',
        pageBuilder: (context, state) {
          final workspace = state.extra as WorkspaceModel;
          return pushPage(
            context,
            state,
            EditWorkspaceSchemeScreen(workspace: workspace),
          );
        },
      ),
      GoRoute(
        path: '/workspace-users',
        pageBuilder: (context, state) {
          final workspaceId = state.extra as String;
          return pushPage(
            context,
            state,
            WorkspaceUsersScreen(workspaceId: workspaceId),
          );
        },
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) =>
            pushPage(context, state, const NotificationsScreen()),
      ),
      GoRoute(
        path: '/notification-detail',
        pageBuilder: (context, state) {
          final assignment = state.extra as PendingAssignmentModel;
          return pushPage(
            context,
            state,
            NotificationDetailScreen(assignment: assignment),
          );
        },
      ),
      GoRoute(
        path: '/add-task',
        pageBuilder: (context, state) {
          final task = state.extra as TaskModel?;
          return pushPage(context, state, AddTaskScreen(task: task));
        },
      ),
      GoRoute(
        path: '/task-detail',
        pageBuilder: (context, state) {
          final task = state.extra as dynamic;
          return pushPage(context, state, TaskDetailScreen(task: task));
        },
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
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
