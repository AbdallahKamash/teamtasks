import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../auth/auth_prov.dart';
import '../models/workspace_model.dart';
import '../models/workspace_member_model.dart';
import 'workspace_repo.dart';

part 'workspace_prov.g.dart';

@riverpod
WorkspaceRepo workspaceRepo(Ref ref) {
  return WorkspaceRepo(ref.watch(fbFirestoreProvider));
}

@riverpod
Stream<List<WorkspaceModel>> workspaces(Ref ref) {
  final user = ref.watch(authRepoProvider).currentUser;
  if (user == null) {
    return Stream.value([]);
  }
  return ref.watch(workspaceRepoProvider).getWorkspacesStream(user.uid);
}

@riverpod
class SelectedWorkspaceId extends _$SelectedWorkspaceId {
  @override
  String? build() => null;

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
bool isCurrentWorkspaceAdmin(Ref ref) {
  final workspace = ref.watch(selectedWorkspaceProvider);
  final user = ref.watch(authRepoProvider).currentUser;

  if (workspace == null || user == null) {
    return false;
  }

  return workspace.admins.contains(user.uid);
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
