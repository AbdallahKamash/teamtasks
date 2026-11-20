import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../auth/auth_prov.dart';
import '../auth/shared_pref_provider.dart';
import '../models/workspace_model.dart';
import '../models/workspace_member_model.dart';
import '../models/pending_assignment_model.dart';
import '../models/permissions_model.dart';
import '../models/task_model.dart';
import '../models/notification_model.dart';
import 'workspace_repo.dart';

part 'workspace_prov.g.dart';

@riverpod
WorkspaceRepo workspaceRepo(Ref ref) {
  return WorkspaceRepo(ref.watch(fbFirestoreProvider));
}

/// Ids of the signed-in user's workspaces.
///
/// Only rebuilds when the user id changes, so auth events that keep the same
/// user don't restart the Firestore listener.
@riverpod
Stream<List<String>> workspaceIds(Ref ref) {
  final auth = ref.watch(
    authStateProvider.select(
      (a) => (waiting: !a.hasValue && a.isLoading, uid: a.value?.uid),
    ),
  );
  if (auth.waiting) return const Stream.empty(); // stay loading until known
  final uid = auth.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(workspaceRepoProvider).getWorkspaceIdsStream(uid);
}

/// The signed-in user's workspaces, newest first.
///
/// Rebuilds (with a fresh query) whenever the set of ids changes — e.g. right
/// after creating, joining or leaving a workspace. While it reloads it keeps
/// the previous list, so the UI never blanks out.
@riverpod
Stream<List<WorkspaceModel>> workspaces(Ref ref) {
  final ids = ref.watch(
    workspaceIdsProvider.select(
      (a) => (key: a.value?.join('|'), error: a.error),
    ),
  );
  final key = ids.key;
  if (key == null) {
    final error = ids.error;
    if (error != null) return Stream.error(error);
    return const Stream.empty(); // stay loading until the ids arrive
  }
  final list = key.isEmpty ? const <String>[] : key.split('|');
  return ref.watch(workspaceRepoProvider).getWorkspacesByIds(list);
}

/// The id of the workspace the user picked, persisted per user.
///
/// Read synchronously from SharedPreferences, so the right workspace is
/// selected on the first frame after launch. Only rebuilds when the signed-in
/// user changes (not on every auth event such as token refreshes).
@Riverpod(keepAlive: true)
class SelectedWorkspaceId extends _$SelectedWorkspaceId {
  @override
  String? build() {
    final uid = ref.watch(authStateProvider.select((a) => a.value?.uid));
    if (uid == null) return null;
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getString(SharedPrefKeys.selectedWorkspaceIdFor(uid)) ??
        prefs.getString(SharedPrefKeys.selectedWorkspaceId);
  }

  String? get _key {
    final uid = ref.read(authStateProvider).value?.uid;
    return uid == null ? null : SharedPrefKeys.selectedWorkspaceIdFor(uid);
  }

  /// Select a workspace and persist the choice.
  Future<void> select(String id) async {
    state = id;
    final key = _key;
    if (key == null) return;
    try {
      await ref.read(sharedPreferencesProvider).setString(key, id);
    } catch (_) {
      // The in-memory selection still applies for this session.
    }
  }

  /// Forget the saved choice (e.g. the workspace was deleted).
  Future<void> clear() async {
    state = null;
    final key = _key;
    if (key == null) return;
    try {
      await ref.read(sharedPreferencesProvider).remove(key);
    } catch (_) {}
  }
}

/// The workspace currently shown.
///
/// Pure derivation with no side effects: the saved choice if it is in the
/// list, otherwise the newest workspace. Keeps the previous list while the
/// stream reloads, so the UI never blanks out.
@riverpod
WorkspaceModel? selectedWorkspace(Ref ref) {
  final workspaces = ref.watch(workspacesProvider).value;
  if (workspaces == null || workspaces.isEmpty) return null;
  final selectedId = ref.watch(selectedWorkspaceIdProvider);
  if (selectedId != null) {
    for (final w in workspaces) {
      if (w.id == selectedId) return w;
    }
  }
  return workspaces.first;
}

