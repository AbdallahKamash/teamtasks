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
