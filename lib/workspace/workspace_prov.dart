import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../auth/auth_prov.dart';
import '../models/workspace_model.dart';
import '../models/workspace_member_model.dart';
import '../models/pending_assignment_model.dart';
import 'workspace_repo.dart';

part 'workspace_prov.g.dart';

// ============================================================================
// Providers
// ============================================================================

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

/// Check if a role has all admin permissions
/// Admin = all of these permissions are true:
/// people_delete, people_add, roles_add, messages_edit, tasks_add, 
/// workspace_edit, tasks_delete, workspace_delete, messages_delete, 
/// roles_delete, tasks_edit, roles_edit, people_edit, messages_add
bool _roleHasAllAdminPermissions(Map<String, dynamic>? rolePerms) {
  if (rolePerms is! Map<String, dynamic>) return false;

  const adminPermissions = {
    'people_delete',
    'people_add',
    'roles_add',
    'messages_edit',
    'tasks_add',
    'workspace_edit',
    'tasks_delete',
    'workspace_delete',
    'messages_delete',
    'roles_delete',
    'tasks_edit',
    'roles_edit',
    'people_edit',
    'messages_add',
  };

  // Check if all required admin permissions exist and are true
  for (final perm in adminPermissions) {
    if (rolePerms[perm] != true) {
      return false;
    }
  }
  return true;
}

/// Locally calculated admin status based on role permissions
/// A user is admin if their role has ALL the required permissions
@riverpod
bool isCurrentWorkspaceAdmin(Ref ref) {
  final workspace = ref.watch(selectedWorkspaceProvider);
  final userAsync = ref.watch(authStateProvider);
  final user = userAsync.value;

  if (workspace == null || user == null) {
    return false;
  }

  // Get the current user's member data to find their roleId
  final membersAsync = ref.watch(workspaceMembersProvider(workspace.id));

  return membersAsync.maybeWhen(
    data: (members) {
      final currentMember = members.cast<WorkspaceMemberModel?>().firstWhere(
        (m) => m?.uid == user.uid,
        orElse: () => null,
      );

      if (currentMember?.roleId == null) {
        return false;
      }

      // Get role permissions to check if user's role is admin
      final rolesAsync = ref.watch(rolePermissionsProvider(workspace.id));

      return rolesAsync.maybeWhen(
        data: (permissions) {
          final rolePerms = permissions[currentMember!.roleId];
          return _roleHasAllAdminPermissions(rolePerms);
        },
        orElse: () => false,
      );
    },
    orElse: () => false,
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
Future<Map<String, dynamic>> rolePermissions(Ref ref, String workspaceId) {
  return ref
      .watch(workspaceRepoProvider)
      .getRolePermissions(workspaceId);
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
