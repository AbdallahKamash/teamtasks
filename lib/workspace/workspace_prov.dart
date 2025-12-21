import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../auth/auth_prov.dart';
import '../models/workspace_model.dart';
import 'workspace_repo.dart';

part 'workspace_prov.g.dart';

@riverpod
WorkspaceRepo workspaceRepo(Ref ref) {
  return WorkspaceRepo(ref.watch(fbFirestoreProvider));
}

@riverpod
Stream<List<WorkspaceModel>> workspaces(Ref ref) {
  final user = ref.watch(authStateProvider).value;
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
  final workspaces = ref.watch(workspacesProvider).maybeWhen(
    data: (data) => data,
    orElse: () => <WorkspaceModel>[],
  );

  final selectedId = ref.watch(selectedWorkspaceIdProvider);

  if (selectedId != null) {
    for (final w in workspaces) {
      if (w.id == selectedId) return w;
    }
  }

  return workspaces.isNotEmpty ? workspaces.first : null;
}