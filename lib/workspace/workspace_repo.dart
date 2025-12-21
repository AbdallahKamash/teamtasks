import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workspace_model.dart';

class WorkspaceRepo {
  final FirebaseFirestore _firestore;

  WorkspaceRepo(this._firestore);

  Stream<List<WorkspaceModel>> getWorkspacesStream(String userId) {
    return _firestore
        .collection('workspaces')
        .where('creatorId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => WorkspaceModel.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  Future<void> createWorkspace(WorkspaceModel workspace) async {
    // 1. Create the workspace document
    final workspaceRef = _firestore.collection('workspaces').doc();
    final workspaceWithId = workspace.copyWith(id: workspaceRef.id);

    await workspaceRef.set(workspaceWithId.toJson());

    // 2. Save to users_workspaces collection as requested
    // "the document should be with the user's id and within it save a value of the workspace id"
    // To support multiple, I'll use arrayUnion if possible, but the prompt says "save a value".
    // I'll assume they meant adding it to a list in that doc.
    await _firestore
        .collection('users_workspaces')
        .doc(workspace.creatorId)
        .set({
          'workspaceIds': FieldValue.arrayUnion([workspaceRef.id]),
        }, SetOptions(merge: true));
  }
}