@riverpod
Stream<List<WorkspaceMemberModel>> workspaceMembers(
  Ref ref,
  String workspaceId,
) {
  return ref
      .watch(workspaceRepoProvider)
      .getWorkspaceMembersStream(workspaceId);
}

@riverpod
Stream<Map<String, dynamic>> rolePermissions(Ref ref, String workspaceId) {
  return ref.watch(workspaceRepoProvider).getRolePermissionsStream(workspaceId);
}

@riverpod
Stream<List<PendingAssignmentModel>> pendingAssignments(Ref ref) {
  final userAsync = ref.watch(authStateProvider);
  return userAsync.when(
    data: (user) {
      if (user == null || user.email == null) return Stream.value([]);
      return ref
          .watch(workspaceRepoProvider)
          .getPendingAssignmentsStream(user.email!);
    },
    loading: () => const Stream.empty(),
    error: (e, s) => Stream.error(e, s),
  );
}

@riverpod
Future<WorkspaceModel?> workspaceById(Ref ref, String workspaceId) {
  return ref.watch(workspaceRepoProvider).getWorkspaceById(workspaceId);
}

/// The signed-in user's permissions in the selected workspace.
///
/// Derived synchronously from the members and role-permission streams, so it
/// keeps its last value while those reload (no flicker of tabs/FAB).
@riverpod
AsyncValue<Permissions> currentUserPermissions(Ref ref) {
  final workspace = ref.watch(selectedWorkspaceProvider);
  final user = ref.watch(authStateProvider).value;

  if (workspace == null || user == null) {
    return AsyncData(_emptyPermissions());
  }

  final membersAsync = ref.watch(workspaceMembersProvider(workspace.id));
  final rolesAsync = ref.watch(rolePermissionsProvider(workspace.id));

  final members = membersAsync.value;
  final roles = rolesAsync.value;
  if (members == null || roles == null) {
    final error = membersAsync.error ?? rolesAsync.error;
    if (error != null) {
      return AsyncError(
        error,
        membersAsync.stackTrace ?? rolesAsync.stackTrace ?? StackTrace.current,
      );
    }
    return const AsyncLoading();
  }

  final roleId = members.where((m) => m.uid == user.uid).firstOrNull?.roleId;
  final rolePerms = roleId == null ? null : roles[roleId];
  return AsyncData(
    rolePerms is Map<String, dynamic>
        ? Permissions.fromMap(rolePerms)
        : _emptyPermissions(),
  );
}

Permissions _emptyPermissions() {
  return Permissions(
    workspace: WorkspacePermissions(edit: false, delete: false),
    tasks: TasksPermissions(add: false, edit: false, delete: false),
    messages: MessagesPermissions(add: false, edit: false, delete: false),
    roles: RolesPermissions(add: false, edit: false, delete: false),
    people: PeoplePermissions(add: false, edit: false, delete: false),
  );
}

@riverpod
Stream<List<AppNotificationModel>> appNotifications(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(workspaceRepoProvider).getNotificationsStream(user.uid);
}

@riverpod
Stream<List<TaskModel>> assignedTasks(Ref ref, String workspaceId) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref
      .watch(workspaceRepoProvider)
      .getAssignedTasksStream(workspaceId, user.uid);
}

@riverpod
Stream<List<TaskModel>> createdTasks(Ref ref, String workspaceId) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref
      .watch(workspaceRepoProvider)
      .getCreatedTasksStream(workspaceId, user.uid);
}

@riverpod
Stream<List<TaskModel>> taskHistory(Ref ref, String workspaceId) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref
      .watch(workspaceRepoProvider)
      .getTaskHistoryStream(workspaceId, user.uid);
}
