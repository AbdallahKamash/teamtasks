import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../models/workspace_model.dart';

class WorkspaceRepo {
  final FirebaseFirestore _firestore;

  WorkspaceRepo(this._firestore);

  Stream<List<WorkspaceModel>> getWorkspacesStream(String userId) {
    return _firestore
        .collection('users_workspaces')
        .doc(userId)
        .snapshots()
        .switchMap((userDoc) {
          final data = userDoc.data();
          if (data == null || data['workspaceIds'] == null) {
            return Stream.value([]);
          }

          final List<String> workspaceIds = List<String>.from(
            data['workspaceIds'],
          );
          if (workspaceIds.isEmpty) {
            return Stream.value([]);
          }

          // Create a stream for each workspace ID
          final workspaceStreams = workspaceIds.map((id) {
            return _firestore.collection('workspaces').doc(id).snapshots().map((
              doc,
            ) {
              if (!doc.exists) return null;
              return WorkspaceModel.fromJson({...doc.data()!, 'id': doc.id});
            });
          }).toList();

          // Combine all workspace streams into one stream of a list of workspaces
          return CombineLatestStream.list(
            workspaceStreams,
          ).map((list) => list.whereType<WorkspaceModel>().toList());
        });
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
