import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../auth/auth_prov.dart';
import '../models/workspace_model.dart';
import '../models/workspace_member_model.dart';
import '../models/pending_assignment_model.dart';
import '../models/permissions_model.dart';
import 'workspace_repo.dart';

part 'workspace_prov.g.dart';

@riverpod
WorkspaceRepo workspaceRepo(Ref ref) {
  return WorkspaceRepo(ref.watch(fbFirestoreProvider));
}

@riverpod
Stream<List<WorkspaceModel>> workspaces(Ref ref) {
  final userAsync = ref.watch(authStateProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return ref.watch(workspaceRepoProvider).getWorkspacesStream(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (e, s) => Stream.error(e, s),
  );
}

@riverpod
class SelectedWorkspaceId extends _$SelectedWorkspaceId {
  @override
  String? build() {
    ref.watch(authStateProvider);
    return null;
  }

  void select(String id) {
    state = id;
  }
}

@riverpod
WorkspaceModel? selectedWorkspace(Ref ref) {
  final workspacesAsync = ref.watch(workspacesProvider);

  return workspacesAsync.maybeWhen(
    data: (workspaces) {
      final selectedId = ref.watch(selectedWorkspaceIdProvider);

      if (selectedId != null) {
        return workspaces.firstWhere(
          (w) => w.id == selectedId,
          orElse: () => workspaces.first,
        );
      }

      return workspaces.isNotEmpty ? workspaces.first : null;
    },
    orElse: () => null,
  );
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
  return ref
      .watch(workspaceRepoProvider)
      .getRolePermissionsStream(workspaceId);
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

@riverpod
Stream<Permissions> currentUserPermissions(Ref ref) {
  final workspace = ref.watch(selectedWorkspaceProvider);
  final userAsync = ref.watch(authStateProvider);
  final user = userAsync.value;

  if (workspace == null || user == null) {
    return Stream.value(Permissions(
      workspace: WorkspacePermissions(edit: false, delete: false),
      tasks: TasksPermissions(add: false, edit: false, delete: false),
      messages: MessagesPermissions(add: false, edit: false, delete: false),
      roles: RolesPermissions(add: false, edit: false, delete: false),
      people: PeoplePermissions(add: false, edit: false, delete: false),
    ));
  }

  final membersAsync = ref.watch(workspaceMembersProvider(workspace.id));

  return membersAsync.maybeWhen(
    data: (members) {
      final currentMember = members.cast<WorkspaceMemberModel?>().firstWhere(
        (m) => m?.uid == user.uid,
        orElse: () => null,
      );

      if (currentMember?.roleId == null) {
        return Stream.value(Permissions(
          workspace: WorkspacePermissions(edit: false, delete: false),
          tasks: TasksPermissions(add: false, edit: false, delete: false),
          messages: MessagesPermissions(add: false, edit: false, delete: false),
          roles: RolesPermissions(add: false, edit: false, delete: false),
          people: PeoplePermissions(add: false, edit: false, delete: false),
        ));
      }

      final rolesAsync = ref.watch(rolePermissionsProvider(workspace.id));

      final perms = rolesAsync.maybeWhen(
        data: (permissions) {
          final rolePerms = permissions[currentMember!.roleId];
          if (rolePerms is Map<String, dynamic>) {
            return Permissions.fromMap(rolePerms);
          }
          return Permissions(
            workspace: WorkspacePermissions(edit: false, delete: false),
            tasks: TasksPermissions(add: false, edit: false, delete: false),
            messages: MessagesPermissions(add: false, edit: false, delete: false),
            roles: RolesPermissions(add: false, edit: false, delete: false),
            people: PeoplePermissions(add: false, edit: false, delete: false),
          );
        },
        orElse: () => Permissions(
          workspace: WorkspacePermissions(edit: false, delete: false),
          tasks: TasksPermissions(add: false, edit: false, delete: false),
          messages: MessagesPermissions(add: false, edit: false, delete: false),
          roles: RolesPermissions(add: false, edit: false, delete: false),
          people: PeoplePermissions(add: false, edit: false, delete: false),
        ),
      );

      return Stream.value(perms);
    },
    orElse: () => Stream.value(Permissions(
      workspace: WorkspacePermissions(edit: false, delete: false),
      tasks: TasksPermissions(add: false, edit: false, delete: false),
      messages: MessagesPermissions(add: false, edit: false, delete: false),
      roles: RolesPermissions(add: false, edit: false, delete: false),
      people: PeoplePermissions(add: false, edit: false, delete: false),
    )),
  );
}